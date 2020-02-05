// DO NOT EDIT.
//
// Generated by the AnytypeSwiftCodegen.
//
// For information on using the generated types, please see the documentation:
//   https://github.com/anytypeio/anytype-swift-codegen

import Foundation
import SwiftProtobuf

extension Anytype_Event {
  init(messages: [Anytype_Event.Message], contextID: String, initiator: Anytype_Model_Account) {
    self.messages = messages
    self.contextID = contextID
    self.initiator = initiator
  }
}

extension Anytype_Event.Account.Show {
  init(index: Int32, account: Anytype_Model_Account) {
    self.index = index
    self.account = account
  }
}

extension Anytype_Event.Block.Add {
  init(blocks: [Anytype_Model_Block]) {
    self.blocks = blocks
  }
}

extension Anytype_Event.Block.Delete {
  init(blockID: String) {
    self.blockID = blockID
  }
}

extension Anytype_Event.Block.FilesUpload {
  init(blockID: String, filePath: [String]) {
    self.blockID = blockID
    self.filePath = filePath
  }
}

extension Anytype_Event.Block.MarksInfo {
  init(marksInRange: [Anytype_Model_Block.Content.Text.Mark.TypeEnum]) {
    self.marksInRange = marksInRange
  }
}

extension Anytype_Event.Block.Set.ChildrenIds {
  init(id: String, childrenIds: [String]) {
    self.id = id
    self.childrenIds = childrenIds
  }
}

extension Anytype_Event.Block.Set.Fields {
  init(id: String, fields: SwiftProtobuf.Google_Protobuf_Struct) {
    self.id = id
    self.fields = fields
  }
}

extension Anytype_Event.Block.Set.File {
  init(
    id: String,
    type: Anytype_Event.Block.Set.File.TypeMessage,
    state: Anytype_Event.Block.Set.File.State,
    mime: Anytype_Event.Block.Set.File.Mime,
    hash: Anytype_Event.Block.Set.File.Hash,
    name: Anytype_Event.Block.Set.File.Name,
    size: Anytype_Event.Block.Set.File.Size
  ) {
    self.id = id
    self.type = type
    self.state = state
    self.mime = mime
    self.hash = hash
    self.name = name
    self.size = size
  }
}

extension Anytype_Event.Block.Set.File.Hash {
  init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.File.Mime {
  init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.File.Name {
  init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.File.Size {
  init(value: Int64) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.File.State {
  init(value: Anytype_Model_Block.Content.File.State) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.File.TypeMessage {
  init(value: Anytype_Model_Block.Content.File.TypeEnum) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.File.Width {
  init(value: Int32) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Icon {
  init(id: String, name: Anytype_Event.Block.Set.Icon.Name) {
    self.id = id
    self.name = name
  }
}

extension Anytype_Event.Block.Set.Icon.Name {
  init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.IsArchived {
  init(id: String, isArchived: Bool) {
    self.id = id
    self.isArchived = isArchived
  }
}

extension Anytype_Event.Block.Set.Link {
  init(id: String, targetBlockID: Anytype_Event.Block.Set.Link.TargetBlockId, style: Anytype_Event.Block.Set.Link.Style, fields: Anytype_Event.Block.Set.Link.Fields) {
    self.id = id
    self.targetBlockID = targetBlockID
    self.style = style
    self.fields = fields
  }
}

extension Anytype_Event.Block.Set.Link.Fields {
  init(value: SwiftProtobuf.Google_Protobuf_Struct) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Link.Style {
  init(value: Anytype_Model_Block.Content.Link.Style) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Link.TargetBlockId {
  init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Restrictions {
  init(id: String, restrictions: Anytype_Model_Block.Restrictions) {
    self.id = id
    self.restrictions = restrictions
  }
}

extension Anytype_Event.Block.Set.Text {
  init(
    id: String,
    text: Anytype_Event.Block.Set.Text.Text,
    style: Anytype_Event.Block.Set.Text.Style,
    marks: Anytype_Event.Block.Set.Text.Marks,
    checked: Anytype_Event.Block.Set.Text.Checked,
    color: Anytype_Event.Block.Set.Text.Color,
    backgroundColor: Anytype_Event.Block.Set.Text.BackgroundColor
  ) {
    self.id = id
    self.text = text
    self.style = style
    self.marks = marks
    self.checked = checked
    self.color = color
    self.backgroundColor = backgroundColor
  }
}

extension Anytype_Event.Block.Set.Text.BackgroundColor {
  init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Text.Checked {
  init(value: Bool) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Text.Color {
  init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Text.Marks {
  init(value: Anytype_Model_Block.Content.Text.Marks) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Text.Style {
  init(value: Anytype_Model_Block.Content.Text.Style) {
    self.value = value
  }
}

extension Anytype_Event.Block.Set.Text.Text {
  init(value: String) {
    self.value = value
  }
}

extension Anytype_Event.Block.Show {
  init(rootID: String, blocks: [Anytype_Model_Block]) {
    self.rootID = rootID
    self.blocks = blocks
  }
}

extension Anytype_Event.Message {
  init(value: OneOf_Value?) {
    self.value = value
  }
}

extension Anytype_Event.Ping {
  init(index: Int32) {
    self.index = index
  }
}

extension Anytype_Event.User.Block.Join {
  init(account: Anytype_Event.Account) {
    self.account = account
  }
}

extension Anytype_Event.User.Block.Left {
  init(account: Anytype_Event.Account) {
    self.account = account
  }
}

extension Anytype_Event.User.Block.SelectRange {
  init(account: Anytype_Event.Account, blockIdsArray: [String]) {
    self.account = account
    self.blockIdsArray = blockIdsArray
  }
}

extension Anytype_Event.User.Block.TextRange {
  init(account: Anytype_Event.Account, blockID: String, range: Anytype_Model_Range) {
    self.account = account
    self.blockID = blockID
    self.range = range
  }
}
