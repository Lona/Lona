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

        return .init(
            [trueSuggestion, falseSuggestion].titleContains(prefix: query),
            windowConfiguration: .inputAndList
        )
    }
}

extension Int {
    static func expressionSuggestions(node: LGCSyntaxNode, query: String) -> LogicEditor.ConfiguredSuggestions {
        let markdown = """
        # Whole Number

        Type any whole number, like `0` or `42`, and press enter!
        """

        let customSuggestion = LogicSuggestionItem(
            title: "Whole Number: \(query)",
            category: LGCLiteral.Suggestion.categoryTitle,
            node: .expression((Int(query) ?? 0).expressionNode),
            disabled: Int(query) == nil,
            documentation: ({ builder in
                LightMark.makeScrollView(markdown: markdown, renderingOptions: .init(formattingOptions: .visual))
            })
        )

        return .init([customSuggestion])
    }
}

extension CGFloat {
    static func expressionSuggestions(node: LGCSyntaxNode, query: String) -> LogicEditor.ConfiguredSuggestions {
        let markdown = """
        # Number

        Type any number, like `42` or `0.5`, and press enter!
        """

        let customSuggestion = LogicSuggestionItem(
            title: "Number: \(query)",
            category: LGCLiteral.Suggestion.categoryTitle,
            node: .expression(CGFloat(Double(query) ?? 0).expressionNode),
            disabled: Double(query) == nil,
            documentation: ({ builder in
                LightMark.makeScrollView(markdown: markdown, renderingOptions: .init(formattingOptions: .visual))
            })
        )

        return .init([customSuggestion])
    }
}

extension String {
    static func expressionSuggestions(node: LGCSyntaxNode, query: String) -> LogicEditor.ConfiguredSuggestions {
        let markdown = """
        # String

        Type any text, like `Hello!`, and press enter!

        Press enter without typing anything for an empty string.
        """

        let customSuggestion = LogicSuggestionItem(
            title: "String: \"\(query)\"",
            category: LGCLiteral.Suggestion.categoryTitle,
            node: .expression(query.expressionNode),
            documentation: ({ builder in
                LightMark.makeScrollView(markdown: markdown, renderingOptions: .init(formattingOptions: .visual))
            })
        )

        return .init([customSuggestion])
    }
}
