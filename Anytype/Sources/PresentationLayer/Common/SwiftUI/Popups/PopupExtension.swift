import SwiftUI

extension View {
    func bottomFloater<Content: View>(isPresented: Binding<Bool>, view: @escaping () -> Content) -> some View {
        return self.popup(
            isPresented: isPresented,
            type: .floater(verticalPadding: 42),
            animation: .fastSpring,
            closeOnTap: false,
            closeOnTapOutside: true,
            backgroundOverlayColor: Color.black.opacity(0.25),
            view: view
        )
    }
    
    func bottomSheet<Content: View>(isPresented: Binding<Bool>, view: @escaping () -> Content) -> some View {
        return self.popup(
            isPresented: isPresented,
            type: .floater(verticalPadding: 0),
            animation: .fastSpring,
            closeOnTap: false,
            closeOnTapOutside: true,
            backgroundOverlayColor: Color.black.opacity(0.25),
            view: {
                VStack(spacing: 0) {
                    view()
                    Rectangle()
                        .frame(height: UIApplication.shared.mainWindowInsets.bottom)
                        .foregroundColor(.backgroundSecondary)
                }
            }
        )
    }
}
