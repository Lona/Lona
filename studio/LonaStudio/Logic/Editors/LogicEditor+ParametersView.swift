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
    static func makeParameterDocumentationHandler() ->
        (LGCSyntaxNode, LogicSuggestionItem, String, LogicFormattingOptions, LogicSuggestionItem.DynamicSuggestionBuilder) -> NSView {
        return { rootNode, suggestion, query, formattingOptions, builder in
            if let view = suggestion.documentation?(builder) {
                return view
            }

            switch suggestion.node {
            case .functionParameter:
                let alert = query.isEmpty
                    ? "I> Type a parameter name!"
                    : query.contains(" ")
                    ? "E> Parameter names can't contain spaces!"
                    : query.first?.isNumber == true
                    ? "E> Parameter names can't start with numbers!"
                    : query.first?.isUppercase == true
                    ? "W> We recommend using **camelCased** parameter names (the first letter should be lowercase)."
                    : ""

                return LightMark.makeScrollView(markdown: """
\(alert.isEmpty ? "" : alert + "\n\n")# Component parameter

Parameters are the inputs used to configure components. Each parameter has a name, a type, and optionally a default value.

## Naming Conventions

It's best to use **camelCase** capitalization when choosing parameter names. This is because most JavaScript, Swift, and Kotlin style guides recommend camelCased parameter names. Names can be transformed automatically if needed (for example, when generating a Sketch library).
""", renderingOptions: .init(formattingOptions: formattingOptions))
            default:
                return NSView()
            }
        }
    }

    static func makeParameterSuggestionsHandler(types: [CSType]) -> (LGCSyntaxNode, LGCSyntaxNode, String) -> LogicEditor.ConfiguredSuggestions {
        return { rootNode, syntaxNode, query in
            switch syntaxNode {
            case .functionParameterDefaultValue:
                guard let parent = rootNode.pathTo(id: syntaxNode.uuid)?.dropLast().last else { return .init([]) }

                switch parent {
                case .functionParameter(.parameter(id: _, localName: _, annotation: let annotation, defaultValue: _, _)):
                    guard let csType = annotation.csType(environmentTypes: types) else { return .init([]) }
                    return .init(
                        [
                            LogicSuggestionItem(
                                title: "No default",
                                category: "NONE",
                                node: .functionParameterDefaultValue(.none(id: UUID()))
                            )
                        ].titleContains(prefix: query) +
                            LogicInput.suggestions(forType: csType, node: syntaxNode, query: query).items.map {
                                var suggestion = $0
                                switch suggestion.node {
                                case .expression(let expression):
                                    suggestion.node = .functionParameterDefaultValue(.value(id: UUID(), expression: expression))
                                    return suggestion
                                default:
                                    fatalError("Only expressions allowed")
                                }
                            }
                    )
                default:
                    return .init([])
                }
            case .typeAnnotation:
                return .init(typeAnnotationSuggestions(query: query, rootNode: rootNode, types: types))
            case .functionParameter:
                let defaultItems = syntaxNode.suggestions(within: rootNode, for: query)

                return .init(
                    defaultItems.map { item in
                        var copy = item
                        copy.category = "Component Parameter".uppercased()
                        return copy
                    }
                )
            default:
                return .init([])
            }
        }
    }

    static func makeParameterEditorView() -> LogicEditor {
        let logicEditor = LogicEditor(rootNode: topLevelParametersRootNode)

        logicEditor.showsDropdown = true
        logicEditor.fillColor = Colors.contentBackground

        LightMark.QuoteKind.paragraphMargin.bottom += 2
        LightMark.QuoteKind.paragraphMargin.right += 4
        LightMark.QuoteKind.iconMargin.top += 1

        logicEditor.documentationForSuggestion = makeParameterDocumentationHandler()
        logicEditor.suggestionsForNode = makeParameterSuggestionsHandler(types: [])

        return logicEditor
    }

    static let topLevelParametersRootNode = LGCSyntaxNode.topLevelParameters(
        LGCTopLevelParameters(id: UUID(), parameters: .next(.placeholder(id: UUID()), .empty))
    )
}
