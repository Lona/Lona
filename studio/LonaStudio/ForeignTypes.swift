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
public typealias StringHandler = ((String) -> Void)?
public typealias TextInput = ControlledComponents.TextInput
public typealias ColorWellPicker = ColorPicker.ColorWellPicker

public typealias ColorPickerColor = Color?
public typealias ColorPickerHandler = ((Color) -> Void)?

extension TextInput {
    public override var undoManager: UndoManager? {
        return nil
    }
}
