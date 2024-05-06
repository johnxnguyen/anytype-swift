import Foundation
import Services
import SwiftUI
import AnytypeCore


@MainActor
final class TypeSearchForNewObjectCoordinatorViewModel: ObservableObject {
    @Published var shouldDismiss = false
    
    @Injected(\.pasteboardBlockService)
    private var pasteboardBlockService: PasteboardBlockServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: ObjectActionsServiceProtocol
    @Injected(\.blockService)
    private var blockService: BlockServiceProtocol
    @Injected(\.bookmarkService)
    private var bookmarkService: BookmarkServiceProtocol
    @Injected(\.activeWorkspaceStorage)
    private var activeWorkspaceStorage: ActiveWorkpaceStorageProtocol
    @Injected(\.objectTypeProvider)
    private var typeProvider: ObjectTypeProviderProtocol
    
    private let openObject: (ObjectDetails)->()
    
    init(openObject: @escaping (ObjectDetails)->()) {
        self.openObject = openObject
    }
    
    func typeSearchModule() -> ObjectTypeSearchView {
        ObjectTypeSearchView(
            title: Loc.createNewObject,
            spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
            settings: .newObjectCreation
        ) { [weak self] result in
            guard let self else { return }
            shouldDismiss = true
            
            switch result {
            case .objectType(let type):
                createAndShowNewObject(type: type, pasteContent: false)
            case .createFromPasteboard:
                switch pasteboardBlockService.pasteboardContent {
                case .none:
                    anytypeAssertionFailure("No content in Pasteboard")
                    break
                case .url(let url):
                    createAndShowNewBookmark(url: url)
                case .string:
                    fallthrough
                case .otherContent:
                    guard let type = try? typeProvider.defaultObjectType(spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId) else {
                        return
                    }
                    
                    createAndShowNewObject(type: type, pasteContent: true)
                }
            }
        }
    }
    
    private func createAndShowNewBookmark(url: AnytypeURL) {
        Task {
            let details = try await bookmarkService.createBookmarkObject(
                spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
                url: url,
                origin: .clipboard
            )
            
            AnytypeAnalytics.instance().logSelectObjectType(details.analyticsType, route: .clipboard)
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: .clipboard)

            openObject(details)
        }
    }
    
    
    private func createAndShowNewObject(
        type: ObjectType,
        pasteContent: Bool
    ) {
        Task {
            let details = try await objectActionsService.createObject(
                name: "",
                typeUniqueKey: type.uniqueKey,
                shouldDeleteEmptyObject: true,
                shouldSelectType: false,
                shouldSelectTemplate: true,
                spaceId: activeWorkspaceStorage.workspaceInfo.accountSpaceId,
                origin: .none,
                templateId: type.defaultTemplateId
            )
            
            AnytypeAnalytics.instance().logSelectObjectType(type.analyticsType, route: pasteContent ? .clipboard : .longTap)
            AnytypeAnalytics.instance().logCreateObject(objectType: details.analyticsType, spaceId: details.spaceId, route: pasteContent ? .clipboard : .navigation)
            
            if pasteContent && !type.isListType {
                try await objectActionsService.applyTemplate(objectId: details.id, templateId: type.defaultTemplateId)
                let blockId = try await blockService.addFirstBlock(contextId: details.id, info: .emptyText)
                
                pasteboardBlockService.pasteInsideBlock(
                    objectId: details.id,
                    spaceId: details.spaceId,
                    focusedBlockId: blockId,
                    range: .zero,
                    handleLongOperation: { },
                    completion: { _ in }
                )
            }

            openObject(details)
        }
    }
}
