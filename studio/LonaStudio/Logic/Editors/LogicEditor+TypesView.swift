//
//  LogicEditor+TypesView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/9/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

private let startsWithNumberRegex = try? NSRegularExpression(pattern: #"^\d"#)

extension LogicEditor {
    static func makeTypeDocumentationHandler() -> (LGCSyntaxNode, String) -> NSView {
        return { syntaxNode, query in
            switch syntaxNode {
            default:
                return NSView()
            }
        }
    }

    static func makeTypeSuggestionsHandler(types: [CSType]) -> (LGCSyntaxNode, LGCSyntaxNode, String) -> LogicEditor.ConfiguredSuggestions {
        return { rootNode, syntaxNode, query in
            switch syntaxNode {
            case .statement:
                return .init(
                    [
                        LogicSuggestionItem(
                            title: "Enumeration",
                            category: "Type Declarations".uppercased(),
                            node: .statement(
                                .declaration(
                                    id: UUID(),
                                    content: .enumeration(
                                        id: UUID(),
                                        name: LGCPattern(id: UUID(), name: "name"),
                                        genericParameters: .empty,
                                        cases: .next(
                                            LGCEnumerationCase.placeholder(id: UUID()),
                                            .empty
                                        ),
                                        comment: nil
                                    )
                                )
                            )
                        )
                    ]
                )
            case .pattern:
                return .init(
                    [
                        LogicSuggestionItem(
                            title: "Type name: \(query)",
                            category: "Pattern".uppercased(),
                            node: LGCSyntaxNode.pattern(LGCPattern(id: UUID(), name: query)),
                            disabled: query.isEmpty
                        )
                    ]
                )
            case .enumerationCase:
                return .init(syntaxNode.suggestions(within: rootNode, for: query))
            case .typeAnnotation:
                return .init(typeAnnotationSuggestions(query: query, rootNode: rootNode, types: types))
            default:
                return .init([])
            }
        }
    }

    static func makeTypeEditorView() -> LogicEditor {
        let logicEditor = LogicEditor()

        logicEditor.showsDropdown = true
        logicEditor.fillColor = Colors.contentBackground

        LightMark.QuoteKind.paragraphMargin.bottom += 2
        LightMark.QuoteKind.paragraphMargin.right += 4
        LightMark.QuoteKind.iconMargin.top += 1

        logicEditor.documentationForSuggestion = makeParameterDocumentationHandler()
        logicEditor.suggestionsForNode = makeTypeSuggestionsHandler(types: [])

        return logicEditor
    }
}
