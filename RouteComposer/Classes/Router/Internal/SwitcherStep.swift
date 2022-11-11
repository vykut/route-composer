//
// RouteComposer
// SwitcherStep.swift
// https://github.com/ekazaev/route-composer
//
// Created by Eugene Kazaev in 2018-2022.
// Distributed under the MIT license.
//

import Foundation
import UIKit

protocol StepCaseResolver {

    func resolve(with context: Any?) -> RoutingStep?

}

final class SwitcherStep: RoutingStep, ChainableStep {

    final var resolvers: [StepCaseResolver]

    final func getPreviousStep(with context: Any?) -> RoutingStep? {
        resolvers.reduce(nil as RoutingStep?) { result, resolver in
            guard result == nil else {
                return result
            }
            return resolver.resolve(with: context)
        }
    }

    init(resolvers: [StepCaseResolver]) {
        self.resolvers = resolvers
    }

}
