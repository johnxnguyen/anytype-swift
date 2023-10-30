import Foundation
import SwiftUI
import NavigationBackport

struct HomeWidgetsCoordinatorView: View {
    
    @StateObject var model: HomeWidgetsCoordinatorViewModel
//    @State private var backgroundOpacity = 0.0
    
    var body: some View {
        HomeBottomPanelContainer(
            path: $model.editorPath,
            content: {
                NBNavigationStack(path: $model.editorPath) {
//                    ZStack {
//                        Color.Text.primary
//                            .opacity(backgroundOpacity)
//                            .ignoresSafeArea()
//                            .onChange(of: model.homeAnimationId) { newValue in
//                                backgroundOpacity = 0
//                                withAnimation(.easeInOut(duration: 0.2)) {
//                                    backgroundOpacity = 0.5
//                                }
//                            }
                        model.homeWidgetsModule()
//                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .offset(x: -100)))
//                            .animation(.easeInOut(duration: 0.35), value: model.homeAnimationId)
//                    }
                    .nbNavigationDestination(for: EditorScreenData.self) { data in
                        model.editorModule(data: data)
                    }
                    .fixNavigationBarGesture()
                }
            },
            bottomPanel: {
                model.homeBottomNavigationPanelModule()
//                bottomPanel
            }
        )
        .onAppear {
            model.onAppear()
        }
        .environment(\.pageNavigation, model.pageNavigation)
        .sheet(item: $model.showChangeSourceData) { data in
            model.changeSourceModule(data: data)
        }
        .sheet(item: $model.showChangeTypeData) { data in
            model.changeTypeModule(data: data)
        }
        .sheet(item: $model.showSearchData) { data in
            model.searchModule(data: data)
        }
        .sheet(item: $model.showCreateWidgetData) { data in
            model.createWidgetModule(data: data)
        }
        .sheet(isPresented: $model.showSpaceSwitch) {
            model.createSpaceSwitchModule()
        }
        .sheet(isPresented: $model.showSpaceSettings) {
            model.createSpaceSeetingsModule()
        }
        .sheet(isPresented: $model.showSharing) {
            model.createSharingModule()
        }
        .sheet(isPresented: $model.showCreateObjectWithType) {
            model.createObjectWithTypeModule()
        }
    }
}
