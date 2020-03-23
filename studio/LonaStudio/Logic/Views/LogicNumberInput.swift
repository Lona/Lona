//
//  LogicNumberInput.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/13/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

// MARK: - LogicNumberInput

public class LogicNumberInput: NSView {

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var numberValue: CGFloat = 0 { didSet { update() } }

    public var onChangeNumberValue: ((CGFloat) -> Void)?

    // MARK: Private

    private var logicEditor = LogicEditor()

    private func setUpViews() {
        logicEditor.showsLineButtons = false
        logicEditor.showsDropdown = false
        logicEditor.supportsLineSelection = false
        logicEditor.scrollsVertically = false
        logicEditor.canvasStyle.textAlignment = .center
        logicEditor.canvasStyle.textMargin = .init(width: 1, height: 1)

        addSubview(logicEditor)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        logicEditor.translatesAutoresizingMaskIntoConstraints = false

        logicEditor.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        logicEditor.topAnchor.constraint(equalTo: topAnchor).isActive = true
        logicEditor.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        logicEditor.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func update() {
        logicEditor.rootNode = .expression(LogicInput.expression(forValue: CSValue(type: .number, data: .Number(Double(numberValue)))))

        logicEditor.onChangeRootNode = { [unowned self] node in
            if let value = self.evaluateExpression(node: node) {
                switch value.memory {
                case .number(let number):
                    self.onChangeNumberValue?(number)
                default:
                    break
                }
            }

            return true
        }

        logicEditor.suggestionsForNode = { [unowned self] rootNode, node, query in
            guard case .expression(let expression) = node else { return .init([]) }

            let program: LGCSyntaxNode = .program(LogicNumberInput.makeProgram(from: expression).expandImports(importLoader: LogicLoader.load))

            return .init(
                StandardConfiguration.suggestions(
                    rootNode: program,
                    node: node,
                    formattingOptions: self.logicEditor.formattingOptions
                )?(query) ?? []
            )
        }
    }

    private func evaluateExpression(node: LGCSyntaxNode) -> LogicValue? {
        guard case .expression(let expression) = node else { return nil }

        let program: LGCSyntaxNode = .program(LogicNumberInput.makeProgram(from: expression).expandImports(importLoader: LogicLoader.load))
        let scopeContext = Compiler.scopeContext(program)
        let unificationContext = Compiler.makeUnificationContext(program, scopeContext: scopeContext)

        guard case .success(let substitution) = Unification.unify(constraints: unificationContext.constraints) else {
            return nil
        }

        let result = Compiler.evaluate(program, rootNode: program, scopeContext: scopeContext, unificationContext: unificationContext, substitution: substitution, context: .init())

        switch result {
        case .success(let evaluationContext):
            return evaluationContext.evaluate(uuid: expression.uuid)
        case .failure(let error):
            Swift.print("Eval failure", error)
            return nil
        }
    }

    private static func makeProgram(from expression: LGCExpression) -> LGCProgram {
        let program: LGCProgram = .init(
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
                            name: .init(id: UUID(), name: "number"),
                            annotation: .typeIdentifier(
                                id: UUID(),
                                identifier: .init(id: UUID(), string: "Number"),
                                genericArguments: .empty
                            ),
                            initializer: .some(expression),
                            comment: nil
                        )
                    )
                ]
            )
        )

        return LGCProgram.join(programs: [LonaModule.current.logic.program, program])
    }
}
