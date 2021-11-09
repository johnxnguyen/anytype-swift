import AnytypeCore
import BlocksModels

final class BlockMarkupChanger: BlockMarkupChangerProtocol {
    
    weak var handler: BlockActionHandlerProtocol?
    
    private let blocksContainer: BlockContainerModelProtocol
    private let detailsStorage: ObjectDetailsStorageProtocol
    
    init(
        blocksContainer: BlockContainerModelProtocol,
        detailsStorage: ObjectDetailsStorageProtocol
    ) {
        self.blocksContainer = blocksContainer
        self.detailsStorage = detailsStorage
    }
    
    func toggleMarkup(
        _ markup: MarkupType,
        for blockId: BlockId
    ) {
        guard let info = blocksContainer.model(id: blockId)?.information,
              case let .text(blockText) = info.content else { return }
        
        toggleMarkup(
            markup,
            for: blockId,
            in: blockText.anytypeText(using: detailsStorage).attrString.wholeRange
        )
    }
    
    func toggleMarkup(
        _ markup: MarkupType,
        for blockId: BlockId,
        in range: NSRange
    ) {
        guard let (model, content) = blockData(blockId: blockId) else { return }

        let restrictions = BlockRestrictionsBuilder.build(textContentType: content.contentType)

        guard restrictions.isMarkupAvailable(markup) else { return }

        let attributedText = content.anytypeText(using: detailsStorage).attrString
        let shouldApplyMarkup = !attributedText.hasMarkup(markup, range: range)

        applyAndStore(
            markup,
            shouldApplyMarkup: shouldApplyMarkup,
            block: model,
            content: content,
            attributedText: attributedText,
            range: range
        )
    }

    func setMarkup(
        _ markup: MarkupType,
        for blockId: BlockId,
        in range: NSRange
    ) {
        updateMarkup(markup, shouldApplyMarkup: true, for: blockId, in: range)
    }

    func removeMarkup(
        _ markup: MarkupType,
        for blockId: BlockId,
        in range: NSRange
    ) {
        updateMarkup(markup, shouldApplyMarkup: false, for: blockId, in: range)
    }

    private func updateMarkup(
        _ markup: MarkupType,
        shouldApplyMarkup: Bool,
        for blockId: BlockId,
        in range: NSRange
    ) {
        guard let (model, content) = blockData(blockId: blockId) else { return }

        let restrictions = BlockRestrictionsBuilder.build(textContentType: content.contentType)

        guard restrictions.isMarkupAvailable(markup) else { return }

        let attributedText = content.anytypeText(using: detailsStorage).attrString

        applyAndStore(
            markup,
            shouldApplyMarkup: shouldApplyMarkup,
            block: model,
            content: content,
            attributedText: attributedText,
            range: range
        )
    }

    
    private func applyAndStore(
        _ action: MarkupType,
        shouldApplyMarkup: Bool,
        block: BlockModelProtocol,
        content: BlockText,
        attributedText: NSAttributedString,
        range: NSRange
    ) {
        // Ignore changing markup in empty string 
        guard range.length != 0 else { return }
        
        let modifier = MarkStyleModifier(
            attributedString: attributedText,
            anytypeFont: content.contentType.uiFont
        )
        
        modifier.apply(action, shouldApplyMarkup: shouldApplyMarkup, range: range)
        let result = NSAttributedString(attributedString: modifier.attributedString)
        
        handler?.changeText(result, info: block.information)
    }
    
    private func blockData(blockId: BlockId) -> (BlockModelProtocol, BlockText)? {
        guard let model = blocksContainer.model(id: blockId) else {
            anytypeAssertionFailure("Can't find block with id: \(blockId)")
            return nil
        }
        guard case let .text(content) = model.information.content else {
            anytypeAssertionFailure("Unexpected block type \(model.information.content)")
            return nil
        }
        return (model, content)
    }
}
