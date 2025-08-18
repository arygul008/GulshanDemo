import Foundation

protocol StockHoldingsViewModelDelegate: AnyObject {
    func didUpdateStocks()
    func didEncounterError(_ error: Error)
    func didStartLoading()
    func didFinishLoading()
}

final class StockHoldingsViewModel {
    // MARK: - Dependencies
    private let repository: StockHoldingsRepositoryProtocol
    private let queue = DispatchQueue(label: "com.gulshan.stocksholding.viewmodel", qos: .userInitiated)
    private let loadingStateQueue = DispatchQueue(label: "com.gulshan.stocksholding.isLoading", qos: .userInitiated)
    
    // MARK: - State
    private(set) var holdings: [StockHolding] = []
    private(set) var isExpanded = false
    private(set) var currentDataSource: DataSource = .network
    private(set) var isDataStale = false
    
    private var _isLoading = false
    private(set) var threadSafeIsLoading : Bool {
        get {
            loadingStateQueue.sync { _isLoading }
        }
        set {
            loadingStateQueue.sync { _isLoading = newValue }
        }
    }
    weak var delegate: StockHoldingsViewModelDelegate?
    
    // MARK: - Computed Properties
    var totalCurrentValue: Double {
        holdings.reduce(0) { $0 + $1.currentValue }
    }
    
    var totalInvestment: Double {
        holdings.reduce(0) { $0 + $1.totalInvestment }
    }
    
    var totalPNL: Double {
        totalCurrentValue - totalInvestment
    }
    
    var todaysTotalPNL: Double {
        holdings.reduce(0) { $0 + $1.todaysPNL }
    }
    
    var dataSourceDescription: String {
        switch currentDataSource {
        case .network:
            return isDataStale ? "Live Data (Stale)" : "Live Data"
        case .cache:
            return isDataStale ? "Cached Data (Stale)" : "Cached Data"
        case .fallback:
            return "Demo Data"
        }
    }
    
    // MARK: - Initialization
    init(repository: StockHoldingsRepositoryProtocol = StockHoldingsRepositoryFactory.makeRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    func toggleExpanded() {
        isExpanded.toggle()
    }
    
    func fetchHoldings() {
        guard !threadSafeIsLoading else {
            logger.log("ViewModel: Fetch already in progress, ignoring duplicate request")
            return
        }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.setLoadingState(true)
            }
            
            self.repository.fetchStockHoldings { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let dataResponse):
                        self.updateState(with: dataResponse)
                        self.setLoadingState(false)
                        self.delegate?.didUpdateStocks()
                        logger.log("ViewModel: Data loaded from \(dataResponse.source)")
                        
                    case .failure(let error):
                        self.setLoadingState(false)
                        self.handleError(error)
                    }
                }
            }
        }
    }
    
    func forceRefresh() {
        guard !threadSafeIsLoading else {
            logger.log("ViewModel: Force refresh already in progress, ignoring duplicate request")
            return
        }
        
        queue.async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.setLoadingState(true)
            }
            
            self.repository.forceRefresh { [weak self] result in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    switch result {
                    case .success(let dataResponse):
                        self.updateState(with: dataResponse)
                        self.setLoadingState(false)
                        self.delegate?.didUpdateStocks()
                        logger.log("ViewModel: Force refresh completed from \(dataResponse.source)")
                        
                    case .failure(let error):
                        self.setLoadingState(false)
                        self.handleError(error)
                    }
                }
            }
        }
    }
    
    func clearCache() {
        repository.clearCache()
        logger.log("ViewModel: Cache cleared")
    }
    
    // MARK: - Private Helper Methods
    private func updateState(with dataResponse: DataResponse) {
        self.holdings = dataResponse.holdings.holdings
        self.currentDataSource = dataResponse.source
        self.isDataStale = dataResponse.isStale
    }
    
    private func setLoadingState(_ loading: Bool) {
        threadSafeIsLoading = loading
        if loading {
            delegate?.didStartLoading()
            logger.log("ViewModel: Loading started")
        } else {
            delegate?.didFinishLoading()
            logger.log("ViewModel: Loading finished")
        }
    }
    
    private func handleError(_ error: Error) {
        delegate?.didEncounterError(error)
        logger.log("ViewModel: Error occurred - \(error.localizedDescription)")
    }
} 
