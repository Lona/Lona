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
    static func rootNode(forColorString colorString: String?) -> LGCSyntaxNode {
        switch colorString {
        case .none:
            return .expression(
                .identifierExpression(
                    id: UUID(),
                    identifier: LGCIdentifier(id: UUID(), string: "none")
                )
            )
        case .some(let value):
            return .expression(
                .literalExpression(
                    id: UUID(),
                    literal: .color(id: UUID(), value: value)
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

    static func suggestionsForColor(isOptional: Bool, node: LGCSyntaxNode, query: String) -> [LogicSuggestionItem] {
        let noneSuggestion = LogicSuggestionItem(
            title: "None",
            category: "No Color".uppercased(),
            node: .expression(
                .identifierExpression(
                    id: UUID(),
                    identifier: LGCIdentifier(id: UUID(), string: "none")
                )
            )
        )

        let queryColor = NSColor.parse(css: query)

        let customSuggestion = LogicSuggestionItem(
            title: "Custom: \(query)",
            category: "Custom Color".uppercased(),
            node: .expression(
                .literalExpression(
                    id: UUID(),
                    literal: .color(id: UUID(), value: query)
                )
            ),
            disabled: queryColor == nil,
            style: queryColor != nil ? .colorPreview(code: query, queryColor!) : .normal
        )

        let lowercasedQuery = query.lowercased()

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
                        .literalExpression(
                            id: UUID(),
                            literal: .color(id: UUID(), value: color.resolvedValue)
                        )
                    ),
                    style: .colorPreview(code: color.value, color.color)
                )
        }

        return (isOptional && query.isEmpty || "none".contains(lowercasedQuery) ? [noneSuggestion] : []) +
            systemColorSuggestions + [customSuggestion]
    }
}
