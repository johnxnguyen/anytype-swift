@testable import Anytype
import UIKit
import Foundation
import Combine


final class UserDefaultsStorageMock: UserDefaultsStorageProtocol {
    private var spacesOrder = [String]()
    func saveSpacesOrder(accountId: String, spaces: [String]) {
        spacesOrder = spaces
    }
    
    func getSpacesOrder(accountId: String) -> [String] {
        return spacesOrder
    }
    
    // Unused
    var showUnstableMiddlewareError: Bool { get { fatalError() } set { fatalError() } }
    var usersId: String { get { fatalError() } set { fatalError() } }
    var currentVersionOverride: String { get { fatalError() } set { fatalError() } }
    var installedAtDate: Date? { get { fatalError() } set { fatalError() } }
    var analyticsUserConsent: Bool { get { fatalError() } set { fatalError() } }
    var defaultObjectTypes: [String : String] { get { fatalError() } set { fatalError() } }
    var rowsPerPageInSet: Int { get { fatalError() } set { fatalError() } }
    var rowsPerPageInGroupedSet: Int { get { fatalError() } set { fatalError() } }
    var userInterfaceStyle: UIUserInterfaceStyle { get { fatalError() } set { fatalError() } }
    var lastOpenedScreen: EditorScreenData? { get { fatalError() } set { fatalError() } }
    
    func wallpaperPublisher(spaceId: String) -> AnyPublisher<Anytype.ObjectBackgroundType, Never> {
        fatalError()
    }
    
    func wallpaper(spaceId: String) -> Anytype.ObjectBackgroundType {
        fatalError()
    }
    
    func setWallpaper(spaceId: String, wallpaper: Anytype.ObjectBackgroundType) {
        fatalError()
    }
    
    func cleanStateAfterLogout() {
        fatalError()
    }
}
