//
//  LogicInput+TextStyle.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/14/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

extension LogicInput {
    static func expression(forTextStyleString string: String?) -> LGCExpression {
        switch string {
        case .none:
            return .identifierExpression(
                id: UUID(),
                identifier: LGCIdentifier(id: UUID(), string: "none")
            )

        case .some(let value):
            return .identifierExpression(
                id: UUID(),
                identifier: LGCIdentifier(id: UUID(), string: value)
            )
        }
    }

    static func makeTextStyleString(node: LGCSyntaxNode) -> String? {
        switch node {
        case .expression(.identifierExpression(id: _, identifier: let identifier)):
            return identifier.string
        default:
            return nil
        }
    }

    static func suggestionsForTextStyle(isOptional: Bool, node: LGCSyntaxNode, query: String) -> LogicEditor.ConfiguredSuggestions {
        let noneSuggestion = LogicSuggestionItem(
            title: "None",
            category: LGCExpression.Suggestion.variablesCategoryTitle,
            node: .expression(
                .identifierExpression(
                    id: UUID(),
                    identifier: LGCIdentifier(id: UUID(), string: "none")
                )
            )
        )

        let lowercasedQuery = query.lowercased()

        let systemSuggestions: [LogicSuggestionItem] = CSTypography.styles
            .filter { style in
                if query.isEmpty { return true }

                return style.name.lowercased().contains(lowercasedQuery) || style.id.lowercased().contains(lowercasedQuery)
            }
            .map { style in
                let font = style.font
                return LogicSuggestionItem(
                    title: style.name,
                    category: LGCExpression.Suggestion.variablesCategoryTitle,
                    node: .expression(
                        .identifierExpression(
                            id: UUID(),
                            identifier: LGCIdentifier(id: UUID(), string: style.id)
                        )
                    ),
                    style: .textStylePreview(
                        Logic.TextStyle(
                            family: font.family,
                            name: font.name,
                            weight: font.weight,
                            size: font.size,
                            lineHeight: font.lineHeight,
                            kerning: font.kerning,
                            color: font.color,
                            alignment: font.alignment
                        )
                    )
                )
        }

        return .init(
            (isOptional && (query.isEmpty || "none".contains(lowercasedQuery)) ? [noneSuggestion] : []) + systemSuggestions
        )
    }
}
