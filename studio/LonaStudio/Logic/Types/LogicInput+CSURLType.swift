//
//  LogicInput+CSUrl.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/14/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

extension LogicInput {
    static func expression(forURLString string: String?) -> LGCExpression {
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

    static func makeURLString(node: LGCSyntaxNode) -> String? {
        switch node {
        case .expression(.identifierExpression(id: _, identifier: let identifier)):
            return identifier.string
        default:
            return nil
        }
    }

    private static let sizeRE = try! NSRegularExpression(pattern: #"(\d+)\s*[ x]?\s*(\d+)?"#)

    static func suggestionsForURL(isOptional: Bool, isVector: Bool, node: LGCSyntaxNode, query: String) -> [LogicSuggestionItem] {
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

        let customSuggestion = LogicSuggestionItem(
            title: "URL: \(query)",
            category: LGCLiteral.Suggestion.categoryTitle,
            node: .expression(
                .identifierExpression(
                    id: UUID(),
                    identifier: LGCIdentifier(id: UUID(), string: query)
                )
            ),
            disabled: URL(string: query) == nil
        )

        var width: Int?
        var height: Int?

        if let sizeMatch = sizeRE.firstMatch(in: query, range: NSRange(query.startIndex..<query.endIndex, in: query)) {
            if sizeMatch.numberOfRanges > 1, let range = Range(sizeMatch.range(at: 1), in: query) {
                width = Int(query[range])
            }
            if sizeMatch.numberOfRanges > 2, let range = Range(sizeMatch.range(at: 2), in: query) {
                height = Int(query[range])
            }
        }

        let sizes = [width, height].compactMap { $0 }.map { $0.description }

        let workspacePath = CSUserPreferences.workspaceURL.path

        let assets = isVector ? LonaModule.current.vectorFileUrls : LonaModule.current.assetsFileUrls
        let assetSuggestions: [LogicSuggestionItem] = assets.map { url in
            let urlString: String
            let displayString: String
            if url.scheme == nil || url.scheme == "file",
                let relativePath = url.path.pathRelativeTo(basePath: workspacePath) {
                urlString = "file://" + relativePath
                displayString = relativePath
            } else {
                urlString = url.absoluteString
                displayString = url.path
            }

            return LogicSuggestionItem(
                title: displayString,
                category: LGCExpression.Suggestion.variablesCategoryTitle,
                node: .expression(
                    .identifierExpression(
                        id: UUID(),
                        identifier: LGCIdentifier(id: UUID(), string: urlString)
                    )
                )
            )
        }

        let dataSourceSuggestions = [
            LogicSuggestionItem(
                title: !sizes.isEmpty ? "placehold.it/\(sizes.joined(separator: "x"))" : "placehold.it",
                category: LGCExpression.Suggestion.variablesCategoryTitle,
                node: .expression(
                    .identifierExpression(
                        id: UUID(),
                        identifier: LGCIdentifier(id: UUID(), string: "https://placehold.it/\(sizes.joined(separator: "x"))")
                    )
                ),
                disabled: sizes.isEmpty
            ),
            LogicSuggestionItem(
                title: !sizes.isEmpty ? "picsum.photos/\(sizes.joined(separator: "/"))" : "picsum.photos",
                category: LGCExpression.Suggestion.variablesCategoryTitle,
                node: .expression(
                    .identifierExpression(
                        id: UUID(),
                        identifier: LGCIdentifier(id: UUID(), string: "https://picsum.photos/\(sizes.joined(separator: "/"))")
                    )
                ),
                disabled: sizes.isEmpty
            )
        ]

        let randomProfileSuggestion = LogicSuggestionItem(
            title: "Random profile photo",
            category: LGCExpression.Suggestion.variablesCategoryTitle,
            node: .expression(
                .identifierExpression(
                    id: UUID(),
                    identifier: LGCIdentifier(
                        id: UUID(),
                        string: "https://randomuser.me/api/portraits/\(Bool.random() ? "men" : "women")/\(Int.random(in: 0..<100)).jpg"
                    )
                )
            )
        )

        return (isOptional && (query.isEmpty || "none".contains(lowercasedQuery)) ? [noneSuggestion] : []) + assetSuggestions.titleContains(prefix: query) +
            (isVector
                ? []
                : [customSuggestion] + dataSourceSuggestions + [randomProfileSuggestion].titleContains(prefix: query))
    }
}
