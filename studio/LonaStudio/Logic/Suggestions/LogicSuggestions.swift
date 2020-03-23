//
//  LogicSuggestions.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/14/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

extension Bool {
    static func expressionSuggestions(node: LGCSyntaxNode, query: String) -> LogicEditor.ConfiguredSuggestions {
        let trueSuggestion = LogicSuggestionItem(
            title: "true",
            category: LGCLiteral.Suggestion.categoryTitle,
            node: .expression(true.expressionNode)
        )

        let falseSuggestion = LogicSuggestionItem(
            title: "false",
            category: LGCLiteral.Suggestion.categoryTitle,
            node: .expression(false.expressionNode)
        )

        return .init([trueSuggestion, falseSuggestion].titleContains(prefix: query), windowConfiguration: .inputAndList)
    }
}

extension Int {
    static func expressionSuggestions(node: LGCSyntaxNode, query: String) -> LogicEditor.ConfiguredSuggestions {
        let customSuggestion = LogicSuggestionItem(
            title: "Whole Number: \(query)",
            category: LGCLiteral.Suggestion.categoryTitle,
            node: .expression((Int(query) ?? 0).expressionNode),
            disabled: Int(query) == nil
        )

        return .init([customSuggestion])
    }
}

extension CGFloat {
    static func expressionSuggestions(node: LGCSyntaxNode, query: String) -> LogicEditor.ConfiguredSuggestions {
        let customSuggestion = LogicSuggestionItem(
            title: "Number: \(query)",
            category: LGCLiteral.Suggestion.categoryTitle,
            node: .expression(CGFloat(Double(query) ?? 0).expressionNode),
            disabled: Double(query) == nil
        )

        return .init([customSuggestion])
    }
}

extension String {
    static func expressionSuggestions(node: LGCSyntaxNode, query: String) -> LogicEditor.ConfiguredSuggestions {
        let customSuggestion = LogicSuggestionItem(
            title: "String: \"\(query)\"",
            category: LGCLiteral.Suggestion.categoryTitle,
            node: .expression(query.expressionNode)
        )

        return .init([customSuggestion])
    }
}
