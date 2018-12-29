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
    "index": (type: CSType.number, access: .read),
    "name": (type: CSType.number, access: .read)
])

let CSEmptyCanvasValue = CSValue(type: CSCanvasType, data: .Object([
    "height": CSData.Null,
    "width": CSData.Null,
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
    var device: Device = .custom

    var computedName: String {
        switch device {
        case .preset(let devicePreset):
            if !name.isEmpty && name != devicePreset.name {
                return name
            } else {
                return devicePreset.name
            }
        case .custom:
            return name
        }
    }

    var computedHeight: CGFloat {
        switch device {
        case .custom:
            return CGFloat(height)
        case .preset(let devicePreset):
            switch heightMode {
            case "At Least":
                return 1
            default:
                return devicePreset.height
            }
        }
    }

    var computedWidth: CGFloat {
        switch device {
        case .custom:
            return CGFloat(width)
        case .preset(let devicePreset):
            return devicePreset.width
        }
    }

    var label: String {
        return name
    }

    func value() -> CSValue {
        return CSValue(type: CSCanvasType, data: toData())
    }

    func dimensionsString() -> String {
        return String(format: "%.0fx%.0f", width * exportScale, height * exportScale)
    }

    static let defaults: Canvas = Canvas()

    init() {}

    required init(_ data: CSData) {
        visible = data.get(key: "visible").bool ?? true
        name = data.get(key: "name").stringValue
        heightMode = data.get(key: "heightMode").stringValue

        if let deviceId = data.get(key: "deviceId").string,
            let devicePreset = Canvas.devicePresets.first(where: { $0.name == deviceId }) {
            device = .preset(devicePreset)

            width = Double(devicePreset.width)

            if heightMode == "At Least" {
                height = 1
            } else {
                height = Double(devicePreset.height)
            }
        } else {
            device = .custom

            width = data.get(key: "width").numberValue
            height = data.get(key: "height").numberValue
        }

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

        switch device {
        case .preset(let devicePreset):
            data["deviceId"] = devicePreset.name.toData()

            if !name.isEmpty && name != devicePreset.name {
                data["name"] = name.toData()
            }
        case .custom:
            data["width"] = width.toData()
            data["height"] = height.toData()
            data["name"] = name.toData()
        }

        return data
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copyData = toData()
        let copy = Canvas.init(copyData)
        return copy
    }
}

extension Canvas: Equatable {
    static func == (lhs: Canvas, rhs: Canvas) -> Bool {
        return (lhs.visible == rhs.visible &&
            lhs.name == rhs.name &&
            lhs.width == rhs.width &&
            lhs.height == rhs.height &&
            lhs.heightMode == rhs.heightMode &&
            lhs.backgroundColor == rhs.backgroundColor &&
            lhs.exportScale == rhs.exportScale &&
            lhs.parameters == rhs.parameters &&
            lhs.device == rhs.device)
    }
}

extension Canvas {
    enum Device: Equatable {
        case custom
        case preset(DevicePreset)
    }

    struct DevicePreset: Equatable {
        let name: String
        let width: CGFloat
        let height: CGFloat
    }

    static let devicePresets: [DevicePreset] = [
        DevicePreset(name: "iPhone 8", width: 375, height: 667),
        DevicePreset(name: "iPhone 8 Plus", width: 414, height: 736),
        DevicePreset(name: "iPhone SE", width: 320, height: 568),
        DevicePreset(name: "iPhone XS", width: 375, height: 812),
        DevicePreset(name: "iPhone XR", width: 414, height: 896),
        DevicePreset(name: "iPhone XS Max", width: 414, height: 896),
        DevicePreset(name: "iPad", width: 768, height: 1024),
        DevicePreset(name: "iPad Pro 10.5\"", width: 834, height: 1112),
        DevicePreset(name: "iPad Pro 11\"", width: 834, height: 1194),
        DevicePreset(name: "iPad Pro 12.9\"", width: 1024, height: 1366),
        DevicePreset(name: "Pixel 2", width: 412, height: 732),
        DevicePreset(name: "Pixel 2 XL", width: 360, height: 720),
        DevicePreset(name: "Galaxy S8", width: 360, height: 740),
        DevicePreset(name: "Nexus 7", width: 600, height: 960),
        DevicePreset(name: "Nexus 9", width: 768, height: 1024),
        DevicePreset(name: "Nexus 10", width: 800, height: 1280),
        DevicePreset(name: "Desktop", width: 1024, height: 1024),
        DevicePreset(name: "Desktop HD", width: 1440, height: 1024)
    ]
}
