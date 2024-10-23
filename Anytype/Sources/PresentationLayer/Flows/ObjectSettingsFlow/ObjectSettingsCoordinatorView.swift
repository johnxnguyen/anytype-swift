import Foundation
import SwiftUI

struct ObjectSettingsCoordinatorView: View {
    
    @StateObject private var model: ObjectSettingsCoordinatorViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(objectId: String, spaceId: String, output: (any ObjectSettingsCoordinatorOutput)?) {
        self._model = StateObject(wrappedValue: ObjectSettingsCoordinatorViewModel(objectId: objectId, spaceId: spaceId, output: output))
    }
    
    var body: some View {
        ObjectSettingsView(objectId: model.objectId, spaceId: model.spaceId, output: model)
            .sheet(item: $model.coverPickerData) {
                ObjectCoverPicker(data: $0)
            }
            .sheet(item: $model.objectIconPickerData) {
                ObjectIconPicker(data: $0)
            }
            .sheet(item: $model.layoutPickerObjectId) {
                ObjectLayoutPicker(objectId: $0.value, spaceId: model.spaceId)
            }
            .sheet(item: $model.blockObjectSearchData) {
                BlockObjectSearchView(data: $0)
            }
            .sheet(item: $model.relationsListData) {
                RelationsListCoordinatorView(document: $0.document, output: model)
            }
            .sheet(item: $model.versionHistoryData) {
                VersionHistoryCoordinatorView(data: $0, output: model)
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
    }
}
