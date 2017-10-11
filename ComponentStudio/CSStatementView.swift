//
//  ExpressionTableCell.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/29/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

let EDITABLE_TEXT_FIELD_TAG: Int = 10

let editableFontAttributes: [String: Any] = [
    NSFontAttributeName: NSFont.systemFont(ofSize: 12),
    NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue | NSUnderlineStyle.patternDot.rawValue,
    NSForegroundColorAttributeName: NSColor.parse(css: "#4A90E2")!,
]

let disabledFontAttributes: [String: Any] = [
    NSFontAttributeName: NSFont.systemFont(ofSize: 12),
    NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue | NSUnderlineStyle.patternDot.rawValue,
    NSForegroundColorAttributeName: NSColor.gray,
]

class CSStatementView: NSTableCellView {
    
    enum Component {
        case text(String)
        case value(String, CSValue, [String])
        case identifier(String, CSScope, CSType, CSAccess, [String])
    }
    
    var onChangeValue: (String, CSValue, [String]) -> Void = { _ in }
    var onAddChild: () -> Void = { _ in }
    
    func handleChange(component: Component, componentName: String, value: CSValue, keyPath: [String]) {
//        if keyPath == ["custom", "type"] {
//
//        } else {
            onChangeValue(componentName, value, keyPath)
//        }
    }
    
    var allowsChildren: Bool = false {
        didSet {
            if allowsChildren == false { return }
            
            let rightButton = Button(frame: NSRect(x: 0, y: 0, width: 17, height: 17))
            rightButton.translatesAutoresizingMaskIntoConstraints = false
            rightButton.bezelStyle = .inline
            rightButton.image = NSImage.init(named: NSImageNameAddTemplate)!
            rightButton.imageScaling = .scaleProportionallyDown
            rightButton.onPress = { _ in self.onAddChild() }
            
            self.addSubview(rightButton)
            
            rightAnchor.constraint(equalTo: rightButton.rightAnchor, constant: 3).isActive = true
            centerYAnchor.constraint(equalTo: rightButton.centerYAnchor).isActive = true
        }
    }
    
//    func buildControl(for component: Component) -> CSValueField {
//
//    }
    
    func setup(components: [Component]) {
        for component in components {
            render(component: component)
        }
    }
    
    func render(component: Component) {
        switch component {
        case .text(let string):
            let field = TextField(frame: NSRect(x: 0, y: 0, width: 80, height: 16))
            field.isEditable = false
            field.isBordered = false
            field.drawsBackground = false
            field.value = string
            field.usesSingleLineMode = true
            
            let font = NSFont.systemFont(ofSize: NSFont.systemFontSize())
            let attributedString = NSAttributedString(string: string, attributes: [NSFontAttributeName: font])
            field.frame.size = measureText(string: attributedString, width: 1000)
            //                name.frame.size.width += 10
            field.useYogaLayout = true
            
            addSubview(field)
        case .value(let name, let value, let keyPath):
            let control = CSValueField(value: value)
            
            control.onChangeData = { data in
                self.handleChange(component: component, componentName: name, value: CSValue(type: value.type, data: data), keyPath: keyPath)
            }
            
            addSubview(control.view)
        case .identifier(let name, let scope, let type, let access, let keyPath):
            let frame = NSRect(x: 0, y: 0, width: 70, height: 26)
//                var dictionary = scope.dictionary(access: access)
//            Swift.print("Dictionary", name, type, access, keyPath)
            var dictionary = scope.data(typed: type, accessed: access)
            dictionary[CSFunction.Argument.noneValue] = CSData.Null
            dictionary[CSFunction.Argument.customValue] = CSData.Null
            let control = MultilevelPopupField(frame: frame, data: dictionary, initialValue: keyPath)
            
            control.onChangeData = { keyPath in
                let path = keyPath.arrayValue.map({ $0.stringValue })
                
                if path[0] == CSFunction.Argument.customValue {
                    self.handleChange(component: component, componentName: name, value: CSValue(type: .number, data: .Number(20)), keyPath: [])
                } else {
                    self.onChangeValue(name, scope.getValueAt(keyPath: path), path)
                }
            }
            
            let attributedString = NSAttributedString(string: keyPath.joined(separator: " → "), attributes: editableFontAttributes)
            let size = measureText(string: attributedString, width: 1000)
            
            control.frame.size = size
            control.frame.size.width += 24
            control.useYogaLayout = true
            control.ygNode?.marginLeft = -7
            control.ygNode?.marginBottom = -1
            control.isBordered = false
            
            func styleItems(for menu: NSMenu) {
                for item in menu.items {
                    let desc = String(describing: item.title)
                    let text = NSAttributedString(string: desc, attributes: editableFontAttributes)
                    item.attributedTitle = text
                    
                    if let submenu = item.submenu {
                        styleItems(for: submenu)
                    }
                }
            }
            
            styleItems(for: control.menu!)
            
            addSubview(control)
            
            break
        }
    }
    
