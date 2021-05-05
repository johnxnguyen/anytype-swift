import Foundation
import UIKit
import SwiftUI


/// This is a builder for EditorModule.ContainerViewController
/// It provides several builders which could build both `SwiftUI` (`SwiftUIBuilder`) and `UIKit` (`UIKitBuilder`) components.
///
enum EditorModuleContainerViewBuilder {
    struct Request {
        var id: String
        
        fileprivate var documentRequest: EditorModuleContentViewBuilder.Request {
            .init(documentRequest: .init(id: self.id))
        }
    }
    
    /// We have the following system.
    /// Builder has two kind of components: Self and Child.
    /// You have an access to both components through `SelfComponent` and `ChildComponent`.
    /// We don't have a type erasure here ( we don't want to ).
    ///
    /// Next, typealiases to `Child` components ( `ChildViewModel`, `ChildViewController`, `ChildViewBuilder` ) have prefix `Child`.
    ///
    /// But, typealiases to `Self` components ( `ViewModel`, `ViewController`, `SelfComponent` ) may not have prefix `Self`.
    ///
    /// Interesting part is `SelfComponent`.
    /// `SelfComponent` is a triple `(ViewController, ViewModel, ChildComponent)`.
    ///
    /// It allows us to access to child of child of views to configure them on any level if we want to.
    ///
    ///
    typealias ChildViewModel = EditorModuleContentViewModel
    typealias ChildViewController = EditorModuleContentViewController
    typealias ChildViewBuilder = EditorModuleContentViewBuilder
    
    typealias ChildComponent = ChildViewBuilder.SelfComponent
    typealias SelfComponent = (viewController: EditorModuleContainerViewController, viewModel: EditorModuleContainerViewModel, childComponent: ChildComponent)
    
    static func view(by request: Request) -> EditorModuleContainerViewController {
        self.selfComponent(by: request).0
    }
    
    /// Returns `ChildComponent` for request in concrete builder. It uses `ChildViewBuilder.UIKitBuilder.selfComponent(by:)` method.
    /// For us `childComponent` is a `selfComponent` of `ChildViewBuilder` or `ChildViewBuilder.UIKitBuilder.selfComponent(by:)`
    /// - Parameter request: A request for which we will build child component.
    /// - Returns: A child component for a request.
    ///
    static func childComponent(by request: Request) -> ChildComponent {
        ChildViewBuilder.selfComponent(by: request.documentRequest)
    }
    
    /// Return `SelfComponent` for request in concrete builder.
    /// For us `selfComponent` is a target for this builder. It access childComponent to configure it by entities on this level.
    ///
    /// For example, if you want connect user actions which are coming from internal view, you need access to it on level of builder.
    /// It will be `childComponent` or `childChildComponent` ( a.k.a. `ChildViewBuilder.UIKitBuilder.ChildComponent` )
    ///
    /// - Parameter request: A request for which we will build self component.
    /// - Returns: A self component for a request.
    ///
    private static func selfComponent(by request: Request) -> SelfComponent {
        let childComponent = self.childComponent(by: request)
        
        let childViewController = childComponent.0
        
        /// Configure Navigation Controller
        let navigationController = UINavigationController(navigationBarClass: EditorModuleContainerViewBuilder.NavigationBar.self, toolbarClass: nil)
        NavigationBar.applyAppearance()
        navigationController.setViewControllers([childViewController], animated: false)
        navigationController.navigationBar.isTranslucent = false
        
        /// Configure Navigation Item for Content View Model.
        /// We need it to support Selection navigation bar buttons.
        let childViewModel = childComponent.1
        _ = childViewModel.configured(navigationItem: childViewController.navigationItem)
        
        let childChildComponent = childComponent.2
        let childChildViewModel = childChildComponent.1
        
        /// Don't forget configure router by events from blocks.
        let router: DocumentViewRouting.CompoundRouter = .init()
        _ = router.configured(userActionsStream: childChildViewModel.publicUserActionPublisher)
        
        /// Configure ViewModel of current View Controller.
        let viewModel = EditorModuleContainerViewModel()
        _ = viewModel.configured(router: router)
        
        /// Configure current ViewController.
        let viewController = EditorModuleContainerViewController(viewModel: viewModel)
        _ = viewController.configured(childViewController: navigationController)
        
        /// Configure navigation item of root
        let backButtonImage = UIImage(systemName: "chevron.backward", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
        childViewController.navigationItem.leftBarButtonItem = .init(image: backButtonImage, style: .plain, target: viewController, action: #selector(viewController.dismissAction))

        /// DEBUG: Conformance to navigation delegate.
        ///
        navigationController.delegate = viewController
        
        return (viewController, viewModel, childComponent)
    }
}

// MARK: Custom Appearance
/// TODO: Move it somewhere
private extension EditorModuleContainerViewBuilder {
    class NavigationBar: UINavigationBar {
        static func applyAppearance() {
            let appearance = Self.appearance()
            appearance.prefersLargeTitles = false
            appearance.tintColor = .gray
            appearance.backgroundColor = .white
        }
    }
}
