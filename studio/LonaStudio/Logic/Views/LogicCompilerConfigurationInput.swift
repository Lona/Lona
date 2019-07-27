//
//  LogicCompilerConfigurationInput.swift
//  LonaStudio
//
//  Created by Devin Abbott on 7/11/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

// MARK: - LogicNumberInput

public class LogicCompilerConfigurationInput: NSView {

    public struct CompilerConfiguration: Codable {
        public var target: String
        public var framework: String
    }

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

    public var onChangeRootNode: ((Logic.LGCSyntaxNode) -> Bool)? {
        get { return logicEditor.onChangeRootNode }
        set { logicEditor.onChangeRootNode = newValue }
    }

    public var rootNode: LGCSyntaxNode {
        get { return logicEditor.rootNode }
        set { logicEditor.rootNode = newValue }
    }

    // MARK: Private

    private var logicEditor = LogicEditor()

    private func setUpViews() {
        logicEditor.rootNode = .expression(
            .functionCallExpression(
                id: UUID(),
                expression: .identifierExpression(
                    id: UUID(),
                    identifier: .init(id: UUID(), string: "CompilerConfiguration")
                ),
                arguments: .init(
                    [
                        .argument(
                            id: UUID(),
                            label: "target",
                            expression: .functionCallExpression(
                                id: UUID(),
                                expression: .memberExpression(
                                    id: UUID(),
                                    expression: .identifierExpression(id: UUID(), identifier: .init(id: UUID(), string: "CompilerTarget")),
                                    memberName: .init(id: UUID(), string: "js")
                                ),
                                arguments: .empty
                            )
                        ),
                        .argument(
                            id: UUID(),
                            label: "framework",
                            expression: .functionCallExpression(
                                id: UUID(),
                                expression: .memberExpression(
                                    id: UUID(),
                                    expression: .identifierExpression(id: UUID(), identifier: .init(id: UUID(), string: "CompilerFramework")),
                                    memberName: .init(id: UUID(), string: "reactdom")
                                ),
                                arguments: .empty
                            )
                        )
                    ]
                )
            )
        )

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
        logicEditor.suggestionsForNode = { rootNode, node, query in
            guard case .expression(let expression) = rootNode else { return [] }

            let program = LGCSyntaxNode.program(LogicCompilerConfigurationInput.makeProgram(from: expression))

            let formattingOptions = LogicFormattingOptions.init(style: LogicViewController.formattingStyle, locale: .en_US, getColor: { _ in nil })
            return StandardConfiguration.suggestions(rootNode: program, node: node, formattingOptions: formattingOptions)?(query) ?? []
        }
    }

    private static func logicValue(rootNode: LGCSyntaxNode) -> LogicValue? {
        guard case .expression(let expression) = rootNode else { return nil }

        let program: LGCSyntaxNode = .program(LogicCompilerConfigurationInput.makeProgram(from: expression))
        let scopeContext = Compiler.scopeContext(program)
        let unificationContext = Compiler.makeUnificationContext(program, scopeContext: scopeContext)

        guard case .success(let substitution) = Unification.unify(constraints: unificationContext.constraints) else { return nil }

        let result = Compiler.evaluate(program, rootNode: program, scopeContext: scopeContext, unificationContext: unificationContext, substitution: substitution, context: .init())

        switch result {
        case .success(let evaluationContext):
            return evaluationContext.values[expression.uuid]
        case .failure(let error):
            Swift.print("Eval failure", error)
            return nil
        }
    }

    public static func evaluateConfiguration(rootNode: LGCSyntaxNode) -> CompilerConfiguration? {
        if let value = self.logicValue(rootNode: rootNode) {
            switch value.memory {
            case .record(values: let pairs):
                let target = pairs.value(for: "target")
                let framework = pairs.value(for: "framework")
                switch (target, framework) {
                case (.some(.some(let targetValue)), .some(.some(let frameworkValue))):
                    let targetMemory = targetValue.memory
                    let frameworkMemory = frameworkValue.memory
                    switch (targetMemory, frameworkMemory) {
                    case (.enum(caseName: let targetName, _), .enum(caseName: let frameworkName, _)):
                        return .init(target: targetName, framework: frameworkName)
                    default:
                        break
                    }
                default:
                    break
                }
            default:
                break
            }
        }

        return nil
    }

    private static func makeProgram(from expression: LGCExpression) -> LGCProgram {
        let program = LGCProgram(
            id: UUID(),
            block: .init(
                [
                    .declaration(
                        id: UUID(),
                        content: .importDeclaration(id: UUID(), name: .init(id: UUID(), name: "CompilerConfiguration"))
                    ),
                    .declaration(
                        id: UUID(),
                        content: .variable(
                            id: UUID(),
                            name: .init(id: UUID(), name: "RESULT"),
                            annotation: .typeIdentifier(
                                id: UUID(),
                                identifier: .init(id: UUID(), string: "CompilerConfiguration"),
                                genericArguments: .empty
                            ),
                            initializer: expression,
                            comment: nil
                        )
                    )
                ]
            )
        )

        return program.expandImports(importLoader: LogicLoader.load)
    }
}
