//
//  LogicInspectorView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/2/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit
import Logic
import NavigationComponents

public struct LogicInspectableExpression: Equatable {
    var name: String
    var type: Unification.T
    var expression: LGCExpression?
}

public class LogicInspectorView: NSBox {

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var items: [LogicInspectableExpression] = [] {
        didSet {
            if items != oldValue {
                update()
            }
        }
    }

    public var onChangeItems: (([LogicInspectableExpression]) -> Void)?

    // MARK: Private

    private let stackView = NSStackView()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        stackView.orientation = .vertical
        stackView.spacing = 0

        addSubview(stackView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    private func update() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if !items.isEmpty {
            stackView.addArrangedSubview(DividerView())
        }

        for (index, item) in items.enumerated() {
            let itemView = LogicInspectorHeaderBlock(titleText: item.name, buttonType: item.expression == nil ? .plus : .minus)

            itemView.onPressButton = { [unowned self] in
                if item.expression == nil {
                    let newItems = self.items.map({
                        $0 == item
                            ? LogicInspectableExpression(
                                name: $0.name,
                                type: $0.type,
                                expression: .identifierExpression(
                                    id: UUID(),
                                    identifier: .init(id: UUID(), string: $0.name, isPlaceholder: true)
                                )
                            )
                            : $0
                    })
                    self.onChangeItems?(newItems)
                } else {
                    let newItems = self.items.map({
                        $0 == item
                            ? LogicInspectableExpression(name: $0.name, type: $0.type, expression: nil)
                            : $0
                    })
                    self.onChangeItems?(newItems)
                }
            }

            stackView.addArrangedSubview(itemView)

            if let expression = item.expression {
                stackView.addArrangedSubview(DividerView())

                let valueView = LogicInspectorGenericValueBlock(expression: expression)

                valueView.onChange = { [unowned self] newExpression in
                    var newItems = self.items
                    var newItem = item
                    newItem.expression = newExpression
                    newItems[index] = newItem
                    self.onChangeItems?(newItems)
                }

                stackView.addArrangedSubview(valueView)
            }

            if item != items.last {
                stackView.addArrangedSubview(DividerView())
            }
        }

        if !items.isEmpty {
            stackView.addArrangedSubview(DividerView())
        }
    }
}

class DividerView: NSView {

    override var intrinsicContentSize: NSSize {
        return .init(width: NSView.noIntrinsicMetric, height: 1)
    }

    override func draw(_ dirtyRect: NSRect) {
        Colors.vibrantDivider.setFill()

        dirtyRect.fill()
    }
}

// MARK: LogicInspectorGenericValueBlock

public class LogicInspectorGenericValueBlock: NSBox {

    // MARK: Lifecycle

    init(expression: LGCExpression) {
        super.init(frame: .zero)

        self.expression = expression

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var onChange: ((LGCExpression?) -> Void)?

    public var expression: LGCExpression? {
        didSet {
            if expression != oldValue {
                update()
            }
        }
    }

    // MARK: Private

    private let logicEditorView = LogicEditor()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        fillColor = Colors.vibrantWell

        logicEditorView.showsLineButtons = false
        logicEditorView.showsDropdown = false
        logicEditorView.supportsLineSelection = false
        logicEditorView.scrollsVertically = false

        logicEditorView.canvasStyle.textMargin = .init(width: 10, height: 6)

        addSubview(logicEditorView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        logicEditorView.translatesAutoresizingMaskIntoConstraints = false

        logicEditorView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        logicEditorView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        logicEditorView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        logicEditorView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    private func update() {
        if let expression = expression {
            let module = LonaModule.current.logic
            let compiled = module.compiled

            logicEditorView.rootNode = .expression(expression)
            logicEditorView.decorationForNodeID = { id in
                return LogicViewController.decorationForNodeID(
                    rootNode: .expression(expression), // We only need to look within this logic file
                    formattingOptions: module.formattingOptions,
                    evaluationContext: compiled.evaluation,
                    id: id
                )
            }
            logicEditorView.suggestionsForNode = LogicViewController.suggestionsForNode
            logicEditorView.onChangeRootNode = { rootNode in
                guard case let .expression(expression) = rootNode else { return false }
                self.onChange?(expression)
                return true
            }
            logicEditorView.isHidden = false
        } else {
            logicEditorView.isHidden = true
        }
    }

    public override var intrinsicContentSize: NSSize {
        return logicEditorView.intrinsicContentSize
    }
}



// MARK: LogicInspectorHeaderBlock

public class LogicInspectorHeaderBlock: NSBox {

    public enum ButtonType {
        case plus, minus

        var image: NSImage {
            switch self {
            case .plus:
                return NSImage(named: NSImage.addTemplateName)!
            case .minus:
                return NSImage(named: NSImage.removeTemplateName)!
            }
        }
    }

    // MARK: Lifecycle

    init(titleText: String? = nil, buttonType: ButtonType? = nil) {
        super.init(frame: .zero)

        self.titleText = titleText
        self.buttonType = buttonType

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var titleText: String? {
        didSet {
            if titleText != oldValue {
                update()
            }
        }
    }

    public var buttonType: ButtonType?

    public var onPressButton: (() -> Void)? {
        get { buttonView.onClick }
        set { buttonView.onClick = newValue }
    }

    // MARK: Private

    private let titleView = NavigationItemView()

    private let titleTextStyle: TextStyle = .init(
        weight: .medium,
        size: NSFont.systemFontSize(for: .small),
        color: NSColor.themed(color: NSColor.textColor.withAlphaComponent(0.8))
    )

    private let buttonView = NavigationItemView()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        titleView.style.font = titleTextStyle.nsFont
        titleView.style.textColor = titleTextStyle.color!

        addSubview(titleView)
        addSubview(buttonView)

        fillColor = Colors.vibrantRaised
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.translatesAutoresizingMaskIntoConstraints = false

        titleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true

        buttonView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        buttonView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
    }

    private func update() {
        titleView.titleText = titleText?.camelCasedComponents.joined(separator: " ").uppercased()
        buttonView.icon = buttonType?.image
    }

    public override var intrinsicContentSize: NSSize {
        return .init(width: NSView.noIntrinsicMetric, height: EditorViewController.navigationBarHeight - 1)
    }
}

