import Foundation
import BlocksModels
import Combine
import AnytypeCore

private extension LoggerCategory {
    static let baseDocument: Self = "BaseDocument"
}

final class BaseDocument: BaseDocumentProtocol {
        
    var onUpdateReceive: ((BaseDocumentUpdateResult) -> Void)?
    
    private let blockActionsService = ServiceLocator.shared.blockActionsServiceSingle()
    var rootActiveModel: BlockModelProtocol? {
        rootModel.blocksContainer.model(id: objectId)
    }
    
    let objectId: BlockId

    let rootModel: RootBlockContainer
    let eventHandler: EventsListener
    
    /// Services
    private var smartblockService: BlockActionsServiceSingle = .init()
    
    init(objectId: BlockId) {
        self.objectId = objectId
        self.rootModel = RootBlockContainer(
            blocksContainer: BlockContainer(),
            detailsStorage: ObjectDetailsStorage()
        )
        
        self.eventHandler = EventsListener(
            objectId: objectId,
            container: self.rootModel
        )
        
        setup()
    }
    
    func setup() {
        eventHandler.onUpdateReceive = { [weak self] update in
            guard update.hasUpdate else { return }
            guard let self = self else { return }
    
            if
                let rootModel = self.rootModel.blocksContainer.model(id: self.objectId) {
                BlockFlattener.flattenIds(root: rootModel, in: self.rootModel, options: .default)
            }
            
            let details = self.rootModel.detailsStorage.get(id: self.objectId)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.onUpdateReceive?(
                    BaseDocumentUpdateResult(
                        updates: update,
                        details: details,
                        models: self.models(from: update)
                    )
                )
            }
        }
        eventHandler.startListening()
    }
    
    deinit {
        smartblockService.close(contextId: objectId, blockId: objectId)
    }

    // MARK: - BaseDocumentProtocol

    func open() {
        guard
            let result = blockActionsService.open(
                contextId: objectId,
                blockId: objectId
            )
        else { return }
        
        handleOpen(result)
        eventHandler.handle(
            events: PackOfEvents(objectId: objectId, middlewareEvents: result.messages)
        )
    }

    // MARK: - Handle Open
    
    private func handleOpen(_ serviceSuccess: ResponseEvent) {
        let blocks = eventHandler.handleBlockShow(
            events: .init(objectId: objectId, middlewareEvents: serviceSuccess.messages)
        )
        guard let event = blocks.first else { return }
        
        // Build blocks tree and create new container
        // And then, sync builders
        let rootId = serviceSuccess.contextID
        
        TreeBlockBuilder.buildBlocksTree(
            from: event.blocks,
            with: rootId,
            in: rootModel.blocksContainer
        )
        
        event.details.forEach {
            rootModel.detailsStorage.add(details: $0, id: $0.id)
        }
    }
    
    /// Returns a flatten list of active models of document.
    /// - Returns: A list of active models.
    private func getModels() -> [BlockModelProtocol] {
        guard
            let activeModel = rootModel.blocksContainer.model(id: objectId)
        else {
            AnytypeLogger.create(.baseDocument).debug("getModels. Our document is not ready yet")
            return []
        }
        return BlockFlattener.flatten(root: activeModel, in: rootModel, options: .default)
    }
    
    private func models(from updates: EventHandlerUpdate) -> [BlockModelProtocol] {
        switch updates {
        case .general:
            return getModels()
        case .details:
            return []
        case .update:
            return []
        }
    }

    // MARK: - Details
    /// Return configured details for provided id for listening events.
    ///
    /// Note.
    ///
    /// Provided `id` should be in `a list of details of opened document`.
    /// If you receive a error, assure yourself, that you've opened a document before accessing details.
    ///
    /// - Parameter id: Id of item for which we would like to listen events.
    /// - Returns: details active model.
    ///
    func getDetails(id: BlockId) -> ObjectDetails? {
        let value = rootModel.detailsStorage.get(id: id)
        if value.isNil {
            AnytypeLogger.create(.baseDocument)
                .debug("getDetails(by:). Our document is not ready yet")
        }
        return value
    }
    
    /// Convenient publisher for accessing default details properties by typed enum.
    /// - Returns: Publisher of default details properties.
    func pageDetailsPublisher() -> AnyPublisher<DetailsDataProtocol?, Never> {
        // TODO: - details. implement
        .empty()
    }

    // MARK: - Events
    
    /// Handle events initiated by user.
    ///
    /// - Parameter events: A pack of events.
    ///
    func handle(events: PackOfEvents) {
        eventHandler.handle(events: events)
    }
}
