import Foundation
import SwiftUI

struct EditorSetCoordinatorView: View {
    
    @StateObject private var model: EditorSetCoordinatorViewModel
    @Environment(\.pageNavigation) private var pageNavigation
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dismissAllPresented) private var dismissAllPresented
    
    init(data: EditorSetObject, showHeader: Bool) {
        self._model = StateObject(wrappedValue: EditorSetCoordinatorViewModel(data: data, showHeader: showHeader))
    }
    
    var body: some View {
        EditorSetView(data: model.data, showHeader: model.showHeader, output: model)
            .onAppear {
                model.pageNavigation = pageNavigation
                model.dismissAllPresented = dismissAllPresented
            }
            .onChange(of: model.dismiss) { _ in
                dismiss()
            }
            .sheet(item: $model.setQueryData) { data in
                model.setQuery(data)
            }
            .sheet(item: $model.relationValueData) { data in
                RelationValueCoordinatorView(data: data, output: model)
            }
            .anytypeSheet(item: $model.setViewPickerData) { data in
                SetViewPickerCoordinatorView(data: data)
            }
            .anytypeSheet(item: $model.setViewSettingsData) { data in
                SetViewSettingsCoordinatorView(data: data)
            }
            .sheet(item: $model.covertPickerData) {
                ObjectCoverPicker(data: $0)
            }
            .sheet(item: $model.objectIconPickerData) {
                ObjectIconPicker(data: $0)
            }
            .anytypeSheet(item: $model.syncStatusSpaceId) {
                SyncStatusInfoView(spaceId: $0.value)
            }
            .anytypeSheet(isPresented: $model.presentSettings) {
                ObjectSettingsCoordinatorView(
                    objectId: model.data.objectId,
                    spaceId: model.data.spaceId,
                    output: model
                )
            }
            .anytypeSheet(item: $model.setObjectCreationData) {
                SetObjectCreationSettingsView(data: $0, output: model)
            }
            .snackbar(toastBarData: $model.toastBarData)
    }
}
