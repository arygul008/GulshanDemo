import Foundation

struct StockHolding: Codable {
    let symbol: String
    let quantity: Int
    let ltp: Double
    let averagePrice: Double
    let close: Double
    
    var currentValue: Double {
        return Double(quantity) * ltp
    }
    
    var totalInvestment: Double {
        return Double(quantity) * averagePrice
    }
    
    var pnl: Double {
        return currentValue - totalInvestment
    }
    
    var todaysPNL: Double {
        return Double(quantity) * (close - ltp)
    }
    
    enum CodingKeys: String, CodingKey {
        case symbol
        case quantity = "quantity"
        case ltp = "ltp"
        case averagePrice = "avgPrice"
        case close
    }
}

struct StockHoldingResponse: Codable {
    let holdings: [StockHolding]
} 
