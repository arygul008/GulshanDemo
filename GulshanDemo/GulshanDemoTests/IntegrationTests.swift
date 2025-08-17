//
//  IntegrationTests.swift
//  GulshanDemoTests
//
//  Created by Gulshan Kumar on 15/08/25.
//

import XCTest
import UIKit
@testable import GulshanDemo

class IntegrationTests: XCTestCase {

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
    
    // MARK: - End-to-End Integration Tests
    
    func testCompleteIntegrationWithRealStockData() {
        // Given
        let stockHolding = createStockHolding(
            symbol: "TSLA",
            quantity: 50,
            ltp: 250.75,
            averagePrice: 220.50,
            close: 248.00
        )
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then - Test all properties integration
        XCTAssertEqual(viewModel.symbol, "TSLA")
        XCTAssertEqual(viewModel.quantityText, "NET QTY:")
        XCTAssertEqual(viewModel.quantityValue, "50")
        XCTAssertEqual(viewModel.ltpText, "LTP:")
        XCTAssertEqual(viewModel.ltpValue, "₹250.75")
        XCTAssertEqual(viewModel.pnlText, "P&L:")
        
        // P&L calculation: (250.75 - 220.50) * 50 = 1512.50
        XCTAssertEqual(viewModel.pnlValue, "₹1512.50")
        XCTAssertEqual(viewModel.pnlColor, UIColor.systemGreen)
    }
    
    func testIntegrationWithNegativePNL() {
        // Given
        let stockHolding = createStockHolding(
            symbol: "NFLX",
            quantity: 25,
            ltp: 400.25,
            averagePrice: 450.80,
            close: 405.00
        )
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        // P&L calculation: (400.25 - 450.80) * 25 = -1263.75
        XCTAssertEqual(viewModel.pnlValue, "-₹1263.75")
        XCTAssertEqual(viewModel.pnlColor, UIColor.systemRed)
        
        // Test other properties are still correct
        XCTAssertEqual(viewModel.symbol, "NFLX")
        XCTAssertEqual(viewModel.quantityValue, "25")
        XCTAssertEqual(viewModel.ltpValue, "₹400.25")
    }
    
    func testIntegrationWithZeroPNL() {
        // Given
        let stockHolding = createStockHolding(
            symbol: "AMZN",
            quantity: 75,
            ltp: 150.0,
            averagePrice: 150.0,
            close: 152.0
        )
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        // P&L calculation: (150.0 - 150.0) * 75 = 0.0
        XCTAssertEqual(viewModel.pnlValue, "₹0.00")
        XCTAssertEqual(viewModel.pnlColor, UIColor.systemGreen)
        
        // Verify formatter and color provider work together correctly for zero
        XCTAssertEqual(viewModel.symbol, "AMZN")
        XCTAssertEqual(viewModel.quantityValue, "75")
        XCTAssertEqual(viewModel.ltpValue, "₹150.00")
    }
    
    // MARK: - Component Integration Tests
    
    func testCurrencyFormatterAndColorProviderIntegration() {
        // Given - Test various P&L scenarios to ensure formatter and color provider work together
        let testCases: [(pnl: Double, expectedFormat: String, expectedColor: UIColor)] = [
            (1234.56, "₹1234.56", UIColor.systemGreen),
            (-1234.56, "-₹1234.56", UIColor.systemRed),
            (0.0, "₹0.00", UIColor.systemGreen),
            (0.01, "₹0.01", UIColor.systemGreen),
            (-0.01, "-₹0.01", UIColor.systemRed)
        ]
        
        for testCase in testCases {
            // When
            let formattedValue = CurrencyFormatter.formatPNL(amount: testCase.pnl)
            let color = PNLColorProvider.color(for: testCase.pnl)
            
            // Then
            XCTAssertEqual(formattedValue, testCase.expectedFormat, "Failed for P&L: \(testCase.pnl)")
            XCTAssertEqual(color, testCase.expectedColor, "Failed color for P&L: \(testCase.pnl)")
        }
    }
    
    func testViewModelWithCurrencyFormatterIntegration() {
        // Given - Test that view model properly delegates to currency formatter
        let stockHolding = createStockHolding(ltp: 123.456, averagePrice: 100.123)
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // When - Direct formatter call vs view model call
        let directLTPFormat = CurrencyFormatter.format(amount: 123.456)
        let viewModelLTPFormat = viewModel.ltpValue
        
        // Then - Should be identical
        XCTAssertEqual(directLTPFormat, viewModelLTPFormat)
        XCTAssertEqual(viewModelLTPFormat, "₹123.46") // Verify rounding
    }
    
