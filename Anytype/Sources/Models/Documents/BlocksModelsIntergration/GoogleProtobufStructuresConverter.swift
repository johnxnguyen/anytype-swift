import Foundation
import SwiftProtobuf
import BlocksModels
import ProtobufMessages
import AnytypeCore

struct GoogleProtobufStructuresConverter {
    static func structure(_ from: [String: Any]) -> Google_Protobuf_Struct {
        /// NOTE: Not implemented.
        /// Don't delete this code.
        /// Read comments below.
        ///
//            let fields = from.compactMapValues({ (value) in
//                Google_Protobuf_Any.init
//                try? Google_Protobuf_Value.init(unpackingAny: value)
//            })
        /// HowTo:
        /// We should use either our replica of GoogleProtobufStruct or we could use GoogleProtobufStruct directly.
        /// Look at GoogleProtobufStruct.kind property type. It has indirect cases which are impossible to store without full support of same Struct type.
        ///
        ///
        AnytypeLogger.create(LoggerCategory(stringLiteral: "GoogleProtobufStructuresConverter"))
            .debug("Add conversion for categories")
        return [:]
    }
}

/// NOTE: Do not delete it before integration with new middleware and SetDetails refactoring.
/// Set Details task also contains some refactoring against current algorithm for parsing events.
/// Please, do not delete commented code.

//// MARK: ContentPage
//private extension BlockModels.Parser.Converters {
//    class ContentPage: BlocksModelsBaseContentConverter {
//        func contentType(_ from: Anytype_Model_Block.Content.Page.Style) -> BlockType.Page.Style? {
//            switch from {
//            case .empty: return .empty
//            case .task: return .task
//            case .set: return .set
//            case .breadcrumbs: return nil
//            default: return nil
//            }
//        }
//        func style(_ from: BlockType.Page.Style) -> Anytype_Model_Block.Content.Page.Style? {
//            switch from {
//            case .empty: return .empty
//            case .task: return .task
//            case .set: return .set
//            }
//        }
//        func blockType(_ from: Anytype_Model_Block.OneOf_Content) -> BlockType? {
//            switch from {
//            case let .page(value): return self.contentType(value.style).flatMap({BlockType.page(.init(style: $0))})
//            default: return nil
//            }
//        }
//        func middleware(_ from: BlockType?) -> Anytype_Model_Block.OneOf_Content? {
//            switch from {
//            case let .page(value): return self.style(value.style).flatMap({.page(.init(style: $0))})
//            default: return nil
//            }
//        }
//    }
//}

