//
//  CSLayer.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/26/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Lottie

// TODO Move elsewhere
extension Dictionary {
    init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
    
    func map<OutValue>(_ transform: (Value) throws -> OutValue) rethrows -> [Key: OutValue] {
        return Dictionary<Key, OutValue>(try map { (k, v) in (k, try transform(v)) })
    }
}

enum ResizeMode: String {
    case contain, cover, stretch
    
    func lotViewContentMode() -> LOTViewContentMode {
        switch self {
        case .cover: return .scaleAspectFill
        case .contain: return .scaleAspectFit
        case .stretch: return .scaleToFill
        }
    }
}

enum PositionType: String {
    case relative, absolute
}

extension CSData {
    var int: Int {
        get { return Int(numberValue) }
    }
}

class CSLayer: CSDataDeserializable, CSDataSerializable, DataNode, NSCopying {
    
    // Hack: attach this for use in layout
    var config: ComponentConfiguration? = nil
    
    var name: String = "Layer"
    var type: String = "View"
    var children: [CSLayer] = []
    var parent: CSLayer? = nil
    var parameters: [String: CSData] = [:]

    func removeParameter(_ key: String) {
        parameters.removeValue(forKey: key)
    }

    var numberOfLines: Int? {
        get { return parameters["numberOfLines"]?.int }
        set { parameters["numberOfLines"] = newValue != nil ? Double(newValue!).toData() : nil }
    }
    var visible: Bool {
        get { return parameters["visible"]?.boolValue ?? true }
        set { parameters["visible"] = newValue.toData() }
    }
    var widthSizingRule: DimensionSizingRule {
        get {
            var value: DimensionSizingRule
            
            if self.parent?.flexDirection == "row" {
                if self.flex == 1 {
                    value = .Expand
                } else if self.width != nil {
                    value = .Fixed
                } else {
                    value = .Shrink
                }
            // This case also catches the root level which has no parent.
            // The root level is assumed to be in a "column" parent.
            } else {
                if self.alignSelf == "stretch" {
                    value = .Expand
                } else if self.width == nil {
                    value = .Shrink
                } else {
                    value = .Fixed
                }
            }
            
            return value
        }
        set {
            if self.parent?.flexDirection == "row" {
                switch newValue {
                case .Expand:
                    self.flex = 1
                    removeParameter("width")
                case .Shrink:
                    removeParameter("flex")
                    removeParameter("width")
                case .Fixed:
                    removeParameter("flex")
                    self.width = self.width ?? 0
                }
            } else {
                switch newValue {
                case .Expand:
                    self.alignSelf = "stretch"
                    removeParameter("width")
                case .Shrink:
                    removeParameter("alignSelf")
                    removeParameter("width")
                case .Fixed:
                    removeParameter("alignSelf")
                    self.width = self.width ?? 0
                }
            }
        }
    }
    
    var heightSizingRule: DimensionSizingRule {
        get {
            var value: DimensionSizingRule
            
            if self.parent?.flexDirection == "row" {
                if self.alignSelf == "stretch" {
                    value = .Expand
                } else if self.height == nil {
                    value = .Shrink
                } else {
                    value = .Fixed
                }
            // This case also catches the root level which has no parent.
            // The root level is assumed to be in a "column" parent.
            } else {
                if self.flex == 1 {
                    value = .Expand
                } else if self.height != nil {
                    value = .Fixed
                } else {
                    value = .Shrink
                }
            }
            
            return value
        }
        set {
            if self.parent?.flexDirection == "row" {
                switch newValue {
                case .Expand:
                    self.alignSelf = "stretch"
                    removeParameter("height")
                case .Shrink:
                    removeParameter("alignSelf")
                    removeParameter("height")
                case .Fixed:
                    removeParameter("alignSelf")
                    self.height = self.height ?? 0
                }
            } else {
                switch newValue {
                case .Expand:
                    self.flex = 1
                    removeParameter("height")
                case .Shrink:
                    removeParameter("flex")
                    removeParameter("height")
                case .Fixed:
                    removeParameter("flex")
                    self.height = self.height ?? 0
                }
            }
        }
    }
    
