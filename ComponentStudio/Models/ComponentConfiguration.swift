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
    var children: [CSLayer]? = nil
    
    // Allows us to traverse back up the component scope hierarchy
    var parentComponentLayer: CSLayer? = nil
    
    init() {}
    
    init(component: CSComponent, arguments: ExampleDictionary, canvas: Canvas) {
        self.canvas = canvas
        
        // Make sure that we iterate through the canvas' params by including them here
//        var argumentsWithCanvasDefaults = canvas.parameters.merge(CSData.Object(arguments))
        var argumentsWithCanvasDefaults = CSData.Object(arguments)
        
        func performLogic(node: LogicNode, in scope: CSScope) {
            var scope = scope
            let invocation = node.invocation
            
            if invocation.canBeInvoked {
                let results = invocation.run(in: scope)
                scope = results.scope
                
                switch results.controlFlow {
                case .stepInto:
                    node.nodes.forEach({ performLogic(node: $0, in: scope) })
                case .stepOver:
                    return
                }
            }
        }
        
        self.scope = component.rootScope(canvas: canvas)
        
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

        if parametersData.objectValue.count > 0 {
            let parametersValue = CSValue(type: .dictionary([:]), data: parametersData)
            scope.set(variable: "parameters", to: CSVariable(value: parametersValue, access: .read))
        }
        
        for node in component.logic {
            performLogic(node: node, in: self.scope)
        }
    }
    
//    private func createKey(attribute: String, target: String) -> String {
//        return "\(target):\(attribute)"
//    }
//
//    func has(attribute: String, for target: String) -> Bool {
//        return params[createKey(attribute: attribute, target: target)] != nil
//    }
    
    func get(attribute: String, for target: String) -> CSData {
        return scope.get(value: "layers").data.get(keyPath: [target, attribute])
    }
//
//    func get(attribute: String, for target: String, withDefault defaultValue: String) -> String {
//        if has(attribute: attribute, for: target) {
//            return get(attribute: attribute, for: target)!
//        } else {
//            return defaultValue
//        }
//    }
//
//    func set(attribute: String, for target: String, to value: String?) {
//        params[createKey(attribute: attribute, target: target)] = value
//    }
//
//    func remove(attribute: String, for target: String) {
//        params.removeValue(forKey: createKey(attribute: attribute, target: target))
//    }
//
    func getAllAttributes(for target: String) -> [String: CSData] {
        return scope.get(value: "layers").data.get(keyPath: [target]).objectValue
    }
}
