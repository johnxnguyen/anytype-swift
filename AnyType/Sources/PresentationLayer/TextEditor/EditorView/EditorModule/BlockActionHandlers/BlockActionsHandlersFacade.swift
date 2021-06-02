import Combine
import BlocksModels
import os


private extension LoggerCategory {
    static let blockActionsHandlersFacade: Self = "BlockActionsHandlersFacade"
}

/// Interaction with document view
protocol DocumentViewInteraction: AnyObject {
    /// Update blocks by ids
    /// - Parameter ids: blocks ids
    func updateBlocks(with ids: Set<BlockId>)
}

final class BlockActionsHandlersFacade {
    typealias ActionsPayload = BaseBlockViewModel.ActionsPayload
    // TODO: remove when possible
//    typealias ActionsPayloadToolbar = BlocksViews.Toolbar.UnderlyingAction

    private var subscription: AnyCancellable?
    private let service: BlockActionService = .init(documentId: "")
    private var documentId: String = ""
    private var indexWalker: LinearIndexWalker?
    private weak var documentViewInteraction: DocumentViewInteraction?
    
    private lazy var textBlockActionHandler: TextBlockActionHandler = .init(contextId: self.documentId, service: service, indexWalker: indexWalker)
    private lazy var toolbarBlockActionHandler: ToolbarBlockActionHandler = .init(service: service, indexWalker: indexWalker)
    private lazy var marksPaneBlockActionHandler: MarksPaneBlockActionHandler = .init(documentViewInteraction: self.documentViewInteraction,
                                                                                      service: service,
                                                                                      contextId: self.documentId,
                                                                                      subject: reactionSubject)
    private lazy var buttonBlockActionHandler: ButtonBlockActionHandler = .init(service: service)
    private lazy var userActionHandler: UserActionHandler = .init(service: service)

    private let reactionSubject: PassthroughSubject<BlockActionService.Reaction?, Never> = .init()
    private(set) var reactionPublisher: AnyPublisher<BlockActionService.Reaction, Never> = .empty()

    init(documentViewInteraction: DocumentViewInteraction) {
        self.documentViewInteraction = documentViewInteraction
        self.setup()
    }

    func setup() {
        self.reactionPublisher = self.reactionSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
        // config block action service with completion that send value to subscriber (EditorModule.Document.ViewController.ViewModel)
        _ = self.service.configured { [weak self] (actionType, value) in
            self?.reactionSubject.send(.shouldHandleEvent(.init(actionType: actionType, events: value)))
        }
    }

    /// Attaches subscriber to base blocks views (BlocksViews.Base) publisher
    /// - Parameter publisher: Publisher that send action from block view to this handler
    /// - Returns: self
    func configured(_ publisher: AnyPublisher<ActionsPayload, Never>) -> Self {
        self.subscription = publisher
            .sink { [weak self] (value) in
            self?.didReceiveAction(action: value)
        }
        return self
    }

    func configured(documentId: String) -> Self {
        self.documentId = documentId
        _ = self.service.configured(documentId: documentId)
        return self
    }

    func configured(_ model: DocumentEditorViewModel) -> Self {
        self.indexWalker = .init(DocumentModelListProvider.init(model: model))
        return self
    }

    func didReceiveAction(action: ActionsPayload) {
        switch action {
        case let .toolbar(value): self.toolbarBlockActionHandler.handlingToolbarAction(value.model, value.action)
        case let .marksPane(value): self.marksPaneBlockActionHandler.handlingMarksPaneAction(value.model, value.action)
        case let .textView(value):
            switch value.action {
            case let .textView(action): textBlockActionHandler.handlingTextViewAction(value.model, action)
            case let .buttonView(action):
                self.buttonBlockActionHandler.handlingButtonViewAction(value.model, action)
            }
        case let .userAction(value): self.userActionHandler.handlingUserAction(value.model, value.action)
        case .showCodeLanguageView: return
        case .showStyleMenu: return
        case .becomeFirstResponder: return
        }
    }
}

