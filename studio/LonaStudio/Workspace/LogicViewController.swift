//
//  LogicViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 6/5/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Defaults
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

    public var rootNode: LGCSyntaxNode = .topLevelDeclarations(
        .init(
            id: UUID(),
            declarations: .init([.makePlaceholder()])
        )
    ) { didSet { update() } }

    override var undoManager: UndoManager? { return nil }

    public var onChangeRootNode: ((LGCSyntaxNode) -> Void)?

    // MARK: Private

    private let logicEditor = LogicEditor()
    private let infoBar = InfoBar()
    private let divider = Divider()
    private let containerView = NSBox()

    private var colorValues: [UUID: String] = [:]
    private var shadowValues: [UUID: NSShadow] = [:]
    private var textStyleValues: [UUID: Logic.TextStyle] = [:]

    private let editorDisplayStyles: [LogicFormattingOptions.Style] = [.visual, .natural]

    private func setUpViews() {
        containerView.boxType = .custom
        containerView.borderType = .noBorder
        containerView.contentViewMargins = .zero

        containerView.addSubview(logicEditor)
        containerView.addSubview(infoBar)
        containerView.addSubview(divider)

        infoBar.fillColor = Colors.contentBackground

        divider.fillColor = NSSplitView.defaultDividerColor

        logicEditor.placeholderText = "Search or create"
        logicEditor.fillColor = Colors.contentBackground
        logicEditor.canvasStyle.textMargin = .init(width: 10, height: 6)
        logicEditor.showsFilterBar = true
        logicEditor.showsMinimap = true
        logicEditor.showsLineButtons = true
        logicEditor.suggestionFilter = Defaults[.suggestionFilter]
        TooltipWindow.contentInsets = .init(top: 4, left: 8, bottom: 6, right: 8)

        logicEditor.onInsertBelow = { [unowned self] rootNode, node in
            StandardConfiguration.handleMenuItem(logicEditor: self.logicEditor, action: .insertBelow(node.uuid))
        }

        logicEditor.contextMenuForNode = { [unowned self] rootNode, node in
            return StandardConfiguration.menu(rootNode: rootNode, node: node, allowComments: false, handleMenuAction: { [unowned self] action in
                StandardConfiguration.handleMenuItem(logicEditor: self.logicEditor, action: action)
                self.onChangeRootNode?(self.logicEditor.rootNode)
            })
        }

        logicEditor.onChangeSuggestionFilter = { [unowned self] value in
            self.logicEditor.suggestionFilter = value
            Defaults[.suggestionFilter] = value
        }

        infoBar.dropdownIndex = editorDisplayStyles.firstIndex(of: Defaults[.formattingStyle]) ?? 0
        infoBar.dropdownValues = editorDisplayStyles.map { $0.displayName }
        infoBar.onChangeDropdownIndex = { [unowned self] index in
            Defaults[.formattingStyle] = self.editorDisplayStyles[index]
            let newFormattingOptions = self.logicEditor.formattingOptions
            newFormattingOptions.style = self.editorDisplayStyles[index]
            self.logicEditor.formattingOptions = newFormattingOptions
            self.infoBar.dropdownIndex = index
        }

        self.view = containerView
    }

    private func setUpConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        logicEditor.translatesAutoresizingMaskIntoConstraints = false
        infoBar.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false

        logicEditor.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        logicEditor.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        logicEditor.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true

        logicEditor.bottomAnchor.constraint(equalTo: divider.topAnchor).isActive = true

        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        divider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true

        divider.bottomAnchor.constraint(equalTo: infoBar.topAnchor).isActive = true

        infoBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        infoBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        infoBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }

    private func update() {
        let module = LonaModule.current.logic
        let compiled = module.compiled
        let formattingOptions = module.formattingOptions

        logicEditor.formattingOptions = formattingOptions

        logicEditor.rootNode = rootNode

        logicEditor.elementErrors = compiled.errors.filter { rootNode.find(id: $0.uuid) != nil }

        logicEditor.onChangeRootNode = { [unowned self] newRootNode in
            self.onChangeRootNode?(newRootNode)
            return true
        }

        logicEditor.suggestionsForNode = LogicViewController.suggestionsForNode

        logicEditor.documentationForSuggestion = LogicViewController.documentationForSuggestion

        logicEditor.decorationForNodeID = { [unowned self] id in
            return LogicViewController.decorationForNodeID(
                rootNode: self.logicEditor.rootNode, // We only need to look within this logic file
                formattingOptions: formattingOptions,
                evaluationContext: compiled.evaluation,
                id: id
            )
        }
    }
}

public enum LogicEditorType: String, Codable {
    case componentEditor
    case codeEditor
}

extension Defaults.Keys {
    static let suggestionFilter = Key<SuggestionView.SuggestionFilter>("Logic editor suggestion filter", default: .all)
    static let formattingStyle = Key<LogicFormattingOptions.Style>("Logic editor style", default: .visual)
    static let logicEditorType = Key<LogicEditorType>("Logic editor style", default: .componentEditor)
}
