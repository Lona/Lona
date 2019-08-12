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

        let program: LGCSyntaxNode = compiled.programNode

        let scopeContext = Compiler.scopeContext(program)

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

        guard let substitution = try? substitutionResult.get() else {
            return compiled
        }

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
            compiled.evaluation = evaluation
        default:
            Swift.print("Evaluation failed")
        }

        return compiled
    }

    // MARK: Public Static

    public static func updateFile(url: URL, value: LGCSyntaxNode) {
        // TODO: Remove only those modules which rely on this url
        compiledCache.removeAll(keepingCapacity: true)
        programCache[url] = LGCProgram.make(from: value)
    }

    public static func load(url: URL) -> LGCProgram? {
        if let cached = programCache[url] {
            return cached
        }

        guard let data = try? Data(contentsOf: url) else {
            Swift.print("Failed to load \(url)")
            return nil
        }

        guard let syntaxNode = try? LogicDocument.read(from: data) else {
            Swift.print("Failed to decode \(url)")
            return nil
        }

        guard let program = LGCProgram.make(from: syntaxNode) else {
            Swift.print("Failed to make program from \(url)")
            return nil
        }

        programCache[url] = program

        return program
    }

    // MARK: Private Static

    private static let logicRE = try! NSRegularExpression(pattern: #"\.logic$"#)

    private static let preludeProgram = LGCProgram(
        id: UUID(),
        block: .init(
            [
                .declaration(
                    id: UUID(),
                    content: .importDeclaration(id: UUID(), name: .init(id: UUID(), name: "Prelude"))
                )
            ]
        )
    )

    private static var compiledCache: [URL: Compiled] = [:]

    private static var programCache: [URL: LGCProgram] = [:]
}
