import Combine
import UIKit
import BlocksModels

struct CodeBlockViewModel: BlockViewModelProtocol {    
    var hashable: AnyHashable {
        [
            information,
            indentationLevel
        ] as [AnyHashable]
    }
    
    let block: BlockModelProtocol
    var information: BlockInformation { block.information }
    var indentationLevel: Int { block.indentationLevel }
    let content: BlockText
    private var codeLanguage: CodeLanguage {
        CodeLanguage.create(
            middleware: block.information.fields[FieldName.codeLanguage]?.stringValue
        )
    }

    let becomeFirstResponder: (BlockModelProtocol) -> ()
    let textDidChange: (BlockModelProtocol, UITextView) -> ()
    let showCodeSelection: (BlockModelProtocol) -> ()

    func makeContentConfiguration(maxWidth _ : CGFloat) -> UIContentConfiguration {
        return CodeBlockContentConfiguration(
            content: content,
            backgroundColor: block.information.backgroundColor,
            codeLanguage: codeLanguage,
            actions: .init(
                becomeFirstResponder: { becomeFirstResponder(block) },
                textDidChange: { textView in textDidChange(block, textView) },
                showCodeSelection: { showCodeSelection(block) }
            )
        ).asCellBlockConfiguration
    }
    
    func didSelectRowInTableView() { }
}

// MARK: - Debug

extension CodeBlockViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        return "id: \(blockId)\ntext: \(content.anytypeText.attrString.string.prefix(10))...\ntype: \(block.information.content.type.style.description)"
    }
}
