//
//  PerformanceTests.swift
//  GulshanDemoTests
//
//  Created by Gulshan Kumar on 15/08/25.
//

import XCTest
import UIKit
@testable import GulshanDemo

class PerformanceTests: XCTestCase {

    // MARK: - Test Helper Methods
    
    private func createStockHolding(
        symbol: String = "AAPL",
        quantity: Int = 100,
        ltp: Double = 150.0,
        averagePrice: Double = 140.0,
        close: Double = 155.0
    ) -> StockHolding {
        return StockHolding(
            symbol: symbol,
            quantity: quantity,
            ltp: ltp,
            averagePrice: averagePrice,
            close: close
        )
    }
    
    // MARK: - CurrencyFormatter Performance Tests
    
    func testCurrencyFormatterPerformance() {
        // Test currency formatting performance with 1000 iterations
        measure {
            for _ in 0..<1000 {
                _ = CurrencyFormatter.format(amount: 1234.56)
            }
        }
    }
    
    func testPNLFormatterPerformance() {
        // Test P&L formatting performance with 1000 iterations
        measure {
            for _ in 0..<1000 {
                _ = CurrencyFormatter.formatPNL(amount: -1234.56)
            }
        }
    }
    
    func testCurrencyFormatterWithVariousAmounts() {
        // Test formatting performance with different amount ranges
        let amounts = [0.01, 1.0, 100.0, 1000.0, 10000.0, 100000.0, 1000000.0]
        
        measure {
            for _ in 0..<500 {
                for amount in amounts {
                    _ = CurrencyFormatter.format(amount: amount)
                }
            }
        }
    }
    
    func testPNLFormatterWithMixedValues() {
        // Test P&L formatting with positive and negative values
        let pnlValues = [-10000.0, -100.0, -1.0, 0.0, 1.0, 100.0, 10000.0]
        
        measure {
            for _ in 0..<500 {
                for pnl in pnlValues {
                    _ = CurrencyFormatter.formatPNL(amount: pnl)
                }
            }
        }
    }
    
    // MARK: - PNLColorProvider Performance Tests
    
    func testPNLColorProviderPerformance() {
        // Test color determination performance
        measure {
            for _ in 0..<1000 {
                _ = PNLColorProvider.color(for: 100.0)
            }
        }
    }
    
    func testPNLColorProviderWithVariousValues() {
        // Test color provider with different P&L ranges
        let pnlValues = [-10000.0, -100.0, -1.0, -0.01, 0.0, 0.01, 1.0, 100.0, 10000.0]
        
        measure {
            for _ in 0..<500 {
                for pnl in pnlValues {
                    _ = PNLColorProvider.color(for: pnl)
                }
            }
        }
    }
    
    // MARK: - StockHoldingCellViewModel Performance Tests
    
    func testViewModelCreationPerformance() {
        // Test view model initialization performance
        let stockHolding = createStockHolding()
        
        measure {
            for _ in 0..<1000 {
                _ = StockHoldingCellViewModel(stockHolding: stockHolding)
            }
        }
    }
    
    func testViewModelPropertyAccessPerformance() {
        // Test performance of accessing all view model properties
        let stockHolding = createStockHolding()
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        measure {
            for _ in 0..<1000 {
                _ = viewModel.symbol
                _ = viewModel.quantityText
                _ = viewModel.quantityValue
                _ = viewModel.ltpText
                _ = viewModel.ltpValue
                _ = viewModel.pnlText
                _ = viewModel.pnlValue
                _ = viewModel.pnlColor
            }
        }
    }
    
