//
//  PNLColorProviderTests.swift
//  GulshanDemoTests
//
//  Created by Gulshan Kumar on 15/08/25.
//

import XCTest
import UIKit
@testable import GulshanDemo

class PNLColorProviderTests: XCTestCase {

    // MARK: - Basic Color Tests
    
    func testColorForPositivePNL() {
        // When
        let color = PNLColorProvider.color(for: 100.0)
        
        // Then
        XCTAssertEqual(color, UIColor.systemGreen)
    }
    
    func testColorForNegativePNL() {
        // When
        let color = PNLColorProvider.color(for: -100.0)
        
        // Then
        XCTAssertEqual(color, UIColor.systemRed)
    }
    
    func testColorForZeroPNL() {
        // When
        let color = PNLColorProvider.color(for: 0.0)
        
        // Then
        XCTAssertEqual(color, UIColor.systemGreen)
    }
    
    // MARK: - Small Value Tests
    
    func testColorForVerySmallPositivePNL() {
        // When
        let color = PNLColorProvider.color(for: 0.01)
        
        // Then
        XCTAssertEqual(color, UIColor.systemGreen)
    }
    
    func testColorForVerySmallNegativePNL() {
        // When
        let color = PNLColorProvider.color(for: -0.01)
        
        // Then
        XCTAssertEqual(color, UIColor.systemRed)
    }
    
    func testColorForMinimalPositivePNL() {
        // When
        let color = PNLColorProvider.color(for: 0.001)
        
        // Then
        XCTAssertEqual(color, UIColor.systemGreen)
    }
    
    func testColorForMinimalNegativePNL() {
        // When
        let color = PNLColorProvider.color(for: -0.001)
        
        // Then
        XCTAssertEqual(color, UIColor.systemRed)
    }
    
    // MARK: - Large Value Tests
    
    func testColorForLargePositivePNL() {
        // When
        let color = PNLColorProvider.color(for: 999999999.99)
        
        // Then
        XCTAssertEqual(color, UIColor.systemGreen)
    }
    
    func testColorForLargeNegativePNL() {
        // When
        let color = PNLColorProvider.color(for: -999999999.99)
        
        // Then
        XCTAssertEqual(color, UIColor.systemRed)
    }
    
    // MARK: - Edge Case Tests
    
    func testColorForInfinitePNL() {
        // When
        let color = PNLColorProvider.color(for: Double.infinity)
        
        // Then
        XCTAssertEqual(color, UIColor.systemGreen)
    }
    
    func testColorForNegativeInfinitePNL() {
        // When
        let color = PNLColorProvider.color(for: -Double.infinity)
        
        // Then
        XCTAssertEqual(color, UIColor.systemRed)
    }
    
    func testColorForNaNPNL() {
        // When
        let color = PNLColorProvider.color(for: Double.nan)
        
        // Then
        // NaN >= 0 evaluates to false, so it should be red
        XCTAssertEqual(color, UIColor.systemRed)
    }
    
    // MARK: - Precision Boundary Tests
    
    func testColorForExtremelySmallPositiveValue() {
        // When
        let color = PNLColorProvider.color(for: Double.leastNormalMagnitude)
        
        // Then
        XCTAssertEqual(color, UIColor.systemGreen)
    }
    
    func testColorForExtremelySmallNegativeValue() {
        // When
        let color = PNLColorProvider.color(for: -Double.leastNormalMagnitude)
        
        // Then
        XCTAssertEqual(color, UIColor.systemRed)
    }
    
    func testColorForMaximumPositiveValue() {
        // When
        let color = PNLColorProvider.color(for: Double.greatestFiniteMagnitude)
        
        // Then
        XCTAssertEqual(color, UIColor.systemGreen)
    }
    
    func testColorForMaximumNegativeValue() {
        // When
        let color = PNLColorProvider.color(for: -Double.greatestFiniteMagnitude)
        
        // Then
        XCTAssertEqual(color, UIColor.systemRed)
    }
    
    // MARK: - Business Logic Validation Tests
    
    func testColorConsistencyAcrossMultipleCalls() {
        // Given
        let testValue = 42.5
        
        // When
        let color1 = PNLColorProvider.color(for: testValue)
        let color2 = PNLColorProvider.color(for: testValue)
        let color3 = PNLColorProvider.color(for: testValue)
        
        // Then
        XCTAssertEqual(color1, color2)
        XCTAssertEqual(color2, color3)
        XCTAssertEqual(color1, UIColor.systemGreen)
    }
    
    func testColorLogicBoundary() {
        // Given - Test values very close to zero boundary
        let justAboveZero = 0.0000001
        let justBelowZero = -0.0000001
        
        // When
        let positiveColor = PNLColorProvider.color(for: justAboveZero)
        let negativeColor = PNLColorProvider.color(for: justBelowZero)
        
        // Then
        XCTAssertEqual(positiveColor, UIColor.systemGreen)
        XCTAssertEqual(negativeColor, UIColor.systemRed)
    }
} 