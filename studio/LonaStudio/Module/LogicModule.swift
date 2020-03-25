//
//  LogicModule.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/11/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

public class LogicModule {

    public class Compiled {
        public init(program: LGCProgram) {
            self.program = program
            self.programNode = .program(program)
        }

        public var programNode: LGCSyntaxNode
        public var program: LGCProgram
        public var errors: [LogicEditor.ElementError] = []
        public var unification: (Compiler.UnificationContext, Unification.Substitution)?
        public var evaluation: Compiler.EvaluationContext?
    }

    // MARK: Lifecycle

    public init(url: URL) {
        self.url = url
    }

    // MARK: Public

    public var url: URL

    public var fileUrls: [URL] {
        return FileSearch.search(filesIn: url, matching: LogicModule.logicRE)
    }

    public var program: LGCProgram {
        let programs: [LGCProgram] = fileUrls.compactMap { LogicModule.load(url: $0) }

        let joinedProgram: LGCProgram = .join(programs: [LogicModule.preludeProgram] + programs)

        return joinedProgram.expandImports(importLoader: LogicLoader.load)
    }

    public var compiled: Compiled {
        if let cached = LogicModule.compiledCache[url] {
            return cached
        }

        let compiled = compile()

        LogicModule.compiledCache[url] = compiled

        return compiled
    }

    // MARK: Private

    private func compile() -> Compiled {
        let compiled = Compiled(program: self.program)

        AppDelegate.debugController.rootNode = compiled.programNode

        let program: LGCSyntaxNode = compiled.programNode

        let scopeContext = Compiler.scopeContext(program)

        AppDelegate.debugController.scopeContext = scopeContext

        scopeContext.undefinedIdentifiers.forEach { errorId in
            if case .identifier(let identifierNode)? = program.find(id: errorId) {
                compiled.errors.append(
                    LogicEditor.ElementError(uuid: errorId, message: "The name \"\(identifierNode.string)\" hasn't been declared yet")
                )
            }
        }

        scopeContext.undefinedMemberExpressions.forEach { errorId in
            if case .expression(let expression)? = program.find(id: errorId), let identifiers = expression.flattenedMemberExpression {
                let keyPath = identifiers.map { $0.string }
                let last = keyPath.last ?? ""
                let rest = keyPath.dropLast().joined(separator: ".")
                compiled.errors.append(
                    LogicEditor.ElementError(uuid: errorId, message: "The name \"\(last)\" hasn't been declared in \"\(rest)\" yet")
                )
            }
        }

        let unificationContext = Compiler.makeUnificationContext(program, scopeContext: scopeContext)
        let substitutionResult = Unification.unify(constraints: unificationContext.constraints)

        AppDelegate.debugController.unificationContext = unificationContext

        guard let substitution = try? substitutionResult.get() else {
            return compiled
        }

        AppDelegate.debugController.substitution = substitution

        compiled.unification = (unificationContext, substitution)

        let evaluationContext = Compiler.evaluate(
            program,
            rootNode: program,
            scopeContext: scopeContext,
            unificationContext: unificationContext,
            substitution: substitution,
            context: .init()
        )

        switch evaluationContext {
        case .success(let evaluation):
            AppDelegate.debugController.evaluationContext = evaluation

            compiled.evaluation = evaluation

            if evaluation.hasCycle {
                Swift.print("Logic cycle(s) found", evaluation.cycles)
            }

            let cycleErrors = evaluation.cycles.map { cycle in
                return cycle.map { id -> LogicEditor.ElementError in
                    return LogicEditor.ElementError(uuid: id, message: "A variable's definition can't include its name (there's a cycle somewhere)")
                }
            }

            compiled.errors.append(contentsOf: Array(cycleErrors.joined()))
        default:
            Swift.print("Evaluation failed")
        }

        return compiled
    }

    // MARK: Public Static

    public static func invalidateCaches(url: URL, newValue: LGCProgram) {
        LogicViewController.invalidateThumbnail(url: url)
        LogicModule.updateFile(url: url, value: newValue)
    }