    var itemSpacingRule: DimensionSizingRule {
        get {
            if itemSpacing != nil {
                return DimensionSizingRule.Fixed
            }
            
            if justifyContent == "space-between" {
                return DimensionSizingRule.Expand
            }

            return DimensionSizingRule.Shrink
        }
        set {
            switch newValue {
            case .Fixed:
                itemSpacing = 0
                if justifyContent == "space-between" {
                    justifyContent = "flex-start"
                }
            case .Shrink:
                removeParameter("itemSpacing")
                justifyContent = "flex-start"
            case .Expand:
                removeParameter("itemSpacing")
                justifyContent = "space-between"
            }
        }
    }
    
    var resizeMode: ResizeMode? {
        get { return ResizeMode(rawValue: parameters["resizeMode"]?.string ?? "") }
        set { parameters["resizeMode"] = newValue?.rawValue.toData() }
    }
    
    var image: String? {
        get { return parameters["image"]?.string }
        set { parameters["image"] = newValue?.toData() }
    }
    
    var animation: String? {
        get { return parameters["animation"]?.string }
        set { parameters["animation"] = newValue?.toData() }
    }
    var animationSpeed: Double? {
        get { return parameters["animationSpeed"]?.number }
        set { parameters["animationSpeed"] = newValue?.toData() }
    }
    var position: PositionType? {
        get { return PositionType(rawValue: parameters["position"]?.string ?? "") }
        set { parameters["position"] = newValue?.rawValue.toData() }
    }
    var top: Double? {
        get { return parameters["top"]?.number }
        set { parameters["top"] = newValue?.toData() }
    }
    var right: Double? {
        get { return parameters["right"]?.number }
        set { parameters["right"] = newValue?.toData() }
    }
    var bottom: Double? {
        get { return parameters["bottom"]?.number }
        set { parameters["bottom"] = newValue?.toData() }
    }
    var left: Double? {
        get { return parameters["left"]?.number }
        set { parameters["left"] = newValue?.toData() }
    }
    var flex: Double? {
        get { return parameters["flex"]?.number }
        set { parameters["flex"] = newValue?.toData() }
    }
    var itemSpacing: Double? {
        get { return parameters["itemSpacing"]?.number }
        set { parameters["itemSpacing"] = newValue?.toData() }
    }
    var width: Double? {
        get { return parameters["width"]?.number }
        set { parameters["width"] = newValue?.toData() }
    }
    var height: Double? {
        get { return parameters["height"]?.number }
        set { parameters["height"] = newValue?.toData() }
    }
    var paddingLeft: Double? {
        get { return parameters["paddingLeft"]?.number }
        set { parameters["paddingLeft"] = newValue?.toData() }
    }
    var paddingTop: Double? {
        get { return parameters["paddingTop"]?.number }
        set { parameters["paddingTop"] = newValue?.toData() }
    }
    var paddingRight: Double? {
        get { return parameters["paddingRight"]?.number }
        set { parameters["paddingRight"] = newValue?.toData() }
    }
    var paddingBottom: Double? {
        get { return parameters["paddingBottom"]?.number }
        set { parameters["paddingBottom"] = newValue?.toData() }
    }
    var marginLeft: Double? {
        get { return parameters["marginLeft"]?.number }
        set { parameters["marginLeft"] = newValue?.toData() }
    }
    var marginTop: Double? {
        get { return parameters["marginTop"]?.number }
        set { parameters["marginTop"] = newValue?.toData() }
    }
    var marginRight: Double? {
        get { return parameters["marginRight"]?.number }
        set { parameters["marginRight"] = newValue?.toData() }
    }
    var marginBottom: Double? {
        get { return parameters["marginBottom"]?.number }
        set { parameters["marginBottom"] = newValue?.toData() }
    }
    var aspectRatio: Double? {
        get { return parameters["aspectRatio"]?.number }
        set { parameters["aspectRatio"] = newValue?.toData() }
    }
    
