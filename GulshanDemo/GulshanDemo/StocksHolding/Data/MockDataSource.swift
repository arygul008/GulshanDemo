import Foundation

// COMMENTED OUT: Protocol conformance removed since protocol is eliminated
final class MockDataSource /* : MockDataSourceProtocol */ {
    
    // COMMENTED OUT: String-based mock data method
    // Now returns nil to force network/cache usage
    func getMockData() -> StockHoldingResponse? {
        // No longer using string-based mock data
        // Return nil to force the repository to use network/cache layers
        logger.log("MockDataSource: String-based mock data disabled")
        return nil
    }
    
    // COMMENTED OUT: Mock data methods that were using hardcoded data
    // Keeping these simple methods for basic testing if needed
    /*
    func getEmptyMockData() -> StockHoldingResponse {
        return StockHoldingResponse(holdings: [])
    }
    
    func getSingleStockMockData() -> StockHoldingResponse {
        let singleStock = StockHolding(
            symbol: "DEMO",
            quantity: 100,
            ltp: 100.0,
            averagePrice: 95.0,
            close: 98.0
        )
        return StockHoldingResponse(holdings: [singleStock])
    }
    */
} 
