import UIKit

/// view with two labels in horizontal direction , different fonts. we can make it more configurable by exposing
/// font size and text color of each label. 
final class LabelValueView: UIView {
    
    // MARK: - UI Components
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Properties
    var textAlignment: NSTextAlignment = .left {
        didSet {
            textLabel.textAlignment = textAlignment
            valueLabel.textAlignment = textAlignment
        }
    }
    
    var valueTextColor: UIColor = .label {
        didSet {
            valueLabel.textColor = valueTextColor
        }
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        stackView.addArrangedSubview(textLabel)
        stackView.addArrangedSubview(valueLabel)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    func configure(text: String, value: String, valueColor: UIColor = .label) {
        textLabel.text = text
        valueLabel.text = value
        valueLabel.textColor = valueColor
    }
    
    func setTextAlignment(_ alignment: NSTextAlignment) {
        textAlignment = alignment
    }
} 
