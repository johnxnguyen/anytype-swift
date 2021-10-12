import Combine
import BlocksModels
import UIKit
import Amplitude
import AnytypeCore
import ProtobufMessages


extension LoggerCategory {
    static let blockActionService: Self = "blockActionService"
}

final class BlockActionService: BlockActionServiceProtocol {
    private var documentId: BlockId

    private var subscriptions: [AnyCancellable] = []
    private let singleService = ServiceLocator.shared.blockActionsServiceSingle()
    private let pageService = ObjectActionsService()
    private let textService = TextService()
    private let listService = BlockListService()
    private let bookmarkService = BookmarkService()
    private let fileService = BlockActionsServiceFile()

    private var didReceiveEvent: (PackOfEvents) -> () = { _  in }

    init(documentId: String) {
        self.documentId = documentId
    }
    
    /// Method to handle our events from outside of action service
    ///
    /// - Parameters:
    ///   - events: Event to handle
    func receivelocalEvents(_ events: [LocalEvent]) {
        didReceiveEvent(
            PackOfEvents(objectId: documentId, localEvents: events)
        )
    }

    func configured(documentId: String) -> Self {
        self.documentId = documentId
        return self
    }

    func configured(didReceiveEvent: @escaping (PackOfEvents) -> ()) {
        self.didReceiveEvent = didReceiveEvent
    }

    // MARK: Actions/Add

    func addChild(info: BlockInformation, parentBlockId: BlockId) {
        add(info: info, targetBlockId: parentBlockId, position: .inner, shouldSetFocusOnUpdate: true)
    }

    func add(info: BlockInformation, targetBlockId: BlockId, position: BlockPosition, shouldSetFocusOnUpdate: Bool) {
        guard let response = singleService
                .add(contextId: documentId, targetId: targetBlockId, info: info, position: position) else { return }
        
        let event = shouldSetFocusOnUpdate ? response.addEvent : response.defaultEvent
        didReceiveEvent(event)
    }

    func split(
        info: BlockInformation,
        oldText: String,
        newBlockContentType: BlockText.Style
    ) {
        let blockId = info.id
        // We are using old text as a cursor position.
        let position = oldText.count

        let content = info.content
        guard case let .text(blockText) = content else {
            anytypeAssertionFailure("We have unsupported content type: \(content)")
            return
        }

        let range = NSRange(location: position, length: 0)
        let documentId = self.documentId
        
        // if splitted block has child then new block should be child of splitted block
        let mode: Anytype_Rpc.Block.Split.Request.Mode = info.childrenIds.count > 0 ? .inner : .bottom

        guard textService.setText(
            contextId: documentId,
            blockId: blockId,
            middlewareString: MiddlewareString(text: blockText.text, marks: blockText.marks)
        ).isNotNil else { return }
            
        guard let splitSuccess = textService.split(
            contextId: documentId,
            blockId: blockId,
            range: range,
            style: newBlockContentType,
            mode: mode
        ) else { return }
            
        let allEvents = PackOfEvents(
            objectId: documentId,
            middlewareEvents: splitSuccess.responseEvent.messages,
            localEvents: [
                .setFocus(blockId: splitSuccess.blockId, position: .beginning)
            ]
       )
        didReceiveEvent(allEvents)
    }

    func duplicate(blockId: BlockId) {        
        singleService
            .duplicate(
                contextId: documentId,
                targetId: blockId,
                blockIds: [blockId],
                position: .bottom
            )
            .flatMap {
                didReceiveEvent(
                    PackOfEvents(objectId: documentId, middlewareEvents: $0.messages)
                )
            }
    }

    func createPage(position: BlockPosition) {
       guard let response = pageService.createPage(
            contextID: documentId,
            targetID: "",
            details: [.name: DetailsEntry(value: "")],
            position: position,
            templateID: ""
       ) else { return }
        
        Amplitude.instance().logEvent(AmplitudeEventsName.blockCreatePage)
        didReceiveEvent(
            PackOfEvents(objectId: documentId, middlewareEvents: response.messages)
        )
    }

