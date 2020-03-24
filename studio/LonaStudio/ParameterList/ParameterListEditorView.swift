//
//  ParameterListEditorView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa
import Logic

class ParameterListEditorView: NSView {

    // MARK: Lifecycle

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        setUpViews()
        setUpConstraints()

        update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var types: [CSType] = [] {
        didSet {
            if types != oldValue {
                update()
            }
        }
    }

    var fillColor: NSColor {
        get { return logicEditor.fillColor }
        set { logicEditor.fillColor = newValue }
    }

    var parameterList: [CSParameter] {
        get { return ParameterListEditorView.makeParameterList(from: logicEditor.rootNode, types: types) }
        set {
            let newRootNode = ParameterListEditorView.makeRootNode(from: newValue)
            if logicEditor.rootNode != newRootNode {
                logicEditor.rootNode = newRootNode
                update()
            }
        }
    }

    var onChange: ([CSParameter]) -> Void = {_ in }

    // MARK: Private

    private var logicEditor = LogicEditor.makeParameterEditorView()

    private func setUpViews() {
        addSubview(logicEditor)
        
        logicEditor.onChangeRootNode = { [unowned self] rootNode in
            self.onChange(ParameterListEditorView.makeParameterList(from: rootNode, types: self.types))

            return true
        }
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        logicEditor.translatesAutoresizingMaskIntoConstraints = false

        logicEditor.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        logicEditor.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        logicEditor.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        logicEditor.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func update() {
        logicEditor.suggestionsForNode = LogicEditor.makeParameterSuggestionsHandler(types: types)
    }
}

// MARK: - Logic <==> Parameter Conversion

extension ParameterListEditorView {
    private static func makeParameterList(from rootNode: LGCSyntaxNode, types: [CSType]) -> [CSParameter] {
        switch rootNode {
        case .topLevelParameters(let topLevel):
            return topLevel.parameters.map { param in
                switch param {
                case .placeholder:
                    return nil
                case .parameter(let value):
                    guard let csType = value.annotation.csType(environmentTypes: types) else { return nil }

                    switch value.defaultValue {
                    case .none:
                        return CSParameter(name: value.localName.name, type: csType)
                    case .value(id: _, expression: let expression):
                        return CSParameter(
                            name: value.localName.name,
                            type: csType,
                            defaultValue: LogicInput.makeValue(forType: csType, node: .expression(expression)))
                    }
                }
                }.compactMap { $0 }
        default:
            return []
        }
    }

    private static func makeRootNode(from parameterList: [CSParameter]) -> LGCSyntaxNode {
        return LGCSyntaxNode.topLevelParameters(
            LGCTopLevelParameters(
                id: UUID(),
                parameters: LGCList(
                    parameterList.map { param in
                        return LGCFunctionParameter.parameter(
                            id: UUID(),
                            localName: LGCPattern(id: UUID(), name: param.name),
                            annotation: LGCTypeAnnotation(csType: param.type),
                            defaultValue: param.hasDefaultValue
                                ? .value(id: UUID(), expression: LogicInput.expression(forValue: param.defaultValue))
                                : .none(id: UUID()),
                            comment: nil
                        )
                        } + [LGCFunctionParameter.makePlaceholder()]
                )
            )
        )
    }
}
