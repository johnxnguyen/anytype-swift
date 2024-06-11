import Foundation
import SwiftUI

private struct AppSceneHandlerModifier: ViewModifier {
    
    @StateObject private var model = AppSceneHandlerModifierModel()
    
    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                model.onOpenURL(url)
            }
    }
}

extension View {
    func setupAppSceneHandler() -> some View {
        modifier(AppSceneHandlerModifier())
    }
}
