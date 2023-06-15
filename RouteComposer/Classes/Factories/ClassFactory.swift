//
// RouteComposer
// ClassFactory.swift
// https://github.com/ekazaev/route-composer
//
// Created by Eugene Kazaev in 2018-2023.
// Distributed under the MIT license.
//
// Become a sponsor:
// https://github.com/sponsors/ekazaev
//

import UIKit

/// The `Factory` that creates a `UIViewController` instance using its type.
@MainActor
public struct ClassFactory<VC: UIViewController, C>: Factory {

    // MARK: Associated types

    public typealias ViewController = VC

    public typealias Context = C

    // MARK: Properties

    /// A Xib file name
    public let nibName: String?

    /// A `Bundle` instance
    public let bundle: Bundle?

    /// The additional configuration block
    public let configuration: @MainActor (VC) -> Void

    // MARK: Methods

    /// Constructor
    ///
    /// - Parameters:
    ///   - nibNameOrNil: A Xib file name
    ///   - nibBundleOrNil: A `Bundle` instance if needed
    ///   - configuration: A block of code that will be used for the extended configuration of the created `UIViewController`. Can be used for
    ///                    a quick configuration instead of `ContextTask`.
    public init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil, configuration: @escaping @MainActor (VC) -> Void = { _ in }) {
        self.nibName = nibNameOrNil
        self.bundle = nibBundleOrNil
        self.configuration = configuration
    }

    public func build(with context: C) throws -> VC {
        let viewController = VC(nibName: nibName, bundle: bundle)
        configuration(viewController)
        return viewController
    }

}
