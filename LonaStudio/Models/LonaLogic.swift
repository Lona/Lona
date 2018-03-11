//
//  LonaLogic.swift
//  LonaStudio
//
//  Created by devin_abbott on 3/10/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation

protocol TestingHello {}

private let comparatorMapping: [String: LonaOperator] = [
    "equal to": .eq,
    "not equal to": .neq,
    "greater than": .gt,
    "greater than or equal to": .gte,
    "less than": .lt,
    "less than or equal to": .lte
]

enum LonaOperator: String {
    case eq = "=="
    case neq = "!="
    case gt = ">"
    case gte = ">="
    case lt = "<"
    case lte = "<="

    init?(comparator: CSValue) {
        if let op = comparatorMapping[comparator.data.stringValue] {
            self.init(rawValue: op.rawValue)
        } else {
            self.init(rawValue: "==")
        }
    }

    func comparator() -> CSValue {
        guard let result = comparatorMapping.first(where: { $0.value == self }) else { return CSUndefinedValue }
        return CSValue(type: CSComparatorType, data: result.key.toData())
    }
}

struct AssignmentExpressionNode {
    var assignee: LonaExpression
    var content: LonaExpression

    enum Keys: String {
        case assignee
        case content
    }

    func toData() -> CSData {
        return .Object([
            Keys.assignee.rawValue: assignee.toData(),
            Keys.content.rawValue: content.toData()
            ])
    }
}

struct IfExpressionNode {
    var condition: LonaExpression
    var body: [LonaExpression]

    enum Keys: String {
        case condition
        case body
    }

    func toData() -> CSData {
        return .Object([
            Keys.condition.rawValue: condition.toData(),
            Keys.body.rawValue: body.toData()
            ])
    }
}

struct VariableDeclarationNode {
    var identifier: LonaExpression
    var content: LonaExpression

    enum Keys: String {
        case identifier = "id"
        case content
    }

    func toData() -> CSData {
        return .Object([
            Keys.identifier.rawValue: identifier.toData(),
            Keys.content.rawValue: content.toData()
            ])
    }
}

struct BinaryExpressionNode {
    var left: LonaExpression
    var op: LonaExpression
    var right: LonaExpression

    enum Keys: String {
        case left
        case op
        case right
    }

    func toData() -> CSData {
        return .Object([
            Keys.left.rawValue: left.toData(),
            Keys.op.rawValue: op.toData(),
            Keys.right.rawValue: right.toData()
            ])
    }
}

indirect enum LonaExpression: CSDataSerializable, CSDataDeserializable {
    case assignmentExpression(AssignmentExpressionNode)
    case ifExpression(IfExpressionNode)
    case variableDeclarationExpression(VariableDeclarationNode)
    case binaryExpression(BinaryExpressionNode)
    case memberExpression([LonaExpression])
    case identifierExpression(String)
    case literalExpression(CSValue)
    case placeholderExpression

    enum ExpressionType: String, CSDataSerializable {
        case assignmentExpression = "AssignExpr"
        case ifExpression = "IfExpr"
        case variableDeclarationExpression = "VarDeclExpr"
        case binaryExpression = "BinExpr"
        case literalExpression = "LitExpr"

        func toData() -> CSData {
            return self.rawValue.toData()
        }

        init?(_ data: CSData) {
            self.init(rawValue: data.stringValue)
        }

    }

    init(_ data: CSData) {
        if let value = data.string {
            self = .identifierExpression(value)
        } else if let value = data.array {
            self = .memberExpression(value.map({ expression in LonaExpression(expression) }))
        } else if let type = ExpressionType(data.get(key: "type")) {
            switch type {
            case .assignmentExpression:
                let content = AssignmentExpressionNode(
                    assignee: LonaExpression(data.get(key: AssignmentExpressionNode.Keys.assignee.rawValue)),
                    content: LonaExpression(data.get(key: AssignmentExpressionNode.Keys.content.rawValue)))
                self = .assignmentExpression(content)
            case .ifExpression:
                let content = IfExpressionNode(
                    condition: LonaExpression(data.get(key: IfExpressionNode.Keys.condition.rawValue)),
                    body: data.get(key: IfExpressionNode.Keys.body.rawValue).arrayValue.map({ LonaExpression($0) }))
                self = .ifExpression(content)
            case .variableDeclarationExpression:
                let content = VariableDeclarationNode(
                    identifier: LonaExpression(data.get(key: VariableDeclarationNode.Keys.identifier.rawValue)),
                    content: LonaExpression(data.get(key: VariableDeclarationNode.Keys.content.rawValue)))
                self = .variableDeclarationExpression(content)
            case .binaryExpression:
                let content = BinaryExpressionNode(
                    left: LonaExpression(data.get(key: BinaryExpressionNode.Keys.left.rawValue)),
                    op: LonaExpression(data.get(key: BinaryExpressionNode.Keys.op.rawValue)),
                    right: LonaExpression(data.get(key: BinaryExpressionNode.Keys.right.rawValue)))
                self = .binaryExpression(content)
            case .literalExpression:
                self = .literalExpression(CSValue(data.get(key: "value")))
            }
        } else {
            self = .placeholderExpression
        }
    }

    func toData() -> CSData {
        switch self {
        case .assignmentExpression(let node):
            return CSData.Object([
                "type": ExpressionType.assignmentExpression.toData()
                ]).merge(node.toData())
        case .ifExpression(let node):
            return CSData.Object([
                "type": ExpressionType.ifExpression.toData()
                ]).merge(node.toData())
        case .variableDeclarationExpression(let node):
            return CSData.Object([
                "type": ExpressionType.variableDeclarationExpression.toData()
                ]).merge(node.toData())
        case .binaryExpression(let node):
            return CSData.Object([
                "type": ExpressionType.binaryExpression.toData()
                ]).merge(node.toData())
        case .memberExpression(let path):
            return path.toData()
        case .identifierExpression(let identifier):
            return identifier.toData()
        case .literalExpression(let value):
            return CSData.Object([
                "type": ExpressionType.literalExpression.toData(),
                "value": value.toData()])
        case .placeholderExpression:
            return CSData.Null
        }
    }
}
