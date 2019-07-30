//
//  Logic+Builders.swift
//  LonaStudio
//
//  Created by Devin Abbott on 7/29/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

extension LGCPattern {
    public init(_ name: String) {
        self = .init(id: UUID(), name: name)
    }
}

extension LGCIdentifier {
    public init(_ name: String) {
        self = .init(id: UUID(), string: name)
    }
}

extension LGCTypeAnnotation {
    public static func typeIdentifier(name: String, genericArguments: [LGCTypeAnnotation] = []) -> LGCTypeAnnotation {
        return .typeIdentifier(id: UUID(), identifier: .init(name), genericArguments: .init(genericArguments))
    }
}

extension LGCExpression {
    public static func colorLiteral(_ colorString: String) -> LGCExpression {
        return .literalExpression(id: UUID(), literal: .color(id: UUID(), value: colorString))
    }

    public static func numberLiteral(_ value: CGFloat) -> LGCExpression {
        return .literalExpression(id: UUID(), literal: .number(id: UUID(), value: value))
    }
}

extension LGCDeclaration {
    public static func variable(name: String, annotation: LGCTypeAnnotation, initializer: LGCExpression? = nil) -> LGCDeclaration {
        return .variable(
            id: UUID(),
            name: .init(name),
            annotation: annotation,
            initializer: initializer,
            comment: nil
        )
    }
}
