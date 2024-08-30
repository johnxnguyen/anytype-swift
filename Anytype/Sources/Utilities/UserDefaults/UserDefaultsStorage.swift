import AnytypeCore
import Services
import Combine
import SwiftUI

protocol UserDefaultsStorageProtocol {
    var showUnstableMiddlewareError: Bool { get set }
    var usersId: String { get set }
    var currentVersionOverride: String { get set }
    var installedAtDate: Date? { get set }
    var analyticsUserConsent: Bool { get set }
    var defaultObjectTypes: [String: String] { get set }
    var rowsPerPageInSet: Int { get set }
    var rowsPerPageInGroupedSet: Int { get set }
    var userInterfaceStyle: UIUserInterfaceStyle { get set }
    var lastOpenedScreen: EditorScreenData? { get set }
    
    func saveSpacesOrder(accountId: String, spaces: [String])
    func getSpacesOrder(accountId: String) -> [String]
    
    func wallpaperPublisher(spaceId: String) -> AnyPublisher<ObjectBackgroundType, Never>
    func wallpaper(spaceId: String) -> ObjectBackgroundType
    func setWallpaper(spaceId: String, wallpaper: ObjectBackgroundType)
    
    func cleanStateAfterLogout()
}

final class UserDefaultsStorage: UserDefaultsStorageProtocol {
    @UserDefault("showUnstableMiddlewareError", defaultValue: true)
    var showUnstableMiddlewareError: Bool
    
    @UserDefault("userId", defaultValue: "")
    var usersId: String
    
    @UserDefault("UserData.CurrentVersionOverride", defaultValue: "")
    var currentVersionOverride: String
    
    @UserDefault("App.InstalledAtDate", defaultValue: nil)
    var installedAtDate: Date?
    
    @UserDefault("App.AnalyticsUserConsent", defaultValue: false)
    var analyticsUserConsent: Bool
    
    // Key - spaceId, value - objectTypeId
    @UserDefault("UserData.DefaultObjectTypes", defaultValue: [:])
    var defaultObjectTypes: [String: String]
    
    @UserDefault("UserData.RowsPerPageInSet", defaultValue: 50)
    var rowsPerPageInSet: Int
    
    @UserDefault("UserData.RowsPerPageInGroupedSet", defaultValue: 20)
    var rowsPerPageInGroupedSet: Int
    
    @UserDefault("UserData.LastOpenedScreen", defaultValue: nil)
    var lastOpenedScreen: EditorScreenData?
    
    
    // MARK: - UserInterfaceStyle
    @UserDefault("UserData.UserInterfaceStyle", defaultValue: UIUserInterfaceStyle.unspecified.rawValue)
    private var _userInterfaceStyleRawValue: Int
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        get { UIUserInterfaceStyle(rawValue: _userInterfaceStyleRawValue) ?? .unspecified }
        set {
            _userInterfaceStyleRawValue = newValue.rawValue

            AnytypeAnalytics.instance().logSelectTheme(userInterfaceStyle)
        }
    }
    
    // MARK: - Wallpaper
    @UserDefault("UserData.Wallpapers", defaultValue: [:])
    private var _wallpapers: [String: ObjectBackgroundType] {
        didSet { wallpapersSubject.send(_wallpapers) }
    }
    
    private lazy var wallpapersSubject = CurrentValueSubject<[String: ObjectBackgroundType], Never>(_wallpapers)
    func wallpaperPublisher(spaceId: String) -> AnyPublisher<ObjectBackgroundType, Never> {
        return wallpapersSubject
            .compactMap { items -> ObjectBackgroundType in
                return items[spaceId] ?? .default
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    func wallpaper(spaceId: String) -> ObjectBackgroundType {
        return _wallpapers[spaceId] ?? .default
    }
    
    func setWallpaper(spaceId: String, wallpaper: ObjectBackgroundType) {
        _wallpapers[spaceId] = wallpaper
    }
    
    // MARK: - Spaces order
    @UserDefault("SpaceOrderStorage.CustomSpaceOrder", defaultValue: [:])
    private var spacesOrder: [String: [String]]
    
    func saveSpacesOrder(accountId: String, spaces: [String]) {
        spacesOrder[accountId] = spaces
    }
    func getSpacesOrder(accountId: String) -> [String] {
        spacesOrder[accountId] ?? []
    }
    
    // MARK: - Cleanup
    func cleanStateAfterLogout() {
        usersId = ""
        showUnstableMiddlewareError = true
        lastOpenedScreen = nil
    }
    
}
