import SwiftProtobuf
import ProtobufMessages

public typealias BlockFields = [String : Google_Protobuf_Value]

public typealias SyncStatus = Anytype_Event.Space.Status
public typealias SyncStatusInfo = Anytype_Event.Space.SyncStatus.Update
public typealias P2PStatusInfo = Anytype_Event.P2PStatus.Update
