import Foundation

// MARK: - Request Protocol
protocol NetworkRequest {
    associatedtype ResponseType: Codable
    
    var baseURL: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
    var needsCaching: Bool { get }
    var timeout: TimeInterval { get }
}

// MARK: - Request Builder Helper
extension NetworkRequest {
    // Default implementations
    var headers: [String: String]? { nil }
    var queryParameters: [String: String]? { nil }
    var needsCaching: Bool { false }
    var timeout: TimeInterval { 30.0 }
    var path: String { "" }
}