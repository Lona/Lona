//
//  LabeledValueInput+String.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/13/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

// MARK: - String

extension LogicValueInput {
    static func rootNode(for string: String) -> LGCSyntaxNode {
        return .expression(
            .literalExpression(
                id: UUID(),
                literal: .string(id: UUID(), value: string)
            )
        )
    }

    static func makeString(node: LGCSyntaxNode) -> String {
        switch node {
        case .expression(.literalExpression(id: _, literal: .string(id: _, value: let value))):
            return value
        default:
            fatalError("Invalid node")
        }
    }

    static func suggestionsForString(query: String) -> [LogicSuggestionItem] {
        let customSuggestion = LogicSuggestionItem(
            title: "String: \"\(query)\"",
            category: "Strings".uppercased(),
            node: .expression(
                .literalExpression(
                    id: UUID(),
                    literal: .string(id: UUID(), value: query)
                )
            )
        )

        return [customSuggestion]
    }
}

// MARK: - Bool

extension LogicValueInput {
    static func rootNode(for bool: Bool) -> LGCSyntaxNode {
        return .expression(
            .literalExpression(
                id: UUID(),
                literal: .boolean(id: UUID(), value: bool)
            )
        )
    }

    static func makeBool(node: LGCSyntaxNode) -> Bool {
        switch node {
        case .expression(.literalExpression(id: _, literal: .boolean(id: _, value: let value))):
            return value
        default:
            fatalError("Invalid node")
        }
    }

    static func suggestionsForBool(query: String) -> [LogicSuggestionItem] {
        let trueSuggestion = LogicSuggestionItem(
            title: "true",
            category: "Booleans".uppercased(),
            node: .expression(
                .literalExpression(
                    id: UUID(),
                    literal: .boolean(id: UUID(), value: true)
                )
            )
        )

        let falseSuggestion = LogicSuggestionItem(
            title: "false",
            category: "Booleans".uppercased(),
            node: .expression(
                .literalExpression(
                    id: UUID(),
                    literal: .boolean(id: UUID(), value: false)
                )
            )
        )

        return [trueSuggestion, falseSuggestion].titleContains(prefix: query)
    }
}

