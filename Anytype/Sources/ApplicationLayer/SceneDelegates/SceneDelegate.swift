import UIKit
import SwiftUI
import AnytypeCore
import DeepLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    @Injected(\.appActionStorage)
    private var appActionStorage: AppActionStorage
    @Injected(\.universalLinkParser)
    private var universalLinkParser: UniversalLinkParserProtocol
    @Injected(\.deepLinkParser)
    private var deepLinkParser: DeepLinkParserProtocol
    @Injected(\.quickActionShortcutBuilder)
    private var quickActionShortcutBuilder: QuickActionShortcutBuilderProtocol
    
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        let window = AnytypeWindow(windowScene: windowScene)
        self.window = window
        ViewControllerProvider.shared.sceneWindow = window
        
        connectionOptions.shortcutItem.flatMap { _ = handleQuickAction($0) }
        if let userActivity = connectionOptions.userActivities.first {
            handleUserActivity(userActivity)
        }
        handleURLContext(openURLContexts: connectionOptions.urlContexts)
        
        
        let applicationView = ApplicationCoordinatorView()
            .setKeyboardDismissEnv(window: window)
            .setPresentedDismissEnv(window: window)
            .setAppInterfaceStyleEnv(window: window)
        window.rootViewController = UIHostingController(rootView: applicationView)
        window.makeKeyAndVisible()
        window.overrideUserInterfaceStyle = UserDefaultsConfig.userInterfaceStyle
        
        ToastPresenter.shared = ToastPresenter()
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        handleURLContext(openURLContexts: URLContexts)
    }

    func sceneWillResignActive(_ scene: UIScene) {
        UIApplication.shared.shortcutItems = quickActionShortcutBuilder.buildShortcutItems()
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        handleUserActivity(userActivity)
    }
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleQuickAction(shortcutItem))
    }
    
    private func handleQuickAction(_ item: UIApplicationShortcutItem) -> Bool {
        guard let action = quickActionShortcutBuilder.buildAction(shortcutItem: item) else { return false }
        
        appActionStorage.action = action.toAppAction()
        return true
    }

    private func handleURLContext(openURLContexts: Set<UIOpenURLContext>) {
        guard openURLContexts.count == 1,
              let context = openURLContexts.first,
              let deepLink = deepLinkParser.parse(url: context.url)
        else { return }
        
        appActionStorage.action = .deepLink(deepLink)
    }
    
    private func handleUserActivity(_ userActivity: NSUserActivity) {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
                let url = userActivity.webpageURL else { return }
    
        guard let link = universalLinkParser.parse(url: url) else { return }
        
        appActionStorage.action = .deepLink(link.toDeepLink())
    }
}
