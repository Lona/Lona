//
//  LogicEditor+Suggestions.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/9/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

extension LogicEditor {
    static func typeAnnotationSuggestions(
        query: String,
        rootNode: LGCSyntaxNode,
        types: [CSType]) -> [LogicSuggestionItem] {

        let primitiveTypes = CSType.primitiveTypeNames().map { name in
            LogicSuggestionItem(
                title: name,
                category: "Primitive Types".uppercased(),
                node: LGCSyntaxNode.typeAnnotation(
                    LGCTypeAnnotation.typeIdentifier(
                        id: UUID(),
                        identifier: LGCIdentifier(id: UUID(), string: name),
                        genericArguments: .empty
                    )
                )
            )
        }

        let tokenTypes = CSType.tokenTypeNames().map { name in
            LogicSuggestionItem(
                title: name,
                category: "Token Types".uppercased(),
                node: LGCSyntaxNode.typeAnnotation(
                    LGCTypeAnnotation.typeIdentifier(
                        id: UUID(),
                        identifier: LGCIdentifier(id: UUID(), string: name),
                        genericArguments: .empty
                    )
                )
            )
        }

        let optionalType = LogicSuggestionItem(
            title: "Optional",
            category: "Generic Types".uppercased(),
            node: LGCSyntaxNode.typeAnnotation(
                LGCTypeAnnotation.typeIdentifier(
                    id: UUID(),
                    identifier: LGCIdentifier(id: UUID(), string: "Optional"),
                    genericArguments: .next(
                        LGCTypeAnnotation.typeIdentifier(
                            id: UUID(),
                            identifier: LGCIdentifier(id: UUID(), string: "Void"),
                            genericArguments: .empty
                        ),
                        .empty
                    )
                )
            )
        )

        let arrayType = LogicSuggestionItem(
            title: "Array",
            category: "Generic Types".uppercased(),
            node: LGCSyntaxNode.typeAnnotation(
                LGCTypeAnnotation.typeIdentifier(
                    id: UUID(),
                    identifier: LGCIdentifier(id: UUID(), string: "Array"),
                    genericArguments: .next(
                        LGCTypeAnnotation.typeIdentifier(
                            id: UUID(),
                            identifier: LGCIdentifier(id: UUID(), string: "Void"),
                            genericArguments: .empty
                        ),
                        .empty
                    )
                )
            )
        )

        let functionType = LogicSuggestionItem(
            title: "Function",
            category: "Function Types".uppercased(),
            node: LGCSyntaxNode.typeAnnotation(
                LGCTypeAnnotation.functionType(
                    id: UUID(),
                    returnType: LGCTypeAnnotation.typeIdentifier(
                        id: UUID(),
                        identifier: LGCIdentifier(id: UUID(), string: "Unit"),
                        genericArguments: .empty
                    ),
                    argumentTypes: .next(
                        .placeholder(id: UUID()),
                        .empty
                    )
                )
            )
        )

        let customTypes: [LogicSuggestionItem] = types.map { csType in
            switch csType {
            case .named(let name, _):
                Swift.print(name, csType, LGCTypeAnnotation(csType: csType))
                return LogicSuggestionItem(
                    title: name,
                    category: "Custom Types".uppercased(),
                    node: .typeAnnotation(LGCTypeAnnotation(csType: csType))
                )
            default:
                return nil
            }
            }.compactMap { $0 }

        return (
            primitiveTypes.sortedByPrefix() +
                tokenTypes.sortedByPrefix() +
                [optionalType, arrayType] +
                [functionType] +
                customTypes.sortedByPrefix()
            ).titleContains(prefix: query)
    }
}
