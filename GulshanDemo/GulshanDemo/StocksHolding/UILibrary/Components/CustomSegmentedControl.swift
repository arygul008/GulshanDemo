import UIKit

// MARK: - Custom Segmented Control Delegate Protocol
protocol CustomSegmentedControlDelegate: AnyObject {
    func customSegmentedControl(_ control: CustomSegmentedControl, didSelectSegmentAt index: Int)
}

public struct CustomSegmentedControlConfiguration {
    let normalTextColor: UIColor
    let selectedTextColor: UIColor
    let selectedFont: UIFont
    let normalFont: UIFont
    let underlineColor: UIColor
    let separatorColor: UIColor
    let underlineExtraWidth: CGFloat
    let animationDuration: TimeInterval
    
    public static let `default` = CustomSegmentedControlConfiguration(
        normalTextColor: .darkGray,
        selectedTextColor: .black,
        selectedFont: .boldSystemFont(ofSize: 18),
        normalFont: .systemFont(ofSize: 16),
        underlineColor: .lightGray,
        separatorColor: .lightGray,
        underlineExtraWidth: 4.0,
        animationDuration: 0.3
    )
}

// we can make it more configurable by exposing properties. 
final class CustomSegmentedControl: UIView {
    
    // MARK: - Public Properties
    weak var delegate: CustomSegmentedControlDelegate?
    
    private(set) var selectedSegmentIndex: Int = 0 {
        didSet {
            updateSelection()
        }
    }
    
    private(set) var segmentTitles: [String] = []
    
    // MARK: - Private Properties
    private var configuration: CustomSegmentedControlConfiguration
    
    // MARK: - UI Components
    private lazy var segmentControl: UISegmentedControl = {
        let segment = UISegmentedControl()
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.backgroundColor = .clear
        segment.selectedSegmentTintColor = .clear
        
        // Remove corner radius and borders
        segment.layer.cornerRadius = 0
        segment.layer.borderWidth = 0
        segment.layer.borderColor = UIColor.clear.cgColor
        
        // Remove divider lines between segments
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segment.setDividerImage(UIImage(), forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
        segment.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .selected, barMetrics: .default)
        
        // Remove background images
        segment.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segment.setBackgroundImage(UIImage(), for: .selected, barMetrics: .default)
        
        // Add target for value changes
        segment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        
        return segment
    }()
    
    private lazy var underlineView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Constraints
    private var underlineLeadingConstraint: NSLayoutConstraint!
    private var underlineWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Initialization
    init(
        titles: [String],
        selectedIndex: Int = 0,
        configuration: CustomSegmentedControlConfiguration = .default
    ) {
        self.segmentTitles = titles
        self.selectedSegmentIndex = selectedIndex
        self.configuration = configuration
        
        super.init(frame: .zero)
        
        setupUI()
        configureSegments()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func selectSegment(at index: Int, animated: Bool = true) {
        guard index >= 0 && index < segmentTitles.count else { return }
        
        selectedSegmentIndex = index
        segmentControl.selectedSegmentIndex = index
        
        if animated {
            updateUnderlinePosition(for: index)
        } else {
            UIView.performWithoutAnimation {
                updateUnderlinePosition(for: index)
            }
        }
    }
    
    func updateConfiguration(_ newConfiguration: CustomSegmentedControlConfiguration) {
        self.configuration = newConfiguration
        applyConfiguration()
    }
    
    // MARK: - Private Setup Methods
    private func setupUI() {
        addSubview(segmentControl)
        addSubview(underlineView)
        addSubview(separatorView)
        
        // Setup underline constraints
        underlineLeadingConstraint = underlineView.leadingAnchor.constraint(equalTo: segmentControl.leadingAnchor)
        underlineWidthConstraint = underlineView.widthAnchor.constraint(equalToConstant: 100) // Initial value
        
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: topAnchor),
            segmentControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            segmentControl.heightAnchor.constraint(equalToConstant: 32),
            
            underlineView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 1),
            underlineLeadingConstraint,
            underlineWidthConstraint,
            underlineView.heightAnchor.constraint(equalToConstant: 1.0),
            
