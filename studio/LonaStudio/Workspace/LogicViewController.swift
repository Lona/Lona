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

    private func setUpViews() {
        self.view = logicView

        logicView.fillColor = Colors.contentBackground
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

    private func update() {
        logicView.rootNode = rootNode

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
