import Foundation

enum DataSource {
    case network
    case cache
    case fallback
}

struct DataResponse {
    let holdings: StockHoldingResponse
    let source: DataSource
    let timestamp: Date
    
    var isStale: Bool {
        Date().timeIntervalSince(timestamp) > 300 // 5 minutes
    }
} 