// MARK: TODO - Move to enum or wrap in another protocol
extension BlockActionsHandlersFacade {
    func createEmptyBlock(listIsEmpty: Bool, parentModel: BlockActiveRecordModelProtocol?) {
        if listIsEmpty {
            if let defaultBlock = BlockBuilder.createDefaultInformation() {
                self.service.addChild(childBlock: defaultBlock, parentBlockId: self.documentId)
            }
        }
        else {
            // Unknown for now.
            // Check that previous ( last block ) is not nil.
            // We must provide a smartblock of page to solve it.
            //
            guard let parentModel = parentModel else {
                // We don't have parentModel, so, we can't proceed.
                assertionFailure("createEmptyBlock.listIsEmpty. We don't have parent model.")
                return
            }
            guard let lastChildId = parentModel.childrenIds().last else {
                // We don't have children, let's do nothing.
                assertionFailure("createEmptyBlock.listIsEmpty. Children are empty.")
                return
            }
            guard let lastChild = parentModel.container?.choose(by: lastChildId) else {
                // No child - nothing to do.
                assertionFailure("createEmptyBlock.listIsEmpty. Last child doesn't exist.")
                return
            }

            switch lastChild.content {
            case let .text(value) where value.attributedText.length == 0:
                // TODO: Add assertionFailure for debug when all converters will be added
                // TASK: https://app.clickup.com/t/h138gt
                Logger.create(.blockActionsHandlersFacade).error("createEmptyBlock.listIsEmpty. Last block is text and it is empty. Skipping..")
//                assertionFailure("createEmptyBlock.listIsEmpty. Last block is text and it is empty. Skipping..")
                return
            default:
                if let defaultBlock = BlockBuilder.createDefaultInformation() {
                    self.service.addChild(childBlock: defaultBlock, parentBlockId: self.documentId)
                }
            }
        }
    }
}

// MARK: - LinearIndexWalker

final class LinearIndexWalker {
    typealias Model = BlockActiveRecordModelProtocol

    private var models: [Model] = []
    var listModelsProvider: UserInteractionHandlerListModelsProvider

    init(_ listModelsProvider: UserInteractionHandlerListModelsProvider) {
        self.listModelsProvider = listModelsProvider
    }

    private func configured(models: [Model]) {
        self.models = models
    }

    private func configured(listModelsProvider: UserInteractionHandlerListModelsProvider) {
        self.listModelsProvider = listModelsProvider
    }

    func renew() {
        self.configured(models: self.listModelsProvider.getModels)
    }
}

// MARK: Search
extension LinearIndexWalker {
    func model(beforeModel model: Model, includeParent: Bool, onlyFocused: Bool = true) -> Model? {
        /// Do we actually need parent?
        guard let modelIndex = self.models.firstIndex(where: { $0.blockId == model.blockId }) else { return nil }

        /// Iterate back
        /// Actually, `index(before:)` doesn't respect indices of collection.
        /// Consider
        ///
        /// let a: [Int] = []
        /// a.startIndex // 0
        /// a.index(before: a.startIndex) // -1
        ///
        let index = self.models.index(before: modelIndex)
        let startIndex = self.models.startIndex
        
        /// TODO:
        /// Look at documentation how we should handle different blocks types.
        if index >= startIndex {
            let object = self.models[index]
            switch object.content {
            case .text: return object
            default: return nil
            }
        }

        return nil
    }
}

// MARK: - DocumentModelListProvider

// MARK: ListModelsProvider
protocol UserInteractionHandlerListModelsProvider {
    var getModels: [BlockActiveRecordModelProtocol] {get}
}

struct DocumentModelListProvider: UserInteractionHandlerListModelsProvider {
    private weak var model: DocumentEditorViewModel?
    private var _models: [BlockActiveRecordModelProtocol] = [] // Do we need cache?

    init(model: DocumentEditorViewModel) {
        self.model = model
    }

    var getModels: [BlockActiveRecordModelProtocol] {
        self.model?.builders.compactMap { $0.getBlock() } ?? []
    }
}

// MARK: - BlockBuilder

