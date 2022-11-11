//
// RouteComposer
// ChildCoordinator.swift
// https://github.com/ekazaev/route-composer
//
// Created by Eugene Kazaev in 2018-2022.
// Distributed under the MIT license.
//

import Foundation
import UIKit

/// Helps to build a child view controller stack
public struct ChildCoordinator {

    // MARK: Properties

    var childFactories: [(factory: PostponedIntegrationFactory, context: Any?)]

    /// Returns `true` if the coordinator contains child factories to build
    public var isEmpty: Bool {
        childFactories.isEmpty
    }

    // MARK: Methods

    init(childFactories: [(factory: PostponedIntegrationFactory, context: Any?)]) {
        self.childFactories = childFactories
    }

    /// Builds child view controller stack with the context instance provided.
    ///
    /// - Parameters:
    ///   - existingViewControllers: Current view controller stack of the container.
    /// - Returns: Built child view controller stack
    public func build(integrating existingViewControllers: [UIViewController] = []) throws -> [UIViewController] {
        var childrenViewControllers = existingViewControllers
        for factory in childFactories {
            try factory.factory.build(with: factory.context, in: &childrenViewControllers)
        }
        return childrenViewControllers
    }

}
