//
//  CSComponentLayer.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/27/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

class CSComponentLayer: CSLayer {
    var component: CSComponent
    var failedToLoad: Bool = false

    func reload() {
        if case CSLayer.LayerType.custom(let name) = type,
            let component = LonaModule.current.component(named: name) {
            self.component = component
        } else {
            self.component = CSComponentLayer.defaultComponent
            failedToLoad = true
        }
    }

    override func value() -> CSValue {
        if failedToLoad { return CSUndefinedValue }

        let parametersSchema: CSType.Schema = component.parameters.key {(parameter) -> (key: String, value: (CSType, CSAccess)) in
            return (key: parameter.name, value: (parameter.type, .write))
        }

        let parametersMap: [String: CSData] = component.parameters.key {(parameter) -> (key: String, value: CSData) in
            return (key: parameter.name, value: parameters[parameter.name] ?? CSData.Null)
        }

        return CSValue(type: CSType.dictionary(parametersSchema), data: CSData.Object(parametersMap))
    }

    private static var defaultComponent: CSComponent {
        let rootLayer = CSLayer(name: "Failed to Load Component", type: .view)
        return CSComponent(name: nil, canvas: [], rootLayer: rootLayer, parameters: [], cases: [], logic: [], config: CSData.Object([:]), metadata: CSData.Object([:]))
    }

    private static func loadComponent(at path: String) -> CSComponent? {
        guard let url = URL(string: path) else { return nil }
        guard let component = CSComponent(url: url) else { return nil }
        return component
    }

    required init(_ json: CSData) {
        if case CSLayer.LayerType.custom(let name) = LayerType(json.get(key: "type")),
            let component = LonaModule.current.component(named: name) {
            self.component = component
        } else {
            self.component = CSComponentLayer.defaultComponent
            failedToLoad = true
        }

        super.init(json)
    }

    override init(name: String, type: LayerType, parameters: [String: CSData] = [:], children: [CSLayer] = []) {
        if case CSLayer.LayerType.custom(let name) = type,
            let component = LonaModule.current.component(named: name) {
            self.component = component
        } else {
            self.component = CSComponentLayer.defaultComponent
            failedToLoad = true
        }

        super.init(name: name, type: type, parameters: parameters, children: children)
    }

    override func encode(parameters: [String: CSData]) -> [String: CSData] {
        var parameters = super.encode(parameters: parameters)

        for (key, value) in parameters {
            guard let parameter = component.parameters.first(where: { arg in arg.name == key }) else { continue }
            parameters[key] = CSValue.compact(type: parameter.type, data: value)
        }

        return parameters
    }

    override func decode(parameters: [String: CSData]) -> [String: CSData] {
        var parameters = super.decode(parameters: parameters)

        for (key, value) in parameters {
            guard let parameter = component.parameters.first(where: { arg in arg.name == key }) else { continue }
            parameters[key] = CSValue.expand(type: parameter.type, data: value)
        }

        return parameters
    }

}
