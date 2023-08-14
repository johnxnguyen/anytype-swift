import Foundation
import Combine
import Services
import UIKit
import AnytypeCore

@MainActor
final class SpaceCreateViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    private let workspaceService: WorkspaceServiceProtocol
//    private let objectActionsService: ObjectActionsServiceProtocol
//    private let relationDetailsStorage: RelationDetailsStorageProtocol
//    private let dateFormatter = DateFormatter.relationDateFormatter
//    private weak var output: SpaceSettingsModuleOutput?
    
    // MARK: - State
    
//    private var subscriptions: [AnyCancellable] = []
//    private var dataLoaded: Bool = false
    
    @Published var spaceName: String = ""
    let spaceGradient: GradientId = .random
    var spaceIcon: Icon { .object(.space(.gradient(spaceGradient))) }
    @Published var spaceType: SpaceAccessibility = .private
    @Published var createLoadingState: Bool = false
    @Published var dismiss: Bool = false
    
    init(
        activeWorkspaceStorage: ActiveWorkpaceStorageProtocol,
        workspaceService: WorkspaceServiceProtocol
    ) {
        self.activeWorkspaceStorage = activeWorkspaceStorage
        self.workspaceService = workspaceService
    }
    
    func onTapCreate() {
        guard !createLoadingState else { return }
        Task {
            createLoadingState = true
            defer {
                createLoadingState = false
            }
            let spaceId = try await workspaceService.createWorkspace(name: spaceName, gradient: spaceGradient, accessibility: spaceType)
            try await activeWorkspaceStorage.setActiveSpace(spaceId: spaceId)
            dismiss.toggle()
        }
    }
}
