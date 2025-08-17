//
//  CoreDataCacheService.swift
//  GulshanDemo
//
//  Created by Gulshan Kumar on 15/08/25.
//

import CoreData
import Foundation

/// Core Data implementation of cache data source
/// Follows Dependency Inversion Principle - depends on abstractions (NSManagedObjectContext)
/// Follows Single Responsibility Principle - only handles Core Data caching logic
final class CoreDataCacheService: CacheDataSourceProtocol {
    
    // MARK: - Dependencies (Injected)
    private let context: NSManagedObjectContext
    private let logger: ConsoleLogger
    
    // MARK: - Configuration
    private let cacheKey: String
    private let cacheExpiryInterval: TimeInterval
    
    // MARK: - Initialization (Dependency Injection)
    /// Initializes with injected dependencies
    /// Follows Dependency Injection Pattern for better testability
    init(
        context: NSManagedObjectContext,
        cacheKey: String = "stock_holdings_cache",
        cacheExpiryInterval: TimeInterval = 300, // 5 minutes
        logger: ConsoleLogger = .shared
    ) {
        self.context = context
        self.cacheKey = cacheKey
        self.cacheExpiryInterval = cacheExpiryInterval
        self.logger = logger
    }
    
    // MARK: - CacheDataSourceProtocol Implementation
    
    func getCachedData() -> StockHoldingResponse? {
        logger.log("CoreDataCache: Attempting to retrieve cached data")
        
        do {
            let cacheSession = try fetchValidCacheSession()
            guard let session = cacheSession else {
                logger.log("CoreDataCache: No valid cache session found")
                return nil
            }
            
            let stockHoldings = session.getStockHoldings()
            logger.log("CoreDataCache: Retrieved \(stockHoldings.count) cached holdings")
            
            return StockHoldingResponse(holdings: stockHoldings)
            
        } catch {
            logger.log("CoreDataCache: Error retrieving cached data - \(error.localizedDescription)")
            return nil
        }
    }
    
    func cacheData(_ response: StockHoldingResponse) {
        logger.log("CoreDataCache: Caching \(response.holdings.count) stock holdings")
        
        // Use background context for heavy operations
        context.perform { [weak self] in
            guard let self = self else { return }
            
            do {
                // Get or create cache session
                let session = try self.getOrCreateCacheSession()
                
                // Update with new data
                session.updateHoldings(response.holdings, in: self.context)
                
                // Save context
                try self.saveContextWithErrorHandling()
                
                self.logger.log("CoreDataCache: Successfully cached data")
                
                // Cleanup old cache sessions
                self.performCacheCleanup()
                
            } catch {
                self.logger.log("CoreDataCache: Error caching data - \(error.localizedDescription)")
                // Rollback changes on error
                self.context.rollback()
            }
        }
    }
    
    func isCacheValid() -> Bool {
        do {
            let cacheSession = try fetchValidCacheSession()
            let isValid = cacheSession?.isCacheValid ?? false
            logger.log("CoreDataCache: Cache validity check - \(isValid)")
            return isValid
        } catch {
            logger.log("CoreDataCache: Error checking cache validity - \(error.localizedDescription)")
            return false
        }
    }
    
    func clearCache() {
        logger.log("CoreDataCache: Clearing cache")
        
        context.perform { [weak self] in
            guard let self = self else { return }
            
            do {
                // Fetch all cache sessions for this key
                let fetchRequest = CacheSession.fetchRequest(for: self.cacheKey)
                fetchRequest.fetchLimit = 0 // Remove limit to get all sessions
                
                let sessions = try self.context.fetch(fetchRequest)
                
                // Delete all sessions (cascade will delete holdings)
                sessions.forEach { session in
                    self.context.delete(session)
                }
                
                try self.saveContextWithErrorHandling()
                self.logger.log("CoreDataCache: Successfully cleared cache")
                
            } catch {
                self.logger.log("CoreDataCache: Error clearing cache - \(error.localizedDescription)")
                self.context.rollback()
            }
        }
    }
    
