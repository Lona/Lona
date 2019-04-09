//
//  LogicEditor+ParametersView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/5/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

private let startsWithNumberRegex = try? NSRegularExpression(pattern: #"^\d"#)

extension LogicEditor {
    static func makeDocumentationHandler() -> ((LGCSyntaxNode, String) -> RichText) {
        return { syntaxNode, query in
            switch syntaxNode {
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
    }

    static func makeSuggestionsHandler(rootNode: LGCSyntaxNode, types: [CSType]) -> ((LGCSyntaxNode, String) -> [LogicSuggestionItem]) {
        return { syntaxNode, query in
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

                let optionalType = LogicSuggestionItem(
                    title: "Optional",
                    category: "Generic Types".uppercased(),
                    node: LGCSyntaxNode.typeAnnotation(
                        LGCTypeAnnotation.typeIdentifier(
                            id: UUID(),
                            identifier: LGCIdentifier(id: UUID(), string: "Optional"),
                            genericArguments: .next(
                                LGCTypeAnnotation.typeIdentifier(
                                    id: UUID(),
                                    identifier: LGCIdentifier(id: UUID(), string: "Void"),
                                    genericArguments: .empty
                                ),
                                .empty
                            )
                        )
                    )
                )

                let arrayType = LogicSuggestionItem(
                    title: "Array",
                    category: "Generic Types".uppercased(),
                    node: LGCSyntaxNode.typeAnnotation(
                        LGCTypeAnnotation.typeIdentifier(
                            id: UUID(),
                            identifier: LGCIdentifier(id: UUID(), string: "Array"),
                            genericArguments: .next(
                                LGCTypeAnnotation.typeIdentifier(
                                    id: UUID(),
                                    identifier: LGCIdentifier(id: UUID(), string: "Void"),
                                    genericArguments: .empty
                                ),
                                .empty
                            )
                        )
                    )
                )

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
                                .placeholder(id: UUID()),
                                .empty
                            )
                        )
                    )
                )

                let customTypes: [LogicSuggestionItem] = types.map { csType in
                    switch csType {
                    case .named(let name, _):
                        Swift.print(name, csType, LGCTypeAnnotation(csType: csType))
                        return LogicSuggestionItem(
                            title: name,
                            category: "Custom Types".uppercased(),
                            node: .typeAnnotation(LGCTypeAnnotation(csType: csType))
                        )
                    default:
                        return nil
                    }
                    }.compactMap { $0 }

                return (
                    primitiveTypes.sortedByPrefix() +
                        tokenTypes.sortedByPrefix() +
                        [optionalType, arrayType] +
                        [functionType] +
                        customTypes.sortedByPrefix()
                    ).titleContains(prefix: query)
            case .functionParameter:
                let defaultItems = syntaxNode.suggestions(within: rootNode, for: query)

                return defaultItems.map { item in
                    var copy = item
                    copy.category = "Component Parameter".uppercased()
                    return copy
                }
            default:
                return []
            }
        }
    }

    static func makeParameterEditorView() -> LogicEditor {
        let logicEditor = LogicEditor(rootNode: defaultRootNode)

        logicEditor.showsDropdown = true
        logicEditor.fillColor = Colors.contentBackground

        LogicCanvasView.minimumLineHeight = 26
        LogicCanvasView.textMargin = CGSize(width: 7, height: 6)
        RichText.AlertStyle.paragraphMargin.bottom = -3
        RichText.AlertStyle.paragraphMargin.right += 4
        RichText.AlertStyle.iconMargin.top += 1

        logicEditor.documentationForNode = makeDocumentationHandler()
        logicEditor.suggestionsForNode = makeSuggestionsHandler(rootNode: defaultRootNode, types: [])

        return logicEditor
    }

    static let defaultRootNode = LGCSyntaxNode.topLevelParameters(
        LGCTopLevelParameters(id: UUID(), parameters: .next(.placeholder(id: UUID()), .empty))
    )
}
