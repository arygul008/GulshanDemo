import UIKit
import Foundation

/// Presentation model for StockHoldingCell
/// Handles all formatting, color logic, and text composition
/// Follows Single Responsibility Principle - only concerned with presentation logic
struct StockHoldingCellViewModel {
    
    // MARK: - Properties
    private let stockHolding: StockHolding
    
    // MARK: - Initialization
    init(stockHolding: StockHolding) {
        self.stockHolding = stockHolding
    }
    
    // MARK: - Display Properties
    var symbol: String {
        return stockHolding.symbol
    }
    
    var quantityText: String {
        return "NET QTY:"
    }
    
    var quantityValue: String {
        return "\(stockHolding.quantity)"
    }
    
    var ltpText: String {
        return "LTP:"
    }
    
    var ltpValue: String {
        return CurrencyFormatter.format(amount: stockHolding.ltp)
    }
    
    var pnlText: String {
        return "P&L:"
    }
    
    var pnlValue: String {
        let pnl = stockHolding.pnl
        return CurrencyFormatter.formatPNL(amount: pnl)
    }
    
    var pnlColor: UIColor {
        return PNLColorProvider.color(for: stockHolding.pnl)
    }
}


/// Handles all currency formatting logic
/// Provides consistent formatting with proper error handling
internal enum CurrencyFormatter {
    static func format(amount: Double) -> String {
        guard amount.isFinite else {
            return "₹0.00" // Safe fallback for invalid numbers
        }
        return "₹\(String(format: "%.2f", amount))"
    }
    
    static func formatPNL(amount: Double) -> String {
        guard amount.isFinite else {
            return "₹0.00" // Safe fallback for invalid numbers
        }
        
        if amount >= 0 {
            return "₹\(String(format: "%.2f", amount))"
        } else {
            return "-₹\(String(format: "%.2f", abs(amount)))"
        }
    }
}

/// Handles color determination logic for P&L
enum PNLColorProvider {
    static func color(for pnl: Double) -> UIColor {
        return pnl >= 0 ? .systemGreen : .systemRed
    }
} 