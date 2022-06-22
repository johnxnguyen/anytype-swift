typealias SystemContentConfiguationProvider = (ContentConfigurationProvider & HashableProvier & BlockFocusing)

enum EditorItem: Hashable {
    case header(ObjectHeader)
    case block(BlockViewModelProtocol)
    case system(SystemContentConfiguationProvider)
    
    static func == (lhs: EditorItem, rhs: EditorItem) -> Bool {
        switch (lhs, rhs) {
        case let (.block(lhsBlock), .block(rhsBlock)):
            return lhsBlock.hashable == rhsBlock.hashable
        case let (.header(lhsHeader), .header(rhsHeader)):
            return lhsHeader == rhsHeader
        case let (.system(rhsSystem), .system(lhsSystem)):
            return rhsSystem.hashable == lhsSystem.hashable
        default:
            return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .block(block):
            hasher.combine(block.info.id)
        case let .header(header):
            hasher.combine(header)
        case let.system(system):
            hasher.combine(system.hashable)
        }
    }
}

extension CollectionDifference where ChangeElement == EditorItem {
    var canPerformAnimation: Bool {
        !insertions.contains { item in
            switch item.element {
            case .block(let blockViewModel):
                if case .featuredRelations = blockViewModel.content {
                    return true
                }

                return false
            default: return false
            }
        }
    }
}
