//
//  CurrencyFormatterTests.swift
//  GulshanDemoTests
//
//  Created by Gulshan Kumar on 15/08/25.
//

import XCTest
@testable import GulshanDemo

class CurrencyFormatterTests: XCTestCase {

    // MARK: - CurrencyFormatter.format Tests
    
    func testCurrencyFormattingPositive() {
        // When
        let formatted = CurrencyFormatter.format(amount: 1234.56)
        
        // Then
        XCTAssertEqual(formatted, "₹1234.56")
    }
    
    func testCurrencyFormattingZero() {
        // When
        let formatted = CurrencyFormatter.format(amount: 0.0)
        
        // Then
        XCTAssertEqual(formatted, "₹0.00")
    }
    
    func testCurrencyFormattingSmallDecimal() {
        // When
        let formatted = CurrencyFormatter.format(amount: 0.01)
        
        // Then
        XCTAssertEqual(formatted, "₹0.01")
    }
    
    func testCurrencyFormattingRounding() {
        // When
        let formatted = CurrencyFormatter.format(amount: 123.456)
        
        // Then
        XCTAssertEqual(formatted, "₹123.46")
    }
    
    func testCurrencyFormattingWithVeryLargeNumber() {
        // When
        let formatted = CurrencyFormatter.format(amount: 999999999.99)
        
        // Then
        XCTAssertEqual(formatted, "₹999999999.99")
    }
    
    // MARK: - Error Handling Tests
    
    func testCurrencyFormattingInfinite() {
        // When
        let formatted = CurrencyFormatter.format(amount: Double.infinity)
        
        // Then
        XCTAssertEqual(formatted, "₹0.00")
    }
    
    func testCurrencyFormattingNaN() {
        // When
        let formatted = CurrencyFormatter.format(amount: Double.nan)
        
        // Then
        XCTAssertEqual(formatted, "₹0.00")
    }
    
    func testCurrencyFormattingNegativeInfinity() {
        // When
        let formatted = CurrencyFormatter.format(amount: -Double.infinity)
        
        // Then
        XCTAssertEqual(formatted, "₹0.00")
    }
    
    // MARK: - CurrencyFormatter.formatPNL Tests
    
    func testPNLFormattingPositive() {
        // When
        let formatted = CurrencyFormatter.formatPNL(amount: 1234.56)
        
        // Then
        XCTAssertEqual(formatted, "₹1234.56")
    }
    
    func testPNLFormattingNegative() {
        // When
        let formatted = CurrencyFormatter.formatPNL(amount: -1234.56)
        
        // Then
        XCTAssertEqual(formatted, "-₹1234.56")
    }
    
    func testPNLFormattingZero() {
        // When
        let formatted = CurrencyFormatter.formatPNL(amount: 0.0)
        
        // Then
        XCTAssertEqual(formatted, "₹0.00")
    }
    
    func testPNLFormattingSmallPositive() {
        // When
        let formatted = CurrencyFormatter.formatPNL(amount: 0.01)
        
        // Then
        XCTAssertEqual(formatted, "₹0.01")
    }
    
    func testPNLFormattingSmallNegative() {
        // When
        let formatted = CurrencyFormatter.formatPNL(amount: -0.01)
        
        // Then
        XCTAssertEqual(formatted, "-₹0.01")
    }
    
    func testPNLFormattingRoundingPositive() {
        // When
        let formatted = CurrencyFormatter.formatPNL(amount: 123.456)
        
        // Then
        XCTAssertEqual(formatted, "₹123.46")
    }
    
    func testPNLFormattingRoundingNegative() {
        // When
        let formatted = CurrencyFormatter.formatPNL(amount: -123.456)
        
        // Then
        XCTAssertEqual(formatted, "-₹123.46")
    }
    
    func testPNLFormattingWithVeryLargePositiveNumber() {
        // When
        let formatted = CurrencyFormatter.formatPNL(amount: 999999999.99)
        
        // Then
        XCTAssertEqual(formatted, "₹999999999.99")
    }
    
    func testPNLFormattingWithVeryLargeNegativeNumber() {
        // When
        let formatted = CurrencyFormatter.formatPNL(amount: -999999999.99)
        
        // Then
        XCTAssertEqual(formatted, "-₹999999999.99")
    }
    
    // MARK: - P&L Error Handling Tests
    
    func testPNLFormattingInfinite() {
        // When
        let formatted = CurrencyFormatter.formatPNL(amount: Double.infinity)
        
        // Then
        XCTAssertEqual(formatted, "₹0.00")
    }
    
    func testPNLFormattingNegativeInfinite() {
        // When
        let formatted = CurrencyFormatter.formatPNL(amount: -Double.infinity)
        
        // Then
        XCTAssertEqual(formatted, "₹0.00")
    }
    
    func testPNLFormattingNaN() {
        // When
        let formatted = CurrencyFormatter.formatPNL(amount: Double.nan)
        
        // Then
        XCTAssertEqual(formatted, "₹0.00")
    }
    
    // MARK: - Precision Tests
    
    func testCurrencyFormattingPrecisionWith3Decimals() {
        // When
        let formatted = CurrencyFormatter.format(amount: 100.125)
        
        // Then - Should round to 2 decimal places
        XCTAssertEqual(formatted, "₹100.12")
    }
    
    func testCurrencyFormattingPrecisionWith4Decimals() {
        // When
        let formatted = CurrencyFormatter.format(amount: 100.1234)
        
        // Then - Should round to 2 decimal places
        XCTAssertEqual(formatted, "₹100.12")
    }
    
    func testPNLFormattingPrecisionWith3Decimals() {
        // When
        let formatted = CurrencyFormatter.formatPNL(amount: -100.125)
        
        // Then - Should round to 2 decimal places
        XCTAssertEqual(formatted, "-₹100.12")
    }
} 
