import Services
import Combine
import AnytypeCore
import Foundation

final class BaseDocument: BaseDocumentProtocol {
    
    // Init state
    let objectId: String
    let forPreview: Bool
    
    // From Containers
    var syncStatus: SyncStatus { statusStorage.status }
    var isLocked: Bool { infoContainer.get(id: objectId)?.isLocked ?? false }
    var details: ObjectDetails? { detailsStorage.get(id: objectId) }
    var objectRestrictions: ObjectRestrictions { restrictionsContainer.restrinctions }
    
    // Custom state
    private(set) var children = [BlockInformation]()
    private(set) var isOpened = false
    
    let infoContainer: InfoContainerProtocol = InfoContainer()
    let relationLinksStorage: RelationLinksStorageProtocol = RelationLinksStorage()
    let restrictionsContainer: ObjectRestrictionsContainer = ObjectRestrictionsContainer()
    let detailsStorage = ObjectDetailsStorage()
    
    private let objectLifecycleService: ObjectLifecycleServiceProtocol
    private let eventsListener: EventsListenerProtocol
    private let relationBuilder: RelationsBuilder
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let accountParticipantsStorage: AccountParticipantsStorageProtocol
    private let statusStorage: DocumentStatusStorageProtocol
    private let viewModelSetter: DocumentViewModelSetterProtocol
    
    private var participantIsEditor: Bool = false
    private var subscriptions = [AnyCancellable]()
    
    // Sync Handle
    var syncDocPublisher: AnyPublisher<[BaseDocumentUpdate], Never> {
        return syncSubject
            .merge(with: Just(isOpened ? [.general] : []))
            .filter { $0.isNotEmpty }
            .eraseToAnyPublisher()
    }
    private var syncSubject = PassthroughSubject<[BaseDocumentUpdate], Never>()
    
    // MARK: - State
    private var parsedRelationsSubject = CurrentValueSubject<ParsedRelations, Never>(.empty)
    var parsedRelationsPublisher: AnyPublisher<ParsedRelations, Never> {
        parsedRelationsSubject.eraseToAnyPublisher()
    }
    // All places, where parsedRelations used, should be subscribe on parsedRelationsPublisher.
    var parsedRelations: ParsedRelations {
        let objectRelationsDetails = relationDetailsStorage.relationsDetails(
            for: relationLinksStorage.relationLinks,
            spaceId: spaceId
        )
        let recommendedRelations = relationDetailsStorage.relationsDetails(for: details?.objectType.recommendedRelations ?? [], spaceId: spaceId)
        let typeRelationsDetails = recommendedRelations.filter { !objectRelationsDetails.contains($0) }
        return relationBuilder.parsedRelations(
            relationsDetails: objectRelationsDetails,
            typeRelationsDetails: typeRelationsDetails,
            objectId: objectId,
            relationValuesIsLocked: !permissions.canEditRelationValues,
            storage: detailsStorage
        )
    }
    
    var permissions: ObjectPermissions {
        ObjectPermissions(
            details: details ?? ObjectDetails(id: ""),
            isLocked: isLocked,
            participantCanEdit: participantIsEditor,
            objectRestrictions: objectRestrictions.objectRestriction
        )
    }
    
    var permissionsPublisher: AnyPublisher<ObjectPermissions, Never> {
        syncPublisher.compactMap {
            [weak self] in self?.permissions
        }
        .removeDuplicates()
        .receiveOnMain()
        .eraseToAnyPublisher()
    }
        
