//
//  Parameter.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

class LogicNode: DataNodeParent, DataNodeCopying {
    var nodes: [LogicNode] = []
    var invocation: CSFunction.Invocation = CSFunction.Invocation()

    required init(_ data: CSData) {
        // Parse old format for backwards compat. TODO: Remove at some point
        if let functionData = data["function"] {
            self.nodes = data.get(key: "nodes").arrayValue.map({ LogicNode($0) })
            self.invocation = CSFunction.Invocation(functionData)
        } else {
            let node = LogicNode.create(from: LonaExpression(data))
            self.nodes = node.nodes
            self.invocation = node.invocation
        }
    }

    required init() {}

    static func create(from expression: LonaExpression) -> LogicNode {
        let node = LogicNode()

        func argument(from expression: LonaExpression) -> CSFunction.Argument? {
            switch expression {
            case .literalExpression(let value):
                return .value(value)
            case .memberExpression(let identifiers):
                let path = identifiers.map({ expression in
                    guard case LonaExpression.identifierExpression(let identifier) = expression else { return nil }
                    return identifier
                }).flatMap({ $0 })
                return .identifier(CSType.any, path)
            case .placeholderExpression:
                return nil
            default:
                return nil
            }
        }

        switch expression {
        case .assignmentExpression(let content):
            var invocation = CSFunction.Invocation()
            switch content.content {
            case .binaryExpression(let bin):
                if let arg = argument(from: content.assignee) {
                    invocation.arguments["value"] = arg
                }
                if let arg = argument(from: bin.left) {
                    invocation.arguments["lhs"] = arg
                }
                if let arg = argument(from: bin.right) {
                    invocation.arguments["rhs"] = arg
                }
                invocation.name = "add(lhs, to rhs, and assign to value)"
            default:
                if let arg = argument(from: content.content) {
                    invocation.arguments["lhs"] = arg
                }
                if let arg = argument(from: content.assignee) {
                    invocation.arguments["rhs"] = arg
                }
                invocation.name = "assign(lhs, to rhs)"
            }
            node.invocation = invocation
        case .ifExpression(let content):
            var invocation = CSFunction.Invocation()

            switch content.condition {
            case .variableDeclarationExpression(let decl):
                if let arg = argument(from: decl.identifier) {
                    invocation.arguments["variable"] = arg
                }
                if let arg = argument(from: decl.content) {
                    invocation.arguments["value"] = arg
                }
                invocation.name = "if let(variable, equal value)"
            case .binaryExpression(let bin):
                switch bin.op {
                case .identifierExpression(let op):
                    if let cmp = LonaOperator(rawValue: op)?.comparator() {
                        invocation.arguments["cmp"] = CSFunction.Argument.value(cmp)
                    }
                default:
                    break
                }
                if let arg = argument(from: bin.left) {
                    invocation.arguments["lhs"] = arg
                }
                if let arg = argument(from: bin.right) {
                    invocation.arguments["rhs"] = arg
                }
                invocation.name = "if(lhs, is cmp, rhs)"
            default:
                break
            }

            node.invocation = invocation
            node.nodes = content.body.map({ LogicNode.create(from: $0) })
        default:
            break
        }

        return node
    }

    func expression() -> LonaExpression {
        func expression(from argument: CSFunction.Argument) -> LonaExpression {
            switch argument {
            case .value(let value):
                return .literalExpression(value)
            case .identifier(_, let path):
                return .memberExpression(path.map({ LonaExpression.identifierExpression($0) }))
            }
        }

        func optionalExpression(from argument: CSFunction.Argument?) -> LonaExpression {
            guard let argument = argument else { return .placeholderExpression }
            return expression(from: argument)
        }

        switch invocation.name {
        case "add(lhs, to rhs, and assign to value)":
            let bin = BinaryExpressionNode(
                left: optionalExpression(from: invocation.arguments["lhs"]),
                op: .identifierExpression("+"),
                right: optionalExpression(from: invocation.arguments["rhs"]))
            let content = AssignmentExpressionNode(
                assignee: optionalExpression(from: invocation.arguments["value"]),
                content: .binaryExpression(bin))
            return .assignmentExpression(content)
        case "assign(lhs, to rhs)":
            let content = AssignmentExpressionNode(
                assignee: optionalExpression(from: invocation.arguments["rhs"]),
                content: optionalExpression(from: invocation.arguments["lhs"]))
            return .assignmentExpression(content)
        case "if(lhs, is cmp, rhs)":
            var op: LonaExpression = .placeholderExpression
            if case LonaExpression.literalExpression(let value) = optionalExpression(from: invocation.arguments["cmp"]) {
                let lonaOperator = LonaOperator(comparator: value)?.rawValue ?? "=="
                op = .identifierExpression(lonaOperator)
            }
            let bin = BinaryExpressionNode(
                left: optionalExpression(from: invocation.arguments["lhs"]),
                op: op,
                right: optionalExpression(from: invocation.arguments["rhs"]))
            let content = IfExpressionNode(
                condition: .binaryExpression(bin),
                body: nodes.map({ logicNode in logicNode.expression() }))
            return .ifExpression(content)
        case "if let(variable, equal value)":
            let decl = VariableDeclarationNode(
                identifier: optionalExpression(from: invocation.arguments["variable"]),
                content: optionalExpression(from: invocation.arguments["value"]))
            let content = IfExpressionNode(
                condition: .variableDeclarationExpression(decl),
                body: nodes.map({ logicNode in logicNode.expression() }))
            return .ifExpression(content)
        default:
            return .placeholderExpression
        }
    }

    func toData() -> CSData {
        return expression().toData()
    }

    func childCount() -> Int { return nodes.count }
    func child(at index: Int) -> Any { return nodes[index] }
    func append(_ node: DataNode) {
        guard let node = node as? LogicNode else { return }
        nodes.append(node)
    }
    func insert(_ node: DataNode, at index: Int) {
        guard let node = node as? LogicNode else { return }

        // TODO: Or is there a bug in the node moving code?
        if index >= nodes.count {
            nodes.append(node)
        } else {
            nodes.insert(node, at: index)
        }
    }
    func remove(at index: Int) {
        if index >= nodes.count {
            Swift.print("ERROR: Failed to remove item from LogicNode, index out of range")
            return
        }

        nodes.remove(at: index)
    }

    func set(variable name: String, to value: CSValue) {}
}
