import UIKit

// MARK: - UIViewController Alert Extension
extension UIViewController {
    
    /// AlertAction configuration for reusable alert creation
    struct AlertAction {
        let title: String
        let style: UIAlertAction.Style
        let handler: (() -> Void)?
        
        init(title: String, style: UIAlertAction.Style = .default, handler: (() -> Void)? = nil) {
            self.title = title
            self.style = style
            self.handler = handler
        }
    }
    
    /// Generic method to show alerts with configurable actions
    private func showAlert(
        title: String,
        message: String,
        actions: [AlertAction],
        includeCancelButton: Bool = true
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Add configured actions
        actions.forEach { alertAction in
            let action = UIAlertAction(title: alertAction.title, style: alertAction.style) { _ in
                alertAction.handler?()
            }
            alert.addAction(action)
        }
        
        // Add cancel button if needed
        if includeCancelButton {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        }
        
        present(alert, animated: true)
    }
    
    /// Shows a standard alert with retry action
    func showRetryAlert(
        title: String,
        message: String,
        retryAction: @escaping () -> Void
    ) {
        let actions = [AlertAction(title: "Retry", handler: retryAction)]
        showAlert(title: title, message: message, actions: actions)
    }
    
    /// Shows a simple alert with OK button
    func showSimpleAlert(title: String, message: String) {
        let actions = [AlertAction(title: "OK")]
        showAlert(title: title, message: message, actions: actions, includeCancelButton: false)
    }
    
    /// Shows an informational alert with custom action
    func showInfoAlert(
        title: String,
        message: String,
        actionTitle: String = "OK",
        action: (() -> Void)? = nil
    ) {
        let actions = [AlertAction(title: actionTitle, handler: action)]
        showAlert(title: title, message: message, actions: actions, includeCancelButton: false)
    }
} 
