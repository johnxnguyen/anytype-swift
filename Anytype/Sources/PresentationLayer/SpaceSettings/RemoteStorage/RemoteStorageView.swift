import SwiftUI
import AnytypeCore

struct RemoteStorageView: View {
    
    @StateObject private var model: RemoteStorageViewModel
    
    init(output: RemoteStorageModuleOutput?) {
        _model = StateObject(wrappedValue: RemoteStorageViewModel(output: output))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.SpaceSettings.remoteStorage)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer.fixedHeight(10)
                    AnytypeText(model.spaceInstruction, style: .uxCalloutRegular)
                        .foregroundColor(.Text.primary)
                    if model.showGetMoreSpaceButton {
                        Spacer.fixedHeight(4)
                        AnytypeText(Loc.FileStorage.Space.getMore, style: .uxCalloutMedium)
                            .foregroundColor(.System.red)
                            .onTapGesture {
                                model.onTapGetMoreSpace()
                            }
                    }
                    Spacer.fixedHeight(20)
                    AnytypeText(model.spaceUsed, style: .relation3Regular)
                        .foregroundColor(.Text.secondary)
                    Spacer.fixedHeight(8)
                    RemoteStorageSegment(model: model.segmentInfo)
                    Spacer.fixedHeight(16)
                    StandardButton(Loc.FileStorage.manageFiles, style: .secondarySmall) {
                        model.onTapManageFiles()
                    }
                }
                .padding(.horizontal, 20)
            }
            .if(!model.contentLoaded) {
                $0.redacted(reason: .placeholder)
                  .allowsHitTesting(false)
            }
        }
        .onAppear {
            model.onAppear()
        }
    }
}
