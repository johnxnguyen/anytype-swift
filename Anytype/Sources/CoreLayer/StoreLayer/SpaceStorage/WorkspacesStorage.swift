import Foundation
import Combine
import Services

protocol WorkspacesStorageProtocol: AnyObject {
    var workspaces: [SpaceView] { get }
    var workspsacesPublisher: AnyPublisher<[SpaceView], Never> { get }
    func startSubscription() async
    func stopSubscription() async
}

final class WorkspacesStorage: WorkspacesStorageProtocol {
    
    // MARK: - DI
    
    private let subscriptionStorage: SubscriptionStorageProtocol
    private let subscriptionBuilder: WorkspacesSubscriptionBuilderProtocol
    
    // MARK: - State
    
    @Published private(set) var workspaces: [SpaceView] = []
    var workspsacesPublisher: AnyPublisher<[SpaceView], Never> { $workspaces.eraseToAnyPublisher() }
    
    init(subscriptionStorageProvider: SubscriptionStorageProviderProtocol, subscriptionBuilder: WorkspacesSubscriptionBuilderProtocol) {
        self.subscriptionStorage = subscriptionStorageProvider.createSubscriptionStorage(subId: subscriptionBuilder.subscriptionId)
        self.subscriptionBuilder = subscriptionBuilder
    }
    
    func startSubscription() async {
        let data = subscriptionBuilder.build()
        try? await subscriptionStorage.startOrUpdateSubscription(data: data) { [weak self] data in
            guard let self else { return }
            workspaces = data.items.map { SpaceView(details: $0) }
        }
    }
    
    func stopSubscription() async {
        try? await subscriptionStorage.stopSubscription()
    }
}