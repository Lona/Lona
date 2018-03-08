//
//  Parameter.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

class CSComponent: DataNode, NSCopying {
    var name: String?
    var canvas: [Canvas]
    var rootLayer: CSLayer
    var parameters: [CSParameter]
    var cases: [CSCase]
    var logic = [LogicNode]()
    var config: CSData
    var metadata: CSData

    enum Metadata: String {
        case description
        case tags
    }

    var label: String {
        return name ?? "Component"
    }

    var canvasLayoutAxis: RenderSurface.Layout {
        get {
            return config.get(key: "canvasLayout").stringValue == "yx"
                ? RenderSurface.Layout.caseXcanvasY
                : RenderSurface.Layout.canvasXcaseY
        }
        set {
            switch newValue {
            case .canvasXcaseY: config["canvasLayout"] = CSData.String("xy")
            case .caseXcanvasY: config["canvasLayout"] = CSData.String("yx")
            }
        }
    }

    required init(name: String?, canvas: [Canvas], rootLayer: CSLayer, parameters: [CSParameter], cases: [CSCase], logic: [LogicNode], config: CSData, metadata: CSData) {
        self.name = name
        self.canvas = canvas
        self.rootLayer = rootLayer
        self.parameters = parameters
        self.cases = cases
        self.logic = logic
        self.config = config
        self.metadata = metadata
    }

    func computedCanvases() -> [Canvas] {
        return canvas.filter({ $0.visible })
    }

    func computedCases(for canvas: Canvas?) -> [CSCaseEntry] {
        // Merge case entries and imported lists into a single flat list
        let list = cases.map({ $0.caseList() }).flatMap({ $0 })

        return list.map({ base in
            var computed: [String: CSData] = [:]

            parameters.forEach { parameter in
                let key = parameter.name

                if let value = base.value[key] {
                    computed[key] = value
                } else if let value = canvas?.parameters[key] {
                    computed[key] = value
                } else if parameter.hasDefaultValue {
                    computed[key] = parameter.defaultValue.data
                }
            }

            return CSCaseEntry(name: base.name, value: CSData.Object(computed), visible: true)
        })
    }

    func parametersType(withAccess access: CSAccess = CSAccess.read) -> CSType {
        let parametersSchema: CSType.Schema = parameters.key { (parameter) -> (key: String, value: (CSType, CSAccess)) in
            return (key: parameter.name, value: (parameter.type, access))
        }

        return CSType.dictionary(parametersSchema)
    }

    func rootScope(canvas: Canvas? = nil) -> CSScope {
        let scope = CSScope()

        let layersSchema = layers.key { (layer) -> (key: String, value: CSType.SchemaRecord) in
            let record: CSType.SchemaRecord = (type: layer.value().type, access: .read)
            return (key: layer.name, value: record)
        }

        let layersMap = layers.key { (layer) -> (key: String, value: CSData) in
            return (key: layer.name, value: layer.value().data)
        }

        if layersMap.count > 0 {
            let layersValue = CSValue(type: CSType.dictionary(layersSchema), data: CSData.Object(layersMap))
            scope.declare(variable: "layers", as: CSVariable(value: layersValue, access: .write))
        }

        var parametersSchema: [String: (type: CSType, access: CSAccess)] = [:]

        let parametersData = parameters
            .reduce(CSData.Object([:])) { (result, parameter) -> CSData in
                var result = result
                parametersSchema[parameter.name] = (type: parameter.type, access: CSAccess.read)
                if case CSType.dictionary(_) = parameter.type {
                    result[parameter.name] = CSValue.defaultValue(for: parameter.type).data
                } else {
                    result[parameter.name] = CSData.Null
                }
                return result
            }

        if parametersData.objectValue.count > 0 {
            let parametersValue = CSValue(type: .dictionary(parametersSchema), data: parametersData)
            scope.declare(variable: "parameters", as: CSVariable(value: parametersValue, access: .read))
        }

        scope.declare(variable: "canvas", as: CSVariable(value: canvas?.value() ?? CSEmptyCanvasValue, access: .read))

        return scope
    }

    func copy(with zone: NSZone? = nil) -> Any {
        return CSComponent(name: name, canvas: canvas, rootLayer: rootLayer, parameters: parameters, cases: cases, logic: logic, config: config, metadata: metadata)
    }

    func child(at index: Int) -> Any {
        return rootLayer
    }

    func childCount() -> Int {
        return 1
    }

    var layers: [CSLayer] {
        var result = [CSLayer]()

        func apply(layer: CSLayer) {
            result.append(layer)

            layer.children.forEach({ apply(layer: $0) })
        }

        apply(layer: rootLayer)

        return result
    }

    func getNewLayerName(startingWith prefix: String) -> String {
        let existing: Int = layers.reduce(0) { (result, layer) in
            let matches = layer.name.capturedGroups(withRegex: "\(prefix).*(\\d+)")

            if matches.isEmpty { return result }

            let number = Int(matches[0].value) ?? 0

            return max(number, result)
        }

        if existing == 0 && layers.index(where: { $0.name == prefix }) == nil {
            return prefix
        }

        let next: String = String(existing + 1)

        return "\(prefix) \(next)"
    }

    func toData() -> CSData? {
        var data = CSData.Object([
            "parameters": CSData.Array(parameters.map({ $0.toData() })),
            "rootLayer": rootLayer.toData(),
            "logic": logic.toData(),
            "canvases": canvas.toData(),
            "cases": cases.toData()
        ])

        var config = self.config
        if config["canvasLayout"]?.stringValue == "xy" {
            config["canvasLayout"] = nil
        }

        if !config.objectValue.isEmpty {
            data["config"] = config
        }

        if !metadata.objectValue.isEmpty {
            data["metadata"] = metadata
        }

        return data
    }

    init(_ json: CSData) {
        parameters = json.get(key: "parameters").arrayValue.map({ CSParameter($0) })
        rootLayer = CSLayer.deserialize(json.get(key: "rootLayer"))!
        logic = json.get(key: "logic").arrayValue.map({ LogicNode($0) })
        canvas = json.get(key: "canvases").arrayValue.map({ Canvas($0) })
        config = json["config"] ?? CSData.Object([:])
        metadata = json["metadata"] ?? CSData.Object([:])
        cases = json.get(key: "cases").arrayValue.map({ CSCase($0) })
    }

    convenience init?(url: URL) {
        guard let data = try? Data(contentsOf: url, options: NSData.ReadingOptions()) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data) else { return nil }

        self.init(CSData.from(json: json))
    }
}
