import Foundation

// MARK: - Stock Holdings Specific Request
struct StockHoldingsRequest: NetworkRequest {
    typealias ResponseType = StockHoldingAPIResponse
    
    let baseURL = "https://35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io/"
    let httpMethod: HTTPMethod = .GET
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var queryParameters: [String: String]? {
        return nil
    }
    
    var needsCaching: Bool {
        return true
    }
    
    var timeout: TimeInterval {
        return 30.0
    }
}

// MARK: - Stock Holdings API Response Model
struct StockHoldingAPIResponse: Codable {
    let data: DataContent
    
    struct DataContent: Codable {
        let userHolding: [StockHolding]
    }
}

// MARK: - Network Data Source Implementation
final class NetworkDataSource: NetworkDataSourceProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService
    }
    
    func fetchStockHoldings(completion: @escaping (Result<StockHoldingResponse, Error>) -> Void) {
        let request = StockHoldingsRequest()
        self.networkService.execute(request) { result in
            switch result {
            case .success(let apiResponse):
                let response = StockHoldingResponse(holdings: apiResponse.data.userHolding)
                completion(.success(response))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
} 
