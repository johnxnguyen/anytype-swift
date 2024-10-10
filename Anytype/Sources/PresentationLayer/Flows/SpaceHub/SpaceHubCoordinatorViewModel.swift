import SwiftUI
import DeepLinks
import Services
import Combine
import AnytypeCore


struct SpaceHubNavigationItem: Hashable { }

@MainActor
final class SpaceHubCoordinatorViewModel: ObservableObject {
    @Published var showSpaceManager = false
    @Published var showSpaceShareTip = false
    @Published var userWarningAlert: UserWarningAlert?
    @Published var typeSearchForObjectCreationSpaceId: StringIdentifiable?
    @Published var sharingSpaceId: StringIdentifiable?
    @Published var showSpaceSwitchData: SpaceSwitchModuleData?
    @Published var membershipTierId: IntIdentifiable?
    @Published var showGalleryImport: GalleryInstallationData?
    @Published var spaceJoinData: SpaceJoinModuleData?
    @Published var membershipNameFinalizationData: MembershipTier?
    @Published var showGlobalSearchData: GlobalSearchModuleData?
    @Published var showChangeSourceData: WidgetChangeSourceSearchModuleModel?
    @Published var showChangeTypeData: WidgetTypeChangeData?
    @Published var showCreateWidgetData: CreateWidgetCoordinatorModel?
    @Published var showSpaceSettingsData: AccountInfo?
    @Published var toastBarData = ToastBarData.empty
    
    @Published var currentSpaceId: String?
    var spaceInfo: AccountInfo? {
        guard let currentSpaceId else { return nil }
        return workspaceStorage.workspaceInfo(spaceId: currentSpaceId)
    }
    
    var fallbackSpaceId: String? {
        userDefaults.lastOpenedScreen?.spaceId ?? participantSpacesStorage.activeParticipantSpaces.first?.id
    }
    
    @Published var pathChanging: Bool = false
    @Published var navigationPath = HomePath(initalPath: [SpaceHubNavigationItem()])
    var pageNavigation: PageNavigation {
        PageNavigation(
            push: { [weak self] data in
                self?.pushSync(data: data)
            }, pop: { [weak self] in
                self?.navigationPath.pop()
            }, replace: { [weak self] data in
                guard let self else { return }
                if navigationPath.count > 1 {
                    navigationPath.replaceLast(data)
                } else {
                    navigationPath.push(data)
                }
            }
        )
    }

    var keyboardDismiss: (() -> ())?
    var dismissAllPresented: DismissAllPresented?
    
    let sceneId = UUID().uuidString
    
