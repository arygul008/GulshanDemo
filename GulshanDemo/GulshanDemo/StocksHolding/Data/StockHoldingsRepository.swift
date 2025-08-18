import Foundation

// MARK: - Repository Errors
enum RepositoryError: LocalizedError {
    case noDataAvailable
    case allSourcesFailed([Error])
    
    var errorDescription: String? {
        switch self {
        case .noDataAvailable:
            return "No data available from any source"
        case .allSourcesFailed(let errors):
            return "All data sources failed: \(errors.map { $0.localizedDescription }.joined(separator: ", "))"
        }
    }
}

final class StockHoldingsRepository: StockHoldingsRepositoryProtocol {
    // MARK: - Dependencies
    private let networkDataSource: NetworkDataSourceProtocol
    private let cacheDataSource: CacheDataSourceProtocol
    private let queue = DispatchQueue(label: "com.gulshan.stocksholding.repository", qos: .userInitiated)
    
    init(networkDataSource: NetworkDataSourceProtocol = NetworkDataSource(),
         cacheDataSource: CacheDataSourceProtocol) {
        self.networkDataSource = networkDataSource
        self.cacheDataSource = cacheDataSource
    }
    
    // MARK: - Repository Methods
    func fetchStockHoldings(completion: @escaping (Result<DataResponse, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            logger.log("Repository: Starting data fetch...")
            
            // Strategy 1: Try network first (if cache is stale or doesn't exist)
            if self.shouldFetchFromNetwork() {
                self.tryNetworkFetch { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let response):
                        DispatchQueue.main.async {
                            completion(.success(response))
                        }
                    case .failure:
                        // Try cache on network failure
                        if let cacheResponse = self.tryCacheFetch() {
                            DispatchQueue.main.async {
                                completion(.success(cacheResponse))
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(.failure(RepositoryError.noDataAvailable))
                            }
                        }
                    }
                }
            } else {
                logger.log("Repository: Using valid cache (skipping network)")
                if let cacheResponse = self.tryCacheFetch() {
                    DispatchQueue.main.async {
                        completion(.success(cacheResponse))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(RepositoryError.noDataAvailable))
                    }
                }
            }
        }
    }
    
    /// when we don't need data from cache. 
    func forceRefresh(completion: @escaping (Result<DataResponse, Error>) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            logger.log("Repository: Force refresh requested")
            
            self.tryNetworkFetch { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
                case .failure:
                    // Try cache as fallback
                    if let cacheResponse = self.tryCacheFetch() {
                        logger.log("Repository: Force refresh failed, using cache")
                        DispatchQueue.main.async {
                            completion(.success(cacheResponse))
                        }
                    } else {
                        logger.log("Repository: Force refresh failed - no fallback data available")
                        DispatchQueue.main.async {
                            completion(.failure(RepositoryError.noDataAvailable))
                        }
                    }
                }
            }
        }
    }
    
    func clearCache() {
        queue.async { [weak self] in
            self?.cacheDataSource.clearCache()
            logger.log("Repository: Cache cleared")
        }
    }
    
    // MARK: - Private Helper Methods
    private func shouldFetchFromNetwork() -> Bool {
        return !cacheDataSource.isCacheValid()
    }
    
    private func tryNetworkFetch(completion: @escaping (Result<DataResponse, Error>) -> Void) {
        networkDataSource.fetchStockHoldings { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                // Cache the fresh data
                self.cacheDataSource.cacheData(response)
                logger.log("Repository: Network fetch successful")
                
                let dataResponse = DataResponse(
                    holdings: response,
                    source: .network,
                    timestamp: Date()
                )
                completion(.success(dataResponse))
                
            case .failure(let error):
                logger.log("Repository: Network fetch failed - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    private func tryCacheFetch() -> DataResponse? {
        guard let cachedResponse = cacheDataSource.getCachedData() else {
            logger.log("Repository: No cached data found")
            return nil
        }
        
        logger.log("Repository: Using cached data")
        return DataResponse(
            holdings: cachedResponse,
            source: .cache,
            timestamp: Date()
        )
    }
}

/// GK: Factory pattern for creating repository instances
/// Follows Factory Pattern and Dependency Injection Principles
final class StockHoldingsRepositoryFactory {
    
    /// Creates repository with Core Data cache service (Production)
    /// Follows Dependency Injection - injects Core Data cache implementation
    /// CLEANED UP: Only Core Data cache, no mock data source dependency
    static func makeRepository(
        persistenceController: PersistenceController = .shared
    ) -> StockHoldingsRepositoryProtocol {
        
        // Create Core Data cache service
        let coreDataCacheService = CoreDataCacheServiceFactory.create(
            persistenceController: persistenceController
        )
        
        return StockHoldingsRepository(
            networkDataSource: NetworkDataSource(),
            cacheDataSource: coreDataCacheService  // ✅ Core Data only!
            // REMOVED: Mock data source eliminated
        )
    }
    
    // REMOVED: UserDefaults cache completely eliminated
    /*
    /// Creates repository with UserDefaults cache (Fallback/Legacy)
    /// Provides backward compatibility and fallback option
    static func makeRepositoryWithUserDefaultsCache() -> StockHoldingsRepositoryProtocol {
        return StockHoldingsRepository(
            networkDataSource: NetworkDataSource(),
            cacheDataSource: CacheDataSource(),  // Legacy UserDefaults implementation
            mockDataSource: MockDataSource()
        )
    }
    */
    
    /// Creates repository for testing with injected dependencies
    /// Follows Dependency Injection for better testability
    /// CLEANED UP: No mock data source dependency
    static func makeTestRepository(
        networkDataSource: NetworkDataSourceProtocol,
        cacheDataSource: CacheDataSourceProtocol
        // REMOVED: Mock data source parameter eliminated
        // mockDataSource: MockDataSourceProtocol
    ) -> StockHoldingsRepositoryProtocol {
        return StockHoldingsRepository(
            networkDataSource: networkDataSource,
            cacheDataSource: cacheDataSource
            // REMOVED: Mock data source parameter eliminated
        )
    }
    
    /// Creates repository for testing with in-memory Core Data
    /// Perfect for unit testing without persistent storage
    /// CLEANED UP: No mock data source dependency
    static func makeTestRepositoryWithInMemoryCoreData() -> (
        repository: StockHoldingsRepositoryProtocol,
        persistenceController: PersistenceController
    ) {
        // Create in-memory persistence controller for testing
        let testPersistenceController = PersistenceController(inMemory: true)
        
        // Create Core Data cache service with in-memory store
        let coreDataCacheService = CoreDataCacheServiceFactory.createForTesting(
            inMemoryController: testPersistenceController
        )
        
        let repository = StockHoldingsRepository(
            networkDataSource: NetworkDataSource(),
            cacheDataSource: coreDataCacheService
            // REMOVED: Mock data source eliminated
        )
        
        return (repository, testPersistenceController)
    }
} 