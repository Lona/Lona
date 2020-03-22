//
//  Logic+Suggestions.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/21/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

extension LogicViewController {
    public static let makeStandardSuggestionBuilder: (LGCSyntaxNode, LGCSyntaxNode, LogicFormattingOptions) -> ((String) -> [LogicSuggestionItem]?)? = Memoize.one({
        rootNode, node, formattingOptions in
        return StandardConfiguration.suggestions(rootNode: rootNode, node: node, formattingOptions: formattingOptions)
    })

    public static let suggestionsForNode: ((LGCSyntaxNode, LGCSyntaxNode, String) -> [LogicSuggestionItem]) = { rootNode, node, query in
        let module = LonaModule.current.logic
        let compiled = module.compiled
        let formattingOptions = module.formattingOptions

        let suggestionBuilder = LogicViewController.makeStandardSuggestionBuilder(compiled.programNode, node, formattingOptions)

        if let suggestionBuilder = suggestionBuilder, let suggestions = suggestionBuilder(query) {
            if let (context, substitution) = compiled.unification, let type = context.nodes[node.uuid] {
                let unifiedType = Unification.substitute(substitution, in: type)

                switch node {
                case .expression:
                    if unifiedType == Unification.T.shadow {
                        let shadowLiteralSuggestion = LogicSuggestionItem(
                            title: "Shadow",
                            category: LGCLiteral.Suggestion.categoryTitle,
                            node: .expression(
                                .functionCallExpression(
                                    id: UUID(),
                                    expression: .identifierExpression(id: UUID(), identifier: .init("Shadow")),
                                    arguments: .init([])
                                )
                            )
                        )

                        return [shadowLiteralSuggestion] + suggestions
                    }
                default:
                    break
                }
            }

            return suggestions
        } else {
            // TODO: Should this be root node, or program node?
            return node.suggestions(within: rootNode, for: query)
        }
    }

}
