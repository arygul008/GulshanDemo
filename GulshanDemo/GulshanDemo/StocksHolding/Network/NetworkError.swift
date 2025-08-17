import Foundation

// MARK: - Network Errors
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case serverError(Error)
    case httpError(statusCode: Int, message: String)
    case timeout
    case noInternetConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: 
            return "Invalid URL"
        case .noData: 
            return "No data received"
        case .decodingError(let error): 
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error): 
            return "Failed to encode request: \(error.localizedDescription)"
        case .serverError(let error): 
            return "Server error: \(error.localizedDescription)"
        case .httpError(let statusCode, let message): 
            return "HTTP \(statusCode): \(message)"
        case .timeout: 
            return "Request timed out"
        case .noInternetConnection: 
            return "No internet connection"
        }
    }
} 