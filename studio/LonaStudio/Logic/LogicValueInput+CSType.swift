//
//  LogicValueInput+Variant.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/13/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

extension LogicValueInput {
    static func rootNode(forValue csValue: CSValue) -> LGCSyntaxNode {
        switch csValue.type {
//        case CSColorType:
//            return rootNode(forColorString: csValue.data.string)
        case .bool:
            return .expression(csValue.data.boolValue.expressionNode)
        case .wholeNumber:
            return .expression(Int(csValue.data.numberValue).expressionNode)
        case .number:
            return .expression(CGFloat(csValue.data.numberValue).expressionNode)
        case .string:
            return .expression(csValue.data.stringValue.expressionNode)
        case .named:
            return rootNode(forValue: csValue.unwrappedNamedType())
        case .variant:
            return .expression(
                .identifierExpression(
                    id: UUID(),
                    identifier: LGCIdentifier(id: UUID(), string: csValue.tag())
                )
            )
        default:
//            fatalError("Not supported")
            return .expression(.identifierExpression(id: UUID(), identifier: LGCIdentifier(id: UUID(), string: "")))
        }
    }

    static func makeValue(forType csType: CSType, node: LGCSyntaxNode) -> CSValue {
        switch (csType, node) {
//        case CSColorType:
//            return CSValue(type: csType, data: makeColorString(node: node).toData())
        case (.bool, .expression(let expression)):
            return CSValue(type: csType, data: Bool(expression).toData())
        case (.number, .expression(let expression)):
            return CSValue(type: csType, data: CGFloat(expression).toData())
        case (.wholeNumber, .expression(let expression)):
            return CSValue(type: csType, data: Int(expression).toData())
        case (.string, .expression(let expression)):
            return CSValue(type: csType, data: String(expression).toData())
        case (.named, _):
            return makeValue(forType: csType.unwrappedNamedType(), node: node)
        case (.variant, _):
            switch node {
            case .expression(.identifierExpression(id: _, identifier: let identifier)):
                return CSValue(type: .unit, data: .Null).wrap(in: csType, tagged: identifier.string)
            default:
                return CSValue(type: .unit, data: .Null)
            }
        default:
            fatalError("Not supported")
        }
    }

    static func suggestions(forType csType: CSType, node: LGCSyntaxNode, query: String) -> [LogicSuggestionItem] {
        switch csType {
        case .bool:
            return Bool.expressionSuggestions(node: node, query: query)
        case .string:
            return String.expressionSuggestions(node: node, query: query)
        case .named:
            return suggestions(forType: csType.unwrappedNamedType(), node: node, query: query)
        case .variant(let cases):
            return cases.map { caseItem in
                LogicSuggestionItem(
                    title: caseItem.0,
                    category: "Cases".uppercased(),
                    node: .expression(
                        .identifierExpression(
                            id: UUID(),
                            identifier: LGCIdentifier(id: UUID(), string: caseItem.0)
                        )
                    )
                )
            }.titleContains(prefix: query)
        default:
            return []
        }
    }
}
