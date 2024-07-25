import Foundation
import SwiftUI
import Services

struct IconsGroupView: View {
    let icons: [ObjectIcon]
    
    var body: some View {
        HStack(spacing: -Constants.imageShift) {
            ForEach(icons, id: \.hashValue) { icon in
                objectIconViewWithBorder(for: icon)
            }
        }
    }
    
    private func objectIconViewWithBorder(for icon: ObjectIcon) ->some View {
        ObjectIconView(icon: icon)
            .frame(width: Constants.iconDiameter, height: Constants.iconDiameter)
            .background {
                Circle()
                    .foregroundColor(Color.Background.secondary)
                    .frame(width: Constants.backgroundDiameter, height: Constants.backgroundDiameter)
            }
    }
}

extension IconsGroupView {
    enum Constants {
        static let iconDiameter: CGFloat = 24
        static let backgroundDiameter = iconDiameter + lineWidth * 2
        static let lineWidth: CGFloat = 2
        static let imageShift = lineWidth * 2
    }
}