    // MARK: - Additional Cache Utilities (Extended functionality)
    
    func getCacheAge() -> TimeInterval {
        do {
            let cacheSession = try fetchValidCacheSession()
            return cacheSession?.cacheAge ?? TimeInterval.infinity
        } catch {
            logger.log("CoreDataCache: Error getting cache age - \(error.localizedDescription)")
            return TimeInterval.infinity
        }
    }
    
    func hasCachedData() -> Bool {
        do {
            let cacheSession = try fetchValidCacheSession()
            let hasData = cacheSession != nil && !(cacheSession?.getStockHoldings().isEmpty ?? true)
            logger.log("CoreDataCache: Has cached data - \(hasData)")
            return hasData
        } catch {
            logger.log("CoreDataCache: Error checking for cached data - \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Private Helper Methods (Single Responsibility)
    
    /// Fetches valid cache session or returns nil
    /// Follows Single Responsibility - only handles session fetching
    private func fetchValidCacheSession() throws -> CacheSession? {
        let fetchRequest = CacheSession.fetchRequest(for: cacheKey)
        let sessions = try context.fetch(fetchRequest)
        
        // Return the latest session if it exists and is valid
        return sessions.first { $0.isCacheValid }
    }
    
    /// Gets existing cache session or creates a new one
    /// Follows Factory Pattern for session creation
    private func getOrCreateCacheSession() throws -> CacheSession {
        // Try to get existing session first
        if let existingSession = try fetchValidCacheSession() {
            return existingSession
        }
        
        // Create new session
        let newSession = CacheSession.create(
            cacheKey: cacheKey,
            expiryInterval: cacheExpiryInterval,
            in: context
        )
        
        logger.log("CoreDataCache: Created new cache session")
        return newSession
    }
    
    /// Saves context with proper error handling
    /// Follows Error Handling best practices
    private func saveContextWithErrorHandling() throws {
        guard context.hasChanges else {
            logger.log("CoreDataCache: No changes to save")
            return
        }
        
        try context.save()
        logger.log("CoreDataCache: Context saved successfully")
    }
    
    /// Performs cleanup of old cache sessions
    /// Follows Single Responsibility - only handles cleanup
    private func performCacheCleanup() {
        logger.log("CoreDataCache: Performing cleanup of old cache sessions")
        
        do {
            let fetchRequest = CacheSession.fetchInvalidSessionsRequest()
            let invalidSessions = try context.fetch(fetchRequest)
            
            if !invalidSessions.isEmpty {
                invalidSessions.forEach { session in
                    context.delete(session)
                }
                
                try saveContextWithErrorHandling()
                logger.log("CoreDataCache: Cleaned up \(invalidSessions.count) invalid sessions")
            }
            
        } catch {
            logger.log("CoreDataCache: Error during cleanup - \(error.localizedDescription)")
        }
    }
}

// MARK: - Cache Service Factory
/// Factory for creating CoreDataCacheService instances
/// Follows Factory Pattern and Dependency Injection
final class CoreDataCacheServiceFactory {
    
    /// Creates a CoreDataCacheService with proper dependencies
    /// Follows Dependency Injection Pattern
    static func create(
        persistenceController: PersistenceController = .shared,
        cacheKey: String = "stock_holdings_cache",
        cacheExpiryInterval: TimeInterval = 300
    ) -> CoreDataCacheService {
        
        // Create background context for cache operations
        let backgroundContext = persistenceController.container.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        return CoreDataCacheService(
            context: backgroundContext,
            cacheKey: cacheKey,
            cacheExpiryInterval: cacheExpiryInterval
        )
    }
    
    /// Creates a CoreDataCacheService for testing with in-memory context
    /// Follows Dependency Injection for better testability
    static func createForTesting(
        inMemoryController: PersistenceController
    ) -> CoreDataCacheService {
        return CoreDataCacheService(
            context: inMemoryController.container.viewContext,
            cacheKey: "test_cache",
            cacheExpiryInterval: 60 // 1 minute for testing
        )
    }
} 