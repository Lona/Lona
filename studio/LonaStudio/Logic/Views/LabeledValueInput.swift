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

    private var logicEditor = LogicValueInput()

    private func setUpViews() {
        inputView = logicEditor

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
        logicEditor.rootNode = LogicValueInput.rootNode(forValue: value)
        logicEditor.onChangeRootNode = { [unowned self] node in
            let newValue = LogicValueInput.makeValue(forType: self.value.type, node: node)
            self.onChangeValue?(newValue)
            return true
        }
        logicEditor.suggestionsForNode = { [unowned self] node, query in
            return LogicValueInput.suggestions(forType: self.value.type, node: node, query: query)
        }
//        logicEditor.isTextStyleEditor = value.type == CSTextStyleType
    }
}
