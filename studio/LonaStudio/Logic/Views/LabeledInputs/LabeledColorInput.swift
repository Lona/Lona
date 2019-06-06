//
//  LabeledColorInput.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/10/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

// MARK: - LabeledColorInput

public class LabeledColorInput: LabeledInput {

    // MARK: Lifecycle

    public init(titleText: String, colorString: String?) {
        self.colorString = colorString

        super.init(titleText: titleText)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var colorString: String? {
        didSet {
            if colorString != oldValue {
                update()
            }
        }
    }

    public var onChangeColorString: ((String?) -> Void)?

    // MARK: Private

    private let logicValueInput = LogicInput()

    private func setUpViews() {
        inputView = logicValueInput
    }

    private func setUpConstraints() {}

    private func evaluateExpression(node: LGCSyntaxNode) -> LogicValue? {
        guard case .expression(let expression) = node else { return nil }

        let program: LGCSyntaxNode = .program(LabeledColorInput.makeExpressionProgram(from: expression).expandImports(importLoader: Library.load))
        let scopeContext = Compiler.scopeContext(program)
        let unificationContext = Compiler.makeUnificationContext(program, scopeContext: scopeContext)

        guard case .success(let substitution) = Unification.unify(constraints: unificationContext.constraints) else {
            return nil
        }

        let result = Compiler.evaluate(program, rootNode: program, scopeContext: scopeContext, unificationContext: unificationContext, substitution: substitution, context: .init())

        switch result {
        case .success(let evaluationContext):
            return evaluationContext.values[expression.uuid]
        case .failure(let error):
            Swift.print("Eval failure", error)
            return nil
        }
    }

    private static func makeTypeAnnotation(type: Unification.T) -> LGCTypeAnnotation {
        switch type {
        case .cons(name: let name, parameters: let parameters):
            return LGCTypeAnnotation.typeIdentifier(
                id: UUID(),
                identifier: LGCIdentifier(id: UUID(), string: name),
                genericArguments: .init(parameters.map(makeTypeAnnotation(type:)))
            )
        case .evar(let name), .gen(let name):
            return LGCTypeAnnotation.typeIdentifier(
                id: UUID(),
                identifier: LGCIdentifier(id: UUID(), string: name),
                genericArguments: .empty
            )
        case .fun:
            fatalError("Not supported")
        }
    }

    private static func makeExpressionProgram(from expression: LGCExpression) -> LGCProgram {
        return .init(
            id: UUID(),
            block: .init(
                [
                    .declaration(
                        id: UUID(),
                        content: .importDeclaration(id: UUID(), name: .init(id: UUID(), name: "Prelude"))
                    ),
                    .declaration(id: UUID(), content: CSColors.logicSyntax),
                    .declaration(
                        id: UUID(),
                        content: .variable(
                            id: UUID(),
                            name: .init(id: UUID(), name: "color"),
                            annotation: makeTypeAnnotation(type: Unification.T.cons(name: "Optional", parameters: [.cssColor])),
                            initializer: .some(expression)
                        )
                    )
                ]
            )
        )
    }

    private func update() {
        logicValueInput.rootNode = .expression(LogicInput.expression(forColorString: colorString))

        logicValueInput.onChangeRootNode = { [unowned self] node in
            if let value = self.evaluateExpression(node: node) {
                // TODO: Looking up a color based on its string value is innaccurate, since there's
                // no way to distinguish between a custom color and a system color. We should allow
                // storing an expression in the .component file
                if let colorString = LogicValue.unwrapOptional(value)?.colorString {
                    let newValue = CSColors.lookup(css: colorString)?.resolvedValue ?? colorString
                    self.onChangeColorString?(newValue)
                } else {
                    self.onChangeColorString?(nil)
                }
            }

            return true
        }

        logicValueInput.suggestionsForNode = { rootNode, node, query in
            guard case .expression(let expression) = node else { return [] }

            let program: LGCSyntaxNode = .program(LabeledColorInput.makeExpressionProgram(from: expression).expandImports(importLoader: Library.load))

            return StandardConfiguration.suggestions(rootNode: program, node: node, query: query) ?? []
        }
    }
}
