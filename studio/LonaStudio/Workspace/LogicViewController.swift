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
        self.activeTab = parametersTabItem.id

        super.init(nibName: nil, bundle: nil)

        setUpViews()
        setUpConstraints()

        update()
    }

    required init?(coder: NSCoder) {
        self.activeTab = parametersTabItem.id

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

    public var onInspect: ((InspectorView.Content?) -> Void)?

    // MARK: Private

    private let componentViewController = MainSectionViewController()
    private let layerViewController = HorizontalSectionViewController()

    private let logicEditor = LogicEditor()
    private let canvasAreaView = CanvasAreaView()
    private let elementEditor = ElementEditor()
    private let parametersTabItem = NavigationItem(id: UUID(), title: "Parameters", icon: nil)
    private let logicTabItem = NavigationItem(id: UUID(), title: "Logic", icon: nil)
    private let examplesTabItem = NavigationItem(id: UUID(), title: "Examples", icon: nil)
    private lazy var tabItems: [NavigationItem] = {
        [parametersTabItem, logicTabItem, examplesTabItem]
    }()
    private let tabView = NavigationItemStack()
    private var activeTab: UUID {
        didSet { update() }
    }
    private let parameterEditor = LogicEditor()
    private let componentLogicEditor = LogicEditor()

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

        tabView.onClickItem = { [unowned self] id in
            self.activeTab = id
        }

        containerView.addSubview(contentContainerView)
        containerView.addSubview(infoBar)
        containerView.addSubview(divider)

        componentViewController.topView = layerViewController.view
        layerViewController.leftView = elementEditor

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
            var canvasAreaParameters = CanvasAreaView.Parameters(
                columns: [],
                showsAccessibilityOverlay: false,
                selectedLayerName: nil
            )

            if let examplesDeclaration = rootNode.findVariableDeclaration(name: "examples"),
                let examplesName = examplesDeclaration.variablePattern,
                let examplesValue = compiled.evaluation?.evaluate(uuid: examplesName.uuid),
                let examplesArray = examplesValue.array {

                let layers = examplesArray.map({ $0.renderableElement() ?? CSLayer() })

                canvasAreaParameters.columns = canvasList.map { canvas in
                    return .init(title: canvas.name, rows: layers.map { rootLayer in
                        Swift.print(canvas, rootLayer)
                        return .init(
                            canvas: canvas,
                            rootLayer: rootLayer,
                            config: .init(),
                            options: .init([
                                .renderCanvasShadow(true)
                            ])
                        )
                    })
                }
            }

            canvasAreaView.parameters = canvasAreaParameters

            canvasAreaView.onSelectCanvasHeaderItem = onSelectCanvasHeaderItem

            layerViewController.rightView = canvasAreaView
            componentViewController.dividerView = tabView

            tabView.activeItem = activeTab

            let componentDeclaration = LogicViewController.componentFunctionDeclaration(rootNode)

            if let declaration = componentDeclaration {
//                Swift.print("OK", compiled.programNode.find(id: declaration.uuid))

                elementEditor.rootItem = LogicViewController.componentElements(inFunctionDeclaration: declaration)

                elementEditor.onRenameItem = { [unowned self] item, name in
                    guard case let .expression(expression) = self.rootNode.find(id: item.id) else { return }

                    let newExpression = expression.withFunctionCallArgument(
                        label: "__name",
                        expression: .literalExpression(id: UUID(), literal: .string(id: UUID(), value: name))
                    )

                    self.onChangeRootNode?(self.rootNode.replace(id: item.id, with: newExpression.node))
                }

                elementEditor.onSelectItem = { [unowned self] item in
                    guard let item = item else {
                        self.onInspect?(nil)
                        return
                    }

                    guard case let .expression(expression) = self.rootNode.find(id: item.id) else { return }

                    self.elementEditor.selectedItem = item

                    self.onInspect?(.logicFunctionCall(expression))
                }
            }

            switch activeTab {
            case parametersTabItem.id:
                if let declaration = componentDeclaration, let parameters = declaration.functionParameters {
                    let topLevelParameters = LGCTopLevelParameters(id: UUID(), parameters: parameters)

                    parameterEditor.rootNode = topLevelParameters.node

                    parameterEditor.onChangeRootNode = { [unowned self] localRoot in
                        guard case .topLevelParameters(let newTopLevelParameters) = localRoot else { return false }

                        guard let newFunctionDeclaration = declaration.functionWith(parameters: newTopLevelParameters.parameters) else { return false }

                        self.onChangeRootNode?(self.rootNode.replace(id: declaration.uuid, with: newFunctionDeclaration.node))

                        return true
                    }
                }

                parameterEditor.formattingOptions = formattingOptions

                parameterEditor.suggestionsForNode = LogicViewController.suggestionsForNode

                parameterEditor.documentationForSuggestion = LogicViewController.documentationForSuggestion

                componentViewController.bottomView = parameterEditor
            case logicTabItem.id:
                if let declaration = LogicViewController.componentFunctionDeclaration(rootNode),
                    let block = declaration.functionStatementsBeforeReturnStatement {

                    let program = LGCProgram(id: UUID(), block: block)

                    componentLogicEditor.rootNode = .program(program)

                    componentLogicEditor.onChangeRootNode = { [unowned self] localRoot in
                        guard case .program(let newProgram) = localRoot else { return false }

                        guard let newFunctionDeclaration = declaration.functionWithStatementsBeforeReturnStatement(block: newProgram.block) else { return false }

                        self.onChangeRootNode?(self.rootNode.replace(id: declaration.uuid, with: newFunctionDeclaration.node))

                        return true
                    }
                }

                componentLogicEditor.formattingOptions = formattingOptions

                componentLogicEditor.suggestionsForNode = LogicViewController.suggestionsForNode

                componentLogicEditor.documentationForSuggestion = LogicViewController.documentationForSuggestion

                componentViewController.bottomView = componentLogicEditor
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
                rootNode: self.rootNode, // We only need to look within this logic file
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
                var width: Double = 375
//                var height: Double = 100

                if let memberValue = members["name"], case .some(.string(let value)) = memberValue?.memory {
                    name = value
                }

                if let memberValue = members["width"], case .some(.number(let value)) = memberValue?.memory {
                    width = Double(value)
                }

//                if let memberValue = members["height"], case .some(.number(let value)) = memberValue?.memory {
//                    height = Double(value)
//                }

                return Canvas(
                    visible: true,
                    name: name,
                    width: width,
                    height: 1,
                    heightMode: "At Least",
                    exportScale: 1,
                    backgroundColor: ""
                )
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

// MARK: - Components

extension LogicViewController {
    private static func componentFunctionDeclaration(_ rootNode: LGCSyntaxNode) -> LGCDeclaration? {
        return rootNode.reduce(initialResult: nil, f: { result, node, config in
            switch node {
            case .declaration(let declaration):
                switch declaration {
                case .function:
                    // TODO: Test returnType == Element and maybe check name too
                    config.stopTraversal = true

                    return declaration
                default:
                    return nil
                }
            default:
                return nil
            }
        })
    }

    private static func componentElements(inFunctionDeclaration declaration: LGCDeclaration) -> ElementItem? {
        return declaration.returnStatement?.returnedExpression?.elementItem()
    }

    public static func inspectableExpressions(expression: LGCExpression) -> [LogicInspectableExpression]? {
        let compiled = LonaModule.current.logic.compiled

        guard case let .functionCallExpression(_, callee, arguments) = expression else { return nil }

        guard let (unification, substitution) = compiled.unification else { return nil }

        guard let type = unification.nodes[callee.uuid] else { return nil }

        let resolvedType = Unification.substitute(substitution, in: type)

        guard case let .fun(argTypes, _) = resolvedType else { return nil }

        let inspectables: [LogicInspectableExpression] = argTypes.compactMap { arg in
            guard let label = arg.label, label != "__name", label != "children" else { return nil }
            let value = arguments.firstArgument(labeled: label)?.expression
            return LogicInspectableExpression(name: label, type: arg.type, expression: value)
        }

        return inspectables
    }
}

// MARK: - LGCArgument

extension LGCFunctionCallArgument {
    public var stringValue: String? {
        switch self {
        case .argument(id: _, label: _, expression: .literalExpression(id: _, literal: .string(id: _, value: let stringLiteral))):
            return stringLiteral
        default:
            return nil
        }
    }

    public var arrayValue: LGCList<LGCExpression>? {
        switch self {
        case .argument(id: _, label: _, expression: .literalExpression(id: _, literal: .array(id: _, value: let arrayLiteral))):
            return arrayLiteral
        default:
            return nil
        }
    }

    public var expression: LGCExpression? {
        switch self {
        case .argument(id: _, label: _, expression: let expression):
            return expression
        default:
            return nil
        }
    }
}

extension LGCList where T == LGCFunctionCallArgument {
    public func firstArgument(labeled label: String) -> LGCFunctionCallArgument? {
        return self.first { (arg) -> Bool in
            switch arg {
            case .argument(id: _, label: .some(label), expression: _):
                return true
            default:
                return false
            }
        }
    }

    public func firstIndexOfArgument(labeled label: String) -> Int? {
        return self.firstIndex { (arg) -> Bool in
            switch arg {
            case .argument(id: _, label: .some(label), expression: _):
                return true
            default:
                return false
            }
        }
    }
}

// MARK: - LGCExpression

extension LGCExpression {
    public var qualifiedDisplayName: String {
        switch self {
        case .identifierExpression(id: _, identifier: let identifier):
            return identifier.string
        case .memberExpression:
            return (flattenedMemberExpression ?? []).map({ $0.string }).joined(separator: ".")
        default:
            return "<computed value>"
        }
    }

    public func elementItem() -> ElementItem? {
        switch self {
        case .functionCallExpression(id: let id, expression: let expression, arguments: let arguments):
            let customLabel: String? = arguments.firstArgument(labeled: "__name")?.stringValue
            let childrenExpressions: LGCList<LGCExpression> = arguments.firstArgument(labeled: "children")?.arrayValue ?? .empty
            let childrenItems = childrenExpressions.compactMap({ $0.elementItem() })
            let functionName = expression.qualifiedDisplayName
            return ElementItem(id: id, type: functionName, name: customLabel, visible: true, children: childrenItems)
        default:
            return nil
        }
    }

    public func withFunctionCallArgument(label: String, expression argumentExpression: LGCExpression?) -> LGCExpression {
        guard case let .functionCallExpression(callID, callExpression, oldArguments) = self else {
            fatalError("Not a function call: \(self)")
        }

        var newArguments: [LGCFunctionCallArgument] = .init(oldArguments)

        if let matchingIndex = oldArguments.firstIndexOfArgument(labeled: label) {
            if let argumentExpression = argumentExpression {
                newArguments[matchingIndex] = .argument(id: UUID(), label: label, expression: argumentExpression)
            } else {
                newArguments.remove(at: matchingIndex)
            }
        } else if let argumentExpression = argumentExpression {
            newArguments.append(.argument(id: UUID(), label: label, expression: argumentExpression))
        }

        let newFunctionCall: LGCExpression = .functionCallExpression(
            id: callID,
            expression: callExpression,
            arguments: .init(newArguments)
        )

        return newFunctionCall.copy(deep: true)
    }
}

// MARK: - LGCStatement

extension LGCStatement {
    public var returnedExpression: LGCExpression? {
        switch self {
        case .returnStatement(id: _, expression: let expression):
            return expression
        default:
            return nil
        }
    }
}

// MARK: - LGCDeclaration

extension LGCDeclaration {
    public var variablePattern: LGCPattern? {
        switch self {
        case .variable(_, let pattern, _, _, _):
            return pattern
        default:
            return nil
        }
    }

    public var returnStatement: LGCStatement? {
        guard case .function(_, _, _, _, _, let block, _) = self else { return nil }
        return block.first(where: {
            if case .returnStatement = $0 { return true }
            return false
        })
    }

    public var functionParameters: LGCList<LGCFunctionParameter>? {
        guard case .function(_, _, _, _, let parameters, _, _) = self else { return nil }
        return parameters
    }

    public var functionBlock: LGCList<LGCStatement>? {
        guard case .function(_, _, _, _, _, let block, _) = self else { return nil }
        return block
    }

    public func functionWith(parameters newParameters: LGCList<LGCFunctionParameter>? = nil, block newBlock: LGCList<LGCStatement>? = nil) -> LGCDeclaration? {
        guard case let .function(id, name, returnType, genericParameters, parameters, block, comment) = self else { return nil }

        return .function(
            id: id,
            name: name,
            returnType: returnType,
            genericParameters: genericParameters,
            parameters: newParameters ?? parameters,
            block: newBlock ?? block,
            comment: comment
        )
    }

    public var functionStatementsBeforeReturnStatement: LGCList<LGCStatement>? {
        guard case .function(_, _, _, _, _, let block, _) = self else { return nil }
        let prefix = block.prefix(while: {
            if case .returnStatement = $0 { return false }
            return true
        })
        return LGCList(Array(prefix)).normalizedPlaceholders
    }

    public func functionWithStatementsBeforeReturnStatement(block: LGCList<LGCStatement>) -> LGCDeclaration? {
        guard case .function(_, _, _, _, _, let block, _) = self else { return nil }
        let suffix = block.drop(while: {
            if case .returnStatement = $0 { return false }
            return true
        })
        return functionWith(block: LGCList(Array(block) + Array(suffix)).normalizedPlaceholders)
    }
}

// MARK: LGCSyntaxNode

extension LGCSyntaxNode {
    public func findVariableDeclaration(name: String, typeAnnotation: LGCTypeAnnotation? = nil) -> LGCDeclaration? {
        return self.reduce(initialResult: nil, f: { result, node, config in
            switch node {
            case .declaration(let declaration):
                switch declaration {
                case .variable(_, let pattern, let annotation, _, _)
                    where pattern.name == name && (typeAnnotation == nil || annotation.isEquivalentTo(typeAnnotation)):

                    config.stopTraversal = true
                    return declaration
                default:
                    return nil
                }
            default:
                return nil
            }
        })
    }
}

// MARK: - Logic Value

extension LogicValue {
    func renderableElement() -> CSLayer? {
        guard case .record(let members) = self.memory,
            case .some(.string(let typeName)) = members["type"]??.memory,
            case .some(.array(let parametersArrayValue)) = members["parameters"]??.memory
            else { return nil }

        let parameters: [String: LogicValue] = parametersArrayValue.reduce(into: [:]) { (result, value) in
            guard case .enum(caseName: _, associatedValues: let associatedValues) = value.memory else { return }
            guard case .string(let parameterName) = associatedValues.first?.memory else { return }
            result[parameterName] = associatedValues[1]
        }

        let layer = CSLayer()

        switch typeName {
        case "LonaView":
            layer.type = .view
        case "LonaText":
            layer.type = .text

            if case .some(.string(let text)) = parameters["value"]?.memory {
                layer.text = text
            }
        default:
            return nil
        }

        layer.backgroundColor = parameters["backgroundColor"]?.colorString

        if case .some(.number(let paddingTop)) = parameters["paddingTop"]?.memory {
            layer.paddingTop = Double(paddingTop)
        }
        if case .some(.number(let paddingRight)) = parameters["paddingRight"]?.memory {
            layer.paddingRight = Double(paddingRight)
        }
        if case .some(.number(let paddingBottom)) = parameters["paddingBottom"]?.memory {
            layer.paddingBottom = Double(paddingBottom)
        }
        if case .some(.number(let paddingLeft)) = parameters["paddingLeft"]?.memory {
            layer.paddingLeft = Double(paddingLeft)
        }

        if case .some(.array(let childrenArrayValue)) = parameters["children"]?.memory {
            layer.children = childrenArrayValue.compactMap { $0.renderableElement() }
        }

        Swift.print(layer.type, layer.parameters)

        return layer
    }
}
