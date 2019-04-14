//
//  LogicExpressionConvertible.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/14/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

// MARK: - LogicLiteralConvertible

protocol LogicLiteralConvertible {
    var literalNode: LGCLiteral { get }
    init(_ literalNode: LGCLiteral)

//    func suggestions(root: LGCSyntaxNode, query: String) -> [LogicSuggestionItem]
}

extension Bool: LogicLiteralConvertible {
    var literalNode: LGCLiteral {
        return .boolean(id: UUID(), value: self)
    }

    init(_ literalNode: LGCLiteral) {
        switch literalNode {
        case .boolean(id: _, value: let value):
            self = value
        default:
            fatalError("Invalid node")
        }
    }
}

extension Int: LogicLiteralConvertible {
    var literalNode: LGCLiteral {
        return .number(id: UUID(), value: CGFloat(self))
    }

    init(_ literalNode: LGCLiteral) {
        switch literalNode {
        case .number(id: _, value: let value):
            self = Int(value)
        default:
            fatalError("Invalid node")
        }
    }
}

extension CGFloat: LogicLiteralConvertible {
    var literalNode: LGCLiteral {
        return .number(id: UUID(), value: self)
    }

    init(_ literalNode: LGCLiteral) {
        switch literalNode {
        case .number(id: _, value: let value):
            self = value
        default:
            fatalError("Invalid node")
        }
    }
}

extension String: LogicLiteralConvertible {
    var literalNode: LGCLiteral {
        return .string(id: UUID(), value: self)
    }

    init(_ literalNode: LGCLiteral) {
        switch literalNode {
        case .string(id: _, value: let value):
            self = value
        default:
            fatalError("Invalid node")
        }
    }
}

// MARK: - LogicExpressionConvertible

protocol LogicExpressionConvertible {
    var expressionNode: LGCExpression { get }
    init(_ expressionNode: LGCExpression)
}

extension LogicExpressionConvertible where Self: LogicLiteralConvertible {
    var expressionNode: LGCExpression {
        return .literalExpression(
            id: UUID(),
            literal: self.literalNode
        )
    }

    init(_ expressionNode: LGCExpression) {
        switch expressionNode {
        case .literalExpression(id: _, literal: let literal):
            self = .init(literal)
        default:
            fatalError("Invalid node")
        }
    }
}

extension Bool: LogicExpressionConvertible {}
extension CGFloat: LogicExpressionConvertible {}
extension Int: LogicExpressionConvertible {}
extension String: LogicExpressionConvertible {}