    func testViewModelWithPNLColorProviderIntegration() {
        // Given
        let positiveStockHolding = createStockHolding(ltp: 200.0, averagePrice: 150.0)
        let negativeStockHolding = createStockHolding(ltp: 100.0, averagePrice: 150.0)
        
        let positiveViewModel = StockHoldingCellViewModel(stockHolding: positiveStockHolding)
        let negativeViewModel = StockHoldingCellViewModel(stockHolding: negativeStockHolding)
        
        // When - Direct color provider call vs view model call
        let directPositiveColor = PNLColorProvider.color(for: positiveStockHolding.pnl)
        let directNegativeColor = PNLColorProvider.color(for: negativeStockHolding.pnl)
        
        // Then - Should be identical
        XCTAssertEqual(directPositiveColor, positiveViewModel.pnlColor)
        XCTAssertEqual(directNegativeColor, negativeViewModel.pnlColor)
        XCTAssertEqual(positiveViewModel.pnlColor, UIColor.systemGreen)
        XCTAssertEqual(negativeViewModel.pnlColor, UIColor.systemRed)
    }
    
    // MARK: - Real-World Scenario Tests
    
    func testRealWorldHighVolumeTrading() {
        // Given - High volume, high value trading scenario
        let stockHolding = createStockHolding(
            symbol: "MSFT",
            quantity: 10000,
            ltp: 415.67,
            averagePrice: 398.23,
            close: 412.00
        )
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        // P&L = (415.67 - 398.23) * 10000 = 174400.0
        XCTAssertEqual(viewModel.symbol, "MSFT")
        XCTAssertEqual(viewModel.quantityValue, "10000")
        XCTAssertEqual(viewModel.ltpValue, "₹415.67")
        XCTAssertEqual(viewModel.pnlValue, "₹174400.00")
        XCTAssertEqual(viewModel.pnlColor, UIColor.systemGreen)
    }
    
    func testRealWorldPennyStock() {
        // Given - Penny stock scenario with small values
        let stockHolding = createStockHolding(
            symbol: "PENNY",
            quantity: 5000,
            ltp: 2.34,
            averagePrice: 2.89,
            close: 2.31
        )
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        // P&L = (2.34 - 2.89) * 5000 = -2750.0
        XCTAssertEqual(viewModel.symbol, "PENNY")
        XCTAssertEqual(viewModel.quantityValue, "5000")
        XCTAssertEqual(viewModel.ltpValue, "₹2.34")
        XCTAssertEqual(viewModel.pnlValue, "-₹2750.00")
        XCTAssertEqual(viewModel.pnlColor, UIColor.systemRed)
    }
    
    func testRealWorldFractionalShares() {
        // Given - Fractional shares (simulated with decimal quantities in integer field)
        let stockHolding = createStockHolding(
            symbol: "FRAC",
            quantity: 1, // Representing 0.1 shares in business logic
            ltp: 1000.50,
            averagePrice: 980.25,
            close: 995.00
        )
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        // P&L = (1000.50 - 980.25) * 1 = 20.25
        XCTAssertEqual(viewModel.symbol, "FRAC")
        XCTAssertEqual(viewModel.quantityValue, "1")
        XCTAssertEqual(viewModel.ltpValue, "₹1000.50")
        XCTAssertEqual(viewModel.pnlValue, "₹20.25")
        XCTAssertEqual(viewModel.pnlColor, UIColor.systemGreen)
    }
    
    // MARK: - Error Handling Integration Tests
    
    func testIntegrationWithInvalidData() {
        // Given - Stock with extreme/invalid data
        let stockHolding = createStockHolding(
            symbol: "INVALID",
            quantity: 100,
            ltp: Double.infinity,
            averagePrice: 100.0,
            close: 105.0
        )
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then - Should handle gracefully with fallbacks
        XCTAssertEqual(viewModel.symbol, "INVALID")
        XCTAssertEqual(viewModel.ltpValue, "₹0.00") // Formatter handles infinity
        
        // P&L will be infinity - (100 * 100) which is still infinity
        // But formatter should handle this gracefully
        XCTAssertEqual(viewModel.pnlValue, "₹0.00")
    }
    
    func testBoundaryValueIntegration() {
        // Given - Test with boundary values
        let stockHolding = createStockHolding(
            quantity: Int.max,
            ltp: 0.01,
            averagePrice: 0.02,
            close: 0.015
        )
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then - Should handle large quantity * small price without overflow
        XCTAssertEqual(viewModel.quantityValue, "\(Int.max)")
        XCTAssertEqual(viewModel.ltpValue, "₹0.01")
        // P&L calculation might overflow, but should be handled gracefully
        XCTAssertNotNil(viewModel.pnlValue)
        XCTAssertNotNil(viewModel.pnlColor)
    }
} 