import Foundation

// MARK: - Network Protocols
protocol NetworkServiceProtocol {
    func execute<T: NetworkRequest>(_ request: T, completion: @escaping (Result<T.ResponseType, Error>) -> Void)
}

final class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let cache: URLCache
    private let queue = DispatchQueue(label: "com.gulshan.stocksholding.network", qos: .userInitiated)
    
    init(session: URLSession = .shared, cache: URLCache = .shared) {
        self.session = session
        self.cache = cache
    }
    
    func execute<T: NetworkRequest>(_ request: T, completion: @escaping (Result<T.ResponseType, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                // Build URL
                let url = try self.buildURL(from: request)
                
                // Create URLRequest
                var urlRequest = URLRequest(url: url, timeoutInterval: request.timeout)
                urlRequest.httpMethod = request.httpMethod.rawValue
                
                // Add headers
                if let headers = request.headers {
                    for (key, value) in headers {
                        urlRequest.setValue(value, forHTTPHeaderField: key)
                    }
                }
                
                // Handle caching
                // TODO: not using cachePolicy as no cache coming from the api. 
               // urlRequest.cachePolicy = request.needsCaching ? .useProtocolCachePolicy : .reloadIgnoringLocalCacheData
                
                let task = self.session.dataTask(with: urlRequest) { [weak self] data, response, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        if (error as NSError).code == NSURLErrorTimedOut {
                            completion(.failure(NetworkError.timeout))
                        } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
                            completion(.failure(NetworkError.noInternetConnection))
                        } else {
                            completion(.failure(NetworkError.serverError(error)))
                        }
                        return
                    }
                    
                    do {
                        try self.validateHTTPResponse(response)
                        
                        guard let data = data, !data.isEmpty else {
                            completion(.failure(NetworkError.noData))
                            return
                        }
                        
                        let result = try self.parseResponse(data: data, responseType: T.ResponseType.self)
                        completion(.success(result))
                    } catch let error as NetworkError {
                        completion(.failure(error))
                    } catch let error as DecodingError {
                        completion(.failure(NetworkError.decodingError(error)))
                    } catch {
                        completion(.failure(NetworkError.serverError(error)))
                    }
                }
                
                task.resume()
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Helper Methods
    private func buildURL<T: NetworkRequest>(from request: T) throws -> URL {
        guard var urlComponents = URLComponents(string: request.baseURL + request.path) else {
            throw NetworkError.invalidURL
        }
        
        // Add query parameters
        if let queryParams = request.queryParameters, !queryParams.isEmpty {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        return url
    }
    
    private func validateHTTPResponse(_ response: URLResponse?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError(NSError(
                domain: "InvalidResponse",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"]
            ))
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            let message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, message: message)
        }
    }
    
    private func parseResponse<T: Codable>(data: Data, responseType: T.Type) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(responseType, from: data)
    }
} 
