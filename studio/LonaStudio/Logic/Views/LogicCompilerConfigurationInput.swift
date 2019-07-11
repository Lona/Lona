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

    public struct CompilerConfiguration {
        public var target: String
        public var framework: String
    }

    // MARK: Lifecycle

    public init(configuration: CompilerConfiguration) {
        self.configuration = configuration

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var onChangeConfiguration: ((CompilerConfiguration) -> Void)?

    // MARK: Private

    private var configuration: CompilerConfiguration

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
                        .init(
                            id: UUID(),
                            label: "target",
                            expression: .functionCallExpression(
                                id: UUID(),
                                expression: .memberExpression(
                                    id: UUID(),
                                    expression: .identifierExpression(id: UUID(), identifier: .init(id: UUID(), string: "CompilerTarget")),
                                    memberName: .init(id: UUID(), string: configuration.target)
                                ),
                                arguments: .empty
                            )
                        ),
                        .init(
                            id: UUID(),
                            label: "framework",
                            expression: .functionCallExpression(
                                id: UUID(),
                                expression: .memberExpression(
                                    id: UUID(),
                                    expression: .identifierExpression(id: UUID(), identifier: .init(id: UUID(), string: "CompilerFramework")),
                                    memberName: .init(id: UUID(), string: configuration.framework)
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
        logicEditor.onChangeRootNode = { [unowned self] node in
            self.logicEditor.rootNode = node

            if let value = self.evaluateExpression(node: node) {
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
                            self.onChangeConfiguration?(.init(target: targetName, framework: frameworkName))
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

            return true
        }

        logicEditor.suggestionsForNode = { rootNode, node, query in
            guard case .expression(let expression) = rootNode else { return [] }

            let program = LGCSyntaxNode.program(LogicCompilerConfigurationInput.makeProgram(from: expression))

            return StandardConfiguration.suggestions(rootNode: program, node: node, query: query, logLevel: .verbose) ?? []
        }
    }

    private func evaluateExpression(node: LGCSyntaxNode) -> LogicValue? {
        guard case .expression(let expression) = node else { return nil }

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
                            initializer: expression
                        )
                    )
                ]
            )
        )

        return program.expandImports(importLoader: LogicLoader.load)
    }
}
