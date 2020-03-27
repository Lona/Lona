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
    public static let suggestionsForNode: ((LGCSyntaxNode, LGCSyntaxNode, String) -> LogicEditor.ConfiguredSuggestions) = { rootNode, node, query in
        let module = LonaModule.current.logic
        let compiled = module.compiled
        let formattingOptions = module.formattingOptions

        // Get scope within this file
        let currentScopeContext = Compiler.scopeContext(rootNode, targetId: node.uuid)

        guard let scopeContext = compiled.scope,
            let unification = compiled.unification,
            let evaluation = compiled.evaluation else { return .init([]) }

        let suggestions = StandardConfiguration.suggestions(
            rootNode: rootNode,
            node: node,
            query: query,
            currentScopeContext: currentScopeContext,
            scopeContext: scopeContext,
            unificationContext: unification.0,
            substitution: unification.1,
            evaluationContext: evaluation,
            formattingOptions: formattingOptions
        )

        if let suggestions = suggestions {
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

                        return .init([shadowLiteralSuggestion] + suggestions)
                    }
                default:
                    break
                }
            }

            return .init(suggestions)
        } else {
            // TODO: Should this be root node, or program node?
            return .init(node.suggestions(within: rootNode, for: query))
        }
    }

}