/// This class should be moved to Middleware.
/// We don't care about business logic on THIS level.
struct BlockBuilder {
    typealias KeyboardAction = BlockTextView.UserAction.KeyboardAction

    static func newBlockId() -> BlockId { "" }

    static func createInformation(block: BlockActiveRecordModelProtocol, action: KeyboardAction, textPayload: String) -> BlockInformation? {
        switch block.content {
        case .text:
            return self.createContentType(block: block, action: action, textPayload: textPayload).flatMap({(newBlockId(), $0)}).map(TopLevelBlockBuilder.shared.informationBuilder.build)
        default: return nil
        }
    }

    static func createInformation(block: BlockActiveRecordModelProtocol, action: BlocksViews.Toolbar.UnderlyingAction, textPayload: String = "") -> BlockInformation? {
        switch action {
        case .addBlock:
            return self.createContentType(block: block, action: action, textPayload: textPayload)
                .flatMap { (newBlockId(), $0) }
                .map(TopLevelBlockBuilder.shared.informationBuilder.build)
        default: return nil
        }
    }

    static func createDefaultInformation(block: BlockActiveRecordModelProtocol? = nil) -> BlockInformation? {
        guard let block = block else {
            return TopLevelBlockBuilder.shared.informationBuilder.build(id: newBlockId(), content: .text(.empty()))
        }
        switch block.content {
        case let .text(value):
            switch value.contentType {
            case .toggle: return TopLevelBlockBuilder.shared.informationBuilder.build(id: newBlockId(), content: .text(.empty()))
            default: return nil
            }
        case .smartblock: return TopLevelBlockBuilder.shared.informationBuilder.build(id: newBlockId(), content: .text(.empty()))
        default: return nil
        }
    }

    static func createContentType(block: BlockActiveRecordModelProtocol, action: KeyboardAction, textPayload: String) -> BlockContent? {
        switch block.content {
        case let .text(blockType):
            switch blockType.contentType {
            case .bulleted where blockType.attributedText.string != "": return .text(.init(contentType: .bulleted))
            case .checkbox where blockType.attributedText.string != "": return .text(.init(contentType: .checkbox))
            case .numbered where blockType.attributedText.string != "": return .text(.init(contentType: .numbered))
            case .toggle where block.isToggled: return .text(.init(contentType: .text))
            case .toggle where blockType.attributedText.string != "": return .text(.init(contentType: .toggle))
            default: return .text(.init(contentType: .text))
            }
        default: return nil
        }
    }

    static func createContentType(block: BlockActiveRecordModelProtocol,
                                  action: BlocksViews.Toolbar.UnderlyingAction,
                                  textPayload: String = "") -> BlockContent? {
        switch action {
        case let .addBlock(blockType):
            switch blockType {
            case let .text(value):
                switch value {
                case .text: return .text(.init(contentType: .text))
                case .h1: return .text(.init(contentType: .header))
                case .h2: return .text(.init(contentType: .header2))
                case .h3: return .text(.init(contentType: .header3))
                case .highlighted: return .text(.init(contentType: .quote))
                }
            case let .list(value):
                switch value {
                case .bulleted: return .text(.init(contentType: .bulleted))
                case .checkbox: return .text(.init(contentType: .checkbox))
                case .numbered: return .text(.init(contentType: .numbered))
                case .toggle: return .text(.init(contentType: .toggle))
                }
            case let .objects(mediaType):
                switch mediaType {
                case .page: return .link(.init(style: .page))
                case .picture: return .file(.init(contentType: .image))
                case .bookmark: return .bookmark(.empty())
                case .file: return .file(.init(contentType: .file))
                case .video: return .file(.init(contentType: .video))
                case .linkToObject: return nil
                }
            case let .other(value):
                switch value {
                case .lineDivider: return .divider(.init(style: .line))
                case .dotsDivider: return .divider(.init(style: .dots))
                case .code: return .text(BlockContent.Text(contentType: .code))
                }
            default: return nil
            }
        default: return nil
        }
    }
}
