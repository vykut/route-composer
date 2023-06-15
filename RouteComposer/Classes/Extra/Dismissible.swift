//
// RouteComposer
// Dismissible.swift
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

var associatedObjectHandle: UInt8 = 0

/// `UIViewController` should conform to `Dismissible` protocol to be used with `DismissalMethodProvidingContextTask`.
@MainActor
public protocol Dismissible where Self: UIViewController {

    // MARK: Associated types

    /// Type of instance that `Dismissible` `UIViewController` will provide on dismissal.
    associatedtype DismissalTargetContext

    // MARK: Properties to implement

    /// Property to store the dismissal block provided by `DismissalMethodProvidingContextTask`
    var dismissalBlock: @MainActor (Self, DismissalTargetContext, Bool, @escaping @MainActor (RoutingResult) -> Void) -> Void { get set }

}

// MARK: Helper methods

public extension Dismissible {

    /// Dismisses current `UIViewController` using dismissal block provided by `DismissalMethodProvidingContextTask`
    ///
    /// - Parameters:
    ///   - context: `DismissalTargetContext` required to be dismissed.
    ///   - animated: Dismissal process should be animated if set to `true`
    ///   - completion: The completion block.
    func dismissViewController(with context: DismissalTargetContext, animated: Bool, completion: @escaping @MainActor (RoutingResult) -> Void = { _ in }) {
        dismissalBlock(self, context, animated, completion)
    }

}

// MARK: Helper methods where the DismissalTargetContext is Any?

public extension Dismissible where DismissalTargetContext == Any? {

    /// Dismisses current `UIViewController` using dismissal block provided by `DismissalMethodProvidingContextTask`
    ///
    /// - Parameters:
    ///   - animated: Dismissal process should be animated if set to `true`
    ///   - completion: The completion block.
    func dismissViewController(animated: Bool, completion: @escaping @MainActor (RoutingResult) -> Void = { _ in }) {
        dismissViewController(with: nil, animated: animated, completion: completion)
    }

}

// MARK: Helper methods where the DismissalTargetContext is Void

public extension Dismissible where DismissalTargetContext == Void {

    /// Dismisses current `UIViewController` using dismissal block provided by `DismissalMethodProvidingContextTask`
    ///
    /// - Parameters:
    ///   - animated: Dismissal process should be animated if set to `true`
    ///   - completion: The completion block.
    func dismissViewController(animated: Bool, completion: @escaping @MainActor (RoutingResult) -> Void = { _ in }) {
        dismissViewController(with: (), animated: animated, completion: completion)
    }

}

/// `DismissibleWithRuntimeStorage` simplifies `Dismissible` protocol conformance implementing required
/// `dismissalBlock` using Objective C runtime.
@MainActor
public protocol DismissibleWithRuntimeStorage: Dismissible {}

public extension DismissibleWithRuntimeStorage {

    var dismissalBlock: @MainActor (Self, DismissalTargetContext, Bool, @escaping @MainActor (RoutingResult) -> Void) -> Void {
        get {
            objc_getAssociatedObject(self, &associatedObjectHandle) as? (@MainActor (Self, DismissalTargetContext, Bool, @escaping @MainActor (RoutingResult) -> Void) -> Void) ?? { _,_,_, completion in
                completion(.failure(RoutingError.generic(.init("Could not retrieve object from runtime storage"))))
            }
        }
        set {
            objc_setAssociatedObject(self, &associatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}
