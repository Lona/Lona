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

let editableFontAttributes: [NSAttributedStringKey: Any] = [
    NSAttributedStringKey.font: NSFont.systemFont(ofSize: 12),
    NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue | NSUnderlineStyle.patternDot.rawValue,
    NSAttributedStringKey.foregroundColor: NSColor.parse(css: "#4A90E2")!
]

let disabledFontAttributes: [NSAttributedStringKey: Any] = [
    NSAttributedStringKey.font: NSFont.systemFont(ofSize: 12),
    NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue | NSUnderlineStyle.patternDot.rawValue,
    NSAttributedStringKey.foregroundColor: NSColor.gray
]

class CSStatementView: NSTableCellView {

    enum Component {
        case text(String)
        case function(String, String)
        case value(String, CSValue, [String])
        case identifier(String, CSScope, CSType, CSAccess, [String])
    }

    var onChangeValue: (String, CSValue, [String]) -> Void = { _, _, _  in }
    var onAddChild: () -> Void = {  }

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
            rightButton.image = NSImage.init(named: NSImage.Name.addTemplate)!
            rightButton.imageScaling = .scaleProportionallyDown
            rightButton.onPress = { [unowned self] in self.onAddChild() }

            self.addSubview(rightButton)

            rightAnchor.constraint(equalTo: rightButton.rightAnchor, constant: 3).isActive = true
            centerYAnchor.constraint(equalTo: rightButton.centerYAnchor).isActive = true
        }
    }

    func setup(components: [Component]) {
        components.map { render(component: $0) }.forEach { view in
            stackView.addArrangedSubview(view)
        }
    }

    func render(component: Component) -> NSView {
        switch component {
        case .text(let string):
            let field = TextField(frame: NSRect(x: 0, y: 0, width: 80, height: 16))
            field.isEditable = false
            field.isBordered = false
            field.drawsBackground = true
            field.backgroundColor = NSColor.clear
            field.value = string
            field.usesSingleLineMode = true

            let font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
            let attributedString = NSAttributedString(string: string, attributes: [NSAttributedStringKey.font: font])
            field.frame.size = attributedString.measure(width: 1000)
            //                name.frame.size.width += 10

            return field
        case .function(let name, let value):
            let values = CSFunction.registeredFunctionDeclarations

            let control = CustomPopupField<String>(
                values: values,
                initialValue: value,
                displayValue: { CSFunction.getFunction(declaredAs: $0).name },
                view: { declaration in
                    let function = CSFunction.getFunction(declaredAs: declaration)

                    let titleText = NSTextField(labelWithString: function.name)
                    let titleFont = NSFont.boldSystemFont(ofSize: 13)
                    titleText.font = titleFont

                    let subtitleText = NSTextField(labelWithString: function.description)
                    let subtitleFont = NSFont.systemFont(ofSize: 10)
                    subtitleText.font = subtitleFont

                    let view = NSStackView(views: [
                        titleText,
                        subtitleText
                        ], orientation: .vertical)
                    view.spacing = 0
                    view.alignment = .leading

                    let inset: CGFloat = 8
                    let width = max(subtitleText.intrinsicContentSize.width, titleText.intrinsicContentSize.width) + inset * 2
                    view.frame = NSRect(x: 0, y: 0, width: width, height: 34)
                    view.edgeInsets = NSEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)

                    return view
            },
                onChange: { [unowned self] declaration in
                    self.handleChange(component: component, componentName: name, value: CSValue(type: CSType.string, data: CSData.String(declaration)), keyPath: [])
            },
                frame: NSRect(x: 0, y: 0, width: 70, height: 26)
            )

            control.isBordered = false

            return control
        case .value(let name, let value, let keyPath):
            let control = CSValueField(value: value)

            control.onChangeData = { [unowned self] data in
                self.handleChange(component: component, componentName: name, value: CSValue(type: value.type, data: data), keyPath: keyPath)
            }

            return control.view
        case .identifier(let name, let scope, let type, let access, let keyPath):
            let frame = NSRect(x: 0, y: 0, width: 70, height: 26)
            var dictionary = scope.data(typed: type, accessed: access)
            dictionary[CSFunction.Argument.noneValue] = CSData.Null
            dictionary[CSFunction.Argument.customValue] = CSData.Null
            let control = MultilevelPopupField(frame: frame, data: dictionary, initialValue: keyPath)

            control.onChangeData = { [unowned self] keyPath in
                let path = keyPath.arrayValue.map({ $0.stringValue })

                if path[0] == CSFunction.Argument.customValue {
                    self.handleChange(component: component, componentName: name, value: CSValue(type: .number, data: .Number(20)), keyPath: [])
                } else {
                    self.onChangeValue(name, scope.getValueAt(keyPath: path), path)
                }
            }

            let attributedString = NSAttributedString(string: keyPath.joined(separator: " → "), attributes: editableFontAttributes)
            let size = attributedString.measure(width: 1000)

            control.frame.size = size
            control.frame.size.width += 24
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

            return control
        }
    }

    static func automaticallySetNextArguments(for invocation: CSFunction.Invocation) -> CSFunction.Invocation {
        let function = CSFunction.getFunction(declaredAs: invocation.name)

        var updated = invocation

        outer: for parameter in function.parameters where invocation.arguments[parameter.name] == nil {
            switch parameter.type {
            case .declaration, .variable:
                break outer
            case .keyword(let type):
                let value = CSValue.defaultValue(for: type)
                updated.arguments[parameter.name] = CSFunction.Argument.value(value)
            }
        }

        return updated
    }

    static func view(for invocation: CSFunction.Invocation, in scope: CSScope) -> CSStatementView {
        var components: [CSStatementView.Component] = []

        let rect = NSRect(x: 0, y: 0, width: 2000, height: 30)
        let nameComponent = CSStatementView.Component.function("functionName", invocation.name)

        components.append(nameComponent)

        let function = CSFunction.getFunction(declaredAs: invocation.name)
        outer: for parameter in function.parameters {
            if let label = parameter.label {
                components.append(.text(label))
            }

            func needsInput(_ keyPath: [String]) {
                switch parameter.type {
                case .declaration:
                    let value = CSValue(type: CSType.string, data: "".toData())
                    components.append(.value(parameter.name, value, []))
                case .variable(type: let variableType, access: let access):
                    let type = invocation.concreteTypeForArgument(named: parameter.name, in: scope) ?? variableType
                    components.append(.identifier(parameter.name, scope, type, access, keyPath))
                case .keyword(type: let type):
                    let value = CSValue.defaultValue(for: type)
                    components.append(.value(parameter.name, value, CSFunction.Argument.customValueKeyPath))
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
                    case .declaration:
                        components.append(.value(parameter.name, value, []))
                    // TODO Use this instead of custom key path stuff?
                    case .variable(type: _, access: _):
                        let typeValue = CSUnitValue.wrap(in: CSType.parameterType(), tagged: value.type.toString())
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

    private var stackView = NSStackView()

    init(frame frameRect: NSRect, components: [Component]) {
        super.init(frame: frameRect)

        setup(components: components)

        setUpViews()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpViews() {
        stackView.orientation = .horizontal
        stackView.distribution = .fill
        stackView.spacing = 0

        addSubview(stackView)
    }

    func setUpConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    // Respond to clicks within text fields only, because other clicks will be duplicates of events passed to mouseDown
    func mouseDownForTextFields(with event: NSEvent) -> Bool {
        // If shift or command are being held, we're selecting rows, so ignore
        if event.modifierFlags.contains(NSEvent.ModifierFlags.command) ||
            event.modifierFlags.contains(NSEvent.ModifierFlags.shift) {
            return false
        }

        var activated = false
        let selfPoint = convert(event.locationInWindow, from: nil)

        func findTextField(view: NSView, point: NSPoint) {
            if activated { return }

            if view.tag == EDITABLE_TEXT_FIELD_TAG {
                if view.frame.contains(point) {
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
