//
//  LabeledColorInput.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/10/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

// MARK: - LabeledColorInput

public class LabeledColorInput: NSBox {

    // MARK: Lifecycle

    public init(titleText: String, colorString: String?) {
        self.titleText = titleText
        self.colorString = colorString

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var titleText: String {
        didSet {
            if titleText != oldValue {
                update()
            }
        }
    }

    public var colorString: String? {
        didSet {
            if colorString != oldValue {
                update()
            }
        }
    }

    public var onChangeColorString: ((String?) -> Void)?

    // MARK: Private

    private let labeledInputView = LabeledLogicInput(titleText: "")

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        addSubview(labeledInputView)

        labeledInputView.logicEditor.rootNode = .expression(
            .identifierExpression(
                id: UUID(),
                identifier: LGCIdentifier(id: UUID(), string: "none")
            )
        )
        labeledInputView.logicEditor.decorationForNodeID = { [unowned self] id in
            guard let node = self.labeledInputView.logicEditor.rootNode.find(id: id) else { return nil }
            switch node {
            case .literal(.color(id: _, value: let code)):
                return .color(CSColors.parse(css: code).color)
            default:
                return nil
            }
        }
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        labeledInputView.translatesAutoresizingMaskIntoConstraints = false

        labeledInputView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        labeledInputView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        labeledInputView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        labeledInputView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func update() {
        labeledInputView.titleText = titleText

        switch colorString {
        case .none:
            labeledInputView.logicEditor.rootNode = .expression(
                .identifierExpression(
                    id: UUID(),
                    identifier: LGCIdentifier(id: UUID(), string: "none")
                )
            )
        case .some(let value):
            labeledInputView.logicEditor.rootNode = .expression(
                .literalExpression(
                    id: UUID(),
                    literal: .color(id: UUID(), value: value)
                )
            )
        }

        labeledInputView.logicEditor.onChangeRootNode = { [unowned self] node in
            func makeColorValue(node: LGCSyntaxNode) -> String? {
                switch node {
                case .expression(.literalExpression(id: _, literal: .color(id: _, value: let value))):
                    return value
                default:
                    return nil
                }
            }

            self.onChangeColorString?(makeColorValue(node: node))
            return true
        }

        labeledInputView.logicEditor.suggestionsForNode = { _, query in
            let noneSuggestion = LogicSuggestionItem(
                title: "None",
                category: "No Color".uppercased(),
                node: .expression(
                    .identifierExpression(
                        id: UUID(),
                        identifier: LGCIdentifier(id: UUID(), string: "none")
                    )
                )
            )

            let queryColor = NSColor.parse(css: query)

            let customSuggestion = LogicSuggestionItem(
                title: "Custom: \(query)",
                category: "Custom Color".uppercased(),
                node: .expression(
                    .literalExpression(
                        id: UUID(),
                        literal: .color(id: UUID(), value: query)
                    )
                ),
                disabled: queryColor == nil,
                style: queryColor != nil ? .colorPreview(code: query, queryColor!) : .normal
            )

            let systemColorSuggestions = CSColors.colors
                .filter { color in
                    if query.isEmpty { return true }

                    let lowercasedQuery = query.lowercased()
                    return color.name.lowercased().contains(lowercasedQuery) || color.id.lowercased().contains(lowercasedQuery)
                }
                .map { color in
                    return LogicSuggestionItem(
                        title: color.name,
                        category: "Colors".uppercased(),
                        node: .expression(
                            .literalExpression(
                                id: UUID(),
                                literal: .color(id: UUID(), value: color.resolvedValue)
                            )
                        ),
                        style: .colorPreview(code: color.value, color.color)
                    )
            }

            return (query.isEmpty ? [noneSuggestion] : []) + systemColorSuggestions + [customSuggestion]
        }
    }
}
