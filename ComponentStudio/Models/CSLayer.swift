//
//  CSLayer.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/26/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import SwiftyJSON
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

class CSLayer: JSONDeserializable, JSONSerializable, DataNode, NSCopying {
    
    // Hack: attach this for use in layout
    var config: ComponentConfiguration? = nil
    
    var name: String = "Layer"
    var type: String = "View"
    var children: [CSLayer] = []
    var parent: CSLayer? = nil
    var parameters: [String: JSON] = [:]
    
//    func parameterData() -> CSData {
//        let map = parameters.mapValues({ CSData.from(json: $0) })
//        return CSData.Object(map)
//    }
    
    func removeParameter(_ key: String) {
        self.parameters.removeValue(forKey: key)
    }
    
    var numberOfLines: Int? {
        get { return parameters["numberOfLines"]?.int }
        set { parameters["numberOfLines"] = JSON(newValue as Any) }
    }
    var visible: Bool {
        get { return parameters["visible"]?.boolValue ?? true }
        set { parameters["visible"] = JSON(newValue as Any) }
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
        set { parameters["resizeMode"] = JSON(newValue?.rawValue as Any) }
    }
    
    var image: String? {
        get { return parameters["image"]?.string }
        set { parameters["image"] = JSON(newValue as Any) }
    }
    
    var animation: String? {
        get { return parameters["animation"]?.string }
        set { parameters["animation"] = JSON(newValue as Any) }
    }
    var animationSpeed: Double? {
        get { return parameters["animationSpeed"]?.double }
        set { parameters["animationSpeed"] = JSON(newValue as Any) }
    }
    var position: PositionType? {
        get { return PositionType(rawValue: parameters["position"]?.string ?? "") }
        set { parameters["position"] = JSON(newValue?.rawValue as Any) }
    }
    var top: Double? {
        get { return parameters["top"]?.double }
        set { parameters["top"] = JSON(newValue as Any) }
    }
    var right: Double? {
        get { return parameters["right"]?.double }
        set { parameters["right"] = JSON(newValue as Any) }
    }
    var bottom: Double? {
        get { return parameters["bottom"]?.double }
        set { parameters["bottom"] = JSON(newValue as Any) }
    }
    var left: Double? {
        get { return parameters["left"]?.double }
        set { parameters["left"] = JSON(newValue as Any) }
    }
    var flex: Double? {
        get { return parameters["flex"]?.double }
        set { parameters["flex"] = JSON(newValue as Any) }
    }
    var itemSpacing: Double? {
        get { return parameters["itemSpacing"]?.double }
        set { parameters["itemSpacing"] = JSON(newValue as Any) }
    }
    var width: Double? {
        get { return parameters["width"]?.double }
        set { parameters["width"] = JSON(newValue as Any) }
    }
    var height: Double? {
        get { return parameters["height"]?.double }
        set { parameters["height"] = JSON(newValue as Any) }
    }
//    var padding: Double? {
//        get { return parameters["padding"]?.double }
//        set { parameters["padding"] = JSON(newValue as Any) }
//    }
    var paddingLeft: Double? {
        get { return parameters["paddingLeft"]?.double }
        set { parameters["paddingLeft"] = JSON(newValue as Any) }
    }
    var paddingTop: Double? {
        get { return parameters["paddingTop"]?.double }
        set { parameters["paddingTop"] = JSON(newValue as Any) }
    }
    var paddingRight: Double? {
        get { return parameters["paddingRight"]?.double }
        set { parameters["paddingRight"] = JSON(newValue as Any) }
    }
    var paddingBottom: Double? {
        get { return parameters["paddingBottom"]?.double }
        set { parameters["paddingBottom"] = JSON(newValue as Any) }
    }
//    var margin: Double? {
//        get { return parameters["margin"]?.double }
//        set { parameters["margin"] = JSON(newValue as Any) }
//    }
    var marginLeft: Double? {
        get { return parameters["marginLeft"]?.double }
        set { parameters["marginLeft"] = JSON(newValue as Any) }
    }
    var marginTop: Double? {
        get { return parameters["marginTop"]?.double }
        set { parameters["marginTop"] = JSON(newValue as Any) }
    }
    var marginRight: Double? {
        get { return parameters["marginRight"]?.double }
        set { parameters["marginRight"] = JSON(newValue as Any) }
    }
    var marginBottom: Double? {
        get { return parameters["marginBottom"]?.double }
        set { parameters["marginBottom"] = JSON(newValue as Any) }
    }
    var aspectRatio: Double? {
        get { return parameters["aspectRatio"]?.double }
        set { parameters["aspectRatio"] = JSON(newValue as Any) }
    }
    
