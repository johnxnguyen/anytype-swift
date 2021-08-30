import BlocksModels


/// Input data for document view
protocol DocumentEditorViewInput: AnyObject {
    
    func updateData(header: ObjectHeader, blocks: [BlockViewModelProtocol])

    func configureNavigationBar(using header: ObjectHeader, details: DetailsDataProtocol?)
    
    func selectBlock(blockId: BlockId)

    /// Ask view rebuild layout
    func needsUpdateLayout()

    /// Tells the delegate when editing of the text block begins
    func textBlockDidBeginEditing()

    /// Tells the delegate when editing of the text block will begin
    func textBlockWillBeginEditing()
}
