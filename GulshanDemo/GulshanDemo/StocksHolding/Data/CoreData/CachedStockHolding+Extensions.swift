//
//  CachedStockHolding+Extensions.swift
//  GulshanDemo
//
//  Created by Gulshan Kumar on 15/08/25.
//

import CoreData
import Foundation

// MARK: - CachedStockHolding Extensions
extension CachedStockHolding {
    
    /// Converts Core Data entity to domain model
    /// Follows Single Responsibility Principle - only handles data conversion
    func toStockHolding() -> StockHolding {
        return StockHolding(
            symbol: symbol ?? "",
            quantity: Int(quantity),
            ltp: ltp,
            averagePrice: averagePrice,
            close: close
        )
    }
    
    /// Updates Core Data entity from domain model
    /// Follows Open/Closed Principle - extendable for new properties
    func update(from stockHolding: StockHolding) {
        symbol = stockHolding.symbol
        quantity = Int32(stockHolding.quantity)
        ltp = stockHolding.ltp
        averagePrice = stockHolding.averagePrice
        close = stockHolding.close
    }
    
    /// Creates a new Core Data entity from domain model
    /// Factory method following SOLID principles
    static func create(from stockHolding: StockHolding, in context: NSManagedObjectContext) -> CachedStockHolding {
        let cachedStockHolding = CachedStockHolding(context: context)
        cachedStockHolding.update(from: stockHolding)
        return cachedStockHolding
    }
}

// MARK: - Array Extensions for Batch Operations
extension Array where Element == CachedStockHolding {
    
    /// Converts array of Core Data entities to domain models
    /// Efficient batch conversion with error handling
    func toStockHoldings() -> [StockHolding] {
        return compactMap { cachedHolding in
            // Ensure we have valid data before conversion
            guard let symbol = cachedHolding.symbol, !symbol.isEmpty else {
                ConsoleLogger.shared.log("Warning: Skipping cached holding with invalid symbol")
                return nil
            }
            return cachedHolding.toStockHolding()
        }
    }
}

extension Array where Element == StockHolding {
    
    /// Creates Core Data entities from domain models
    /// Bulk creation with proper context management
    func createCachedEntities(in context: NSManagedObjectContext) -> [CachedStockHolding] {
        return map { stockHolding in
            CachedStockHolding.create(from: stockHolding, in: context)
        }
    }
} 