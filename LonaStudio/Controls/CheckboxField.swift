//
//  CheckboxField.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/16/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class CheckboxField: NSButton, CSControl {
    
    var data: CSData {
        get { return CSData.Bool(value) }
        set { value = newValue.boolValue }
    }
    
    var onChangeData: (CSData) -> Void = { _ in }
    
    var value: Bool {
        get { return state == NSOnState }
        set {
            state = newValue ? NSOnState : NSOffState
            onChange(newValue)
        }
    }
    
    var onChange: (Bool) -> Void = {_ in }
    
    func setup() {
        setButtonType(.switch)
        action = #selector(handleChange)
        target = self
    }
    
    @objc func handleChange() {
        onChange(value)
        onChangeData(data)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
}
