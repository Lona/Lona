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

    public lazy var outlineView = MarkdownOutlineView()

    private func setUpViews() {
        containerView.borderType = .noBorder
        containerView.boxType = .custom
        containerView.contentViewMargins = .zero

        containerView.addSubview(contentView)

        contentView.fillColor = .clear
        contentView.showsMinimap = true
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
        outlineView.blocks = content

        outlineView.onSelectItem = { [unowned self] block in
            guard let block = block else { return }

            self.preventSelectionDuringScrollAnimation { [weak self] in
                self?.contentView.select(id: block.id)
                self?.outlineView.selectedID = block.id
            }
        }

        // When visible rows change, select the last header before the first visible row in the outline view
        contentView.onChangeVisibleRows = { [unowned self] rows in
            if self.isSelectingItem { return }

            let previousRows = (0..<rows.lowerBound + 1).clamped(to: 0..<self.content.count)
            let previousBlocks = self.content[previousRows]

            let lastHeader = previousBlocks.last(where: { block in
                switch block.content {
                case .text(_, let level) where level == .h1 || level == .h2 || level == .h3:
                    return true
                default:
                    return false
                }
            })

            // Don't select the first header, since it's visually distracting
            if lastHeader == self.content.textElements(level: .h1).first {
                self.outlineView.selectedID = nil
            } else {
                self.outlineView.selectedID = lastHeader?.id
            }
        }

        if shouldUpdateTokenBlocks {
            configure(blocks: content)
        }
    }


    // Reduce jitter during the scrolling animation.
    // The scrollview scrolls with an animation only when navigating the outline view via arrow keys.
    // If we can find a wayt to disable the animation completely, we should do that instead.
    private var isSelectingItem = false

    private var isSelectingItemTask: DispatchWorkItem?

    private func preventSelectionDuringScrollAnimation(_ block: @escaping () -> Void) {
        isSelectingItemTask?.cancel()
        isSelectingItem = true

        block()

        let task = DispatchWorkItem(block: { [weak self] in
            self?.isSelectingItem = false
        })
        isSelectingItemTask = task

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: task)
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