    static func view(for invocation: CSFunction.Invocation, in scope: CSScope) -> CSStatementView {
        var components: [CSStatementView.Component] = []
        
        let rect = NSRect(x: 0, y: 0, width: 2000, height: 30)
        
        let type = CSType.enumeration(CSFunction.registeredFunctionNames.map({ CSValue(type: .string, data: .String($0)) }))
        let value = CSValue(type: type, data: .String(invocation.name))
        let nameComponent = CSStatementView.Component.value("functionName", value, [])
        
        components.append(nameComponent)
        
        let function = CSFunction.getFunction(named: invocation.name)
        outer: for parameter in function.parameters {
            if let label = parameter.label {
                components.append(.text(label))
            }
            
            func needsInput(_ keyPath: [String]) {
                switch parameter.type {
                case .variable(type: let variableType, access: let access):
                    let type = invocation.concreteTypeForArgument(named: parameter.name, in: scope) ?? variableType
                    components.append(.identifier(parameter.name, scope, type, access, keyPath))
                case .keyword(type: let type):
                    let value = CSValue(type: type, data: .Null)
                    components.append(.value(parameter.name, value, CSFunction.Argument.customValueKeyPath))
                default:
                    break
                }
            }
            
            if let argument = invocation.arguments[parameter.name] {
                switch argument {
                case .identifier(_, let keyPath):
                    if keyPath != CSFunction.Argument.noneKeyPath {
                        let type = invocation.concreteTypeForArgument(named: parameter.name, in: scope) ?? parameter.variableType
                        components.append(.identifier(parameter.name, scope, type, parameter.access, keyPath))
                    } else {
                        needsInput(CSFunction.Argument.noneKeyPath)
                        break outer
                    }
                case .value(let value):
                    switch parameter.type {
                    // TODO Use this instead of custom key path stuff?
                    case .variable(type: _, access: _):
                        let typeValue = CSValue(type: CSParameterType, data: .String(value.type.toString()))
                        needsInput(CSFunction.Argument.customKeyPath)
                        
                        // If we know the concrete type for a custom variable, cast to that automatically
                        if let type = invocation.concreteTypeForArgument(named: parameter.name, in: scope) {
                            let typedValue = value.type == type ? value : value.cast(to: type)
                            components.append(.value(parameter.name, typedValue, CSFunction.Argument.customValueKeyPath))
                        } else {
                            components.append(.value(parameter.name, typeValue, CSFunction.Argument.customTypeKeyPath))
                            components.append(.value(parameter.name, value, CSFunction.Argument.customValueKeyPath))
                        }
                    case .keyword(type: _):
                        components.append(.value(parameter.name, value, CSFunction.Argument.customValueKeyPath))
                    default:
                        break
                    }
                }
            } else {
                needsInput(CSFunction.Argument.noneKeyPath)
                break outer
            }
        }
        
        let statementView = CSStatementView(frame: rect, components: components)
        statementView.allowsChildren = function.hasBody
        
        return statementView
    }
    
    init(frame frameRect: NSRect, components: [Component]) {
        super.init(frame: frameRect)
        
        self.useYogaLayout = true
        self.ygNode?.flexDirection = .row
        self.ygNode?.alignItems = .center
        self.ygNode?.paddingLeft = 4
        
        setup(components: components)
        
        layoutWithYoga()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Respond to clicks within text fields only, because other clicks will be duplicates of events passed to mouseDown
    func mouseDownForTextFields(with event: NSEvent) -> Bool {
        // If shift or command are being held, we're selecting rows, so ignore
        if (
            event.modifierFlags.contains(NSEventModifierFlags.command) ||
            event.modifierFlags.contains(NSEventModifierFlags.shift)
        ) { 
            return false
        }
        
        var activated = false
        let selfPoint = convert(event.locationInWindow, from: nil)
        
        func findTextField(view: NSView, point: NSPoint) {
            if activated { return }
            
            if view.tag == EDITABLE_TEXT_FIELD_TAG {
                if NSPointInRect(point, view.frame) {
                    window?.makeFirstResponder(view)
                    activated = true
                }
            }
            
            for subview in view.subviews {
                findTextField(view: subview, point: point - view.frame.origin)
            }
        }
        
        for subview in subviews {
            findTextField(view: subview, point: selfPoint)
        }
        
        return activated
    }
}
