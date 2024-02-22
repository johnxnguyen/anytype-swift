import Services
import Foundation
import Combine

final class PasteboardBlockService: PasteboardBlockServiceProtocol {
    private let document: BaseDocumentProtocol
    private let pasteboardHelper: PasteboardHelperProtocol
    private let pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol
    
    private var tasks = [AnyCancellable]()

    init(
        document: BaseDocumentProtocol,
        pasteboardHelper: PasteboardHelperProtocol,
        pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol
    ) {
        self.document = document
        self.pasteboardMiddlewareService = pasteboardMiddlewareService
        self.pasteboardHelper = pasteboardHelper
    }
    
    var hasValidURL: Bool {
        pasteboardHelper.hasValidURL
    }
    
    func pasteInsideBlock(focusedBlockId: String,
                          range: NSRange,
                          handleLongOperation:  @escaping () -> Void,
                          completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void) {
        let context = PasteboardActionContext.focused(blockId: focusedBlockId, range: range)
        paste(context: context, handleLongOperation: handleLongOperation, completion: completion)
    }
    
    func pasteInSelectedBlocks(selectedBlockIds: [String],
                               handleLongOperation:  @escaping () -> Void,
                               completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void) {
        let context = PasteboardActionContext.selected(blockIds: selectedBlockIds)
        paste(context: context, handleLongOperation: handleLongOperation, completion: completion)
    }
    
    private func paste(context: PasteboardActionContext,
                       handleLongOperation:  @escaping () -> Void,
                       completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void) {
        
        let workItem = DispatchWorkItem {
            handleLongOperation()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.longOperationTime, execute: workItem)
        
        let task = PasteboardTask(
            objectId: document.objectId,
            pasteboardHelper: pasteboardHelper,
            pasteboardMiddlewareService: pasteboardMiddlewareService,
            context: context
        )
        
        Task {
            let pasteResult = try? await task.start()
            
            DispatchQueue.main.async {
                workItem.cancel()
                completion(pasteResult)
            }
        }
        .cancellable()
        .store(in: &tasks)
    }
    
    func copy(blocksIds: [String], selectedTextRange: NSRange) async throws {
        let blockInformations = blocksIds.compactMap { document.infoContainer.get(id: $0) }
        if let result = try await pasteboardMiddlewareService.copy(
            blockInformations: blockInformations,
            objectId: document.objectId,
            selectedTextRange: selectedTextRange
        ) {
            pasteboardHelper.setItems(textSlot: result.textSlot, htmlSlot: result.htmlSlot, blocksSlots: result.blockSlot)
        }
    }
    
    func cut(blocksIds: [String], selectedTextRange: NSRange) async throws {
        let blockInformations = blocksIds.compactMap { document.infoContainer.get(id: $0) }
        if let result = try await pasteboardMiddlewareService.cut(blockInformations: blockInformations, objectId: document.objectId, selectedTextRange: selectedTextRange) {
            pasteboardHelper.setItems(textSlot: result.textSlot, htmlSlot: result.htmlSlot, blocksSlots: result.blockSlot)
        }
    }
}

private extension PasteboardBlockService {
    enum Constants {
        static let longOperationTime: Double = 0.5
    }
}
