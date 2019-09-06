//
//  LogicInput.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/13/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

// MARK: - LogicInput

public class LogicInput: NSView {

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

    public var suggestionsForNode: ((LGCSyntaxNode, LGCSyntaxNode, String) -> [LogicSuggestionItem]) {
        get { return logicEditor.suggestionsForNode }
        set { logicEditor.suggestionsForNode = newValue }
    }

    public var isTextStyleEditor = false {
        didSet {
            if oldValue != isTextStyleEditor {
                logicEditor.forceUpdate()
            }
        }
    }

    // MARK: Private

    public let logicEditor = LogicEditor()

    private func setUpViews() {
        logicEditor.fillColor = Colors.contentBackground
        logicEditor.showsLineButtons = false
        logicEditor.showsDropdown = false
        logicEditor.supportsLineSelection = false
        logicEditor.scrollsVertically = false
        logicEditor.canvasStyle.textMargin = .init(width: 2, height: 3)

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
        logicEditor.topAnchor.constraint(equalTo: topAnchor).isActive = true
        logicEditor.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        logicEditor.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func update() {}
}
