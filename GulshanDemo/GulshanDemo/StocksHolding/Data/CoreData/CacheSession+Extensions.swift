//
//  CacheSession+Extensions.swift
//  GulshanDemo
//
//  Created by Gulshan Kumar on 15/08/25.
//

import CoreData
import Foundation

// MARK: - CacheSession Extensions
extension CacheSession {
    
    /// Checks if the cache session is still valid based on expiry time
    /// Follows Single Responsibility Principle - only handles validity logic
    var isCacheValid: Bool {
        guard isValid,
              let createdAt = createdAt else {
            return false
        }
        
        let currentTime = Date()
        let timeSinceCreation = currentTime.timeIntervalSince(createdAt)
        return timeSinceCreation < expiryInterval
    }
    
    /// Gets the age of the cache in seconds
    /// Useful for debugging and cache analytics
    var cacheAge: TimeInterval {
        guard let createdAt = createdAt else {
            return TimeInterval.infinity
        }
        return Date().timeIntervalSince(createdAt)
    }
    
    /// Marks the cache session as invalid
    /// Follows Command Pattern - encapsulates cache invalidation
    func invalidate() {
        isValid = false
    }
    
    /// Updates the cache session with new data
    /// Ensures atomic updates with proper relationship management
    func updateHoldings(_ stockHoldings: [StockHolding], in context: NSManagedObjectContext) {
        // Remove existing holdings to avoid duplicates
        if let existingHoldings = holdings?.allObjects as? [CachedStockHolding] {
            existingHoldings.forEach { context.delete($0) }
        }
        
        // Create new cached holdings
        let newCachedHoldings = stockHoldings.createCachedEntities(in: context)
        
        // Establish relationships
        newCachedHoldings.forEach { cachedHolding in
            cachedHolding.cacheSession = self
        }
        
        // Update session metadata
        createdAt = Date()
        isValid = true
    }
    
    /// Retrieves all stock holdings from the cache session
    /// Returns empty array if no valid holdings exist
    func getStockHoldings() -> [StockHolding] {
        guard let cachedHoldings = holdings?.allObjects as? [CachedStockHolding] else {
            return []
        }
        return cachedHoldings.toStockHoldings()
    }
    
    /// Factory method to create a new cache session
    /// Follows Factory Pattern with proper initialization
    static func create(
        cacheKey: String,
        expiryInterval: TimeInterval = 300, // 5 minutes default
        in context: NSManagedObjectContext
    ) -> CacheSession {
        let session = CacheSession(context: context)
        session.cacheKey = cacheKey
        session.expiryInterval = expiryInterval
        session.createdAt = Date()
        session.isValid = true
        return session
    }
}

// MARK: - Fetch Request Helpers
extension CacheSession {
    
    /// Creates a fetch request for finding cache sessions by key
    /// Follows Repository Pattern for data access
    static func fetchRequest(for cacheKey: String) -> NSFetchRequest<CacheSession> {
        let request: NSFetchRequest<CacheSession> = CacheSession.fetchRequest()
        request.predicate = NSPredicate(format: "cacheKey == %@", cacheKey)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.fetchLimit = 1 // We only need the latest session
        return request
    }
    
    /// Creates a fetch request for cleaning up invalid cache sessions
    /// Helps maintain database cleanliness
    static func fetchInvalidSessionsRequest() -> NSFetchRequest<CacheSession> {
        let request: NSFetchRequest<CacheSession> = CacheSession.fetchRequest()
        request.predicate = NSPredicate(format: "isValid == false OR createdAt < %@", 
                                      Date().addingTimeInterval(-86400) as NSDate) // Older than 24 hours
        return request
    }
} 