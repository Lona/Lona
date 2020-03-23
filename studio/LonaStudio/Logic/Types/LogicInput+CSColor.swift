//
//  LogicInput+Color.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/13/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

extension LogicInput {
    static func expression(forColorString colorString: String?) -> LGCExpression {
        switch colorString {
        case .none:
            return .functionCallExpression(
                id: UUID(),
                expression: .memberExpression(
                    id: UUID(),
                    expression: .identifierExpression(
                        id: UUID(),
                        identifier: .init(id: UUID(), string: "Optional")
                    ),
                    memberName: .init(id: UUID(), string: "none")
                ),
                arguments: .empty
            )

        case .some(let value):
            return .functionCallExpression(
                id: UUID(),
                expression: .memberExpression(
                    id: UUID(),
                    expression: .identifierExpression(
                        id: UUID(),
                        identifier: .init(id: UUID(), string: "Optional")
                    ),
                    memberName: .init(id: UUID(), string: "value")
                ),
                arguments: .init(
                    [
                        LGCFunctionCallArgument.argument(
                            id: UUID(),
                            label: nil,
                            expression: .literalExpression(
                                id: UUID(),
                                literal: .color(id: UUID(), value: value)
                            )
                        )
                    ]
                )
            )
        }
    }

    static func makeColorString(node: LGCSyntaxNode) -> String? {
        switch node {
        case .expression(.literalExpression(id: _, literal: .color(id: _, value: let value))):
            return value
        default:
            return nil
        }
    }

    static func suggestionsForColor(isOptional: Bool, node: LGCSyntaxNode, query: String) -> LogicEditor.ConfiguredSuggestions {
        let noneSuggestion = LogicSuggestionItem(
            title: "None",
            category: "No Color".uppercased(),
            node: .expression(
                .memberExpression(
                    id: UUID(),
                    expression: .identifierExpression(
                        id: UUID(),
                        identifier: .init(id: UUID(), string: "Optional")
                    ),
                    memberName: .init(id: UUID(), string: "none")
                )
            )
        )

//        let queryColor = NSColor.parse(css: query)
//
//        let customSuggestion = [
//            LGCExpression.Suggestion.from(literalSuggestion: LGCLiteral.Suggestion.color(for: query))
//            ].compactMap { $0 }
//
        let lowercasedQuery = query.lowercased()
//
//        let systemColorSuggestions: [LogicSuggestionItem] = []

        let systemColorSuggestions = CSColors.colors
            .filter { color in
                if query.isEmpty { return true }

                return color.name.lowercased().contains(lowercasedQuery) || color.id.lowercased().contains(lowercasedQuery)
            }
            .map { color in
                return LogicSuggestionItem(
                    title: color.name,
                    category: "Colors".uppercased(),
                    node: .expression(
                        .functionCallExpression(
                            id: UUID(),
                            expression: .memberExpression(
                                id: UUID(),
                                expression: .identifierExpression(
                                    id: UUID(),
                                    identifier: .init(id: UUID(), string: "Optional")
                                ),
                                memberName: .init(id: UUID(), string: "value")
                            ),
                            arguments: .init(
                                [
                                    LGCFunctionCallArgument.argument(
                                        id: UUID(),
                                        label: nil,
                                        expression: .literalExpression(
                                            id: UUID(),
                                            literal: .color(id: UUID(), value: color.resolvedValue)
                                        )
                                    )
                                ]
                            )
                        )
                    ),
                    style: .colorPreview(code: color.value, color.color)
                )
        }

        return .init(
            (isOptional && (query.isEmpty || "none".contains(lowercasedQuery)) ? [noneSuggestion] : []) + systemColorSuggestions //+ customSuggestion
        )
    }
}
