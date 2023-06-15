//
// RouteComposer
// UIHostingControllerWithContextFinder.swift
// https://github.com/ekazaev/route-composer
//
// Created by Eugene Kazaev in 2018-2023.
// Distributed under the MIT license.
//
// Become a sponsor:
// https://github.com/sponsors/ekazaev
//

#if canImport(SwiftUI)

import Foundation
import SwiftUI
import UIKit

/// A default implementation of the finder, that searches for a `UIHostingController` with a specific `View`
/// and its `Context` instance.
///
/// The `View` should conform to the `ContextChecking` to be used with this finder.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct UIHostingControllerWithContextFinder<ContentView: View & ContextChecking>: StackIteratingFinder {

    // MARK: Associated types

    public typealias ViewController = UIHostingController<ContentView>

    public typealias Context = ContentView.Context

    // MARK: Properties

    /// A `StackIterator` is to be used by `ClassWithContextFinder`
    public let iterator: StackIterator

    // MARK: Methods

    /// Constructor
    ///
    /// - Parameter iterator: A `StackIterator` is to be used by `ClassWithContextFinder`
    public init(iterator: StackIterator) {
        self.iterator = iterator
    }

    /// Constructor
    ///
    /// required due to https://github.com/apple/swift/issues/58177
    public init() {
        self.init(iterator: RouteComposerDefaults.shared.stackIterator)
    }

    public func isTarget(_ viewController: ViewController, with context: Context) -> Bool {
        viewController.rootView.isTarget(for: context)
    }

}

/// Extension to use `DefaultStackIterator` as default iterator.
@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public extension UIHostingControllerWithContextFinder {

    /// Constructor
    ///
    /// Parameters
    ///   - options: A combination of the `SearchOptions`
    ///   - startingPoint: `DefaultStackIterator.StartingPoint` value
    ///   - windowProvider: `WindowProvider` instance.
    ///   - containerAdapterLocator: A `ContainerAdapterLocator` instance.
    init(options: SearchOptions,
         startingPoint: DefaultStackIterator.StartingPoint = .topmost,
         windowProvider: WindowProvider,
         containerAdapterLocator: ContainerAdapterLocator) {
        self.init(iterator: DefaultStackIterator(options: options, startingPoint: startingPoint, windowProvider: windowProvider, containerAdapterLocator: containerAdapterLocator))
    }

    /// Constructor
    ///
    /// Parameters
    ///   - options: A combination of the `SearchOptions`
    ///   - startingPoint: `DefaultStackIterator.StartingPoint` value
    ///
    /// required due to https://github.com/apple/swift/issues/58177
    init(options: SearchOptions,
         startingPoint: DefaultStackIterator.StartingPoint = .topmost) {
        let defaults = RouteComposerDefaults.shared
        self.init(iterator: DefaultStackIterator(options: options, startingPoint: startingPoint, windowProvider: defaults.windowProvider, containerAdapterLocator: defaults.containerAdapterLocator))
    }
}

#endif
