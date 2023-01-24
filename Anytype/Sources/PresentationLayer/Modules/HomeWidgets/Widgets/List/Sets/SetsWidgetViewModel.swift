import Foundation
import BlocksModels
import Combine

@MainActor
final class SetsWidgetViewModel: ListWidgetViewModelProtocol, ObservableObject {
    
    private enum Constants {
        static let maxItems = 3
    }
    
    // MARK: - DI
    private let widgetBlockId: BlockId
    private let widgetObject: HomeWidgetsObjectProtocol
    private let setsSubscriptionService: SetsSubscriptionServiceProtocol
    private weak var output: CommonWidgetModuleOutput?
    
    // MARK: - State
    private var rowDetails: [ObjectDetails] = []
    
    @Published private(set) var name: String = Loc.sets
    @Published var isExpanded: Bool = true
    @Published private(set) var headerItems: [ListWidgetHeaderItem.Model] = []
    @Published private(set) var rows: [ListWidgetRow.Model] = []
    var minimimRowsCount: Int { Constants.maxItems }
    let count: String? = nil
    
    init(
        widgetBlockId: BlockId,
        widgetObject: HomeWidgetsObjectProtocol,
        setsSubscriptionService: SetsSubscriptionServiceProtocol,
        output: CommonWidgetModuleOutput?
    ) {
        self.widgetBlockId = widgetBlockId
        self.widgetObject = widgetObject
        self.setsSubscriptionService = setsSubscriptionService
        self.output = output
    }
    
    // MARK: - ListWidgetViewModelProtocol
    
    func onAppear() {
        setupAllSubscriptions()
    }

    func onDisappear() {
        setsSubscriptionService.stopSubscription()
    }
    
    func onDeleteWidgetTap() {
       // TODO: Add configuration for context menu
    }
    
    // MARK: - Private
    
    private func setupAllSubscriptions() {
        setsSubscriptionService.startSubscription(
            objectLimit: Constants.maxItems,
            update: { [weak self] _, update in
                self?.rowDetails.applySubscriptionUpdate(update)
                self?.updateViewState()
            }
        )
    }
    
    private func updateViewState() {
        rows = rowDetails.map { details in
            ListWidgetRow.Model(
                details: details,
                onTap: { [weak self] in
                    self?.output?.onObjectSelected(screenData: $0)
                }
            )
        }
    }
}