    // Border
    var borderRadius: Double? {
        get { return parameters["borderRadius"]?.number }
        set { parameters["borderRadius"] = newValue?.toData() }
    }
    var borderColor: String? {
        get { return parameters["borderColor"]?.string }
        set { parameters["borderColor"] = newValue?.toData() }
    }
    var borderWidth: Double? {
        get { return parameters["borderWidth"]?.number }
        set { parameters["borderWidth"] = newValue?.toData() }
    }
    
    // Shadow
    var shadow: String? {
        get { return parameters["shadow"]?.string }
        set { parameters["shadow"] = newValue?.toData() }
    }
    var backgroundColor: String? {
        get { return parameters["backgroundColor"]?.string }
        set { parameters["backgroundColor"] = newValue?.toData() }
    }
    var backgroundGradient: String? {
        get { return parameters["backgroundGradient"]?.string }
        set { parameters["backgroundGradient"] = newValue?.toData() }
    }
    var text: String? {
        get { return parameters["text"]?.string }
        set { parameters["text"] = newValue?.toData() }
    }
    var font: String? {
        get { return parameters["font"]?.string }
        set { parameters["font"] = newValue?.toData() }
    }
    var flexDirection: String? {
        get { return parameters["flexDirection"]?.string }
        
        // We need to rewrite sizingRules for children
        set {
            let widthSizingRules = children.map({ $0.widthSizingRule })
            let heightSizingRules = children.map({ $0.heightSizingRule })
            
            // Actually set the value - this will change what children sizingRule getters return
            parameters["flexDirection"] = newValue?.toData()
            
            for (i, value) in widthSizingRules.enumerated() {
                children[i].widthSizingRule = value
            }
            for (i, value) in heightSizingRules.enumerated() {
                children[i].heightSizingRule = value
            }
        }
    }
    var alignItems: String? {
        get { return parameters["alignItems"]?.string }
        set { parameters["alignItems"] = newValue?.toData() }
    }
    var justifyContent: String? {
        get { return parameters["justifyContent"]?.string }
        set { parameters["justifyContent"] = newValue?.toData() }
    }
    var alignSelf: String? {
        get { return parameters["alignSelf"]?.string }
        set { parameters["alignSelf"] = newValue?.toData() }
    }
    
    var horizontalAlignment: String {
        get {
            if flexDirection == "row" {
                if itemSpacingRule == .Expand {
                    return "flex-start"
                }
                
                return justifyContent ?? "flex-start"
            } else {
                return alignItems ?? "flex-start"
            }
        }
        set {
            if flexDirection == "row" {
                justifyContent = newValue
            } else {
                alignItems = newValue
            }
        }
    }
    
    var verticalAlignment: String {
        get {
            if flexDirection == "row" {
                return alignItems ?? "flex-start"
            } else {
                if itemSpacingRule == .Expand {
                    return "flex-start"
                }
                
                return justifyContent ?? "flex-start"
            }
        }
        set {
            if flexDirection == "row" {
                alignItems = newValue
            } else {
                justifyContent = newValue
            }
        }
    }
    
    static func deserialize(_ json: CSData) -> CSLayer? {
        let type = json.get(key: "type").stringValue
        
        if type == "Component" {
            let layer = CSComponentLayer(json)
            
            if layer.failedToLoad {
                layer.name = "Failed to Load"
            }
            
            return layer
        }
        
        return CSLayer(json)
    }
    
    init() {}
    
    required init(_ json: CSData) {
        name = json.get(key: "name").stringValue
        type = json.get(key: "type").stringValue
        parameters = json.get(key: "parameters").objectValue
        children = json.get(key: "children").arrayValue.map({ CSLayer.deserialize($0) }).flatMap({ $0 })
        children.forEach({ $0.parent = self })
    }
    
