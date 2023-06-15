//
// RouteComposer
// DetailsNavigationFinder.swift
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

/// `Finder` that helps to find the `UINavigationController` inside of the details of the `UISplitController`
@MainActor
public struct DetailsNavigationFinder<C>: Finder {

    // MARK: Associated types

    public typealias ViewController = UINavigationController

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

    /// Constructor
    ///
    /// required due to https://github.com/apple/swift/issues/58177
    public init() {
        self.init(iterator: RouteComposerDefaults.shared.stackIterator)
    }

    public func findViewController(with context: Context) throws -> ViewController? {
        guard let splitViewController = try ClassFinder<UISplitViewController, Context>(iterator: iterator).findViewController(with: context) else {
            return nil
        }
        guard splitViewController.viewControllers.count > 1 else {
            guard let firstNavigationController = splitViewController.viewControllers.first as? UINavigationController,
                  let secondNavigationController = firstNavigationController.viewControllers.last as? UINavigationController else {
                return nil
            }
            return secondNavigationController
        }
        return splitViewController.viewControllers.last as? UINavigationController
    }

}

/// Extension to use `DefaultStackIterator` as default iterator.
public extension DetailsNavigationFinder {

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
        let iterator = DefaultStackIterator(options: options,
                                            startingPoint: startingPoint,
                                            windowProvider: windowProvider,
                                            containerAdapterLocator: containerAdapterLocator)
        self.init(iterator: iterator)
    }

    /// Constructor
    ///
    /// Parameters
    ///   - options: A combination of the `SearchOptions`
    ///   - startingPoint: `DefaultStackIterator.StartingPoint` value
    ///
    ///   required due to https://github.com/apple/swift/issues/58177
    init(options: SearchOptions,
         startingPoint: DefaultStackIterator.StartingPoint = .topmost) {
        let defaults = RouteComposerDefaults.shared
        let iterator = DefaultStackIterator(options: options,
                                             startingPoint: startingPoint,
                                             windowProvider: defaults.windowProvider,
                                             containerAdapterLocator: defaults.containerAdapterLocator)
        self.init(iterator: iterator)
    }

}
