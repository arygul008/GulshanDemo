import UIKit

final class StockHoldingsViewController: UIViewController {
    
    private let viewModel: StockHoldingsViewModel
    
    // MARK: - Status Bar Configuration
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent // White status bar content
    }
        
    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(StockHoldingCell.self, forCellReuseIdentifier: "StockHoldingCell")
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        
        // No pull-to-refresh
        
        return table
    }()
    
    private lazy var summaryView: PortfolioSummaryView = {
        let view = PortfolioSummaryView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(summaryTapped))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    private lazy var customSegmentControl: CustomSegmentedControl = {
        let control = CustomSegmentedControl.stockTradingStyle(
            titles: ["POSITIONS", "HOLDINGS"],
            selectedIndex: 1
        )
        control.translatesAutoresizingMaskIntoConstraints = false
        control.delegate = self
        return control
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var portfolioSummaryBottonConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    init(viewModel: StockHoldingsViewModel = StockHoldingsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.fetchHoldings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .systemGray6
        updatePortfolioSummaryViewBottom()
        
        // Configure navigation bar here to ensure navigation controller is available
        configureNavigationBar()
        
        // Ensure status bar style is applied
        setNeedsStatusBarAppearanceUpdate()
        
        // Ensure navigation bar is visible
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        // Force status bar background color
        //setupStatusBarBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        // Apply status bar background again after view appears
        setupStatusBarBackground()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clean up status bar background views when leaving
        view.window?.subviews.filter { $0.tag == 9999 }.forEach { $0.removeFromSuperview() }
        navigationController?.view.subviews.filter { $0.tag == 9999 }.forEach { $0.removeFromSuperview() }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Add UI components
        view.addSubview(customSegmentControl)
        view.addSubview(tableView)
        view.addSubview(summaryView)
        view.addSubview(activityIndicator)
        
        portfolioSummaryBottonConstraint = summaryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            customSegmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            customSegmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 2),
            customSegmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: customSegmentControl.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: summaryView.topAnchor),
            
            summaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            summaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Center activity indicator
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        portfolioSummaryBottonConstraint?.isActive = true
        //updatePortfolioSummaryViewBottom()
    }
    
    private func configureNavigationBar() {
        // Left bar button - Profile icon
        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.circle")?.withRenderingMode(.alwaysTemplate),
            style: .plain,
            target: self,
            action: #selector(profileTapped)
        )
        
        // Left-aligned title as a bar button item
        let titleLabel = UILabel()
        titleLabel.text = "Portfolio"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .white
        let titleButton = UIBarButtonItem(customView: titleLabel)
        
        navigationItem.leftBarButtonItems = [profileButton, titleButton]
        
        // Right bar button - Search icon  
        let searchButton = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass")?.withRenderingMode(.alwaysTemplate),
            style: .plain,
            target: self,
            action: #selector(searchTapped)
        )
        navigationItem.rightBarButtonItem = searchButton
        
        // Configure navigation bar appearance (only if navigation controller is available)
        guard let navigationController = navigationController else { 
            logger.log("Warning: Navigation controller not available yet. Navigation bar appearance will be applied when available.")
            return 
        }
        
        let navBarColor = UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0) // Dark blue
        
        // Create appearance for different states
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = navBarColor
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        
        // Apply appearance to all navigation bar states
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        
        // Critical: Configure navigation bar to extend behind status bar
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = navBarColor
        navigationController.navigationBar.backgroundColor = navBarColor
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.prefersLargeTitles = false
        
        // Force the view to extend under the status bar
        navigationController.edgesForExtendedLayout = [.top]
        navigationController.extendedLayoutIncludesOpaqueBars = true
        
        // Ensure the navigation controller's view background matches
        navigationController.view.backgroundColor = navBarColor
        
        // Remove any existing status bar view first
        navigationController.view.subviews.filter { $0.tag == 9999 }.forEach { $0.removeFromSuperview() }
    }
    
    // TODO: we should make nav bar reusable across all view controllers. 
    private func setupStatusBarBackground() {
        let navBarColor = UIColor(red: 0.2, green: 0.3, blue: 0.5, alpha: 1.0)
        
        // Remove any existing status bar backgrounds
        view.window?.subviews.filter { $0.tag == 9999 }.forEach { $0.removeFromSuperview() }
        navigationController?.view.subviews.filter { $0.tag == 9999 }.forEach { $0.removeFromSuperview() }
        
        guard let window = view.window else {
            logger.log("Could not get window")
            return
        }
        
        // Get safe area insets to calculate status bar height correctly
        let safeAreaInsets = window.safeAreaInsets
        let statusBarHeight = safeAreaInsets.top
        
        // Create a frame that covers the entire top area including status bar
        let statusBarFrame = CGRect(
            x: 0, 
            y: 0, 
            width: window.bounds.width, 
            height: statusBarHeight
        )
        
        logger.log("Status bar height: \(statusBarHeight), frame: \(statusBarFrame)")
        
        // Create status bar background view
        let statusBarBackgroundView = UIView(frame: statusBarFrame)
        statusBarBackgroundView.backgroundColor = navBarColor
        statusBarBackgroundView.tag = 9999
        statusBarBackgroundView.isUserInteractionEnabled = false
        statusBarBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        
        window.addSubview(statusBarBackgroundView)
        window.bringSubviewToFront(statusBarBackgroundView)
        logger.log("Added status bar background view to window with height: \(statusBarHeight)")
    }
        
    // MARK: - Actions
    @objc private func summaryTapped() {
        logger.log("Summary tapped! Current expanded state: \(viewModel.isExpanded)")
        viewModel.toggleExpanded()
        logger.log("New expanded state: \(viewModel.isExpanded)")
        
        UIView.animate(
            withDuration: 0.6,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5,
            options: [.curveEaseInOut],
            animations: {
                self.summaryView.setExpanded(self.viewModel.isExpanded)
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    @objc private func forceRefresh() {
        viewModel.forceRefresh()
    }
    
    @objc private func searchTapped() {
        showInfoAlert(
            title: "Search",
            message: "Search will be implemented here"
        )
    }
    
    @objc private func profileTapped() {
        showInfoAlert(
            title: "Profile",
            message: "Profile functionality will be implemented here"
        )
    }
    
    // MARK: - Helper Methods
    private func updateUI() {
        summaryView.configure(
            currentValue: viewModel.totalCurrentValue,
            totalInvestment: viewModel.totalInvestment,
            totalPNL: viewModel.totalPNL,
            todaysPNL: viewModel.todaysTotalPNL
        )
        tableView.reloadData()
    }
    
    private func updatePortfolioSummaryViewBottom() {
//        let hasNotch = view.safeAreaInsets.bottom > 0
//        portfolioSummaryBottonConstraint?.constant = hasNotch ? -16 : 0
//        view.layoutIfNeeded()
    }
}

// MARK: - UITableViewDataSource
extension StockHoldingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.holdings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StockHoldingCell", for: indexPath) as? StockHoldingCell else {
            return UITableViewCell()
        }
        
        let holding = viewModel.holdings[indexPath.row]
        cell.configure(with: holding)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension StockHoldingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

// MARK: - StockHoldingsViewModelDelegate
extension StockHoldingsViewController: StockHoldingsViewModelDelegate {
    
    func didStartLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.startAnimating()
        }
    }
    
    func didFinishLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
    
    func didUpdateStocks() {
        updateUI()
    }
    
    func didEncounterError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.showRetryAlert(
                title: "Unable to Load Data",
                message: "Please check your internet connection and try again.",
                retryAction: { [weak self] in
                    self?.viewModel.fetchHoldings()
                }
            )
        }
    }
} 

// MARK: - CustomSegmentedControlDelegate
extension StockHoldingsViewController: CustomSegmentedControlDelegate {
    func customSegmentedControl(_ control: CustomSegmentedControl, didSelectSegmentAt index: Int) {
        // Handle segment selection if needed
        // For now, this is just for UI feedback - the actual functionality would be implemented here
        logger.log("Segment selected at index: \(index)")
    }
}