    init(name: String, type: String, parameters: [String: CSData] = [:], children: [CSLayer] = []) {
        self.name = name
        self.type = type
        self.parameters = parameters
        self.children = children
        children.forEach({ $0.parent = self })
        
        if let rule = parameters["widthSizingRule"] {
            self.widthSizingRule = DimensionSizingRule.fromString(rawValue: rule.stringValue)
            self.parameters.removeValue(forKey: "widthSizingRule")
        }
        
        if let rule = parameters["heightSizingRule"] {
            self.heightSizingRule = DimensionSizingRule.fromString(rawValue: rule.stringValue)
            self.parameters.removeValue(forKey: "heightSizingRule")
        }
    }
    
    func encodeParameters() -> [String: CSData] {
        var parameters = self.parameters
        
        for (key, value) in parameters {
            if value == CSData.Null {
                parameters.removeValue(forKey: key)
            }
        }
        
        return parameters
    }
    
    func toData() -> CSData {
        return CSData.Object([
            "name": name.toData(),
            "type": type.toData(),
            "parameters": CSData.Object(encodeParameters()),
            "children": children.toData(),
        ])
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let serialized = toData()
        let copy = CSLayer.deserialize(serialized)!
        
        copy.parent = self.parent
        copy.config = self.config
        
        return copy as Any
    }
    
    var label: String { return name }
    func childCount() -> Int { return children.count }
    func child(at index: Int) -> Any { return children[index] }
    
    @discardableResult func removeFromParent() -> Int {
        if parent == nil { return -1 }
        
        if let index = parent!.children.index(where: { $0 === self }) {
            parent!.children.remove(at: index)
            
            return index
        }
        
        return -1
    }
    
    func insertChild(_ child: CSLayer, at index: Int) {
        child.removeFromParent()
        
        children.insert(child, at: index)
        child.parent = self
    }
    
    func appendChild(_ child: CSLayer) {
        insertChild(child, at: children.count)
    }
    
    func attributesNames(for type: CSType) -> [String] {
        if let _self = self as? CSComponentLayer {
            let component = _self.component!
            return component.parameters.filter({ $0.type == type }).map({ $0.name })
        }
        
        switch type {
        case .named("Color", .string):
            return ["backgroundColor"]
        case .string:
            return ["backgroundColor", "text", "image", "font"].sorted()
        case .number:
            return [
                "width",
                "height",
                "padding", "paddingVertical", "paddingHorizontal", "paddingLeft", "paddingTop", "paddingRight", "paddingBottom",
                "margin", "marginVertical", "marginHorizontal", "marginLeft", "marginTop", "marginRight", "marginBottom",
                "repeatCount",
            ].sorted()
        case .bool:
            return ["visible"]
        default:
            return []
        }
    }
    
    func visibleChildren(for config: ComponentConfiguration) -> [CSLayer] {
        let dynamicChildren: [CSLayer] = config.get(attribute: "children", for: name).arrayValue.map({ childData in
            let layer = CSLayer.deserialize(childData)
            layer?.config = config
            return layer
        }).flatMap({ $0 })
        
//        Swift.print("dynamic children", dynamicChildren)
        
        return (children + dynamicChildren).filter({ layer in
            var layerVisible = layer.visible
            
//            let textOverride = config.get(attribute: "text", for: layer.name).string
            
            // Don't render text layers without text
            // - A text layer with an empty override
            // - A text layer with no override and an empty default value
//            if layer.text != nil && (textOverride == "" || (textOverride == nil && layer.text == "")) {
//                return false
//            }
            
            if let visible = config.get(attribute: "visible", for: layer.name).bool {
                layerVisible = visible
            }
            
            return layerVisible
        })
    }
    
