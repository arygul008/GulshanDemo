//
//  StockHoldingsViewModelTests.swift
//  GulshanDemoTests
//
//  Created by Gulshan Kumar on 15/08/25.
//

import XCTest
@testable import GulshanDemo

// MARK: - ViewModel Tests
final class StockHoldingsViewModelTests: XCTestCase {
    
    // MARK: - Properties
    private var mockNetworkDataSource: MockNetworkDataSource!
    private var mockCacheDataSource: MockCacheDataSource!
    private var repository: StockHoldingsRepository!
    private var mockDelegate: MockStockHoldingsViewModelDelegate!
    private var viewModel: StockHoldingsViewModel!
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        mockNetworkDataSource = MockNetworkDataSource()
        mockCacheDataSource = MockCacheDataSource()
        repository = StockHoldingsRepository(
            networkDataSource: mockNetworkDataSource,
            cacheDataSource: mockCacheDataSource
        )
        mockDelegate = MockStockHoldingsViewModelDelegate()
        viewModel = StockHoldingsViewModel(repository: repository)
        viewModel.delegate = mockDelegate
    }
    
    override func tearDown() {
        mockNetworkDataSource = nil
        mockCacheDataSource = nil
        repository = nil
        mockDelegate = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Portfolio Calculation Tests
    func testTotalPortfolioCalculations() {
        // Given
        let mockHoldings = [
            StockHolding(symbol: "AAPL", quantity: 100, ltp: 150.0, averagePrice: 140.0, close: 145.0),
            StockHolding(symbol: "GOOGL", quantity: 50, ltp: 2800.0, averagePrice: 2750.0, close: 2780.0),
            StockHolding(symbol: "TSLA", quantity: 75, ltp: 900.0, averagePrice: 850.0, close: 880.0)
        ]
        mockNetworkDataSource.mockResponse = StockHoldingResponse(holdings: mockHoldings)
        
        let expectation = XCTestExpectation(description: "Portfolio calculations")
        
        // When
        viewModel.fetchHoldings()
        
        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        // Then
        // Calculate expected values
        let expectedTotalCurrentValue = mockHoldings.reduce(0.0) { $0 + $1.currentValue }
        let expectedTotalInvestment = mockHoldings.reduce(0.0) { $0 + $1.totalInvestment }
        let expectedTotalPNL = expectedTotalCurrentValue - expectedTotalInvestment
        let expectedTodaysTotalPNL = mockHoldings.reduce(0.0) { $0 + $1.todaysPNL }
        
        // Verify calculations
        XCTAssertEqual(viewModel.totalCurrentValue, expectedTotalCurrentValue, accuracy: 0.01, "Total current value should be \(expectedTotalCurrentValue)")
        XCTAssertEqual(viewModel.totalInvestment, expectedTotalInvestment, accuracy: 0.01, "Total investment should be \(expectedTotalInvestment)")
        XCTAssertEqual(viewModel.totalPNL, expectedTotalPNL, accuracy: 0.01, "Total PNL should be \(expectedTotalPNL)")
        XCTAssertEqual(viewModel.todaysTotalPNL, expectedTodaysTotalPNL, accuracy: 0.01, "Today's total PNL should be \(expectedTodaysTotalPNL)")
    }
    
    func testEmptyPortfolioCalculations() {
        // Given
        mockNetworkDataSource.mockResponse = StockHoldingResponse(holdings: [])
        
        let expectation = XCTestExpectation(description: "Empty portfolio calculations")
        
        // When
        viewModel.fetchHoldings()
        
        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertEqual(viewModel.totalCurrentValue, 0.0, "Total current value should be 0 for empty portfolio")
        XCTAssertEqual(viewModel.totalInvestment, 0.0, "Total investment should be 0 for empty portfolio")
        XCTAssertEqual(viewModel.totalPNL, 0.0, "Total PNL should be 0 for empty portfolio")
        XCTAssertEqual(viewModel.todaysTotalPNL, 0.0, "Today's total PNL should be 0 for empty portfolio")
    }
    
    func testIndividualStockCalculations() {
        // Given
        let mockHoldings = [
            StockHolding(symbol: "AAPL", quantity: 100, ltp: 150.0, averagePrice: 140.0, close: 145.0)
        ]
        mockNetworkDataSource.mockResponse = StockHoldingResponse(holdings: mockHoldings)
        
        let expectation = XCTestExpectation(description: "Individual stock calculations")
        
        // When
        viewModel.fetchHoldings()
        
        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        // Then
        let stock = viewModel.holdings.first!
        
        // Verify individual stock calculations match the model's computed properties
        XCTAssertEqual(stock.currentValue, stock.ltp * Double(stock.quantity), accuracy: 0.01, "Stock current value calculation incorrect")
        XCTAssertEqual(stock.totalInvestment, stock.averagePrice * Double(stock.quantity), accuracy: 0.01, "Stock total investment calculation incorrect")
        XCTAssertEqual(stock.pnl, stock.currentValue - stock.totalInvestment, accuracy: 0.01, "Stock PNL calculation incorrect")
        XCTAssertEqual(stock.todaysPNL, Double(stock.quantity) * (stock.close - stock.ltp), accuracy: 0.01, "Stock today's PNL calculation incorrect")
        
        // Verify that individual stock values contribute correctly to portfolio totals
        XCTAssertEqual(viewModel.totalCurrentValue, stock.currentValue, accuracy: 0.01, "Portfolio total current value should match single stock")
        XCTAssertEqual(viewModel.totalInvestment, stock.totalInvestment, accuracy: 0.01, "Portfolio total investment should match single stock")
        XCTAssertEqual(viewModel.totalPNL, stock.pnl, accuracy: 0.01, "Portfolio total PNL should match single stock")
        XCTAssertEqual(viewModel.todaysTotalPNL, stock.todaysPNL, accuracy: 0.01, "Portfolio today's total PNL should match single stock")
    }
    
    // MARK: - Loading State Tests
    func testFetchHoldingsShowsAndHidesLoading() {
        // Given
        let mockHoldings = [
            StockHolding(symbol: "AAPL", quantity: 100, ltp: 150.0, averagePrice: 140.0, close: 145.0),
            StockHolding(symbol: "GOOGL", quantity: 50, ltp: 2800.0, averagePrice: 2750.0, close: 2780.0)
        ]
        mockNetworkDataSource.mockResponse = StockHoldingResponse(holdings: mockHoldings)
        mockCacheDataSource.isCacheValidValue = false // Force network fetch
        
        let expectation = XCTestExpectation(description: "Fetch holdings")
        
        // When
        viewModel.fetchHoldings()
        
        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertFalse(viewModel.threadSafeIsLoading)
        XCTAssertEqual(viewModel.holdings.count, 2)
    }
    
    func testForceRefreshShowsAndHidesLoading() {
        // Given
        let mockHoldings = [
            StockHolding(symbol: "TSLA", quantity: 75, ltp: 900.0, averagePrice: 850.0, close: 880.0)
        ]
        mockNetworkDataSource.mockResponse = StockHoldingResponse(holdings: mockHoldings)
        
        let expectation = XCTestExpectation(description: "Force refresh")
        
        // When
        viewModel.forceRefresh()
        
        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertFalse(viewModel.threadSafeIsLoading)
        XCTAssertEqual(viewModel.holdings.count, 1)
    }
    
    func testLoadingStateOnError() {
        // Given
        mockNetworkDataSource.shouldThrowError = true
        mockCacheDataSource.mockResponse = nil
        mockCacheDataSource.isCacheValidValue = false
        
        let expectation = XCTestExpectation(description: "Error handling")
        
        // When
        viewModel.fetchHoldings()
        
        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertNotNil(mockDelegate.errorEncountered)
        XCTAssertFalse(viewModel.threadSafeIsLoading)
    }
    
    func testPreventsConcurrentLoading() {
        // Given
        let mockHoldings = [
            StockHolding(symbol: "AAPL", quantity: 100, ltp: 150.0, averagePrice: 140.0, close: 145.0)
        ]
        mockNetworkDataSource.mockResponse = StockHoldingResponse(holdings: mockHoldings)
        mockCacheDataSource.isCacheValidValue = false
        
        let expectation = XCTestExpectation(description: "Concurrent loading")
        
        // When - Try to fetch twice in quick succession
        viewModel.fetchHoldings()
        viewModel.fetchHoldings() // This should be ignored
        
        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        
        // Then
        XCTAssertEqual(viewModel.holdings.count, 1)
        XCTAssertFalse(viewModel.threadSafeIsLoading)
    }
    
    // MARK: - Data Source Tests
    func testNetworkDataSourceDescription() {
        // Given
        let mockHoldings = [
            StockHolding(symbol: "AAPL", quantity: 100, ltp: 150.0, averagePrice: 140.0, close: 145.0)
        ]
        let holdingsResponse = StockHoldingResponse(holdings: mockHoldings)
        
        let expectation = XCTestExpectation(description: "Network data source")
        
        // Test Live Data
        mockNetworkDataSource.mockResponse = holdingsResponse
        mockCacheDataSource.isCacheValidValue = false
        
        viewModel.fetchHoldings()
        
        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(viewModel.dataSourceDescription, "Live Data")
    }
    
    func testCacheDataSourceDescription() {
        // Given
        let mockHoldings = [
            StockHolding(symbol: "AAPL", quantity: 100, ltp: 150.0, averagePrice: 140.0, close: 145.0)
        ]
        let holdingsResponse = StockHoldingResponse(holdings: mockHoldings)
        
        let expectation = XCTestExpectation(description: "Cache data source")
        
        // Test Cache Data
        mockCacheDataSource.mockResponse = holdingsResponse
        mockCacheDataSource.isCacheValidValue = true
        
        viewModel.fetchHoldings()
        
        // Wait for async operations to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertEqual(viewModel.dataSourceDescription, "Cached Data")
    }
    
    // MARK: - Cache Tests
    func testClearCache() {
        // When
        viewModel.clearCache()
        
        // Then
        XCTAssertNil(mockCacheDataSource.mockResponse)
    }
    
    // MARK: - UI State Tests
    func testToggleExpanded() {
        // Given
        XCTAssertFalse(viewModel.isExpanded)
        
        // When
        viewModel.toggleExpanded()
        
        // Then
        XCTAssertTrue(viewModel.isExpanded)
        
        // When
        viewModel.toggleExpanded()
        
        // Then
        XCTAssertFalse(viewModel.isExpanded)
    }
    
  
}