    @Injected(\.appActionStorage)
    private var appActionsStorage: AppActionStorage
    @Injected(\.accountManager)
    private var accountManager: any AccountManagerProtocol
    @Injected(\.spaceSetupManager)
    private var spaceSetupManager: any SpaceSetupManagerProtocol
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @Injected(\.legacySetObjectCreationCoordinator)
    private var setObjectCreationCoordinator: any SetObjectCreationCoordinatorProtocol
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    @Injected(\.workspaceStorage)
    private var workspaceStorage: any WorkspacesStorageProtocol
    @Injected(\.userDefaultsStorage)
    private var userDefaults: any UserDefaultsStorageProtocol
    @Injected(\.objectTypeProvider)
    private var typeProvider: any ObjectTypeProviderProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.defaultObjectCreationService)
    private var defaultObjectService: any DefaultObjectCreationServiceProtocol
    @Injected(\.loginStateService)
    private var loginStateService: any LoginStateServiceProtocol
    @Injected(\.participantSpacesStorage)
    private var participantSpacesStorage: any ParticipantSpacesStorageProtocol
    @Injected(\.userWarningAlertsHandler)
    private var userWarningAlertsHandler: any UserWarningAlertsHandlerProtocol
    
    private var membershipStatusSubscription: AnyCancellable?
    private var preveouslyOpenedSpaceId: String?
    
    init() {
        startSubscriptions()
    }
    
    func onManageSpacesSelected() {
        showSpaceManager = true
    }
    
    func onPathChange() {
        if let editorData = navigationPath.lastPathElement as? EditorScreenData {
            userDefaults.lastOpenedScreen = .editor(editorData)
        } else if let spaceInfo = navigationPath.lastPathElement as? AccountInfo {
            userDefaults.lastOpenedScreen = .widgets(spaceId: spaceInfo.accountSpaceId)
        } else {
            userDefaults.lastOpenedScreen = nil
        }
        
        if navigationPath.count == 1 {
            Task { try await activeSpaceManager.setActiveSpace(spaceId: nil) }
        }
    }
    
    // MARK: - Setup
    func setup() async {
        await spaceSetupManager.registerSpaceSetter(sceneId: sceneId, setter: activeSpaceManager)
        await setupInitialScreen()
        await handleVersionAlerts()
    }
    
    func setupInitialScreen() async {
        guard !loginStateService.isFirstLaunchAfterRegistration else { return }
        
        switch userDefaults.lastOpenedScreen {
        case .editor(let editorData):
            openObject(screenData: editorData)
        case .widgets(let spaceId):
            try? await spaceSetupManager.setActiveSpace(sceneId: sceneId, spaceId: spaceId)
        case .none:
            return
        }
    }
    
    func startHandleAppActions() async {
        for await action in appActionsStorage.$action.values {
            if let action {
                try? await handleAppAction(action: action)
                appActionsStorage.action = nil
            }
        }
    }
    
    func startHandleWorkspaceInfo() async {
        activeSpaceManager.startSubscription()
        for await info in activeSpaceManager.workspaceInfoPublisher.values {
            switchSpace(info: info)
        }
    }
    
    func handleVersionAlerts() async {
        if FeatureFlags.userWarningAlerts {
            userWarningAlert = userWarningAlertsHandler.getNextUserWarningAlertAndStoreIfNeeded()
        }
    }
    
    // MARK: - Private
    
    private func startSubscriptions() {
        membershipStatusSubscription = Container.shared
            .membershipStatusStorage.resolve()
            .statusPublisher.receiveOnMain()
            .sink { [weak self] membership in
                guard membership.status == .pendingRequiresFinalization else { return }
                
                self?.membershipNameFinalizationData = membership.tier
            }
    }

    func typeSearchForObjectCreationModule(spaceId: String) -> TypeSearchForNewObjectCoordinatorView {
        TypeSearchForNewObjectCoordinatorView(spaceId: spaceId) { [weak self] details in
            guard let self else { return }
            openObject(screenData: details.editorScreenData())
        }
    }
    
    // MARK: - Navigation
    private func openObject(screenData: EditorScreenData) {
        pushSync(data: screenData)
    }
    
    private func pushSync(data: EditorScreenData) {
        Task { try await push(data: data) }
    }
    
    private func push(data: EditorScreenData) async throws {
        if let objectId = data.objectId { // validate in case of object
            let document = documentsProvider.document(objectId: objectId, mode: .preview)
            try await document.open()
            guard let details = document.details else { return }
            guard details.isSupportedForEdit else {
                toastBarData = ToastBarData(
                    text: Loc.openTypeError(details.objectType.name), showSnackBar: true, messageType: .none
                )
                return
            }
        }
        
        let spaceId = data.spaceId
        if currentSpaceId != spaceId {
            // Check if space is deleted
            guard workspaceStorage.spaceView(spaceId: spaceId).isNotNil else { return }
           
            currentSpaceId = spaceId
            try await spaceSetupManager.setActiveSpace(sceneId: sceneId, spaceId: spaceId)
            currentSpaceId = spaceId
            
            if let spaceInfo {
                navigationPath = HomePath(initalPath: [SpaceHubNavigationItem(), spaceInfo, data])
            }
        } else {
            navigationPath.push(data)
        }
    }
    
    private func switchSpace(info: AccountInfo?) {
        Task {
            guard currentSpaceId != info?.accountSpaceId else { return }
            currentSpaceId = info?.accountSpaceId
            
            if userWarningAlert.isNil {
                await dismissAllPresented?()
            }
            
            if let info {
                let newPath = HomePath(initalPath: [SpaceHubNavigationItem(), info])
                navigationPath = newPath
                if #available(iOS 17.0, *) {
                    updateSpaceSwitchTip(spaceId: info.accountSpaceId)
                }
            } else {
                navigationPath.popToRoot()
            }
        }
    }
    
    @available(iOS 17.0, *)
    private func updateSpaceSwitchTip(spaceId: String) {
        guard preveouslyOpenedSpaceId != nil else {
            preveouslyOpenedSpaceId = spaceId
            return
        }
        
        if preveouslyOpenedSpaceId != spaceId {
            preveouslyOpenedSpaceId = spaceId
            SpaceSwitcherTip.numberOfSpaceSwitches += 1
        }
    }
    
    // MARK: - App Actions
    private func handleAppAction(action: AppAction) async throws {
        keyboardDismiss?()
        await dismissAllPresented?()
        switch action {
        case .createObjectFromQuickAction(let typeId):
            createAndShowNewObject(typeId: typeId, route: .homeScreen)
        case .deepLink(let deepLink):
            try await handleDeepLink(deepLink: deepLink)
        }
    }
        
    private func handleDeepLink(deepLink: DeepLink) async throws {
        switch deepLink {
        case .createObjectFromWidget:
            createAndShowDefaultObject(route: .widget)
        case .showSharingExtension:
            sharingSpaceId = fallbackSpaceId?.identifiable
        case .spaceSelection:
            showSpaceSwitchData = SpaceSwitchModuleData(activeSpaceId: spaceInfo?.accountSpaceId, sceneId: sceneId)
        case let .galleryImport(type, source):
            showGalleryImport = GalleryInstallationData(type: type, source: source)
        case .invite(let cid, let key):
            spaceJoinData = SpaceJoinModuleData(cid: cid, key: key, sceneId: sceneId)
        case .object(let objectId, _):
            let document = documentsProvider.document(objectId: objectId, mode: .preview)
            try await document.open()
            guard let editorData = document.details?.editorScreenData() else { return }
            try await push(data: editorData)
        case .spaceShareTip:
            showSpaceShareTip = true
        case .membership(let tierId):
            guard accountManager.account.isInProdOrStagingNetwork else { return }
            membershipTierId = tierId.identifiable
        }
    }

    // MARK: - Object creation
    private func createAndShowNewObject(
        typeId: String,
        route: AnalyticsEventsRouteKind
    ) {
        do {
            let type = try typeProvider.objectType(id: typeId)
            createAndShowNewObject(type: type, route: route)
        } catch {
            anytypeAssertionFailure("No object provided typeId", info: ["typeId": typeId])
            createAndShowDefaultObject(route: route)
        }
    }
    
    private func createAndShowNewObject(
        type: ObjectType,
        route: AnalyticsEventsRouteKind
    ) {
        guard let fallbackSpaceId else { return }
        
        Task {
            let details = try await objectActionsService.createObject(
                name: "",
                typeUniqueKey: type.uniqueKey,
                shouldDeleteEmptyObject: true,
                shouldSelectType: false,
                shouldSelectTemplate: true,
                spaceId: fallbackSpaceId,
                origin: .none,
                templateId: type.defaultTemplateId
            )
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: route)
            
            openObject(screenData: details.editorScreenData())
        }
    }
    
    
    private func createAndShowDefaultObject(route: AnalyticsEventsRouteKind) {
        guard let fallbackSpaceId else { return }
        
        Task {
            let details = try await defaultObjectService.createDefaultObject(name: "", shouldDeleteEmptyObject: true, spaceId: fallbackSpaceId)
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: route)
            openObject(screenData: details.editorScreenData())
        }
    }
}

