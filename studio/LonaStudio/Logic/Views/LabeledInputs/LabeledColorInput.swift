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

public class LabeledColorInput: LabeledInput {

    // MARK: Lifecycle

    public init(titleText: String, colorString: String?) {
        self.colorString = colorString

        super.init(titleText: titleText)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var colorString: String? {
        didSet {
            if colorString != oldValue {
                update()
            }
        }
    }

    public var onChangeColorString: ((String?) -> Void)?

    // MARK: Private

    private let logicValueInput = LogicInput()

    private func setUpViews() {
        inputView = logicValueInput
    }

    private func setUpConstraints() {}

    private func update() {
        logicValueInput.rootNode = .expression(LogicInput.expression(forColorString: colorString))

        logicValueInput.onChangeRootNode = { [unowned self] node in
            self.onChangeColorString?(LogicInput.makeColorString(node: node))
            return true
        }

        logicValueInput.suggestionsForNode = { rootNode, node, query in
            return LogicInput.suggestionsForColor(isOptional: true, node: node, query: query)
        }
    }
}
