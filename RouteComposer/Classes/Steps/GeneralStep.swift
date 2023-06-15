//
// RouteComposer
// GeneralStep.swift
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

/// A wrapper for the general steps that can be applied to any `UIViewController`
@MainActor
public enum GeneralStep {

    // MARK: Internal entities

    @MainActor
    struct RootViewControllerStep: RoutingStep, PerformableStep {

        let windowProvider: WindowProvider

        /// Constructor
        init(windowProvider: WindowProvider) {
            self.windowProvider = windowProvider
        }

        func perform(with context: AnyContext) throws -> PerformableStepResult {
            guard let viewController = windowProvider.window?.rootViewController else {
                throw RoutingError.compositionFailed(.init("Root view controller was not found."))
            }
            return .success(viewController)
        }

    }

    @MainActor
    struct CurrentViewControllerStep: RoutingStep, PerformableStep {

        let windowProvider: WindowProvider

        /// Constructor
        init(windowProvider: WindowProvider) {
            self.windowProvider = windowProvider
        }

        func perform(with context: AnyContext) throws -> PerformableStepResult {
            guard let viewController = windowProvider.window?.topmostViewController else {
                throw RoutingError.compositionFailed(.init("Topmost view controller was not found."))
            }
            return .success(viewController)
        }

    }

    @MainActor
    struct FinderStep: RoutingStep, PerformableStep {

        let finder: AnyFinder?

        init(finder: some Finder) {
            self.finder = FinderBox(finder)
        }

        func perform(with context: AnyContext) throws -> PerformableStepResult {
            guard let viewController = try finder?.findViewController(with: context) else {
                throw RoutingError.compositionFailed(.init("A view controller of \(String(describing: finder)) was not found."))
            }
            return .success(viewController)
        }
    }

    // MARK: Steps

    /// Returns the root view controller of the key window.
    public static func root<C>(windowProvider: WindowProvider) -> DestinationStep<UIViewController, C> {
        DestinationStep(RootViewControllerStep(windowProvider: windowProvider))
    }

    /// Returns the root view controller of the key window.
    public static func root<C>() -> DestinationStep<UIViewController, C> {
        root(windowProvider: RouteComposerDefaults.shared.windowProvider)
    }

    /// Returns the topmost presented view controller.
    public static func current<C>(windowProvider: WindowProvider) -> DestinationStep<UIViewController, C> {
        DestinationStep(CurrentViewControllerStep(windowProvider: windowProvider))
    }

    /// Returns the topmost presented view controller.
    public static func current<C>() -> DestinationStep<UIViewController, C> {
        current(windowProvider: RouteComposerDefaults.shared.windowProvider)
    }

    /// Returns the resulting view controller of the finder provided.
    public static func custom<F: Finder>(using finder: F) -> DestinationStep<F.ViewController, F.Context> {
        DestinationStep(FinderStep(finder: finder))
    }

}
