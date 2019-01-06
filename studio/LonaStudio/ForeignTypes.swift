//
//  ForeignTypes.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/25/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Colors
import ControlledComponents
import class ColorPicker.ColorWellPicker

public typealias ColorList = [CSColor]?
public typealias ColorHandler = ((CSColor?) -> Void)?

public typealias TextStyleList = [CSTextStyle]?
public typealias TextStyleHandler = ((CSTextStyle?) -> Void)?

public typealias StringHandler = ((String) -> Void)?
public typealias NumberHandler = ((CGFloat) -> Void)?
public typealias ColorPickerColor = Color?
public typealias ColorPickerHandler = ((Color) -> Void)?
public typealias ItemMoveHandler = ((Int, Int) -> Void)?

// Alias imported components for use in generated code
//public typealias TextInput = ControlledComponents.TextInput
public typealias Button = ControlledComponents.Button
public typealias ColorWellPicker = ColorPicker.ColorWellPicker

// The name "Color" is overloaded. There's the built-in Lona "Color", and there's
// also the "Color" from the "dylan/colors" (import Colors) library. Use a typealias
// to disambiguate.
public typealias SwiftColor = Color
extension Color: Equatable {}

class TextInput: ControlledComponents.TextInput {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        // This lets us use fittingSize to determine total view height (e.g. in the inspector)
        let heightConstraint = heightAnchor.constraint(greaterThanOrEqualToConstant: 22)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

typealias NumberInput = NumberField
extension NumberInput {
    var disabled: Bool {
        get { return isEnabled }
        set {
            if isEnabled != newValue {
                isEnabled = newValue
            }
        }
    }

    var numberValue: CGFloat {
        get { return CGFloat(value) }
        set { value = Double(newValue) }
    }

    var onChangeNumberValue: ((CGFloat) -> Void)? {
        get {
            return { [unowned self] value in
                self.onChange(Double(value))
            }
        }
        set {
            onChange = { value in
                newValue?(CGFloat(value))
            }
        }
    }
}