    func computedChildren(for config: ComponentConfiguration, shouldAssignConfig: Bool = false) -> [CSLayer] {
        return visibleChildren(for: config).reduce([], { (result, layer) in
            var result = result
            var layer = layer
            
            if let componentLayer = layer as? CSComponentLayer {
                let originalLayer = layer
                let originalName = layer.name
                let component = componentLayer.component!
                layer = component.rootLayer
                
                if shouldAssignConfig {
//                    var arguments = componentLayer.parameters
//                    config.getAllAttributes(for: originalName).forEach({ (key, value) in
//                        arguments[key] = JSON(stringLiteral: value)
//                    })
                    
                    // TODO enable
                    layer.config = ComponentConfiguration(
                        component: component,
                        arguments: config.getAllAttributes(for: originalName),
                        canvas: config.canvas
                    )
                    layer.config!.scope.declare(value: "cs:root", as: CSValue(type: .bool, data: .Bool(true)))
                    layer.config!.children = originalLayer.computedChildren(for: layer.config!, shouldAssignConfig: shouldAssignConfig)
                    layer.config!.parentComponentLayer = originalLayer
                    
                    if config.scope.get(value: "cs:selected").data.stringValue == originalName {
                        layer.config!.scope.declare(value: "cs:selected", as: CSValue(type: .string, data: .String(layer.name)))
                    }
//                    if config.has(attribute: "cs:selected", for: originalName) {
//                        layer.config!.set(attribute: "cs:selected", for: layer.name, to: "true")
//                    }
                }
            }
            
            if layer.type == "Children" {
                // TODO Maybe can consolidate and just store the link to the parent
//                if let parent = config.parentComponentLayer {
//                    parent.children.forEach({ result.append($0) })
//                }
                
                // Replace children element placeholder
                if let children = config.children {
                    children.forEach({ result.append($0) })
                // Show children element directly when viewing parent element file
                } else {
                    result.append(layer)
                }
            } else {
                var count = 1
                if let repeatCount = config.get(attribute: "repeatCount", for: layer.name).number {
                    count = Int(repeatCount)
                }
                
                for _ in 0..<count {
                    result.append(layer)
                }
            }
            
            return result
        })
    }
    
    func value() -> CSValue {
        var valueType = CSLayerType
        
        var data = CSData.Object([
            "name": CSData.String(name),
            "visible": CSData.Bool(visible),
            
            // Box model
            "height": CSData.Number(height ?? 0),
            "width": CSData.Number(width ?? 0),
            "marginTop": CSData.Number(marginTop ?? 0),
            "marginRight": CSData.Number(marginRight ?? 0),
            "marginBottom": CSData.Number(marginBottom ?? 0),
            "marginLeft": CSData.Number(marginLeft ?? 0),
            "paddingTop": CSData.Number(paddingTop ?? 0),
            "paddingRight": CSData.Number(paddingRight ?? 0),
            "paddingBottom": CSData.Number(paddingBottom ?? 0),
            "paddingLeft": CSData.Number(paddingLeft ?? 0),
            
            // Color
            "backgroundColor": CSData.String(backgroundColor ?? "transparent"),
            
            // Children
            "children": CSData.Array([]),
        ])
        
        // Text
        if let value = text {
            data["text"] = CSData.String(value)
            data["textStyle"] = CSData.String(font ?? CSTypography.defaultName)
        }
        
        // Image
        if type == "Image" {
            data["image"] = CSData.String(image ?? "")
        }
        
        // Animation
        if type == "Animation",
            let animation = animation,
            let url = URL(string: animation),
            let animationData = AnimationUtils.decode(contentsOf: url)
        {
            let assetMap = AnimationUtils.assetMapValue(from: animationData)
            data["images"] = assetMap.data
            valueType = valueType.merge(key: "images", type: assetMap.type, access: .write)
        }
        
        return CSValue(type: valueType, data: data)
    }
    
    func layerValue() -> CSValue {
        let parametersValue = self.value()
        
        let type = CSType.dictionary([
            "type": (type: .string, access: .write),
            "parameters": (type: parametersValue.type, access: .write)
        ])
        
        let data = CSData.Object([
            "type": self.type.toData(),
            "parameters": parametersValue.data
        ])
        
        return CSValue(type: type, data: data)
    }
}
