import UIKit
import Combine
import Services
import AnytypeCore

final class ChangeTypeAccessoryViewModel {
    typealias TypeItem = HorizontalListItem

    @Published private(set) var isTypesViewVisible: Bool = false
    @Published private(set) var supportedTypes = [TypeItem]()
    var onDoneButtonTap: (() -> Void)?

    private var allSupportedTypes = [TypeItem]()
    private let router: EditorRouterProtocol
    private let handler: BlockActionHandlerProtocol
    private let searchService: SearchServiceProtocol
    private let objectService: ObjectActionsServiceProtocol
    private let document: BaseDocumentProtocol
    private lazy var searchItem = TypeItem.searchItem { [weak self] in self?.onSearchTap() }

    private var cancellables = [AnyCancellable]()

    init(
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        searchService: SearchServiceProtocol,
        objectService: ObjectActionsServiceProtocol,
        document: BaseDocumentProtocol
    ) {
        self.router = router
        self.handler = handler
        self.searchService = searchService
        self.objectService = objectService
        self.document = document

        fetchSupportedTypes()
        subscribeOnDocumentChanges()
    }

    func handleDoneButtonTap() {
        onDoneButtonTap?()
    }

    func toggleChangeTypeState() {
        isTypesViewVisible.toggle()
    }

    private func fetchSupportedTypes() {
        Task { @MainActor [weak self] in
            let supportedTypes = try? await self?.searchService
                .searchObjectTypes(
                    text: "",
                    filteringTypeId: nil,
                    shouldIncludeSets: true,
                    shouldIncludeCollections: true,
                    shouldIncludeBookmark: false,
                    spaceId: self?.document.spaceId ?? ""
                ).map { type in
                    TypeItem(from: type, handler: { [weak self] in
                        self?.onTypeTap(type: ObjectType(details: type))
                    })
                }
            
            supportedTypes.map { self?.allSupportedTypes = $0 }
        }
    }

    private func onTypeTap(type: ObjectType) {
        if type.recommendedLayout == .set {
            Task { @MainActor in
                document.resetSubscriptions() // to avoid glytch with premature document update
                try await handler.setObjectSetType()
                try await document.close()
                router.replaceCurrentPage(with: .set(.init(objectId: document.objectId, spaceId: document.spaceId, isSupportedForEdit: true)))
            }
            return
        }
        
        if type.recommendedLayout == .collection {
            Task { @MainActor in
                document.resetSubscriptions() // to avoid glytch with premature document update
                try await handler.setObjectCollectionType()
                try await document.close()
                router.replaceCurrentPage(with: .set(.init(objectId: document.objectId, spaceId: document.spaceId, isSupportedForEdit: true)))
            }
            return
        }

        Task { @MainActor in
            try await handler.setObjectTypeId(type.id)
            applyDefaultTemplateIfNeeded(typeId: type.id)
        }
    }
    
    private func applyDefaultTemplateIfNeeded(typeId: String) {
        Task { @MainActor in
            let availableTemplates = try? await searchService.searchTemplates(for: .dynamic(typeId), spaceId: document.spaceId)
            guard availableTemplates?.count == 1,
                  let firstTemplate = availableTemplates?.first
            else { return }
            
            try await objectService.applyTemplate(objectId: document.objectId, templateId: firstTemplate.id)
        }
    }

    private func subscribeOnDocumentChanges() {
        document.updatePublisher.sink { [weak self] _ in
            guard let self = self else { return }
            let filteredItems = self.allSupportedTypes.filter {
                $0.id != self.document.details?.type
            }
            self.supportedTypes = [self.searchItem] + filteredItems
        }.store(in: &cancellables)
    }
    
    private func onSearchTap() {
        router.showTypesForEmptyObject(
            selectedObjectId: document.details?.type,
            onSelect: { [weak self] type in
                self?.onTypeTap(type: type)
            }
        )
    }
}

extension ChangeTypeAccessoryViewModel: TypeListItemProvider {
    var typesPublisher: AnyPublisher<[HorizontalListItem], Never> {
        $supportedTypes.eraseToAnyPublisher()
    }
}
