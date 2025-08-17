import Foundation

protocol LoggerProtocol {
    func log(_ message: String)
}

final class ConsoleLogger: LoggerProtocol {
    
    // MARK: - Singleton Instance
    static let shared = ConsoleLogger()
    
    private init() {}
    
    func log(_ message: String) {
        #if DEBUG
        print(message)
        #endif
    }
}

let logger = ConsoleLogger.shared