extension SpaceHubCoordinatorViewModel: HomeWidgetsModuleOutput {
    func onCreateWidgetSelected(context: AnalyticsWidgetContext) {
        guard let spaceInfo else { return }
        
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            spaceId: spaceInfo.accountSpaceId,
            widgetObjectId: spaceInfo.widgetsId,
            position: .end,
            context: context
        )
    }
        
    func onObjectSelected(screenData: EditorScreenData) {
        openObject(screenData: screenData)
    }
    
    func onChangeSource(widgetId: String, context: AnalyticsWidgetContext) {
        guard let spaceInfo else { return }
        
        showChangeSourceData = WidgetChangeSourceSearchModuleModel(
            widgetObjectId: spaceInfo.widgetsId,
            spaceId: spaceInfo.accountSpaceId,
            widgetId: widgetId,
            context: context
        )
    }

    func onChangeWidgetType(widgetId: String, context: AnalyticsWidgetContext) {
        guard let spaceInfo else { return }
        
        showChangeTypeData = WidgetTypeChangeData(
            widgetObjectId: spaceInfo.widgetsId,
            widgetId: widgetId,
            context: context,
            onFinish: { [weak self] in
                self?.showChangeTypeData = nil
            }
        )
    }
    
    func onAddBelowWidget(widgetId: String, context: AnalyticsWidgetContext) {
        guard let spaceInfo else { return }
        
        showCreateWidgetData = CreateWidgetCoordinatorModel(
            spaceId: spaceInfo.accountSpaceId,
            widgetObjectId: spaceInfo.widgetsId,
            position: .below(widgetId: widgetId),
            context: context
        )
    }
    
    func onSpaceSelected() {
        showSpaceSettingsData = spaceInfo
    }
    
    func onCreateObjectInSetDocument(setDocument: some SetDocumentProtocol) {
        setObjectCreationCoordinator.startCreateObject(setDocument: setDocument, output: self, customAnalyticsRoute: .widget)
    }
    
    func onFinishChangeSource(screenData: EditorScreenData?) {
        showChangeSourceData = nil
        if let screenData {
            openObject(screenData: screenData)
        }
    }
    
    func onFinishCreateSource(screenData: EditorScreenData?) {
        if let screenData {
            openObject(screenData: screenData)
        }
    }
}

