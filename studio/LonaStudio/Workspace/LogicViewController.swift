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
import NavigationComponents

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

    private let componentViewController = MainSectionViewController()

    private let logicEditor = LogicEditor()
    private let canvasAreaView = CanvasAreaView()
    private let parametersTabItem = NavigationItem(id: UUID(), title: "Parameters", icon: nil)
    private let logicTabItem = NavigationItem(id: UUID(), title: "Logic", icon: nil)
    private let examplesTabItem = NavigationItem(id: UUID(), title: "Examples", icon: nil)
    private lazy var tabItems: [NavigationItem] = {
        [parametersTabItem, logicTabItem, examplesTabItem]
    }()
    private let tabView = NavigationItemStack()
    private lazy var activeTab: UUID = { parametersTabItem.id }()
    private let parameterEditor = LogicEditor()

    private let infoBar = InfoBar()
    private let divider = Divider()
    private let containerView = NSBox()
    private let contentContainerView = NSBox()

    private var editorType: LogicEditorType = Defaults[.logicEditorType] {
        didSet { update() }
    }

    private var contentView: NSView? {
        didSet {
            if let contentView = contentView {
                if contentView != oldValue {
                    oldValue?.removeFromSuperview()
                    contentView.removeFromSuperview()

                    contentContainerView.addSubview(contentView)

                    contentView.translatesAutoresizingMaskIntoConstraints = false

                    contentView.topAnchor.constraint(equalTo: contentContainerView.topAnchor).isActive = true
                    contentView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor).isActive = true
                    contentView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor).isActive = true
                    contentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor).isActive = true
                }
            } else {
                oldValue?.removeFromSuperview()
            }
        }
    }

    private func setUpViews() {
        containerView.boxType = .custom
        containerView.borderType = .noBorder
        containerView.contentViewMargins = .zero

        contentContainerView.boxType = .custom
        contentContainerView.borderType = .noBorder
        contentContainerView.contentViewMargins = .zero

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

        infoBar.onChangeDropdownIndex = { [unowned self] index in
            let newValue = LogicEditorType.allCases[index]
            Defaults[.logicEditorType] = newValue
            self.editorType = newValue
        }

        tabView.items = tabItems
        tabView.style = .tabs
        tabView.activeItem = parametersTabItem.id

        containerView.addSubview(contentContainerView)
        containerView.addSubview(infoBar)
        containerView.addSubview(divider)

        self.view = containerView
    }

    private func setUpConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        infoBar.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        tabView.translatesAutoresizingMaskIntoConstraints = false

        contentContainerView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        contentContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        contentContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true

        contentContainerView.bottomAnchor.constraint(equalTo: divider.topAnchor).isActive = true

        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        divider.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        divider.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true

        divider.bottomAnchor.constraint(equalTo: infoBar.topAnchor).isActive = true

        infoBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        infoBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        infoBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }

    private func update() {
        // Currently assigning rootNode should happen first, since other methods rely on it
        logicEditor.rootNode = rootNode

        let module = LonaModule.current.logic
        let compiled = module.compiled
        let formattingOptions = module.formattingOptions

        infoBar.dropdownIndex = LogicEditorType.allCases.firstIndex(of: Defaults[.logicEditorType]) ?? 0
        infoBar.dropdownValues = LogicEditorType.allCases.map { $0.rawValue }

        switch editorType {
        case .componentEditor:
            let component: CSComponent = .makeDefaultComponent()
            component.canvas = canvasList

            canvasAreaView.parameters = CanvasAreaView.Parameters(
                component: component,
                showsAccessibilityOverlay: false,
                onSelectLayer: {_ in},
                selectedLayerName: nil
            )

            canvasAreaView.onSelectCanvasHeaderItem = onSelectCanvasHeaderItem

            componentViewController.topView = canvasAreaView
            componentViewController.dividerView = tabView

            switch activeTab {
            case parametersTabItem.id:
                if let (parameters, declarationId) = functionParameters {
                    let topLevelParameters = LGCTopLevelParameters(id: UUID(), parameters: .init(parameters))
                    parameterEditor.rootNode = .topLevelParameters(topLevelParameters)

                    parameterEditor.onChangeRootNode = { [unowned self] parameterRoot in
                        guard case .topLevelParameters(let newTopLevelParameters) = parameterRoot else { return false }

                        guard let newRootNode = self.updateFunctionDeclaration(id: declarationId, newParameters: newTopLevelParameters.parameters) else { return false }

                        self.onChangeRootNode?(newRootNode)

                        return true
                    }
                }

                parameterEditor.formattingOptions = formattingOptions

                parameterEditor.suggestionsForNode = LogicViewController.suggestionsForNode

                parameterEditor.documentationForSuggestion = LogicViewController.documentationForSuggestion

                componentViewController.bottomView = parameterEditor
            default:
                componentViewController.bottomView = nil
            }

            contentView = componentViewController.view
        case .logicEditor:
            contentView = logicEditor
        }

        logicEditor.formattingOptions = formattingOptions

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

public enum LogicEditorType: String, Codable, CaseIterable {
    case componentEditor = "Component Editor"
    case logicEditor = "Logic Editor"
}

extension Defaults.Keys {
    static let suggestionFilter = Key<SuggestionView.SuggestionFilter>("Logic editor suggestion filter", default: .all)
    static let formattingStyle = Key<LogicFormattingOptions.Style>("Logic editor style", default: .visual)
    static let logicEditorType = Key<LogicEditorType>("Logic editor style", default: .componentEditor)
}

// MARK: - Canvases

extension LogicViewController {
    private var canvasExpressions: [LGCExpression] {
        let rootNode = logicEditor.rootNode

        let expressions: [LGCExpression]? = rootNode.reduce(initialResult: [], f: { result, node, config in
            switch node {
            case .declaration(.variable(id: _, name: let pattern, annotation: .some(let annotation), initializer: .some(let initializer), comment: _)) where pattern.name == "devices" && annotation.unificationType(genericsInScope: [:], getName: { "" }) == .cons(name: "Array", parameters: [.cons(name: "LonaDevice")]):
                config.stopTraversal = true

                switch initializer {
                case .literalExpression(id: _, literal: .array(id: _, value: let array)):
                    return array.map { $0 }
                default:
                    return nil
                }
            default:
                return nil
            }
        })

        return expressions ?? []
    }

    private var canvasList: [Canvas] {
        let module = LonaModule.current.logic
        let compiled = module.compiled

        let canvases: [Canvas?]? = canvasExpressions.map({ expression in
            switch compiled.evaluation?.evaluate(uuid: expression.uuid) {
            case .some(let logicValue):
                guard case .record(let members) = logicValue.memory else { return nil }

                var name: String = ""

                if let memberValue = members["name"], case .some(.string(let value)) = memberValue?.memory {
                    name = value
                }

                return Canvas(device: .custom, name: name, heightMode: "At Least", exportScale: 1, backgroundColor: "")
            case .none:
                return nil
            }
        })

        return canvases?.compactMap({ $0 }) ?? []
    }

    public func canvasExpressionSuggestions(for query: String, canvasIndex: Int) -> [LogicSuggestionItem] {
        let module = LonaModule.current.logic
        let compiled = module.compiled

        return LogicViewController
            .suggestionsForNode(compiled.programNode, .expression(self.canvasExpressions[canvasIndex]), query)
            .items
            .compactMap({ (item: LogicSuggestionItem) in
                switch item.node {
                case .expression(.memberExpression), .expression(.identifierExpression):
                    return item
                default:
                    return nil
                }
            })
    }

    public func canvasExpressionSuggestionListItems(for query: String, canvasIndex: Int) -> [SuggestionListItem] {
        canvasExpressionSuggestions(for: query, canvasIndex: canvasIndex).map({ (item: LogicSuggestionItem) in
            return .row(item.title, nil, false, nil, nil)
        })
    }

    public func onSelectCanvasHeaderItem(_ canvasIndex: Int) {
        guard let window = self.canvasAreaView.window else { return }

        let suggestionWindow = SuggestionWindow.shared

        suggestionWindow.suggestionText = ""
        suggestionWindow.suggestionItems = self.canvasExpressionSuggestionListItems(for: "", canvasIndex: canvasIndex)
        suggestionWindow.placeholderText = "Choose device"
        suggestionWindow.style = .contextMenu
        suggestionWindow.onRequestHide = { suggestionWindow.orderOut(nil) }
        suggestionWindow.onPressEscapeKey = { suggestionWindow.orderOut(nil) }
        suggestionWindow.onSelectIndex = { index in
            suggestionWindow.selectedIndex = index
        }
        suggestionWindow.onChangeSuggestionText = { text in
            suggestionWindow.suggestionText = text
            suggestionWindow.suggestionItems = self.canvasExpressionSuggestionListItems(for: text, canvasIndex: canvasIndex)
        }
        suggestionWindow.onSubmit = { index in
            let suggestedNode = self.canvasExpressionSuggestions(for: suggestionWindow.suggestionText, canvasIndex: canvasIndex)[index].node
            let newRootNode = self.rootNode.replace(id: self.canvasExpressions[canvasIndex].uuid, with: suggestedNode)
            _ = self.onChangeRootNode?(newRootNode)

            suggestionWindow.orderOut(nil)
        }

        window.addChildWindow(suggestionWindow, ordered: .above)

        let windowRect = self.canvasAreaView.convert(self.canvasAreaView.headerRect(ofColumn: canvasIndex), to: nil)
        let screenRect = window.convertToScreen(windowRect)
        let adjustedRect = NSRect(
            x: screenRect.midX - suggestionWindow.defaultContentWidth / 2,
            y: screenRect.origin.y,
            width: screenRect.width,
            height: screenRect.height
        )

        suggestionWindow.anchorTo(rect: adjustedRect, verticalOffset: 4)
        suggestionWindow.focusSearchField()
    }
}

// MARK: - Parameters

extension LogicViewController {
    private var functionParameters: (parameters: [LGCFunctionParameter], declarationId: UUID)? {
        let rootNode = logicEditor.rootNode

        return rootNode.reduce(initialResult: nil, f: { result, node, config in
            switch node {
            case .declaration(.function(id: let id, name: _, returnType: _, genericParameters: _, parameters: let parameters, block: _, comment: _)):
                // TODO: Test returnType == Element and maybe check name too
                config.stopTraversal = true

                return (parameters.map { $0 }, id)
            default:
                return nil
            }
        })
    }

    private func updateFunctionDeclaration(id originalDeclarationId: UUID, newParameters: LGCList<LGCFunctionParameter>) -> LGCSyntaxNode? {
        guard case .declaration(.function(let functionValue)) = self.rootNode.find(id: originalDeclarationId) else { return nil }

        let newDeclarationNode: LGCSyntaxNode = .declaration(
            .function(
                id: UUID(),
                name: functionValue.name,
                returnType: functionValue.returnType,
                genericParameters: functionValue.genericParameters,
                parameters: newParameters,
                block: functionValue.block,
                comment: functionValue.comment
            )
        )

        return self.rootNode.replace(id: originalDeclarationId, with: newDeclarationNode)
    }
}
