//
//  NumberField.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/9/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class NumberField: NSTextField, NSTextFieldDelegate, NSControlTextEditingDelegate, CSControl {

    var data: CSData {
        get { return CSData.Number(value) }
        set { value = newValue.numberValue }
    }

    var onChangeData: (CSData) -> Void = { _ in }

    var onSubmitData: (CSData) -> Void = { _ in }

    var value: Double {
        get { return Double(stringValue) ?? 0.0 }
        set { stringValue = String(newValue) }
    }

    var onChange: (Double) -> Void = {_ in }

    var onSubmit: (Double) -> Void = {_ in }

    func setup() {
        delegate = self

        let formatter = NumberFormatter()

        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.allowsFloats = true

        formatter.usesGroupingSeparator = false

        self.formatter = formatter
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        var changeBy = 0.0

        if commandSelector == #selector(moveUp(_:)) { changeBy = 1.0 }
        if commandSelector == #selector(moveUpAndModifySelection(_:)) { changeBy = 10.0 }
        if commandSelector == #selector(moveDown(_:)) { changeBy = -1.0 }
        if commandSelector == #selector(moveDownAndModifySelection(_:)) { changeBy = -10.0 }

        if changeBy != 0 {
            let newValue = value + changeBy

            value = newValue

            onChange(value)
            onChangeData(CSData.Number(value))
        }

        return false
    }

    func controlTextDidChange(_ obj: Notification) {
        // TODO: https://stackoverflow.com/questions/6337464/nsnumberformatter-doesnt-allow-typing-decimal-numbers
        onChange(value)
        onChangeData(CSData.Number(value))
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        onSubmit(value)
        onSubmitData(data)
    }
}
