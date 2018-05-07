//
//  CSParameter.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/26/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

final class CSParameter: CSDataDeserializable, CSDataSerializable, DataNode {
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

    init(name: String, type: CSType) {
        self.name = name
        self.type = type
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

    func childCount() -> Int { return 0 }
    func child(at index: Int) -> Any { return 0 }
}

extension CSParameter {
    static func csType(from parameters: [CSParameter]) -> CSType {
        let parametersSchema: CSType.Schema = parameters.key {(parameter) -> (key: String, value: (CSType, CSAccess)) in
            return (key: parameter.name, value: (parameter.type, .write))
        }

        return CSType.dictionary(parametersSchema)
    }
}
