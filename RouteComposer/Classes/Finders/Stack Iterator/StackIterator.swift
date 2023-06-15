//
// RouteComposer
// StackIterator.swift
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

/// `StackIterator` protocol
@MainActor
public protocol StackIterator {

    // MARK: Methods to implement

    /// Returns `UIViewController` instance if found
    ///
    /// - Parameter predicate: A block that contains `UIViewController` matching condition
    func firstViewController(where predicate: @MainActor (UIViewController) -> Bool) throws -> UIViewController?

}
