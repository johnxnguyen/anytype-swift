import Foundation
import Services

extension SpaceAccessType {
    var name: String {
        switch self {
        case .private:
            return Loc.Spaces.Accessibility.private
        case .personal:
            return Loc.Spaces.Accessibility.personal
        case .shared, .UNRECOGNIZED:
            return ""
        }
    }
}
