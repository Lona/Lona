//
//  MarkdownViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 6/29/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import ColorPicker
import Differ
import Logic

// MARK: - MarkdownViewController

class MarkdownViewController: NSViewController {

    // MARK: Lifecycle

    convenience init(editable: Bool, preview: Bool) {
        self.init(nibName: nil, bundle: nil)

        self.editable = editable
        self.preview = preview
    }

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    // MARK: Public

    override var undoManager: UndoManager? { return nil }

    public var editable: Bool = true

    public var preview: Bool = true

    public var content: [BlockEditor.Block] = [] {
        didSet {
            let diff = oldValue.extendedDiff(content)

            let tokensChanged = diff.contains(where: { element in
                switch element {
                case .delete(at: let index):
                    if case .tokens = oldValue[index].content {
                        return true
                    } else {
                        return false
                    }
                case .insert(at: let index):
                    if case .tokens = content[index].content {
                        return true
                    } else {
                        return false
                    }
                case .move:
                    return false
                }
            })

            update(shouldUpdateTokenBlocks: tokensChanged)
        }
    }

    public var onChange: (([BlockEditor.Block]) -> Bool)? {
        get { return contentView.onChangeBlocks }
        set { contentView.onChangeBlocks = newValue }
    }

    public var onNavigateToPage: ((String) -> Bool)? {
        get { return contentView.onClickPageLink }
        set { contentView.onClickPageLink = newValue }
    }

    public var onRequestCreatePage: ((Int, Bool) -> Void)? {
        get { return contentView.onRequestCreatePage }
        set { contentView.onRequestCreatePage = newValue }
    }

    // MARK: Private

    override func loadView() {

        setUpViews()
        setUpConstraints()

        update(shouldUpdateTokenBlocks: true)
    }

    private let containerView = NSBox()
    private var contentView = BlockEditor()

    private func setUpViews() {
        containerView.borderType = .noBorder
        containerView.boxType = .custom
        containerView.contentViewMargins = .zero

        containerView.addSubview(contentView)

        contentView.fillColor = .clear

        contentView.onClickLink = { link in
            guard let url = URL(string: link) else { return true }
            NSWorkspace.shared.open(url)
            return true
        }

        view = contentView
    }

    private func setUpConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }

    private func update(shouldUpdateTokenBlocks: Bool) {
        contentView.blocks = content

        if shouldUpdateTokenBlocks {
            configure(blocks: content)
        }
    }
}

// MARK: - Editor Configuration

extension MarkdownViewController {

    private func configure(blocks: [BlockEditor.Block]) {
        let module = LonaModule.current.logic
        let compiled = module.compiled

        // TODO: topLevelDeclarations and program are created with a new ID each time, will that hurt performance?
        guard let root = LGCProgram.make(from: .topLevelDeclarations(blocks.topLevelDeclarations)) else { return }

        let rootNode = LGCSyntaxNode.program(root)

        blocks.forEach { block in
            switch block.content {
            case .tokens:
                let logicEditor = block.view as! LogicEditor

                logicEditor.formattingOptions = module.formattingOptions

                logicEditor.suggestionsForNode = { _, node, query in
                    LogicViewController.suggestionsForNode(rootNode, node, query)
                }

                // Only show the errors for nodes within this rootNode
                logicEditor.elementErrors = compiled.errors.filter { logicEditor.rootNode.find(id: $0.uuid) != nil }

                logicEditor.willSelectNode = { rootNode, nodeId in
                    guard let nodeId = nodeId else { return nil }

                    return rootNode.redirectSelection(nodeId)
                }

                logicEditor.documentationForSuggestion = LogicViewController.documentationForSuggestion
            default:
                break
            }
        }
    }
}
