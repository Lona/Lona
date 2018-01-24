//
//  CSComponentLayer.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/27/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

class CSComponentLayer: CSLayer {
    var url: String?
    var component: CSComponent!
    var failedToLoad: Bool = false

    func reload() {
        if let path = url {
            component = loadComponent(at: path)
        } else {
            component = defaultComponent
        }
    }

    override func value() -> CSValue {
        if failedToLoad { return CSUndefinedValue }

        let parametersSchema: CSType.Schema = component.parameters.key {
            (parameter) -> (key: String, value: (CSType, CSAccess)) in
            return (key: parameter.name, value: (parameter.type, .write))
        }

        let parametersMap: [String: CSData] = component.parameters.key {
            (parameter) -> (key: String, value: CSData) in
            return (key: parameter.name, value: parameters[parameter.name] ?? CSData.Null)
        }

        return CSValue(type: CSType.dictionary(parametersSchema), data: CSData.Object(parametersMap))
    }

    private var defaultComponent: CSComponent {
        failedToLoad = true
        let rootLayer = CSLayer(name: "Failed to Load Component", type: "View")
        return CSComponent(name: nil, canvas: [], rootLayer: rootLayer, parameters: [], cases: [], logic: [], config: CSData.Object([:]), metadata: CSData.Object([:]))
    }

    private func loadComponent(at path: String) -> CSComponent? {
        guard let url = URL(string: path) else { return defaultComponent }
        guard let component = CSComponent(url: url) else { return defaultComponent }
        failedToLoad = false
        return component
    }

    required init(_ json: CSData) {
        super.init(json)

        let url = json.get(key: "url").stringValue

        if url.hasPrefix("./") {
            self.url = URL(fileURLWithPath: url, relativeTo: CSWorkspacePreferences.workspaceURL).absoluteString
        } else {
            self.url = url
        }

        reload()
    }

    init(name: String, url: String, parameters: [String: CSData] = [:], children: [CSLayer] = []) {
        self.url = url
        super.init(name: name, type: "Component", parameters: parameters, children: children)

        reload()
    }

    override func toData() -> CSData {
        var data = super.toData()

        guard let absolutePathWithProtocol = url else { return data }
        guard let absolutePath = URL(string: absolutePathWithProtocol)?.path else { return data }
        let basePath = CSWorkspacePreferences.workspaceURL.path

        let relativePath = absolutePath.pathRelativeTo(basePath: basePath)

//        Swift.print("absolute path", absolutePath)
//        Swift.print("base path", basePath)
//        Swift.print("relative path", relativePath)

        data["url"] = relativePath?.toData()

        return data
    }
}
