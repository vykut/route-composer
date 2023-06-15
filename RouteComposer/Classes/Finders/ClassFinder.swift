//
// RouteComposer
// ClassFinder.swift
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

/// A default implementation of the view controllers finder that searches for a view controller by its name.
@MainActor
public struct ClassFinder<VC: UIViewController, C>: StackIteratingFinder {

    // MARK: Associated types

    public typealias ViewController = VC

    public typealias Context = C

    // MARK: Properties

    /// A `StackIterator` is to be used by `ClassFinder`
    public let iterator: StackIterator

    // MARK: Methods

    /// Constructor
    ///
    /// - Parameter iterator: A `StackIterator` is to be used by `ClassFinder`
    public init(iterator: StackIterator) {
        self.iterator = iterator
    }

    public init() {
        self.init(iterator: RouteComposerDefaults.shared.stackIterator)
    }

    public func isTarget(_ viewController: VC, with context: C) -> Bool {
        true
    }

}

/// Extension to use `DefaultStackIterator` as default iterator.
public extension ClassFinder {

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
        self.iterator = DefaultStackIterator(options: options, startingPoint: startingPoint, windowProvider: windowProvider, containerAdapterLocator: containerAdapterLocator)
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
        self.iterator = DefaultStackIterator(options: options,
                                             startingPoint: startingPoint,
                                             windowProvider: RouteComposerDefaults.shared.windowProvider,
                                             containerAdapterLocator: RouteComposerDefaults.shared.containerAdapterLocator)
    }
}
