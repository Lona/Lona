//
//  CSParameter.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/26/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import AppKit

public extension NSPasteboard.PasteboardType {
    static let lonaParameter = NSPasteboard.PasteboardType(rawValue: "lona.parameter")
}

struct CSParameter: CSDataDeserializable, CSDataSerializable {
    var name: String = "parameter"
    var type: CSType = CSType.string
    var defaultValue: CSValue = CSUndefinedValue

    var hasDefaultValue: Bool {
        return defaultValue != CSUndefinedValue
    }

    var initialValue: CSValue {
        return CSValue.exampleValue(for: type)
    }

    init() {}

    init(_ json: CSData) {
        name = json.get(key: "name").stringValue
        type = CSType(json.get(key: "type"))

        if let object = json["defaultValue"] {
            defaultValue = CSValue(object)
        }
    }

    init(name: String, type: CSType, defaultValue: CSValue = CSUndefinedValue) {
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
    }

    func toData() -> CSData {
        var data = CSData.Object([
            "name": name.toData(),
            "type": type.toData()
        ])

        if defaultValue != CSUndefinedValue {
            data["defaultValue"] = defaultValue.toData()
        }

        return data
    }
}

extension CSParameter {
    static func csType(from parameters: [CSParameter]) -> CSType {
        let parametersSchema: CSType.Schema = parameters.key {(parameter) -> (key: String, value: (CSType, CSAccess)) in
            return (key: parameter.name, value: (parameter.type, .write))
        }

        return CSType.dictionary(parametersSchema)
    }
}

extension CSParameter: Equatable {
    static func == (lhs: CSParameter, rhs: CSParameter) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type && lhs.defaultValue == rhs.defaultValue
    }
}

extension CSParameter {
    static func defaultDataObject(for parameters: [CSParameter]) -> [String: CSData] {
        var data: [String: CSData] = [:]

        parameters.forEach({ parameter in
            data[parameter.name] = parameter.hasDefaultValue
                ? parameter.defaultValue.data
                : CSValue.defaultValue(for: parameter.type).data
        })

        return data
    }
}

extension CSParameter {
    func makeAssignmentExpression(layerName: String) -> LonaExpression {
        let expr: LonaExpression = .assignmentExpression(
            AssignmentExpressionNode(
                assignee: .memberExpression(
                    [
                        .identifierExpression("layers"),
                        .identifierExpression(layerName),
                        .identifierExpression(name)
                    ]
                ),
                content: .memberExpression(
                    [
                        .identifierExpression("parameters"),
                        .identifierExpression(name)
                    ]
                )
            )
        )

        return expr
    }
}

extension CSParameter {
    func makePasteboardItem(withAssignmentTo layerName: String?) -> NSPasteboardItem {
        let item = NSPasteboardItem()

        if let data = self.toData().toData() {
            item.setData(data, forType: .lonaParameter)
        }

        if let layerName = layerName,
            let data = self.makeAssignmentExpression(layerName: layerName).toData().toData() {
            item.setData(data, forType: .lonaExpression)
        }

        return item
    }
}