// MARK: - Mock Delegate
final class MockStockHoldingsViewModelDelegate: StockHoldingsViewModelDelegate {
    var updateStocksCallCount = 0
    var errorEncountered: Error?
    var startLoadingCallCount = 0
    var finishLoadingCallCount = 0
    
    func didUpdateStocks() {
        updateStocksCallCount += 1
    }
    
    func didEncounterError(_ error: Error) {
        errorEncountered = error
    }
    
    func didStartLoading() {
        startLoadingCallCount += 1
    }
    
    func didFinishLoading() {
        finishLoadingCallCount += 1
    }
} 


// MARK: - Mock Network Data Source
final class MockNetworkDataSource: NetworkDataSourceProtocol {
    var mockResponse: StockHoldingResponse?
    var shouldThrowError = false
    
    func fetchStockHoldings(completion: @escaping (Result<StockHoldingResponse, Error>) -> Void) {
        if shouldThrowError {
            completion(.failure(NSError(domain: "MockError", code: -1)))
            return
        }
        completion(.success(mockResponse ?? createDefaultResponse()))
    }
    
    private func createDefaultResponse() -> StockHoldingResponse {
        let holdings = [
            StockHolding(symbol: "AAPL", quantity: 100, ltp: 150.0, averagePrice: 140.0, close: 145.0)
        ]
        return StockHoldingResponse(holdings: holdings)
    }
}

// MARK: - Mock Cache Data Source
final class MockCacheDataSource: CacheDataSourceProtocol {
    var mockResponse: StockHoldingResponse?
    var isCacheValidValue = false
    
    func getCachedData() -> StockHoldingResponse? {
        return mockResponse
    }
    
    func cacheData(_ response: StockHoldingResponse) {
        mockResponse = response
    }
    
    func clearCache() {
        mockResponse = nil
    }
    
    func isCacheValid() -> Bool {
        return isCacheValidValue
    }
}
