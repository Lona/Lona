//
//  LogicEditor+Parameters.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/5/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa
import Logic

private let startsWithNumberRegex = try? NSRegularExpression(pattern: #"^\d"#)

extension LogicEditor {
    public static func makeParameterEditorView() -> NSView {
        let canvasView = LogicEditor(
            rootNode: .topLevelParameters(
                LGCTopLevelParameters(id: UUID(), parameters: .next(.placeholder(id: UUID()), .empty))
            )
        )
        canvasView.showsDropdown = true

        LogicCanvasView.minimumLineHeight = 26
        LogicCanvasView.textMargin = CGSize(width: 7, height: 6)
        RichText.AlertStyle.paragraphMargin.bottom = -3
        RichText.AlertStyle.paragraphMargin.right += 4
        RichText.AlertStyle.iconMargin.top += 1

        canvasView.documentationForNode = { syntaxNode, query in
            switch syntaxNode {
//            case .typeAnnotation:
            case .functionParameter:
                func getAlert() -> RichText.BlockElement? {
                    if query.isEmpty { return nil }

                    if query.contains(" ") {
                        return .alert(
                            .error,
                            .paragraph(
                                [.text(.none, "Parameter names can't contain spaces!")]
                            )
                        )
                    }

                    let startsWithNumberMatch = startsWithNumberRegex?.firstMatch(
                        in: query,
                        range: NSRange(location: 0, length: query.count))

                    if startsWithNumberMatch != nil {
                        return .alert(
                            .error,
                            .paragraph(
                                [.text(.none, "Parameter names can't start with numbers!")]
                            )
                        )
                    }

                    if query.first?.isUppercase == true {
                        return .alert(
                            .warning,
                            .paragraph(
                                [.text(.none, "We recommend using camelCased parameter names (the first letter should be lowercase).")]
                            )
                        )
                    }

                    return nil
                }

                return RichText(
                    blocks: [
                        getAlert(),
                        .heading(.title, "Component parameter"),
                        .paragraph(
                            [
                                .text(.none, "Parameters are the "),
                                .text(.bold, "inputs"),
                                .text(.none, " used to configure components. Each parameter has a "),
                                .text(.bold, "name"),
                                .text(.none, ", a "),
                                .text(.bold, "type"),
                                .text(.none, ", and optionally a "),
                                .text(.bold, "default value"),
                                .text(.none, ".")
                            ]
                        ),
                        .heading(.section, "Example"),
                        .paragraph(
                            [
                                .text(.none, "Suppose we want a component with a configurable title. We might define the following parameter:")
                            ]
                        ),
                        .custom(
                            LGCSyntaxNode.functionParameter(
                                .parameter(
                                    id: UUID(),
                                    externalName: nil,
                                    localName: LGCPattern(id: UUID(), name: "titleText"),
                                    annotation: .typeIdentifier(
                                        id: UUID(),
                                        identifier: LGCIdentifier(id: UUID(), string: "String"),
                                        genericArguments: .empty
                                    ),
                                    defaultValue: .none(id: UUID()))
                                ).makeCodeView()
                        ),
                        .heading(.section, "Recommendations"),
                        .paragraph(
                            [
                                .text(.none, "It's best to use "),
                                .text(.link, "camelCase"),
                                .text(.none, " capitalization when choosing parameter names. This is because most JavaScript, Swift, and Kotlin style guides recommend camelCased parameter names. Names can be transformed automatically if needed (for example, when generating a Sketch library).")
                            ]
                        )
                        ].compactMap { $0 }
                )
            default:
                return RichText(blocks: [])
            }
        }
        canvasView.suggestionsForNode = { syntaxNode, query in
            switch syntaxNode {
            case .typeAnnotation:
                let primitiveTypes = CSType.primitiveTypeNames().map { name in
                    LogicSuggestionItem(
                        title: name,
                        category: "Primitive Types".uppercased(),
                        node: LGCSyntaxNode.typeAnnotation(
                            LGCTypeAnnotation.typeIdentifier(
                                id: UUID(),
                                identifier: LGCIdentifier(id: UUID(), string: name),
                                genericArguments: .empty
                            )
                        )
                    )
                }

                let tokenTypes = CSType.tokenTypeNames().map { name in
                    LogicSuggestionItem(
                        title: name,
                        category: "Token Types".uppercased(),
                        node: LGCSyntaxNode.typeAnnotation(
                            LGCTypeAnnotation.typeIdentifier(
                                id: UUID(),
                                identifier: LGCIdentifier(id: UUID(), string: name),
                                genericArguments: .empty
                            )
                        )
                    )
                }

                let functionType = LogicSuggestionItem(
                    title: "Function",
                    category: "Function Types".uppercased(),
                    node: LGCSyntaxNode.typeAnnotation(
                        LGCTypeAnnotation.functionType(
                            id: UUID(),
                            returnType: LGCTypeAnnotation.typeIdentifier(
                                id: UUID(),
                                identifier: LGCIdentifier(id: UUID(), string: "Unit"),
                                genericArguments: .empty
                            ),
                            argumentTypes: .next(
                                LGCTypeAnnotation.typeIdentifier(
                                    id: UUID(),
                                    identifier: LGCIdentifier(id: UUID(), string: "Unit"),
                                    genericArguments: .empty
                                ),
                                .empty
                            )
                        )
                    )
                )

                return (primitiveTypes.sortedByPrefix() + tokenTypes.sortedByPrefix() + [functionType]).titleContains(prefix: query)
            case .functionParameter:
                let defaultItems = syntaxNode.suggestions(within: canvasView.rootNode, for: query)

                return defaultItems.map { item in
                    var copy = item
                    copy.category = "Component Parameter".uppercased()
                    return copy
                }
            case .functionParameterDefaultValue(let value):
                let items = [
                    LogicSuggestionItem(
                        title: "No default",
                        category: "Default Value".uppercased(),
                        node: LGCSyntaxNode.functionParameterDefaultValue(.none(id: UUID()))
                    )
                ]

                var typedItems: [LogicSuggestionItem] = []

                if let inferredType = value.inferType(within: canvasView.rootNode, context: [
                    TypeEntity.nativeType(NativeType(name: "Boolean", parameters: [])),
                    TypeEntity.nativeType(NativeType(name: "Number", parameters: []))
                    ]) {
                    Swift.print("Inferred", inferredType)

                    switch inferredType.entity {
                    case .nativeType(let value):
                        switch value.name {
                        case "Boolean":
                            typedItems = [
                                LogicSuggestionItem(
                                    title: "true",
                                    category: "Literals".uppercased(),
                                    node: LGCSyntaxNode.literal(.boolean(id: UUID(), value: true))
                                ),
                                LogicSuggestionItem(
                                    title: "false",
                                    category: "Literals".uppercased(),
                                    node: LGCSyntaxNode.literal(.boolean(id: UUID(), value: false))
                                )
                                ].compactMap({ item in
                                    switch item.node {
                                    case .literal(let literal):
                                        return LogicSuggestionItem(
                                            title: item.title,
                                            category: item.category,
                                            node: .functionParameterDefaultValue(
                                                LGCFunctionParameterDefaultValue.value(
                                                    id: UUID(),
                                                    expression: LGCExpression.literalExpression(id: UUID(), literal: literal)
                                                )
                                            )
                                        )
                                    default:
                                        return nil
                                    }
                                })
                        default:
                            break
                        }
                    case .genericType:
                        break
                    case .functionType:
                        break
                    }
                }

                return items.titleContains(prefix: query) + typedItems.titleContains(prefix: query).sortedByPrefix()
            default:
                return []
            }
        }

        canvasView.fillColor = Colors.contentBackground
        return canvasView
    }
}
