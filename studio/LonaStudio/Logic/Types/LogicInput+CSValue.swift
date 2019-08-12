//
//  LogicInput+CSValue.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/13/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

extension LogicInput {
    static func expression(forValue csValue: CSValue) -> LGCExpression {
        switch csValue.type {
        case .bool:
            return csValue.data.boolValue.expressionNode
        case .wholeNumber:
            return Int(csValue.data.numberValue).expressionNode
        case .number:
            return CGFloat(csValue.data.numberValue).expressionNode
        case .string:
            return csValue.data.stringValue.expressionNode
        case CSURLType:
            return expression(forURLString: csValue.data.string ?? "")
        case CSColorType:
            return expression(forColorString: csValue.data.string ?? "black")
        case CSTextStyleType:
            return expression(forTextStyleString: csValue.data.string ?? "default")
        case .named:
            return expression(forValue: csValue.unwrappedNamedType())
        case .variant:
            return .identifierExpression(id: UUID(), identifier: LGCIdentifier(id: UUID(), string: csValue.tag()))
        default:
//            fatalError("Not supported")
            return .identifierExpression(id: UUID(), identifier: LGCIdentifier(id: UUID(), string: ""))
        }
    }

    static func makeValue(forType csType: CSType, node: LGCSyntaxNode) -> CSValue {
        switch (csType, node) {
        case (.bool, .expression(let expression)):
            return CSValue(type: csType, data: Bool(expression).toData())
        case (.number, .expression(let expression)):
            return CSValue(type: csType, data: CGFloat(expression).toData())
        case (.wholeNumber, .expression(let expression)):
            return CSValue(type: csType, data: Int(expression).toData())
        case (.string, .expression(let expression)):
            return CSValue(type: csType, data: String(expression).toData())
        case (CSURLType, _):
            return CSValue(type: csType, data: (makeURLString(node: node) ?? "").toData())
        case (CSColorType, _):
            return CSValue(type: csType, data: (makeColorString(node: node) ?? "black").toData())
        case (CSTextStyleType, _):
            return CSValue(type: csType, data: (makeTextStyleString(node: node) ?? "default").toData())
        case (.array(let inner), let expression):
            switch expression {
            case .literal(.array(_, value: let expressions)):
                let elements = expressions.map { makeValue(forType: inner, node: .expression($0)) }
                return CSValue(type: csType, data: CSData.Array(elements.map { $0.data }))
            default:
                return CSValue(type: .unit, data: .Null)
            }
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
        case .wholeNumber:
            return Int.expressionSuggestions(node: node, query: query)
        case .number:
            return CGFloat.expressionSuggestions(node: node, query: query)
        case .string:
            return String.expressionSuggestions(node: node, query: query)
        case CSURLType:
            return suggestionsForURL(isOptional: false, isVector: false, node: node, query: query)
        case CSColorType:
            return suggestionsForColor(isOptional: false, node: node, query: query)
        case CSTextStyleType:
            return suggestionsForTextStyle(isOptional: false, node: node, query: query)
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
