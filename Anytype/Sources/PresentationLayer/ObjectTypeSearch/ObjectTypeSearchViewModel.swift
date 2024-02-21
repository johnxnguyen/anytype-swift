import SwiftUI
import Services
import AnytypeCore


@MainActor
final class ObjectTypeSearchViewModel: ObservableObject {
    @Published var state = State.searchResults([])
    @Published var searchText = ""
    @Published var showPasteButton = false
    
    let showPins: Bool
    private let showLists: Bool
    private let showFiles: Bool
    private let allowPaste: Bool
    
    private let spaceId: String
    private let workspaceService: WorkspaceServiceProtocol
    private let typesService: TypesServiceProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    private let toastPresenter: ToastPresenterProtocol
    private let pasteboardHelper: PasteboardHelperProtocol
    
    private let onSelect: (TypeSelectionResult) -> Void
    private var searchTask: Task<(), any Error>?
    
    nonisolated init(
        showPins: Bool,
        showLists: Bool,
        showFiles: Bool,
        allowPaste: Bool,
        spaceId: String,
        workspaceService: WorkspaceServiceProtocol,
        typesService: TypesServiceProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        toastPresenter: ToastPresenterProtocol,
        pasteboardHelper: PasteboardHelperProtocol,
        onSelect: @escaping (TypeSelectionResult) -> Void
    ) {
        self.showPins = showPins
        self.showLists = showLists
        self.showFiles = showFiles
        self.allowPaste = allowPaste
        self.spaceId = spaceId
        self.workspaceService = workspaceService
        self.typesService = typesService
        self.objectTypeProvider = objectTypeProvider
        self.toastPresenter = toastPresenter
        self.onSelect = onSelect
        self.pasteboardHelper = pasteboardHelper
        
        pasteboardHelper.startSubscription { [weak self] in
            Task { [self] in
                await self?.updatePasteButton()
            }
        }
    }
    
    deinit {
        pasteboardHelper.stopSubscription()
    }
    
    func onAppear() {
        search(text: searchText)
        updatePasteButton()
    }
    
    func updatePasteButton() {
        withAnimation {
            showPasteButton = allowPaste && pasteboardHelper.hasStrings
        }
    }
    
    func search(text: String) {
        searchTask?.cancel()
        
        searchTask = Task {
            let pinnedTypes = showPins ? try await typesService.searchPinnedTypes(text: text, spaceId: spaceId) : []
            let listTypes = showLists ? try await typesService.searchListTypes(
                text: searchText, includePins: !showPins, spaceId: spaceId
            ) : []
            let objectTypes = try await typesService.searchObjectTypes(
                text: searchText,
                includePins: !showPins,
                includeLists: false,
                includeBookmark: true, 
                includeFiles: showFiles,
                spaceId: spaceId
            ).map { ObjectType(details: $0) }
            let libraryTypes = text.isNotEmpty ? try await typesService.searchLibraryObjectTypes(
                text: text, includeInstalledTypes: false, spaceId: spaceId
            ).map { ObjectType(details: $0) } : []
            let defaultType = try objectTypeProvider.defaultObjectType(spaceId: spaceId)
            
            let sectionData: [SectionData] = Array.builder {
                if pinnedTypes.isNotEmpty {
                    SectionData(
                        section: .pins,
                        types: buildTypeData(types: pinnedTypes, defaultType: defaultType)
                    )
                }
                if listTypes.isNotEmpty {
                    SectionData(
                        section: .lists,
                        types: buildTypeData(types: listTypes, defaultType: defaultType)
                    )
                }
                if objectTypes.isNotEmpty {
                    SectionData(
                        section: .objects,
                        types: buildTypeData(types: objectTypes, defaultType: defaultType)
                    )
                }
                if libraryTypes.isNotEmpty {
                    SectionData(
                        section: .library,
                        types: buildTypeData(types: libraryTypes, defaultType: defaultType)
                    )
                }
            }
            
            try Task.checkCancellation()
            
            withAnimation(.easeOut(duration: 0.2)) {
                if sectionData.isNotEmpty {
                    state = .searchResults(sectionData)
                } else {
                    state = .emptyScreen
                }
            }
        }
    }
    
    func didSelectType(_ type: ObjectType, section: SectionType) {
        Task {
            if section == .library {
                _ = try await workspaceService.installObject(spaceId: spaceId, objectId: type.id)
                toastPresenter.show(message: Loc.ObjectType.addedToLibrary(type.name))
            }
            
            onSelect(.object(type: type, content: nil))
        }
    }
    
    func createObjectFromClipboard() {
        Task {
            guard pasteboardHelper.numberOfItems != 0 else { return }
            
            if pasteboardHelper.numberOfItems > 1 {
                // TODO: Support multipaste
                return
            }
            
            if pasteboardHelper.hasValidURL, let url = pasteboardHelper.obtainString() {
                onSelect(.bookmark(url: url))
                return
            }
            
            if pasteboardHelper.hasStrings, let content = pasteboardHelper.obtainString() {
                
                let type = try objectTypeProvider.defaultObjectType(spaceId: spaceId)
                onSelect(.object(type: type, content: content))
                return
            }
            
            anytypeAssertionFailure(
                "Not supported clipboard content",
                info: [
                    "Items":pasteboardHelper.obtainAllItems().debugDescription
                ]
            )
        }
        
    }
    
    func createType(name: String) {
        Task {
            let type = try await typesService.createType(name: name, spaceId: spaceId)
            onSelect(.object(type: type, content: nil))
        }
    }
    
    func deleteType(_ type: ObjectType) {
        Task {
            try await typesService.deleteType(typeId: type.id, spaceId: spaceId)
            search(text: searchText)
        }
    }
    
    func setDefaultType(_ type: ObjectType) {
        objectTypeProvider.setDefaultObjectType(type: type, spaceId: spaceId)
        search(text: searchText)
    }
    
    func addPinedType(_ type: ObjectType) {
        do {
            try typesService.addPinedType(type, spaceId: spaceId)
            search(text: searchText)
        } catch { }
    }
    
    func removePinedType(_ type: ObjectType) {
        do {
            try typesService.removePinedType(typeId: type.id, spaceId: spaceId)
            search(text: searchText)
        } catch { }
    }
    
    // MARK: - Private
    private func buildTypeData(types: [ObjectType], defaultType: ObjectType) -> [ObjectTypeData] {
        return types.map { type in
            ObjectTypeData(
                type: type,
                isDefault: defaultType.id == type.id
            )
        }
    }
}
