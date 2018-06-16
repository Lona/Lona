//
//  CSParameterLayer.swift
//  LonaStudio
//
//  Created by devin_abbott on 6/15/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation

class CSParameterLayer: CSLayer {
    var parameterName: String = "children"

    required init(_ json: CSData) {
        super.init(json)
    }

    init(name: String, parameterName: String, children: [CSLayer] = []) {
        let parameters: [String: CSData] = ["parameterName": parameterName.toData()]

        super.init(name: name, type: .builtIn(.children), parameters: parameters, children: children)

        self.parameterName = parameterName
    }

    override func encode(parameters: [String: CSData]) -> [String: CSData] {
        var parameters = super.encode(parameters: parameters)

        parameters["parameterName"] = parameterName.toData()

        return parameters
    }

    override func decode(parameters: [String: CSData]) -> [String: CSData] {
        var parameters = super.decode(parameters: parameters)

        parameterName = parameters["parameterName"]?.stringValue ?? "children"

        return parameters
    }
}
