//
// RouteComposer
// UIViewController+Action.swift
// https://github.com/ekazaev/route-composer
//
// Created by Eugene Kazaev in 2018-2023.
// Distributed under the MIT license.
//
// Become a sponsor:
// https://github.com/sponsors/ekazaev
//

import Foundation
import UIKit

/// A wrapper for general actions that can be applied to any `UIViewController`
@MainActor
public enum GeneralAction {

    // MARK: Actions

    /// Replaces the root view controller in the key `UIWindow`
    ///
    /// - Parameters:
    ///   - windowProvider: `WindowProvider` instance
    ///   - animationOptions: Set of `UIView.AnimationOptions`. Transition will happen without animation if not provided.
    ///   - duration: Transition duration.
    public static func replaceRoot(windowProvider: WindowProvider,
                                   animationOptions: UIView.AnimationOptions? = nil,
                                   duration: TimeInterval = 0.3) -> ViewControllerActions.ReplaceRootAction {
        ViewControllerActions.ReplaceRootAction(windowProvider: windowProvider, animationOptions: animationOptions, duration: duration)
    }

    /// Replaces the root view controller in the key `UIWindow`
    ///
    /// - Parameters:
    ///   - animationOptions: Set of `UIView.AnimationOptions`. Transition will happen without animation if not provided.
    ///   - duration: Transition duration.
    ///
    /// required due to https://github.com/apple/swift/issues/58177
    public static func replaceRoot(animationOptions: UIView.AnimationOptions? = nil,
                                   duration: TimeInterval = 0.3) -> ViewControllerActions.ReplaceRootAction {
        replaceRoot(windowProvider: RouteComposerDefaults.shared.windowProvider, animationOptions: animationOptions, duration: duration)
    }

    /// Presents a view controller modally
    ///
    /// - Parameters:
    ///   - presentationStartingPoint: A starting point in the modal presentation
    ///   - presentationStyle: `UIModalPresentationStyle` setting, default value: .fullScreen
    ///   - transitionStyle: `UIModalTransitionStyle` setting, default value: .coverVertical
    ///   - transitioningDelegate: `UIViewControllerTransitioningDelegate` instance to be used during the transition
    ///   - isModalInPresentation: A Boolean value indicating whether the view controller enforces a modal behavior.
    ///   - preferredContentSize: The preferredContentSize is used for any container laying out a child view controller.
    ///   - popoverControllerConfigurationBlock: Block to configure `UIPopoverPresentationController`.
    public static func presentModally(startingFrom presentationStartingPoint: ViewControllerActions.PresentModallyAction.ModalPresentationStartingPoint = .current,
                                      presentationStyle: UIModalPresentationStyle? = .fullScreen,
                                      transitionStyle: UIModalTransitionStyle? = .coverVertical,
                                      transitioningDelegate: UIViewControllerTransitioningDelegate? = nil,
                                      preferredContentSize: CGSize? = nil,
                                      isModalInPresentation: Bool? = nil,
                                      popoverConfiguration: ((_: UIPopoverPresentationController) -> Void)? = nil) -> ViewControllerActions.PresentModallyAction {
        ViewControllerActions.PresentModallyAction(startingFrom: presentationStartingPoint,
                                                   presentationStyle: presentationStyle,
                                                   transitionStyle: transitionStyle,
                                                   transitioningDelegate: transitioningDelegate,
                                                   preferredContentSize: preferredContentSize,
                                                   isModalInPresentation: isModalInPresentation,
                                                   popoverConfiguration: popoverConfiguration)
    }

    /// `Action` does nothing, but can be helpful for testing or writing the sequences of steps with the `NilFactory`
    public static func nilAction() -> ViewControllerActions.NilAction {
        ViewControllerActions.NilAction()
    }

}

/// A wrapper for general actions that can be applied to any `UIViewController`
@MainActor
public enum ViewControllerActions {

    // MARK: Internal entities

    /// Presents a view controller modally
    @MainActor
    public struct PresentModallyAction: Action {

        /// A starting point in the modal presentation
        public enum ModalPresentationStartingPoint {

            /// Present from the `UIViewController` from the previous step (Default behaviour)
            case current

            /// Present from the topmost parent `UIViewController` of the `UIViewController` from the previous step
            case topmostParent

            /// Present from the custom `UIViewController`
            case custom(@autoclosure () throws -> UIViewController?)

        }

        // MARK: Properties

        /// A starting point in the modal presentation
        public let presentationStartingPoint: ModalPresentationStartingPoint

        /// `UIModalPresentationStyle` setting
        public let presentationStyle: UIModalPresentationStyle?

        /// A Boolean value indicating whether the view controller enforces a modal behavior.
        public let isModalInPresentation: Bool?

        /// `UIModalTransitionStyle` setting
        public let transitionStyle: UIModalTransitionStyle?

        /// The preferredContentSize is used for any container laying out a child view controller.
        public let preferredContentSize: CGSize?

        /// Block to configure `UIPopoverPresentationController`
        public let popoverControllerConfigurationBlock: ((_: UIPopoverPresentationController) -> Void)?

        /// `UIViewControllerTransitioningDelegate` instance to be used during the transition
        public private(set) weak var transitioningDelegate: UIViewControllerTransitioningDelegate?

        // MARK: Methods

