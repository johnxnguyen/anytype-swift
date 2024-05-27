import Foundation
import Services
import AnytypeCore
import UIKit

@MainActor
final class SlashMenuActionHandler {
    private let actionHandler: BlockActionHandlerProtocol
    private let router: EditorRouterProtocol
    private let document: BaseDocumentProtocol
    private let cursorManager: EditorCursorManager
    private weak var textView: UITextView?
    
    @Injected(\.pasteboardBlockDocumentService)
    private var pasteboardService: PasteboardBlockDocumentServiceProtocol
    
    
    init(
        document: BaseDocumentProtocol,
        actionHandler: BlockActionHandlerProtocol,
        router: EditorRouterProtocol,
        cursorManager: EditorCursorManager
    ) {
        self.document = document
        self.actionHandler = actionHandler
        self.router = router
        self.cursorManager = cursorManager
    }
    
    func handle(
        _ action: SlashAction,
        textView: UITextView?,
        blockInformation: BlockInformation,
        modifiedStringHandler: (SafeNSAttributedString) -> Void
    ) async throws {
        switch action {
        case let .actions(action):
            try await handleActions(action, textView: textView, blockId: blockInformation.id)
        case let .alignment(alignmnet):
            handleAlignment(alignmnet, blockIds: [blockInformation.id])
        case let .style(style):
            try await handleStyle(style, attributedString: textView?.attributedText.sendable(), blockInformation: blockInformation, modifiedStringHandler: modifiedStringHandler)
        case let .media(media):
            actionHandler.addBlock(media.blockViewsType, blockId: blockInformation.id, blockText: textView?.attributedText.sendable(), spaceId: document.spaceId)
        case let .objects(action):
            switch action {
            case .linkTo:
                router.showLinkTo { [weak self] details in
                    self?.actionHandler.addLink(targetDetails: details, blockId: blockInformation.id)
                }
            case .objectType(let object):
                let spaceId = document.spaceId
                AnytypeAnalytics.instance().logCreateLink(spaceId: spaceId)
                try await actionHandler
                    .createPage(
                        targetId: blockInformation.id,
                        spaceId: spaceId,
                        typeUniqueKey: object.uniqueKeyValue,
                        templateId: object.defaultTemplateId
                    )
                    .flatMap { objectId in
                        AnytypeAnalytics.instance().logCreateObject(objectType: object.analyticsType, spaceId: object.spaceId, route: .powertool)
                        router.showEditorScreen(data: editorScreenData(objectId: objectId, objectDetails: object))
                    }
            }
        case let .relations(action):
            switch action {
            case .newRealtion:
                router.showAddNewRelationView(document: document) { [weak self, spaceId = document.spaceId] relation, isNew in
                    self?.actionHandler.addBlock(.relation(key: relation.key), blockId: blockInformation.id, blockText: textView?.attributedText.sendable(), spaceId: spaceId)
                    
                    AnytypeAnalytics.instance().logAddExistingOrCreateRelation(format: relation.format, isNew: isNew, type: .block, spaceId: spaceId)
                }
            case .relation(let relation):
                actionHandler.addBlock(.relation(key: relation.key), blockId: blockInformation.id, blockText: textView?.attributedText.sendable(), spaceId: document.spaceId)
            }
        case let .other(other):
            switch other {
            case .table(let rowsCount, let columnsCount):
                guard let blockId = try? await actionHandler.createTable(
                    blockId: blockInformation.id,
                    rowsCount: rowsCount,
                    columnsCount: columnsCount,
                    blockText: textView?.attributedText.sendable(),
                    spaceId: document.spaceId
                ) else { return }
                
                cursorManager.blockFocus = BlockFocus(id: blockId, position: .beginning)
            default:
                actionHandler.addBlock(other.blockViewsType, blockId: blockInformation.id, blockText: textView?.attributedText.sendable(), spaceId: document.spaceId)
            }
        case let .color(color):
            actionHandler.setTextColor(color, blockIds: [blockInformation.id])
        case let .background(color):
            actionHandler.setBackgroundColor(color, blockIds: [blockInformation.id])
        }
    }
    
