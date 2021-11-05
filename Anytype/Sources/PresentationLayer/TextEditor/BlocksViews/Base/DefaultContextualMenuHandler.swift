import BlocksModels

final class DefaultContextualMenuHandler {
    let handler: BlockActionHandlerProtocol
    let router: EditorRouterProtocol
    
    init(
        handler: BlockActionHandlerProtocol,
        router: EditorRouterProtocol
    ) {
        self.handler = handler
        self.router = router
    }
    
    func handle(action: ContextualMenu, info: BlockInformation) {
        switch action {
        case .addBlockBelow:
            handler.addBlock(.text(.text), blockId: info.id)
        case .delete:
            handler.delete(blockId: info.id)
        case .duplicate:
            handler.duplicate(blockId: info.id)
        case .turnIntoPage:
            handler.turnIntoPage(blockId: info.id)
        case .style:
            router.showStyleMenu(information: info)
        case .download,.replace:
            break
        }
    }
    
    
}