    init(
        objectId: String,
        forPreview: Bool,
        objectLifecycleService: ObjectLifecycleServiceProtocol,
        relationDetailsStorage: RelationDetailsStorageProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        accountParticipantsStorage: AccountParticipantsStorageProtocol,
        statusStorage: DocumentStatusStorageProtocol
    ) {
        self.objectId = objectId
        self.forPreview = forPreview
        
        self.eventsListener = EventsListener(
            objectId: objectId,
            infoContainer: infoContainer,
            relationLinksStorage: relationLinksStorage,
            restrictionsContainer: restrictionsContainer,
            detailsStorage: detailsStorage,
            statusStorage: statusStorage
        )
        
        self.viewModelSetter = DocumentViewModelSetter(
            detailsStorage: detailsStorage,
            relationLinksStorage: relationLinksStorage,
            restrictionsContainer: restrictionsContainer,
            infoContainer: infoContainer
        )
        
        self.objectLifecycleService = objectLifecycleService
        self.relationBuilder = RelationsBuilder()
        self.relationDetailsStorage = relationDetailsStorage
        self.objectTypeProvider = objectTypeProvider
        self.accountParticipantsStorage = accountParticipantsStorage
        self.statusStorage = statusStorage
        
        setup()
    }
    
    deinit {
        guard !forPreview, isOpened, UserDefaultsConfig.usersId.isNotEmpty else { return }
        Task.detached(priority: .userInitiated) { [objectLifecycleService, objectId] in
            try await objectLifecycleService.close(contextId: objectId)
        }
    }
    
    // MARK: - BaseDocumentProtocol
    
    var spaceId: String {
        details?.spaceId ?? ""
    }
    
    @MainActor
    func open() async throws {
        if isOpened {
            return
        }
        guard !forPreview else {
            anytypeAssertionFailure("Document created for preview. You should use openForPreview() method.")
            return
        }
        let model = try await objectLifecycleService.open(contextId: objectId)
        await setupView(model)
    }
    
    @MainActor
    func openForPreview() async throws {
        guard forPreview else {
            anytypeAssertionFailure("Document created for handling. You should use open() method.")
            return
        }
        let model = try await objectLifecycleService.openForPreview(contextId: objectId)
        await setupView(model)
    }
    
    @MainActor
    func close() async throws {
        guard !forPreview, isOpened, UserDefaultsConfig.usersId.isNotEmpty else { return }
        try await objectLifecycleService.close(contextId: objectId)
        isOpened = false
    }
    
    var isEmpty: Bool {
        let filteredBlocks = children.filter { $0.isFeaturedRelations || $0.isText }
        
        if filteredBlocks.count > 0 { return false }
        let allTextChilds = children.filter(\.isText)
        
        if allTextChilds.count > 1 { return false }
        
        return allTextChilds.first?.content.isEmpty ?? false
    }
    
    // MARK: - Private methods
    private func setup() {
        eventsListener.onUpdatesReceive = { [weak self] updates in
            DispatchQueue.main.async { [weak self] in
                self?.triggerSync(updates: updates)
            }
        }
        if !forPreview {
            eventsListener.startListening()
        }
    }
    
    private func reorderChilder() {
        guard let model = infoContainer.get(id: objectId) else {
            return
        }
        let flatten = model.flatChildrenTree(container: infoContainer)
        children = flatten
    }
    
    private func triggerSync(updates: [DocumentUpdate]) {
        
        if updates.contains(where: { $0 == .general || $0.isChildren }) {
            reorderChilder()
        }
        
        parsedRelationsSubject.send(parsedRelations)
        syncSubject.send(updates.flatMap(\.toBaseDocumentUpdate))
    }
    
    func subscibeFor(update: [BaseDocumentUpdate]) -> AnyPublisher<[BaseDocumentUpdate], Never> {
        return syncSubject
            .merge(with: Just(isOpened ? update : []))
            .map { syncUpdate in
                if syncUpdate.contains(.general) {
                    return update
                }
                return update.filter { syncUpdate.contains($0) }
            }
            .filter { $0.isNotEmpty }
            .eraseToAnyPublisher()
    }
    
    private func setupView(_ model: ObjectViewModel) async {
        viewModelSetter.objectViewUpdate(model)
        isOpened = true
        await setupSubscriptions()
        triggerSync(updates: [.general])
    }
    
    private func setupSubscriptions() async {
        await accountParticipantsStorage.canEditPublisher(spaceId: spaceId).sink { [weak self] canEdit in
            self?.participantIsEditor = canEdit
            self?.triggerSync(updates: [.general])
        }.store(in: &subscriptions)
    }
}
