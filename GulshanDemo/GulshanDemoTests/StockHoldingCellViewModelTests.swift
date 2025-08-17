//
//  StockHoldingCellViewModelTests.swift
//  GulshanDemoTests
//
//  Created by Gulshan Kumar on 15/08/25.
//

import XCTest
import UIKit
@testable import GulshanDemo

class StockHoldingCellViewModelTests: XCTestCase {

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
    
    // MARK: - StockHoldingCellViewModel Tests
    
    func testStockSymbolDisplay() {
        // Given
        let stockHolding = createStockHolding(symbol: "GOOGL")
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        XCTAssertEqual(viewModel.symbol, "GOOGL")
    }
    
    func testQuantityDisplay() {
        // Given
        let stockHolding = createStockHolding(quantity: 250)
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        XCTAssertEqual(viewModel.quantityText, "NET QTY:")
        XCTAssertEqual(viewModel.quantityValue, "250")
    }
    
    func testLTPDisplay() {
        // Given
        let stockHolding = createStockHolding(ltp: 123.45)
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        XCTAssertEqual(viewModel.ltpText, "LTP:")
        XCTAssertEqual(viewModel.ltpValue, "₹123.45")
    }
    
    func testPNLTextDisplay() {
        // Given
        let stockHolding = createStockHolding()
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        XCTAssertEqual(viewModel.pnlText, "P&L:")
    }
    
    func testPositivePNLValueAndColor() {
        // Given
        // ltp: 150.0, averagePrice: 140.0, quantity: 100
        // P&L = (150.0 - 140.0) * 100 = 1000.0
        let stockHolding = createStockHolding(quantity: 100, ltp: 150.0, averagePrice: 140.0)
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        XCTAssertEqual(viewModel.pnlValue, "₹1000.00")
        XCTAssertEqual(viewModel.pnlColor, UIColor.systemGreen)
    }
    
    func testNegativePNLValueAndColor() {
        // Given
        // ltp: 130.0, averagePrice: 140.0, quantity: 100
        // P&L = (130.0 - 140.0) * 100 = -1000.0
        let stockHolding = createStockHolding(quantity: 100, ltp: 130.0, averagePrice: 140.0)
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        XCTAssertEqual(viewModel.pnlValue, "-₹1000.00")
        XCTAssertEqual(viewModel.pnlColor, UIColor.systemRed)
    }
    
    func testZeroPNLValueAndColor() {
        // Given
        // ltp: 140.0, averagePrice: 140.0, quantity: 100
        // P&L = (140.0 - 140.0) * 100 = 0.0
        let stockHolding = createStockHolding(quantity: 100, ltp: 140.0, averagePrice: 140.0)
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        XCTAssertEqual(viewModel.pnlValue, "₹0.00")
        XCTAssertEqual(viewModel.pnlColor, UIColor.systemGreen)
    }
    
    // MARK: - Edge Case Tests
    
    func testEdgeCaseWithVeryLargeNumbers() {
        // Given
        let stockHolding = createStockHolding(
            quantity: 1000000,
            ltp: 999999.99,
            averagePrice: 999999.98
        )
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        // P&L = (999999.99 - 999999.98) * 1000000 = 10000.00
        XCTAssertEqual(viewModel.pnlValue, "₹10000.00")
        XCTAssertEqual(viewModel.pnlColor, UIColor.systemGreen)
    }
    
    func testEdgeCaseWithZeroQuantity() {
        // Given
        let stockHolding = createStockHolding(
            quantity: 0,
            ltp: 100.0,
            averagePrice: 90.0
        )
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        XCTAssertEqual(viewModel.quantityValue, "0")
        // P&L = (100.0 - 90.0) * 0 = 0.0
        XCTAssertEqual(viewModel.pnlValue, "₹0.00")
        XCTAssertEqual(viewModel.pnlColor, UIColor.systemGreen)
    }
    
    func testEdgeCaseWithNegativeQuantity() {
        // Given
        let stockHolding = createStockHolding(
            quantity: -50,
            ltp: 100.0,
            averagePrice: 90.0
        )
        let viewModel = StockHoldingCellViewModel(stockHolding: stockHolding)
        
        // Then
        XCTAssertEqual(viewModel.quantityValue, "-50")
        // P&L = (100.0 - 90.0) * -50 = -500.0
        XCTAssertEqual(viewModel.pnlValue, "-₹500.00")
        XCTAssertEqual(viewModel.pnlColor, UIColor.systemRed)
    }
} 