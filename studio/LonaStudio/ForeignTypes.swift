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
public typealias ColorPickerColor = Color?
public typealias ColorPickerHandler = ((Color) -> Void)?
public typealias ItemMoveHandler = ((Int, Int) -> Void)?

// Alias imported components for use in generated code
public typealias TextInput = ControlledComponents.TextInput
public typealias Button = ControlledComponents.Button
public typealias ColorWellPicker = ColorPicker.ColorWellPicker

// The name "Color" is overloaded. There's the built-in Lona "Color", and there's
// also the "Color" from the "dylan/colors" (import Colors) library. Use a typealias
// to disambiguate.
public typealias SwiftColor = Color
extension Color: Equatable {}

typealias NumberInput = NumberField
extension NumberInput {
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
