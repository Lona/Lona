//
//  RenderSurface.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/11/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class ComponentConfiguration {

    var scope: CSScope = CSScope()
    var canvas: Canvas = Canvas()

    // For propagating the <Children /> element into a custom component
    var children: [CSLayer]?

    // Allows us to traverse back up the component scope hierarchy
    var parentComponentLayer: CSLayer?

    init() {}

    func performLogicBody(nodes: [LogicNode], in scope: CSScope) {
        var index = 0
        while index < nodes.count {
            let node = nodes[index]
            let invocation = node.invocation

            if invocation.canBeInvoked {
                let controlFlow = invocation.run(in: scope)

                switch controlFlow {
                case .stepInto:
                    performLogicBody(nodes: node.nodes, in: CSScope(parent: scope))
                    index += 1
                case .stepOver:
                    index += 1
                case .repeatBlock:
                    performLogicBody(nodes: node.nodes, in: CSScope(parent: scope))
                }
            } else {
                index += 1
            }
        }
    }

    init(component: CSComponent, arguments: ExampleDictionary, canvas: Canvas) {
        self.canvas = canvas

        // Make sure that we iterate through the canvas' params by including them here
//        var argumentsWithCanvasDefaults = canvas.parameters.merge(CSData.Object(arguments))
        let argumentsWithCanvasDefaults = CSData.Object(arguments)

        let parametersData = argumentsWithCanvasDefaults.objectValue
            .reduce(CSData.Object([:])) { (result, argument) -> CSData in
                var result = result
                let value = argument.value

                // Use canvas parameter, if it exists
//                if value == CSData.Null {
//                    value = canvas.parameters[argument.key] ?? CSData.Null
//                }

                result[argument.key] = value
                return result
        }

        let scope = component.rootScope(canvas: canvas)

        if parametersData.objectValue.count > 0 {
            let parametersValue = CSValue(type: component.parametersType(), data: parametersData)
            scope.set(variable: "parameters", to: CSVariable(value: parametersValue, access: .read))
        }

        performLogicBody(nodes: component.logic, in: scope)

//        scope.print()

        self.scope = scope
    }

    func get(attribute: String, for target: String) -> CSData {
        return scope.get(value: "layers").data.get(keyPath: [target, attribute])
    }

    func getAllAttributes(for target: String) -> [String: CSData] {
        return scope.get(value: "layers").data.get(keyPath: [target]).objectValue
    }
}
