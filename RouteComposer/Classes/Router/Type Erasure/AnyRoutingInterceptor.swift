//
// RouteComposer
// AnyRoutingInterceptor.swift
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

@MainActor
protocol AnyRoutingInterceptor {

    mutating func prepare(with context: AnyContext) throws

    func perform(with context: AnyContext, completion: @escaping @MainActor (RoutingResult) -> Void)

}
