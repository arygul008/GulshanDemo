import UIKit

// TODO: we should move all hard code integer values to constants file. 
// TODO: we can create wrapper over fonts and colors to make it more standardized. 
final class PortfolioSummaryView: UIView {
    private let expandIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.up")
        imageView.tintColor = .label
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // Current Value Row
    private let currentValueDescLabel: UILabel = {
        let label = UILabel()
        label.text = "Current value*"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let currentValueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Investment Row
    private let investmentDescLabel: UILabel = {
        let label = UILabel()
        label.text = "Total investment*"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let investmentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Today's PNL Row
    private let todaysPNLDescLabel: UILabel = {
        let label = UILabel()
        label.text = "Today's Profit & Loss*"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let todaysPNLLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Total PNL Row
    private let totalPNLDescLabel: UILabel = {
        let label = UILabel()
        label.text = "Profit & Loss*"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let totalPNLLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var isExpanded = false
    private var bottomConstraint: NSLayoutConstraint!
    private var expandedBottomConstraint: NSLayoutConstraint!
    private var totalPNLTopConstraintCollapsed: NSLayoutConstraint!
    private var totalPNLTopConstraintExpanded: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6
//        layer.cornerRadius = 8
//        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // Top left and top right corners only
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 0, height: -2)
//        layer.shadowRadius = 4
//        layer.shadowOpacity = 0.1
        
        [expandIndicator, currentValueDescLabel, currentValueLabel,
         investmentDescLabel, investmentLabel,
         todaysPNLDescLabel, todaysPNLLabel,
         separatorView, totalPNLDescLabel, totalPNLLabel].forEach { view in
            addSubview(view)
        }
        
        // Set up constraints
        bottomConstraint = totalPNLLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        expandedBottomConstraint = totalPNLLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        totalPNLTopConstraintCollapsed = totalPNLDescLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16)
        totalPNLTopConstraintExpanded = totalPNLDescLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 12)
        
        NSLayoutConstraint.activate([
            // Current Value Row
            currentValueDescLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            currentValueDescLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            currentValueDescLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            currentValueLabel.centerYAnchor.constraint(equalTo: currentValueDescLabel.centerYAnchor),
            currentValueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: currentValueDescLabel.trailingAnchor, constant: 8),
            currentValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Investment Row
            investmentDescLabel.topAnchor.constraint(equalTo: currentValueDescLabel.bottomAnchor, constant: 24),
            investmentDescLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            investmentDescLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            investmentLabel.centerYAnchor.constraint(equalTo: investmentDescLabel.centerYAnchor),
            investmentLabel.leadingAnchor.constraint(greaterThanOrEqualTo: investmentDescLabel.trailingAnchor, constant: 8),
            investmentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Today's PNL Row
            todaysPNLDescLabel.topAnchor.constraint(equalTo: investmentDescLabel.bottomAnchor, constant: 24),
            todaysPNLDescLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            todaysPNLDescLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            todaysPNLLabel.centerYAnchor.constraint(equalTo: todaysPNLDescLabel.centerYAnchor),
            todaysPNLLabel.leadingAnchor.constraint(greaterThanOrEqualTo: todaysPNLDescLabel.trailingAnchor, constant: 8),
            todaysPNLLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // Separator
            separatorView.topAnchor.constraint(equalTo: todaysPNLDescLabel.bottomAnchor, constant: 12),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1.0),
            
            // Total PNL Row
            totalPNLDescLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            expandIndicator.centerYAnchor.constraint(equalTo: totalPNLDescLabel.centerYAnchor),
            expandIndicator.leadingAnchor.constraint(equalTo: totalPNLDescLabel.trailingAnchor, constant: 8),
            expandIndicator.widthAnchor.constraint(equalToConstant: 20),
            expandIndicator.heightAnchor.constraint(equalToConstant: 20),
            
            totalPNLLabel.centerYAnchor.constraint(equalTo: totalPNLDescLabel.centerYAnchor),
            totalPNLLabel.leadingAnchor.constraint(greaterThanOrEqualTo: expandIndicator.trailingAnchor, constant: 8),
            totalPNLLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            bottomConstraint,
            totalPNLTopConstraintCollapsed
        ])
        
        setExpanded(false)
    }
    
    func setExpanded(_ isExpanded: Bool) {
        self.isExpanded = isExpanded
        
        // Hide/show description and value labels for expanded state
        currentValueDescLabel.isHidden = !isExpanded
        currentValueLabel.isHidden = !isExpanded
        investmentDescLabel.isHidden = !isExpanded
        investmentLabel.isHidden = !isExpanded
        todaysPNLDescLabel.isHidden = !isExpanded
        todaysPNLLabel.isHidden = !isExpanded
        separatorView.isHidden = !isExpanded
        
        // P&L labels and chevron are always visible
        totalPNLDescLabel.isHidden = false
        totalPNLLabel.isHidden = false
        
        // Switch constraints
        if isExpanded {
            bottomConstraint.isActive = false
            expandedBottomConstraint.isActive = true
            totalPNLTopConstraintCollapsed.isActive = false
            totalPNLTopConstraintExpanded.isActive = true
        } else {
            expandedBottomConstraint.isActive = false
            bottomConstraint.isActive = true
            totalPNLTopConstraintExpanded.isActive = false
            totalPNLTopConstraintCollapsed.isActive = true
        }
        
        UIView.animate(withDuration: 0.3) {
            self.expandIndicator.transform = isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
            self.superview?.layoutIfNeeded()
        }
    }
    
    func configure(currentValue: Double, totalInvestment: Double, totalPNL: Double, todaysPNL: Double) {
        let totalPNLPercentage = totalInvestment > 0 ? (totalPNL / totalInvestment) * 100 : 0
        
        // Configure expanded state values
        currentValueLabel.text = "₹\(String(format: "%.2f", currentValue))"
        
        investmentLabel.text = "₹\(String(format: "%.2f", totalInvestment))"
        
        todaysPNLLabel.text = "₹\(String(format: "%.2f", todaysPNL))"
        todaysPNLLabel.textColor = todaysPNL >= 0 ? .systemGreen : .systemRed
        
        // Configure total P&L (always visible)
        totalPNLLabel.text = "₹\(String(format: "%.2f", totalPNL)) (\(String(format: "%.2f", totalPNLPercentage))%)"
        totalPNLLabel.textColor = totalPNL >= 0 ? .systemGreen : .systemRed
    }
} 
