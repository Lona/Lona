//
//  LogicViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 6/5/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

// MARK: - LogicViewController

class LogicViewController: NSViewController {

    // MARK: Lifecycle

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)

        setUpViews()
        setUpConstraints()

        update()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setUpViews()
        setUpConstraints()

        update()
    }

    // MARK: Public

    public var rootNode: LGCSyntaxNode = LogicEditor.defaultRootNode { didSet { update() } }

    public var onChangeRootNode: ((LGCSyntaxNode) -> Void)?

    // MARK: Private

    private let logicView = LogicEditor()

    private var colorValues: [UUID: String] = [:]

    private func setUpViews() {
        self.view = logicView

        logicView.fillColor = Colors.contentBackground
        logicView.canvasStyle.textMargin = .init(width: 10, height: 6)

        logicView.formattingOptions = LogicFormattingOptions(
            style: .visual,
            getColor: { [unowned self] id in
                guard let colorString = self.colorValues[id],
                    let color = NSColor.parse(css: colorString) else { return nil }
                return (colorString, color)
            }
        )
    }

    private func setUpConstraints() {}

    private static func makePreludeProgram() -> LGCProgram {
        return .init(
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
    }

    private func evaluate() {
        let (scopeContext, unificationContext, substitutionResult) = StandardConfiguration.compile(rootNode)

        guard let substitution = try? substitutionResult.get() else { return }

        guard let evaluationContext = try? Compiler.evaluate(
            rootNode,
            rootNode: rootNode,
            scopeContext: scopeContext,
            unificationContext: unificationContext,
            substitution: substitution,
            context: .init()
            ).get() else { return }

        evaluationContext.values.forEach { id, value in
            if let colorString = value.colorString {
                colorValues[id] = colorString
            }
        }
    }

    private func update() {
        logicView.rootNode = rootNode

        evaluate()

        logicView.onChangeRootNode = { [unowned self] newRootNode in
            self.onChangeRootNode?(newRootNode)
            return true
        }

        logicView.suggestionsForNode = { rootNode, node, query in
            guard case .program(let root) = rootNode else { return [] }

            let program: LGCSyntaxNode = .program(
                LGCProgram.join(programs: [LogicViewController.makePreludeProgram(), root])
                    .expandImports(importLoader: Library.load)
            )

            return StandardConfiguration.suggestions(rootNode: program, node: node, query: query)
                ?? LogicEditor.defaultSuggestionsForNode(rootNode, node, query)
        }
    }
}