extension SpaceHubCoordinatorViewModel: SetObjectCreationCoordinatorOutput {   
    func showEditorScreen(data: EditorScreenData) {
        pushSync(data: data)
    }
}

extension SpaceHubCoordinatorViewModel: HomeBottomNavigationPanelModuleOutput {
    func onSearchSelected() {
        guard let spaceInfo else { return }
        
        showGlobalSearchData = GlobalSearchModuleData(
            spaceId: spaceInfo.accountSpaceId,
            onSelect: { [weak self] screenData in
                self?.openObject(screenData: screenData)
            }
        )
    }
    
    func onCreateObjectSelected(screenData: EditorScreenData) {
        UISelectionFeedbackGenerator().selectionChanged()
        openObject(screenData: screenData)
    }

    func onProfileSelected() {
        UISelectionFeedbackGenerator().selectionChanged()
        showSpaceSwitchData = SpaceSwitchModuleData(activeSpaceId: spaceInfo?.accountSpaceId, sceneId: sceneId)
    }

    func onHomeSelected() {
        guard !pathChanging else { return }
        navigationPath.popToRoot()
    }

    func onForwardSelected() {
        guard !pathChanging else { return }
        navigationPath.pushFromHistory()
    }

    func onBackwardSelected() {
        guard !pathChanging else { return }
        navigationPath.pop()
    }
    
    func onPickTypeForNewObjectSelected() {
        guard let spaceInfo else { return }
        
        UISelectionFeedbackGenerator().selectionChanged()
        typeSearchForObjectCreationSpaceId = spaceInfo.accountSpaceId.identifiable
    }
    
    func onSpaceHubSelected() {
        UISelectionFeedbackGenerator().selectionChanged()
        navigationPath.popToRoot()
    }
}