    func turnInto(blockId: BlockId, type: BlockContentType, shouldSetFocusOnUpdate: Bool) {
        switch type {
        case .text(let style):
            setTextStyle(blockId: blockId, style: style, shouldFocus: shouldSetFocusOnUpdate)
        case .smartblock:
            anytypeAssertionFailure("Use turnIntoPage action instead")
            turnIntoPage(blockId: blockId)
        case .divider(let style): setDividerStyle(blockId: blockId, style: style)
        case .bookmark, .file, .layout, .link:
            anytypeAssertionFailure("TurnInto for that style is not implemented \(type)")
        }
    }
    
    func turnIntoPage(blockId: BlockId, completion: @escaping (BlockId?) -> () = { _ in }) {
        pageService.convertChildrenToPages(contextID: documentId, blocksIds: [blockId], objectType: "")
            .flatMap { completion($0.first) }
    }
    
    func checked(blockId: BlockId, newValue: Bool) {
        guard let response = textService.checked(contextId: documentId, blockId: blockId, newValue: newValue) else {
            return
        }
        didReceiveEvent(
            PackOfEvents(objectId: documentId, middlewareEvents: response.messages)
        )
    }
    
    func delete(blockId: BlockId, completion: @escaping (ResponseEvent) -> (PackOfEvents)) {
        guard
            let response = singleService.delete(
                contextId: documentId,
                blockIds: [blockId]
            )
        else {
            return
        }
        
        didReceiveEvent(completion(response))
    }
    
    func setFields(contextID: BlockId, blockFields: [BlockFields]) {
        guard let response = listService.setFields(contextId: contextID, fields: blockFields) else {
            return
        }
        didReceiveEvent(response.defaultEvent)
    }
}

private extension BlockActionService {

    func setDividerStyle(blockId: BlockId, style: BlockDivider.Style) {
        guard let response = listService.setDivStyle(contextId: documentId, blockIds: [blockId], style: style) else {
            return
        }
        didReceiveEvent(response.defaultEvent)
    }

    func setTextStyle(blockId: BlockId, style: BlockText.Style, shouldFocus: Bool) {
        guard let response = textService.setStyle(contextId: documentId, blockId: blockId, style: style) else {
            return
        }
        
        let events = shouldFocus ? response.turnIntoTextEvent : response.defaultEvent
        didReceiveEvent(events)
    }
}

// MARK: - Delete

extension BlockActionService {
    func merge(firstBlockId: BlockId, secondBlockId: BlockId, localEvents: [LocalEvent]) {
        guard let response = textService
                .merge(contextId: documentId, firstBlockId: firstBlockId, secondBlockId: secondBlockId) else {
                    return
                }
            
        let events = response.defaultEvent.enrichedWith(localEvents: localEvents)
        didReceiveEvent(events)
    }
}

// MARK: - BookmarkFetch

extension BlockActionService {
    func bookmarkFetch(blockId: BlockId, url: String) {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockBookmarkFetch)
        guard let response = bookmarkService.fetchBookmark(contextID: self.documentId, blockID: blockId, url: url) else {
            return
        }
        didReceiveEvent(response.defaultEvent)
    }
}

// MARK: - SetBackgroundColor

extension BlockActionService {
    func setBackgroundColor(blockId: BlockId, color: BlockBackgroundColor) {
        setBackgroundColor(blockId: blockId, color: color.middleware)
    }
    
    func setBackgroundColor(blockId: BlockId, color: MiddlewareColor) {
        guard let response = listService.setBackgroundColor(contextId: documentId, blockIds: [blockId], color: color) else {
            return
        }
        didReceiveEvent(response.defaultEvent)
    }
}

// MARK: - UploadFile

extension BlockActionService {
    func upload(blockId: BlockId, filePath: String) {
        fileService.asyncUploadDataAt(
            filePath: filePath,
            contextID: self.documentId,
            blockID: blockId
        )
            .sinkWithDefaultCompletion("fileService.uploadDataAtFilePath") { [weak self] serviceSuccess in
                self?.didReceiveEvent(serviceSuccess.defaultEvent)
        }.store(in: &self.subscriptions)
    }
}
