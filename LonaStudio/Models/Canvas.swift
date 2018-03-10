//
//  Canvas.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

let CSCanvasType = CSType.dictionary([
    "height": (type: CSType.number, access: .read),
    "width": (type: CSType.number, access: .read),
    "aspectRatio": (type: CSType.number, access: .read),
    "index": (type: CSType.number, access: .read),
    "name": (type: CSType.number, access: .read)
])

let CSEmptyCanvasValue = CSValue(type: CSCanvasType, data: .Object([
    "height": CSData.Null,
    "width": CSData.Null,
    "aspectRatio": CSData.Null,
    "index": CSData.Null,
    "name": CSData.Null
]))

class Canvas: CSDataSerializable, CSDataDeserializable, NSCopying {

    var visible: Bool = true
    var name: String = "Canvas"
    var width: Double = 375
    var height: Double = 100
    var heightMode: String = "At Least"
    var backgroundColor: String = "white"
    var exportScale: Double = 1
    var parameters: CSData = CSData.Object([:])

    var label: String {
        return name
    }

    var aspectRatio: Double {
        return width / height
    }

    func value() -> CSValue {
        var data = toData()
        data.set(keyPath: ["aspectRatio"], to: aspectRatio.toData())
        return CSValue(type: CSCanvasType, data: data)
    }

    func dimensionsString() -> String {
        return String(format: "%.0fx%.0f", width * exportScale, height * exportScale)
    }

    static let defaults: Canvas = Canvas()

    init() {}

    required init(_ data: CSData) {
        visible = data.get(key: "visible").bool ?? true
        name = data.get(key: "name").stringValue
        width = data.get(key: "width").numberValue
        height = data.get(key: "height").numberValue
        heightMode = data.get(key: "heightMode").stringValue
        exportScale = data.get(key: "exportScale").number ?? 1
        backgroundColor = data.get(key: "backgroundColor").string ?? "white"
        parameters = data["params"] ?? data["parameters"] ?? CSData.Object([:])
    }

    required init(visible: Bool, name: String, width: Double, height: Double, heightMode: String, exportScale: Double, backgroundColor: String, parameters: CSData = CSData.Object([:])) {
        self.visible = visible
        self.name = name
        self.width = width
        self.height = height
        self.heightMode = heightMode
        self.exportScale = exportScale
        self.backgroundColor = backgroundColor
        self.parameters = parameters
    }

    func toData() -> CSData {
        var data = CSData.Object([
            "name": name.toData(),
            "width": width.toData(),
            "height": height.toData(),
            "heightMode": heightMode.toData()
        ])

        if !visible {
            data["visible"] = visible.toData()
        }

        if exportScale != 1 {
            data["exportScale"] = exportScale.toData()
        }

        if backgroundColor != "white" {
            data["backgroundColor"] = backgroundColor.toData()
        }

        if !parameters.objectValue.isEmpty {
            data["params"] = parameters
        }

        return data
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copyData = toData()
        let copy = Canvas.init(copyData)
        return copy
    }
}