    private func editorScreenData(objectId: String, objectDetails: ObjectDetails) -> EditorScreenData {
        let objectType = ObjectType(details: objectDetails)
        if objectType.isListType {
            return .set(EditorSetObject(objectId: objectId, spaceId: objectType.spaceId))
        } else {
            return .page(EditorPageObject(objectId: objectId, spaceId: objectType.spaceId, isOpenedForPreview: false))
        }
    }
    
    private func handleAlignment(_ alignment: SlashActionAlignment, blockIds: [String]) {
        actionHandler.setAlignment(alignment.blockAlignment, blockIds: blockIds)
    }
    
    private func handleStyle(
        _ style: SlashActionStyle,
        attributedString: SafeNSAttributedString?,
        blockInformation: BlockInformation,
        modifiedStringHandler: (SafeNSAttributedString) -> Void
    ) async throws {
        switch style {
        case .text:
            try await actionHandler.turnInto(.text, blockId: blockInformation.id)
        case .title:
            try await actionHandler.turnInto(.header, blockId: blockInformation.id)
        case .heading:
            try await actionHandler.turnInto(.header2, blockId: blockInformation.id)
        case .subheading:
            try await actionHandler.turnInto(.header3, blockId: blockInformation.id)
        case .highlighted:
            try await actionHandler.turnInto(.quote, blockId: blockInformation.id)
        case .callout:
            try await actionHandler.turnInto(.callout, blockId: blockInformation.id)
        case .checkbox:
            try await actionHandler.turnInto(.checkbox, blockId: blockInformation.id)
        case .bulleted:
            try await actionHandler.turnInto(.bulleted, blockId: blockInformation.id)
        case .numberedList:
            try await actionHandler.turnInto(.numbered, blockId: blockInformation.id)
        case .toggle:
            try await actionHandler.turnInto(.toggle, blockId: blockInformation.id)
        case .bold:
            let modifiedAttributedString = try await actionHandler.toggleWholeBlockMarkup(
                attributedString,
                markup: .bold,
                info: blockInformation
            )
            
            modifiedAttributedString.map(modifiedStringHandler)
        case .italic:
            let modifiedAttributedString = try await actionHandler.toggleWholeBlockMarkup(
                attributedString,
                markup: .italic,
                info: blockInformation
            )
            
            modifiedAttributedString.map(modifiedStringHandler)
        case .strikethrough:
            let modifiedAttributedString = try await actionHandler.toggleWholeBlockMarkup(
                attributedString,
                markup: .strikethrough,
                info: blockInformation
            )
            
            modifiedAttributedString.map(modifiedStringHandler)
        case .underline:
            let modifiedAttributedString = try await actionHandler.toggleWholeBlockMarkup(
                attributedString,
                markup: .underscored,
                info: blockInformation
            )
            
            modifiedAttributedString.map(modifiedStringHandler)
        case .code:
            let modifiedAttributedString = try await actionHandler.toggleWholeBlockMarkup(
                attributedString,
                markup: .keyboard,
                info: blockInformation
            )
            
            modifiedAttributedString.map(modifiedStringHandler)
        case .link:
            break
        }
    }
    
    private func handleActions(_ action: BlockAction, textView: UITextView?, blockId: String) async throws {
        switch action {
        case .delete:
            actionHandler.delete(blockIds: [blockId])
        case .duplicate:
            actionHandler.duplicate(blockId: blockId, spaceId: document.spaceId)
        case .moveTo:
            router.showMoveTo { [weak self] details in
                self?.actionHandler.moveToPage(blockId: blockId, pageId: details.id)
            }
        case .copy:
            try await pasteboardService.copy(document: document, blocksIds: [blockId], selectedTextRange: NSRange())
        case .paste:
            textView?.paste(self)
        }
    }
}