            separatorView.topAnchor.constraint(equalTo: underlineView.bottomAnchor, constant: 8),
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1.0),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        applyConfiguration()
    }
    
    private func configureSegments() {
        // Remove existing segments
        segmentControl.removeAllSegments()
        
        // Add new segments
        for (index, title) in segmentTitles.enumerated() {
            segmentControl.insertSegment(withTitle: title, at: index, animated: false)
        }
        
        // Set selected index
        segmentControl.selectedSegmentIndex = selectedSegmentIndex
        
        // Update text attributes
        updateSelection()
    }
    
    private func applyConfiguration() {
        // Apply colors
        underlineView.backgroundColor = configuration.underlineColor
        separatorView.backgroundColor = configuration.separatorColor
        
        // Apply text attributes
        segmentControl.setTitleTextAttributes([
            .foregroundColor: configuration.normalTextColor,
            .font: configuration.normalFont
        ], for: .normal)
        
        segmentControl.setTitleTextAttributes([
            .foregroundColor: configuration.selectedTextColor,
            .font: configuration.selectedFont
        ], for: .selected)
    }
    
    private func updateSelection() {
        // Update underline position after layout if needed
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.updateUnderlinePosition(for: self.selectedSegmentIndex)
        }
    }
    
    // MARK: - Underline Animation
    private func updateUnderlinePosition(for selectedIndex: Int) {
        // Ensure segment control has proper frame
        guard segmentControl.frame.width > 0 else {
            // If frame is not ready, schedule for next run loop
            DispatchQueue.main.async { [weak self] in
                self?.updateUnderlinePosition(for: selectedIndex)
            }
            return
        }
        
        let segmentWidth = segmentControl.frame.width / CGFloat(segmentControl.numberOfSegments)
        let segmentTitle = segmentControl.titleForSegment(at: selectedIndex) ?? ""
        
        // Calculate text width using the selected font
        let textSize = (segmentTitle as NSString).size(withAttributes: [.font: configuration.selectedFont])
        let underlineWidth = textSize.width + configuration.underlineExtraWidth
        
        // Calculate position to center the underline under the text
        let segmentCenterX = segmentWidth * CGFloat(selectedIndex) + segmentWidth / 2
        let underlineStartX = segmentCenterX - underlineWidth / 2
        
        underlineLeadingConstraint.constant = underlineStartX
        underlineWidthConstraint.constant = underlineWidth
        
        UIView.animate(withDuration: configuration.animationDuration) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
    
    // MARK: - Layout Override
    override func layoutSubviews() {
        super.layoutSubviews()
        // Position underline after layout is complete
        updateUnderlinePosition(for: selectedSegmentIndex)
    }
    
    // MARK: - Actions
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        updateUnderlinePosition(for: selectedSegmentIndex)
        delegate?.customSegmentedControl(self, didSelectSegmentAt: selectedSegmentIndex)
    }
}

// MARK: - Public Extension for Easy Configuration
extension CustomSegmentedControl {
    
    /// Creates a segment control with stock trading theme
    static func stockTradingStyle(titles: [String], selectedIndex: Int = 0) -> CustomSegmentedControl {
        let config = CustomSegmentedControlConfiguration(
            normalTextColor: .darkGray,
            selectedTextColor: .black,
            selectedFont: .boldSystemFont(ofSize: 18),
            normalFont: .systemFont(ofSize: 16),
            underlineColor: .lightGray,
            separatorColor: .lightGray,
            underlineExtraWidth: 16.0,
            animationDuration: 0.3
        )
        
        return CustomSegmentedControl(
            titles: titles,
            selectedIndex: selectedIndex,
            configuration: config
        )
    }
}

