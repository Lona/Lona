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
            let value = evaluationContext.values[expression.uuid]
            return value
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

        Swift.print("Current node", logicValueInput.rootNode)

        let currentValue = evaluateExpression(node: logicValueInput.rootNode)
        Swift.print("Current value", currentValue?.memory, currentValue?.type)

        logicValueInput.onChangeRootNode = { [unowned self] node in
            Swift.print("Change root", node)

//            self.onChangeColorString?(LogicInput.makeColorString(node: node))

            guard case .expression(let expression) = node else { return true }

            let program: LGCSyntaxNode = .program(LabeledColorInput.makeExpressionProgram(from: expression).expandImports(importLoader: Library.load))

            let scopeContext = Compiler.scopeContext(program)
            let unificationContext = Compiler.makeUnificationContext(program, scopeContext: scopeContext)

            guard case .success(let substitution) = Unification.unify(constraints: unificationContext.constraints) else {
                return true
            }

            let result = Compiler.evaluate(program, rootNode: program, scopeContext: scopeContext, unificationContext: unificationContext, substitution: substitution, context: .init())

            Swift.print(result)

            switch result {
            case .success(let evaluationContext):
                Swift.print("Result value", evaluationContext.values[expression.uuid])

                guard let value = evaluationContext.values[expression.uuid] else { break }

                let colorString = LogicValue.unwrapOptional(value)?.colorString

                Swift.print("Result colorString", colorString)

                self.onChangeColorString?(colorString)
            case .failure(let error):
                Swift.print("Eval failure", error)
            }

            return true
        }

        logicValueInput.suggestionsForNode = { rootNode, node, query in
            guard case .expression(let expression) = node else { return [] }

            let program: LGCSyntaxNode = .program(LabeledColorInput.makeExpressionProgram(from: expression).expandImports(importLoader: Library.load))

            return StandardConfiguration.suggestions(rootNode: program, node: node, query: query) ?? []

//            return LogicInput.suggestionsForColor(isOptional: true, node: node, query: query)
        }
    }
}