        /// Constructor
        ///
        /// - Parameters:
        ///   - presentationStartingPoint: A starting point in the modal presentation
        ///   - presentationStyle: `UIModalPresentationStyle` setting, default value: .fullScreen
        ///   - transitionStyle: `UIModalTransitionStyle` setting, default value: .coverVertical
        ///   - transitioningDelegate: `UIViewControllerTransitioningDelegate` instance to be used during the transition
        ///   - preferredContentSize: The preferredContentSize is used for any container laying out a child view controller.
        ///   - isModalInPresentation: A Boolean value indicating whether the view controller enforces a modal behavior.
        ///   - popoverControllerConfigurationBlock: Block to configure `UIPopoverPresentationController`.
        init(startingFrom presentationStartingPoint: ModalPresentationStartingPoint = .current,
             presentationStyle: UIModalPresentationStyle? = .fullScreen,
             transitionStyle: UIModalTransitionStyle? = .coverVertical,
             transitioningDelegate: UIViewControllerTransitioningDelegate? = nil,
             preferredContentSize: CGSize? = nil,
             isModalInPresentation: Bool? = nil,
             popoverConfiguration: ((_: UIPopoverPresentationController) -> Void)? = nil) {
            self.presentationStartingPoint = presentationStartingPoint
            self.presentationStyle = presentationStyle
            self.transitionStyle = transitionStyle
            self.transitioningDelegate = transitioningDelegate
            self.preferredContentSize = preferredContentSize
            self.popoverControllerConfigurationBlock = popoverConfiguration
            self.isModalInPresentation = isModalInPresentation
        }

        public func perform(with viewController: UIViewController,
                            on existingController: UIViewController,
                            animated: Bool,
                            completion: @escaping (_: RoutingResult) -> Void) {

            let presentingViewController: UIViewController
            switch presentationStartingPoint {
            case .current:
                presentingViewController = existingController
            case .topmostParent:
                presentingViewController = existingController.allParents.last ?? existingController
            case let .custom(viewController):
                guard let viewController = try? viewController() else {
                    completion(.failure(RoutingError.compositionFailed(
                        .init("The view controller to start modal presentation from was not found."))))
                    return
                }
                presentingViewController = viewController
            }

            guard presentingViewController.presentedViewController == nil else {
                completion(.failure(RoutingError.compositionFailed(.init("\(presentingViewController) is " +
                        "already presenting a view controller."))))
                return
            }
            if let presentationStyle {
                viewController.modalPresentationStyle = presentationStyle
            }
            if let transitionStyle {
                viewController.modalTransitionStyle = transitionStyle
            }
            if let transitioningDelegate {
                viewController.transitioningDelegate = transitioningDelegate
            }
            if let preferredContentSize {
                viewController.preferredContentSize = preferredContentSize
            }
            if let popoverPresentationController = viewController.popoverPresentationController,
               let popoverControllerConfigurationBlock {
                popoverControllerConfigurationBlock(popoverPresentationController)
            }
            if #available(iOS 13, *),
               let isModalInPresentation {
                viewController.isModalInPresentation = isModalInPresentation
            }

            presentingViewController.present(viewController, animated: animated, completion: {
                completion(.success)
            })
        }

    }

    /// Replaces the root view controller in the key `UIWindow`
    @MainActor
    public struct ReplaceRootAction: Action {

        // MARK: Properties

        /// `WindowProvider` instance
        public let windowProvider: WindowProvider

        /// Set of `UIView.AnimationOptions`
        public let animationOptions: UIView.AnimationOptions?

        /// Transition duration.
        public let duration: TimeInterval

        // MARK: Methods

        /// Constructor
        ///
        /// - Parameters:
        ///   - windowProvider: `WindowProvider` instance
        ///   - animationOptions: Set of `UIView.AnimationOptions`. Transition will happen without animation if not provided.
        ///   - duration: Transition duration.
        init(windowProvider: WindowProvider, animationOptions: UIView.AnimationOptions? = nil, duration: TimeInterval = 0.3) {
            self.windowProvider = windowProvider
            self.animationOptions = animationOptions
            self.duration = duration
        }

        public func perform(with viewController: UIViewController,
                            on existingController: UIViewController,
                            animated: Bool,
                            completion: @escaping (_: RoutingResult) -> Void) {
            guard let window = windowProvider.window else {
                completion(.failure(RoutingError.compositionFailed(.init("Window was not found."))))
                return
            }
            guard window.rootViewController == existingController else {
                completion(.failure(RoutingError.compositionFailed(.init("Action should be applied to the root view " +
                        "controller, got \(String(describing: existingController)) instead."))))
                return
            }

            guard animated, let animationOptions, duration > 0 else {
                window.rootViewController = viewController
                window.makeKeyAndVisible()
                completion(.success)
                return
            }

            UIView.transition(with: window, duration: duration, options: animationOptions, animations: {
                let oldAnimationState = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                window.rootViewController = viewController
                window.rootViewController?.view.setNeedsLayout()
                window.makeKeyAndVisible()
                UIView.setAnimationsEnabled(oldAnimationState)
            })
            completion(.success)
        }

    }

    /// Helper `Action` that does nothing
    @MainActor
    public struct NilAction: Action {

        // MARK: Methods

        /// Constructor
        init() {}

        /// Does nothing and always succeeds
        public func perform(with viewController: UIViewController, on existingController: UIViewController, animated: Bool, completion: @escaping (RoutingResult) -> Void) {
            completion(.success)
        }

    }

}
