import Foundation

// MARK: - Repository Protocol (Dependency Inversion Principle)
protocol StockHoldingsRepositoryProtocol {
    func fetchStockHoldings(completion: @escaping (Result<DataResponse, Error>) -> Void)
    func forceRefresh(completion: @escaping (Result<DataResponse, Error>) -> Void)
    func clearCache()
}

// MARK: - Data Source Protocols (Interface Segregation Principle)
protocol NetworkDataSourceProtocol {
    func fetchStockHoldings(completion: @escaping (Result<StockHoldingResponse, Error>) -> Void)
}

protocol CacheDataSourceProtocol {
    func getCachedData() -> StockHoldingResponse?
    func cacheData(_ response: StockHoldingResponse)
    func isCacheValid() -> Bool
    func clearCache()
}

/*
protocol MockDataSourceProtocol {
    func getMockData() -> StockHoldingResponse?
}
*/ 