    public static func updateFile(url: URL, value: MDXRoot) {
        updateFile(url: url, value: value.program())
    }

    public static func updateFile(url: URL, value: LGCSyntaxNode) {
        updateFile(url: url, value: LGCProgram.make(from: value)!)
    }

    public static func updateFile(url: URL, value: LGCProgram) {
        let cached = programCache[url]
        if !(cached?.isEquivalentTo(value) ?? false) {
          // TODO: Remove only those modules which rely on this url
          compiledCache.removeAll(keepingCapacity: true)
          programCache[url] = value
        }
    }

    public static func load(url: URL) -> LGCProgram? {
        if let cached = programCache[url] {
            return cached
        }

        guard let data = try? Data(contentsOf: url) else {
            Swift.print("Failed to load \(url)")
            return nil
        }

        func getProgram() -> LGCProgram? {
            if url.pathExtension == "md" || url.pathExtension == "mdx" {
                guard let mdxRoot = MarkdownFile.makeMDXRoot(data) else { return nil }

                return mdxRoot.program()
            } else {
                guard let syntaxNode = try? LogicDocument.read(from: data) else {
                    Swift.print("Failed to decode \(url)")
                    return nil
                }

                guard let program = LGCProgram.make(from: syntaxNode) else {
                    Swift.print("Failed to make program from \(url)")
                    return nil
                }

                return program
            }
        }

        let program = getProgram()

        programCache[url] = program

        return program
    }

    // MARK: Private Static

    private static let logicRE = try! NSRegularExpression(pattern: #"\.(logic|tokens|md|mdx|cmp)$"#)

    private static let preludeProgram = LGCProgram(
        id: UUID(),
        block: .init(
            [
                .declaration(
                    id: UUID(),
                    content: .importDeclaration(id: UUID(), name: .init(id: UUID(), name: "Prelude"))
                ),
                .declaration(
                    id: UUID(),
                    content: .importDeclaration(id: UUID(), name: .init(id: UUID(), name: "Color"))
                ),
                .declaration(
                    id: UUID(),
                    content: .importDeclaration(id: UUID(), name: .init(id: UUID(), name: "Shadow"))
                ),
                .declaration(
                    id: UUID(),
                    content: .importDeclaration(id: UUID(), name: .init(id: UUID(), name: "TextStyle"))
                ),
                .declaration(
                    id: UUID(),
                    content: .importDeclaration(id: UUID(), name: .init(id: UUID(), name: "LonaDevice"))
                )
            ]
        )
    )

    private static var compiledCache: [URL: Compiled] = [:]

    private static var programCache: [URL: LGCProgram] = [:]
}

// MARK: - Formatting

extension LogicModule {
    public var formattingOptions: LogicFormattingOptions {
        let compiled = self.compiled

        let formattingOptions: LogicFormattingOptions = LogicFormattingOptions(
            style: .visual,
            getError: ({ id in
                if let error = compiled.errors.first(where: { $0.uuid == id }) {
                    return error.message
                } else {
                    return nil
                }
            }),
            getArguments: ({ id in
                return StandardConfiguration.formatArguments(
                    rootNode: compiled.programNode,
                    id: id,
                    unificationContext: compiled.unification?.0,
                    substitution: compiled.unification?.1
                )
            }),
            getColor: ({ id in
                guard let evaluation = compiled.evaluation else { return nil }
                guard let value = evaluation.evaluate(uuid: id) else { return nil }
                guard let colorString = value.colorString, let color = NSColor.parse(css: colorString) else { return nil }
                return (colorString, color)
            }),
            getTextStyle: ({ id in
                guard let evaluation = compiled.evaluation else { return nil }
                guard let value = evaluation.evaluate(uuid: id) else { return nil }
                return value.textStyle
            }),
            getShadow: ({ id in
                guard let evaluation = compiled.evaluation else { return nil }
                guard let value = evaluation.evaluate(uuid: id) else { return nil }
                return value.nsShadow
            })
        )

        return formattingOptions
    }
}
