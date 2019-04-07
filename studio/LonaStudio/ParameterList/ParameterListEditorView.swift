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

private let startsWithNumberRegex = try? NSRegularExpression(pattern: #"^\d"#)

class ParameterListEditorView: NSView {

    // MARK: Lifecycle

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        setUpViews()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var parameterList: [CSParameter] {
        get { return ParameterListEditorView.makeParameterList(from: logicEditor.rootNode) }
        set {
            let newRootNode = ParameterListEditorView.makeRootNode(from: newValue)
            if logicEditor.rootNode != newRootNode {
                logicEditor.rootNode = newRootNode
            }
        }
    }

    var onChange: ([CSParameter]) -> Void = {_ in }

    // MARK: Private

    private var logicEditor = LogicEditor.makeParameterEditorView()

    private func setUpViews() {
        addSubview(logicEditor)

        logicEditor.onChangeRootNode = { [unowned self] rootNode in
            self.onChange(ParameterListEditorView.makeParameterList(from: rootNode))

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
}

// MARK: Logic <==> Parameter Conversion

extension ParameterListEditorView {
    private static func makeParameterList(from rootNode: LGCSyntaxNode) -> [CSParameter] {
        switch rootNode {
        case .topLevelParameters(let topLevel):
            return topLevel.parameters.map { param in
                switch param {
                case .placeholder:
                    return nil
                case .parameter(let value):
                    guard let csType = value.annotation.csType else { return nil }

                    return CSParameter(name: value.localName.name, type: csType)
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
                            externalName: nil,
                            localName: LGCPattern(id: UUID(), name: param.name),
                            annotation: LGCTypeAnnotation(csType: param.type),
                            defaultValue: .none(id: UUID())
                        )
                        } + [LGCFunctionParameter.makePlaceholder()]
                )
            )
        )
    }
}
