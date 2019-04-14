//
//  LogicValueInput.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/13/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

// MARK: - LogicValueInput

public class LogicValueInput: NSView {

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var rootNode: LGCSyntaxNode {
        get { return logicEditor.rootNode }
        set { logicEditor.rootNode = newValue }
    }

    public var onChangeRootNode: ((LGCSyntaxNode) -> Bool)? {
        get { return logicEditor.onChangeRootNode }
        set { logicEditor.onChangeRootNode = newValue }
    }

    public var suggestionsForNode: ((LGCSyntaxNode, String) -> [LogicSuggestionItem]) {
        get { return logicEditor.suggestionsForNode }
        set { logicEditor.suggestionsForNode = newValue }
    }

    // MARK: Private

    private var logicEditor = LogicEditor()

    private func setUpViews() {
        logicEditor.fillColor = Colors.contentBackground
        logicEditor.showsDropdown = false
        logicEditor.supportsLineSelection = false
        logicEditor.scrollsVertically = false
        logicEditor.canvasStyle.textMargin.height = 4
        logicEditor.canvasStyle.textMargin.width -= 1

        logicEditor.decorationForNodeID = { [unowned self] id in
            guard let node = self.logicEditor.rootNode.find(id: id) else { return nil }
            switch node {
            case .literal(.color(id: _, value: let code)):
                return .color(CSColors.parse(css: code).color)
            default:
                return nil
            }
        }

        addSubview(logicEditor)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        logicEditor.translatesAutoresizingMaskIntoConstraints = false

        logicEditor.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        logicEditor.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        logicEditor.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2).isActive = true
        logicEditor.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func update() {}
}
