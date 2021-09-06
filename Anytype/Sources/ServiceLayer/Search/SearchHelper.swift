import ProtobufMessages
import SwiftProtobuf
import BlocksModels

class SearchHelper {
    static func sort(relation: DetailsKind, type: Anytype_Model_Block.Content.Dataview.Sort.TypeEnum) -> Anytype_Model_Block.Content.Dataview.Sort {
        var sort = Anytype_Model_Block.Content.Dataview.Sort()
        sort.relationKey = relation.rawValue
        sort.type = type
        
        return sort
    }
    
    static func isArchivedFilter(isArchived: Bool) -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .equal
        filter.value = Google_Protobuf_Value(boolValue: isArchived)
        filter.relationKey = DetailsKind.isArchived.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func notHiddenFilter() -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .equal
        filter.value = Google_Protobuf_Value(boolValue: false)
        filter.relationKey = DetailsKind.isHidden.rawValue
        filter.operator = .and
        
        return filter
    }
    
    static func typeFilter(typeUrls: [String]) -> Anytype_Model_Block.Content.Dataview.Filter {
        var filter = Anytype_Model_Block.Content.Dataview.Filter()
        filter.condition = .in
        filter.value = Google_Protobuf_Value(
            listValue: Google_Protobuf_ListValue(
                values: typeUrls.map { Google_Protobuf_Value(stringValue: $0) }
            )
        )
        filter.relationKey = DetailsKind.type.rawValue
        filter.operator = .and
        
        return filter
    }
}
