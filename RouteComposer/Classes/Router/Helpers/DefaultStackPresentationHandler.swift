//
// RouteComposer
// DefaultStackPresentationHandler.swift
// https://github.com/ekazaev/route-composer
//
// Created by Eugene Kazaev in 2018-2023.
// Distributed under the MIT license.
//
// Become a sponsor:
// https://github.com/sponsors/ekazaev
//

import UIKit

/// Default implementation of `StackPresentationHandler`
@MainActor
public struct DefaultStackPresentationHandler: StackPresentationHandler {

    // MARK: Properties

    /// `Logger` instance to be used by `DefaultRouter`.
    public let logger: Logger?

    /// `ContainerAdapter` instance.
    public let containerAdapterLocator: ContainerAdapterLocator

    // MARK: Methods

    /// Constructor
    ///
    /// Parameters
    ///   - logger: A `Logger` instance to be used by the `DefaultRouter`.
    ///   - containerAdapterLocator: A `ContainerAdapterLocator` instance to be used by the `DefaultRouter`.
    public init(logger: Logger?,
                containerAdapterLocator: ContainerAdapterLocator) {
        self.logger = logger
        self.containerAdapterLocator = containerAdapterLocator
    }

    // MARK: Methods

    /// Constructor
    ///
    /// required due to https://github.com/apple/swift/issues/58177
    public init() {
        let defaults = RouteComposerDefaults.shared
        self.init(logger: defaults.logger,
                  containerAdapterLocator: defaults.containerAdapterLocator)
    }

    public func dismissPresented(from viewController: UIViewController, animated: Bool, completion: @escaping @MainActor (RoutingResult) -> Void) {
        if let presentedController = viewController.presentedViewController {
            if !presentedController.isBeingDismissed {
                viewController.dismiss(animated: animated) {
                    logger?.log(.info("Dismissed all the view controllers presented from \(String(describing: viewController))"))
                    completion(.success)
                }
            } else {
                completion(.failure(RoutingError.compositionFailed(.init("Attempt to dismiss \(String(describing: presentedController)) while it is being dismissed"))))
            }
        } else {
            completion(.success)
        }
    }

    public func makeVisibleInParentContainers(_ viewController: UIViewController,
                                              animated: Bool,
                                              completion: @escaping @MainActor (RoutingResult) -> Void) {
        var parentViewControllers = viewController.allParents
        let topParentViewController = parentViewControllers.last
        func makeVisible(viewController: UIViewController, completion: @escaping @MainActor (RoutingResult) -> Void) {
            guard !parentViewControllers.isEmpty else {
                if !animated,
                   let topParentViewController,
                   topParentViewController.isViewLoaded {
                    topParentViewController.view.layoutIfNeeded()
                }
                completion(.success)
                return
            }
            do {
                let parentViewController = parentViewControllers.removeFirst()
                if let container = parentViewController as? ContainerViewController {
                    let containerAdapter = try containerAdapterLocator.getAdapter(for: container)
                    guard !containerAdapter.isVisible(viewController) else {
                        logger?.log(.info("View controller \(String(describing: viewController)) is visible in \(String(describing: container)). No action needed."))
                        return makeVisible(viewController: parentViewController, completion: completion)
                    }
                    containerAdapter.makeVisible(viewController, animated: animated, completion: { result in
                        guard result.isSuccessful else {
                            completion(result)
                            return
                        }
                        logger?.log(.info("Made \(String(describing: viewController)) visible in \(String(describing: container))"))
                        makeVisible(viewController: parentViewController, completion: completion)
                    })
                } else {
                    makeVisible(viewController: parentViewController, completion: completion)
                }
            } catch {
                completion(.failure(error))
            }
        }

        makeVisible(viewController: viewController, completion: completion)
    }

}
