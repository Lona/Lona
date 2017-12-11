//
//  LayerInspectorView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/4/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class LayerInspectorView: InspectorView {
    
    enum ChangeType {
        case canvas
        case full
    }
    
    var onChangeInspector: (ChangeType) -> Void = {_ in}
    
    init(frame frameRect: NSRect, layer: CSLayer) {
        let properties: Properties = [
            // Layout
            InspectorView.Property.direction: CSData.String(layer.flexDirection ?? "column"),
            InspectorView.Property.horizontalAlignment: CSData.String(layer.horizontalAlignment),
            InspectorView.Property.verticalAlignment: CSData.String(layer.verticalAlignment),
            InspectorView.Property.widthSizingRule: CSData.String(layer.widthSizingRule.toString()),
            InspectorView.Property.heightSizingRule: CSData.String(layer.heightSizingRule.toString()),
            InspectorView.Property.itemSpacing: CSData.Number(layer.itemSpacing ?? 0),
            InspectorView.Property.itemSpacingRule: CSData.String(layer.itemSpacingRule.toString()),
            
            // Box Model
            InspectorView.Property.position: CSData.String(layer.position?.rawValue ?? "relative"),
            InspectorView.Property.top: CSData.Number(layer.top ?? 0),
            InspectorView.Property.right: CSData.Number(layer.right ?? 0),
            InspectorView.Property.bottom: CSData.Number(layer.bottom ?? 0),
            InspectorView.Property.left: CSData.Number(layer.left ?? 0),
            InspectorView.Property.width: CSData.Number(layer.width ?? 0),
            InspectorView.Property.height: CSData.Number(layer.height ?? 0),
            InspectorView.Property.marginTop: CSData.Number(layer.marginTop ?? 0),
            InspectorView.Property.marginRight: CSData.Number(layer.marginRight ?? 0),
            InspectorView.Property.marginBottom: CSData.Number(layer.marginBottom ?? 0),
            InspectorView.Property.marginLeft: CSData.Number(layer.marginLeft ?? 0),
            InspectorView.Property.paddingTop: CSData.Number(layer.paddingTop ?? 0),
            InspectorView.Property.paddingRight: CSData.Number(layer.paddingRight ?? 0),
            InspectorView.Property.paddingBottom: CSData.Number(layer.paddingBottom ?? 0),
            InspectorView.Property.paddingLeft: CSData.Number(layer.paddingLeft ?? 0),
            InspectorView.Property.aspectRatio: CSData.Number(layer.aspectRatio ?? 0),
            
            // Border
            InspectorView.Property.borderRadius: CSData.Number(layer.borderRadius ?? 0),
            InspectorView.Property.borderColor: CSData.String(layer.borderColor ?? "transparent"),
            InspectorView.Property.borderColorEnabled: CSData.Bool(layer.borderColor != nil),
            InspectorView.Property.borderWidth: CSData.Number(layer.borderWidth ?? 0),
            
            // Color
            InspectorView.Property.backgroundColor: CSData.String(layer.backgroundColor ?? "transparent"),
            InspectorView.Property.backgroundColorEnabled: CSData.Bool(layer.backgroundColor != nil),
            InspectorView.Property.backgroundGradient: CSData.String(layer.backgroundGradient ?? ""),
            
            // Shadow
            InspectorView.Property.shadow: CSData.String(layer.shadow ?? "default"),
            InspectorView.Property.shadowEnabled: CSData.Bool(layer.shadow != nil),
            
            // Text
            InspectorView.Property.text: CSData.String(layer.text ?? ""),
            InspectorView.Property.textStyle: CSData.String(layer.font ?? CSTypography.defaultName),
            InspectorView.Property.numberOfLines: CSData.Number(Double(layer.numberOfLines ?? -1)),
            
            // Image
            InspectorView.Property.image: CSData.String(layer.image ?? ""),
            InspectorView.Property.resizeMode: CSData.String(layer.resizeMode?.rawValue ?? "cover"),
            
            // Animation
            InspectorView.Property.animation: CSData.String(layer.animation ?? ""),
            InspectorView.Property.animationSpeed: CSData.Number(layer.animationSpeed ?? 1),
        ]
        
        super.init(frame: frameRect, layerType: layer.type, properties: properties)
        
        self.onChangeProperty = { property, value in
            var changeType: ChangeType = .canvas
            
            switch property {
                
            // Layout
            case .direction: layer.flexDirection = value.stringValue
            case .horizontalAlignment:
                layer.horizontalAlignment = value.stringValue
                changeType = .full
            case .verticalAlignment:
                layer.verticalAlignment = value.stringValue
                changeType = .full
            case .widthSizingRule:
                layer.widthSizingRule = DimensionSizingRule.fromString(rawValue: value.stringValue)
                changeType = .full
            case .heightSizingRule:
                layer.heightSizingRule = DimensionSizingRule.fromString(rawValue: value.stringValue)
                changeType = .full
            case .itemSpacingRule:
                layer.itemSpacingRule = DimensionSizingRule.fromString(rawValue: value.stringValue)
                changeType = .full
            case .itemSpacing: layer.itemSpacing = value.numberValue
                
            // Box Model
            case .position: layer.position = PositionType(rawValue: value.stringValue)
            case .top: layer.top = value.numberValue
            case .right: layer.right = value.numberValue
            case .bottom: layer.bottom = value.numberValue
            case .left: layer.left = value.numberValue
            case .width: layer.width = value.numberValue
            case .height: layer.height = value.numberValue
            case .marginTop: layer.marginTop = value.numberValue
            case .marginRight: layer.marginRight = value.numberValue
            case .marginBottom: layer.marginBottom = value.numberValue
            case .marginLeft: layer.marginLeft = value.numberValue
            case .paddingTop: layer.paddingTop = value.numberValue
            case .paddingRight: layer.paddingRight = value.numberValue
            case .paddingBottom: layer.paddingBottom = value.numberValue
            case .paddingLeft: layer.paddingLeft = value.numberValue
            case .aspectRatio: layer.aspectRatio = value.numberValue
                
            // Border
            case .borderRadius: layer.borderRadius = value.numberValue
            case .borderColor: layer.borderColor = value.stringValue
            case .borderColorEnabled: layer.borderColor = value.boolValue ? "transparent" : nil
            case .borderWidth: layer.borderWidth = value.numberValue
                
            // Color
            case .backgroundColor: layer.backgroundColor = value.stringValue
            case .backgroundColorEnabled: layer.backgroundColor = value.boolValue ? "transparent" : nil
            case .backgroundGradient: layer.backgroundGradient = value.string
            
            // Shadow
            case .shadowEnabled: layer.shadow = value.boolValue ? CSShadows.unstyledDefaultName : nil
            case .shadow: layer.shadow = value.stringValue
           
            // Text
            case .text: layer.text = value.stringValue
            case .numberOfLines: layer.numberOfLines = Int(value.numberValue)
            case .textStyle: layer.font = value.stringValue
                
            // Image
            case .image: layer.image = value.stringValue
            case .resizeMode: layer.resizeMode = ResizeMode(rawValue: value.stringValue)
                
            // Animation
            case .animation: layer.animation = value.stringValue
            case .animationSpeed: layer.animationSpeed = value.numberValue
            }
            
            self.onChangeInspector(changeType)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

