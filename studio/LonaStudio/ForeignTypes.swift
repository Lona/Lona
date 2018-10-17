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
