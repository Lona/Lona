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
    static func makeParameterDocumentationHandler() -> (LGCSyntaxNode, LGCSyntaxNode, String) -> RichText {
        return { rootNode, syntaxNode, query in
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

    static func makeParameterSuggestionsHandler(types: [CSType]) -> (LGCSyntaxNode, LGCSyntaxNode, String) -> [LogicSuggestionItem] {
        return { rootNode, syntaxNode, query in
            switch syntaxNode {
            case .functionParameterDefaultValue:
                guard let parent = rootNode.pathTo(id: syntaxNode.uuid)?.dropLast().last else { return [] }

                switch parent {
                case .functionParameter(.parameter(id: _, externalName: _, localName: _, annotation: let annotation, defaultValue: _)):
                    guard let csType = annotation.csType(environmentTypes: types) else { return [] }
                    return [
                        LogicSuggestionItem(
                            title: "No default",
                            category: "NONE",
                            node: .functionParameterDefaultValue(.none(id: UUID()))
                        )
                    ].titleContains(prefix: query) +
                        LogicInput.suggestions(forType: csType, node: syntaxNode, query: query).map {
                        var suggestion = $0
                        switch suggestion.node {
                        case .expression(let expression):
                            suggestion.node = .functionParameterDefaultValue(.value(id: UUID(), expression: expression))
                            return suggestion
                        default:
                            fatalError("Only expressions allowed")
                        }
                    }
                default:
                    return []
                }
            case .typeAnnotation:
                return typeAnnotationSuggestions(query: query, rootNode: rootNode, types: types)
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
        let logicEditor = LogicEditor(rootNode: topLevelParametersRootNode)

        logicEditor.showsDropdown = true
        logicEditor.fillColor = Colors.contentBackground
        logicEditor.canvasStyle.minimumLineHeight = 26
        logicEditor.canvasStyle.textMargin = CGSize(width: 6, height: 6)

        RichText.AlertStyle.paragraphMargin.bottom = -3
        RichText.AlertStyle.paragraphMargin.right += 4
        RichText.AlertStyle.iconMargin.top += 1

        logicEditor.documentationForNode = makeParameterDocumentationHandler()
        logicEditor.suggestionsForNode = makeParameterSuggestionsHandler(types: [])

        return logicEditor
    }

    static let topLevelParametersRootNode = LGCSyntaxNode.topLevelParameters(
        LGCTopLevelParameters(id: UUID(), parameters: .next(.placeholder(id: UUID()), .empty))
    )
}
