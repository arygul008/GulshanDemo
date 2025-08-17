import UIKit

final class StockHoldingCell: UITableViewCell {
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quantityView: LabelValueView = {
        let view = LabelValueView()
        view.setTextAlignment(.left)
        return view
    }()
    
    private let ltpView: LabelValueView = {
        let view = LabelValueView()
        view.setTextAlignment(.right)
        return view
    }()
    
    private let pnlView: LabelValueView = {
        let view = LabelValueView()
        view.setTextAlignment(.right)
        return view
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        selectionStyle = .none
        
        [symbolLabel, quantityView, ltpView, pnlView, separatorView].forEach {
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            symbolLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            symbolLabel.trailingAnchor.constraint(lessThanOrEqualTo: ltpView.leadingAnchor, constant: -16),
            
            quantityView.leadingAnchor.constraint(equalTo: symbolLabel.leadingAnchor),
            quantityView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            quantityView.trailingAnchor.constraint(lessThanOrEqualTo: pnlView.leadingAnchor, constant: -16),
            
            ltpView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            ltpView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ltpView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            pnlView.trailingAnchor.constraint(equalTo: ltpView.trailingAnchor),
            pnlView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            pnlView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            // Separator constraints
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 2),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1.0)
        ])
    }
    
    func configure(with holding: StockHolding) {
        let viewModel = StockHoldingCellViewModel(stockHolding: holding)
        configure(with: viewModel)
    }
    
    /// Configure cell with presentation model
    /// View is now completely decoupled from business logic and formatting rules
    private func configure(with viewModel: StockHoldingCellViewModel) {
        symbolLabel.text = viewModel.symbol
        
        quantityView.configure(
            text: viewModel.quantityText,
            value: viewModel.quantityValue
        )
        
        ltpView.configure(
            text: viewModel.ltpText,
            value: viewModel.ltpValue
        )
        
        pnlView.configure(
            text: viewModel.pnlText,
            value: viewModel.pnlValue,
            valueColor: viewModel.pnlColor
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        quantityView.configure(text: "", value: "", valueColor: .label)
        ltpView.configure(text: "", value: "", valueColor: .label)
        pnlView.configure(text: "", value: "", valueColor: .label)
    }
} 