    func testViewModelWithComplexCalculations() {
        // Test performance with various stock holdings requiring complex P&L calculations
        let stockHoldings = [
            createStockHolding(quantity: 100, ltp: 150.567, averagePrice: 140.123),
            createStockHolding(quantity: 500, ltp: 25.789, averagePrice: 30.456),
            createStockHolding(quantity: 1000, ltp: 1.234, averagePrice: 1.567),
            createStockHolding(quantity: 50, ltp: 1000.99, averagePrice: 950.11),
            createStockHolding(quantity: 2000, ltp: 75.33, averagePrice: 80.44)
        ]
        
        measure {
            for _ in 0..<200 {
                for stockHolding in stockHoldings {
                    let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
                    _ = viewModel.pnlValue
                    _ = viewModel.pnlColor
                    _ = viewModel.ltpValue
                }
            }
        }
    }
    
    // MARK: - Memory Performance Tests
    
    func testViewModelMemoryPerformance() {
        // Test memory usage with multiple view models
        measure {
            var viewModels: [StockHoldingCellViewModel] = []
            
            for i in 0..<1000 {
                let stockHolding = createStockHolding(
                    symbol: "STOCK\(i)",
                    quantity: i + 1,
                    ltp: Double(i) + 100.0,
                    averagePrice: Double(i) + 90.0
                )
                let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
                viewModels.append(viewModel)
            }
            
            // Force access to prevent optimization
            for viewModel in viewModels {
                _ = viewModel.pnlValue
            }
        }
    }
    
    // MARK: - Concurrent Performance Tests
    
    func testConcurrentFormatting() {
        // Test thread safety and performance under concurrent access
        measure {
            let group = DispatchGroup()
            let queue = DispatchQueue.global(qos: .userInitiated)
            
            for _ in 0..<10 {
                group.enter()
                queue.async {
                    for _ in 0..<100 {
                        _ = CurrencyFormatter.format(amount: 123.45)
                        _ = CurrencyFormatter.formatPNL(amount: -123.45)
                        _ = PNLColorProvider.color(for: 123.45)
                    }
                    group.leave()
                }
            }
            
            group.wait()
        }
    }
    
    func testConcurrentViewModelCreation() {
        // Test concurrent view model creation performance
        measure {
            let group = DispatchGroup()
            let queue = DispatchQueue.global(qos: .userInitiated)
            
            for i in 0..<10 {
                group.enter()
                queue.async {
                    for j in 0..<100 {
                        let stockHolding = self.createStockHolding(
                            symbol: "STOCK\(i)\(j)",
                            quantity: j + 1,
                            ltp: Double(j) + 100.0,
                            averagePrice: Double(j) + 90.0
                        )
                        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
                        _ = viewModel.pnlValue // Force calculation
                    }
                    group.leave()
                }
            }
            
            group.wait()
        }
    }
    
    // MARK: - Stress Tests
    
    func testFormatterWithExtremeValues() {
        // Test performance with extreme values
        let extremeValues = [
            Double.leastNormalMagnitude,
            -Double.leastNormalMagnitude,
            Double.greatestFiniteMagnitude,
            -Double.greatestFiniteMagnitude,
            0.0000001,
            -0.0000001,
            999999999.99,
            -999999999.99
        ]
        
        measure {
            for _ in 0..<100 {
                for value in extremeValues {
                    _ = CurrencyFormatter.format(amount: value)
                    _ = CurrencyFormatter.formatPNL(amount: value)
                    _ = PNLColorProvider.color(for: value)
                }
            }
        }
    }
    
    func testPerformanceWithLargePortfolio() {
        // Simulate performance with a large portfolio (1000 stocks)
        var stockHoldings: [StockHolding] = []
        
        for i in 0..<1000 {
            let stockHolding = createStockHolding(
                symbol: "STOCK\(i)",
                quantity: (i % 100) + 1,
                ltp: Double.random(in: 1.0...1000.0),
                averagePrice: Double.random(in: 1.0...1000.0)
            )
            stockHoldings.append(stockHolding)
        }
        
        measure {
            for stockHolding in stockHoldings {
                let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
                _ = viewModel.symbol
                _ = viewModel.pnlValue
                _ = viewModel.pnlColor
            }
        }
    }
} 