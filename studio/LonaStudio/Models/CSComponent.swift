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

    var canvasLayoutAxis: StaticCanvasRenderer.Layout {
        get {
            return config.get(key: "deviceLayout").stringValue == "yx"
                ? StaticCanvasRenderer.Layout.caseXcanvasY
                : StaticCanvasRenderer.Layout.canvasXcaseY
        }
        set {
            switch newValue {
            case .canvasXcaseY: config["deviceLayout"] = CSData.String("xy")
            case .caseXcanvasY: config["deviceLayout"] = CSData.String("yx")
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
        let serialized = toData()
        let copy = CSComponent(serialized!)

        return copy as Any
    }

    func child(at index: Int) -> Any {
        return rootLayer
    }

    func childCount() -> Int {
        return 1
    }

    var layers: [CSLayer] {
        return rootLayer.descendantLayers
    }

    func getNewLayerName(basedOn originalName: String, ignoring existingNames: [String] = []) -> String {

        let names = layers.map({ $0.name }) + existingNames

        // Try to use the original name
        if !names.contains(originalName) {
            return originalName
        }

        let baseNameGroups = originalName.capturedGroups(withRegex: "^(.*?) ?\\d*$")

        guard let baseName = baseNameGroups.first?.value else {
            return originalName + " copy"
        }

        // Try to use the basename without any suffix
        if !names.contains(baseName) {
            return baseName
        }

        var index = 0
        var name = baseName

        // Add integer suffixes until we get something unique
        while names.contains(name) {
            index += 1
            name = "\(baseName) \(index)"
        }

        return name
    }

    func toData() -> CSData? {
        let parametersType = CSParameter.csType(from: parameters)

        var data = CSData.Object([
            "params": CSData.Array(parameters.map({ $0.toData() })),
            "root": rootLayer.toData(),
            "logic": logic.toData(),
            "devices": canvas.toData(),
            "examples": CSData.Array(cases.map({ $0.toData(parametersType: parametersType) }))
        ])

        var config = self.config
        if config["deviceLayout"]?.stringValue == "xy" {
            config["deviceLayout"] = nil
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
        parameters = (json["params"] ?? json.get(key: "parameters")).arrayValue.map({ CSParameter($0) })
        rootLayer = CSLayer.deserialize(json["root"] ?? json.get(key: "rootLayer"))!
        logic = json.get(key: "logic").arrayValue.map({ LogicNode($0) })
        canvas = (json["devices"] ?? json.get(key: "canvases")).arrayValue.map({ Canvas($0) })
        config = json["config"] ?? CSData.Object([:])
        metadata = json["metadata"] ?? CSData.Object([:])

        let parametersType = CSParameter.csType(from: parameters)
        cases = (json["examples"] ?? json.get(key: "cases")).arrayValue.map({ CSCase($0, parametersType: parametersType) })
    }

    convenience init?(url: URL) {
        guard let data = try? Data(contentsOf: url, options: NSData.ReadingOptions()) else { return nil }
        guard let json = try? JSONSerialization.jsonObject(with: data) else { return nil }

        self.init(CSData.from(json: json))

        self.name = CSComponent.componentName(from: url)
    }

    static func makeDefaultComponent() -> CSComponent {
        return CSComponent(
            name: "Component",
            canvas: [
                Canvas(visible: true, name: "iPhone SE", width: 320, height: 100, heightMode: "At Least", exportScale: 1, backgroundColor: "white"),
                Canvas(visible: true, name: "iPhone 7", width: 375, height: 100, heightMode: "At Least", exportScale: 1, backgroundColor: "white"),
                Canvas(visible: true, name: "iPhone 7+", width: 414, height: 100, heightMode: "At Least", exportScale: 1, backgroundColor: "white")
                ],
            rootLayer: CSLayer(name: "View", type: .view, parameters: [
                "alignSelf": "stretch".toData()
                ]),
            parameters: [],
            cases: [CSCase.defaultCase],
            logic: [],
            config: CSData.Object([:]),
            metadata: CSData.Object([:])
        )
    }

    static func componentName(from url: URL) -> String {
        return url.deletingPathExtension().lastPathComponent
    }
}

extension CSComponent: Equatable {
    static func == (lhs: CSComponent, rhs: CSComponent) -> Bool {
        return (lhs.name == rhs.name &&
            lhs.canvas == rhs.canvas &&
            lhs.rootLayer == rhs.rootLayer &&
            lhs.parameters == rhs.parameters &&
            lhs.cases == rhs.cases &&
            lhs.logic == rhs.logic &&
            lhs.config == rhs.config &&
            lhs.metadata == rhs.metadata)
    }
}
