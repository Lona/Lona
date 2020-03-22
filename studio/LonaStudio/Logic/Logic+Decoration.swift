//
//  Logic+Decoration.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/21/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

extension LogicViewController {
    public static func decorationForNodeID(
        rootNode: LGCSyntaxNode,
        formattingOptions: LogicFormattingOptions,
        evaluationContext: Compiler.EvaluationContext?,
        id: UUID
    ) -> LogicElement.Decoration? {
        guard let node = rootNode.find(id: id) else { return nil }

        if let colorValue = evaluationContext?.evaluate(uuid: node.uuid)?.colorString {
            if formattingOptions.style == .visual,
                let path = rootNode.pathTo(id: id),
                let parent = path.dropLast().last {

                // Don't show color decoration on the variable name
                switch parent {
                case .declaration(.variable):
                    return nil
                default:
                    break
                }

                // Don't show color decoration of literal value if we're already showing a swatch preview
                if let grandParent = path.dropLast().dropLast().last {
                    switch (grandParent, parent, node) {
                    case (.declaration(.variable), .expression(.literalExpression), .literal(.color)):
                        return nil
                    default:
                        break
                    }
                }
            }

            return .color(NSColor.parse(css: colorValue) ?? NSColor.black)
        }

        switch node {
        case .literal(.color(id: _, value: let code)):
            return .color(NSColor.parse(css: code) ?? .clear)
        default:
            return nil
        }
    }
}
