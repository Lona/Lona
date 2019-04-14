//
//  LabeledValueInput.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/12/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

class LabeledValueInput: LabeledInput {

    // MARK: Lifecycle

    public override init(titleText: String) {
        super.init(titleText: titleText)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var value: CSValue = CSValue(type: .unit, data: .Null) {
        didSet {
            if oldValue != value {
                update()
            }
        }
    }

    public var onChangeValue: ((CSValue) -> Void)?

    // MARK: Private

    private var logicInput = LogicInput()

    private func setUpViews() {
        inputView = logicInput

        getPasteboardItem = { [unowned self] in
            let item = NSPasteboardItem()

            if let data = CSParameter(name: self.titleText, type: self.value.type).toData().toData() {
                item.setData(data, forType: .lonaParameter)
            }

            return item
        }
    }

    private func setUpConstraints() {}

    private func update() {
        logicInput.rootNode = .expression(LogicInput.expression(forValue: value))
        logicInput.onChangeRootNode = { [unowned self] node in
            let newValue = LogicInput.makeValue(forType: self.value.type, node: node)
            self.onChangeValue?(newValue)
            return true
        }
        logicInput.suggestionsForNode = { [unowned self] node, query in
            return LogicInput.suggestions(forType: self.value.type, node: node, query: query)
        }
//        logicInput.isTextStyleEditor = value.type == CSTextStyleType
    }
}
