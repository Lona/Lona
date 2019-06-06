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
    static func makeTypeDocumentationHandler() -> (LGCSyntaxNode, String) -> RichText {
        return { syntaxNode, query in
            switch syntaxNode {
            default:
                return RichText(blocks: [])
            }
        }
    }

    static func makeTypeSuggestionsHandler(types: [CSType]) -> (LGCSyntaxNode, LGCSyntaxNode, String) -> [LogicSuggestionItem] {
        return { rootNode, syntaxNode, query in
            switch syntaxNode {
            case .statement:
                return [
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
                                    )
                                )
                            )
                        )
                    )
                ]
            case .pattern:
                return [
                    LogicSuggestionItem(
                        title: "Type name: \(query)",
                        category: "Pattern".uppercased(),
                        node: LGCSyntaxNode.pattern(LGCPattern(id: UUID(), name: query)),
                        disabled: query.isEmpty
                    )
                ]
            case .enumerationCase:
                return syntaxNode.suggestions(within: rootNode, for: query)
            case .typeAnnotation:
                return typeAnnotationSuggestions(query: query, rootNode: rootNode, types: types)
            default:
                return []
            }
        }
    }

    static func makeTypeEditorView() -> LogicEditor {
        let logicEditor = LogicEditor()

        logicEditor.showsDropdown = true
        logicEditor.fillColor = Colors.contentBackground

        RichText.AlertStyle.paragraphMargin.bottom = -3
        RichText.AlertStyle.paragraphMargin.right += 4
        RichText.AlertStyle.iconMargin.top += 1

        logicEditor.documentationForNode = makeParameterDocumentationHandler()
        logicEditor.suggestionsForNode = makeTypeSuggestionsHandler(types: [])

        return logicEditor
    }
}
