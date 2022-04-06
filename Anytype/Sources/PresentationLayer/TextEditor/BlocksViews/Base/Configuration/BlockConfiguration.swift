import UIKit

protocol Configuration {
    associatedtype BlockConfiguration

    var configuration: BlockConfiguration { get }
    var currentConfigurationState: UICellConfigurationState? { get }
}

protocol BlockConfiguration: Hashable where View.Configuration == Self {
    associatedtype View: BlockContentView

    var contentInsets: UIEdgeInsets { get }
}

extension BlockConfiguration {
    var contentInsets: UIEdgeInsets { .init(top: 2, left: 20, bottom: -2, right: -20) }
}

struct BlockDragConfiguration {
    let id: String
}

struct BlockDragConfiguration {
    let id: String
}

extension BlockConfiguration {
    func cellBlockConfiguration(
        indentationSettings: IndentationSettings?,
        dragConfiguration: BlockDragConfiguration?
    ) -> CellBlockConfiguration<Self> {
        CellBlockConfiguration(
            blockConfiguration: self,
            currentConfigurationState: nil,
            indentationSettings: indentationSettings,
            dragConfiguration: dragConfiguration
        )
    }
}