    // Border
    var borderRadius: Double? {
        get { return parameters["borderRadius"]?.double }
        set { parameters["borderRadius"] = JSON(newValue as Any) }
    }
    var borderColor: String? {
        get { return parameters["borderColor"]?.string }
        set { parameters["borderColor"] = JSON(newValue as Any) }
    }
    var borderWidth: Double? {
        get { return parameters["borderWidth"]?.double }
        set { parameters["borderWidth"] = JSON(newValue as Any) }
    }
    
    var backgroundColor: String? {
        get { return parameters["backgroundColor"]?.string }
        set { parameters["backgroundColor"] = JSON(newValue as Any) }
    }
    var backgroundGradient: String? {
        get { return parameters["backgroundGradient"]?.string }
        set { parameters["backgroundGradient"] = JSON(newValue as Any) }
    }
    var text: String? {
        get { return parameters["text"]?.string }
        set { parameters["text"] = JSON(newValue as Any) }
    }
    var font: String? {
        get { return parameters["font"]?.string }
        set { parameters["font"] = JSON(newValue as Any) }
    }
    var flexDirection: String? {
        get { return parameters["flexDirection"]?.string }
        
        // We need to rewrite sizingRules for children
        set {
            let widthSizingRules = children.map({ $0.widthSizingRule })
            let heightSizingRules = children.map({ $0.heightSizingRule })
            
            // Actually set the value - this will change what children sizingRule getters return
            parameters["flexDirection"] = JSON(newValue as Any)
            
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
        set { parameters["alignItems"] = JSON(newValue as Any) }
    }
    var justifyContent: String? {
        get { return parameters["justifyContent"]?.string }
        set { parameters["justifyContent"] = JSON(newValue as Any) }
    }
    var alignSelf: String? {
        get { return parameters["alignSelf"]?.string }
        set { parameters["alignSelf"] = JSON(newValue as Any) }
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
    
    static func deserialize(_ json: JSON) -> CSLayer? {
        let type = json["type"].stringValue
        
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
    
    required init(_ json: JSON) {
        name = json["name"].stringValue
        type = json["type"].stringValue
        parameters = decodeParameters(json["parameters"].dictionaryValue)
        children = json["children"].arrayValue.map({ CSLayer.deserialize($0) }).flatMap({ $0 })
        children.forEach({ $0.parent = self })
    }
    
    init(name: String, type: String, parameters: [String: JSON] = [:], children: [CSLayer] = []) {
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
    
    func decodeParameters(_ json: [String: JSON]) -> [String: JSON] {
        return json
    }
    
    func encodeParameters() -> [String: Any] {
        var parameters = self.parameters.map({ $0 })
        
        for (key, value) in parameters {
            if value.null != nil {
                parameters.removeValue(forKey: key)
            }
        }
        
        return parameters.map({ $0.rawValue });
    }
    
    func toJSON() -> Any? {
        let data: [String: Any?] = [
            "name": name,
            "type": type,
            "parameters": encodeParameters(),
            "children": children.map({ $0.toJSON() }),
        ]
        
        return data
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let serialized = JSON(toJSON()!)
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
        return children.filter({ layer in
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
}
