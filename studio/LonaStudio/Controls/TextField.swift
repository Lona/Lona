//
//  TextField.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/9/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class TextField: NSTextField, NSTextFieldDelegate, NSControlTextEditingDelegate, CSControl {

//    var requiresSubmit: Bool = false

    var data: CSData {
        get { return CSData.String(value) }
        set { value = newValue.stringValue }
    }

    var onChangeData: (CSData) -> Void = { _ in }

    var onSubmitData: (CSData) -> Void = { _ in }

    var value: String {
        get { return stringValue }
        set { stringValue = newValue }
    }

    var onChange: (String) -> Void = {_ in }

    var onSubmit: (String) -> Void = {_ in }

    func setup() {
        delegate = self
//        action = #selector(handleSubmit)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()

        cell?.wraps = false
        cell?.isScrollable = true
    }

    func controlTextDidChange(_ obj: Notification) {
        onChange(value)
        onChangeData(data)
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        onSubmit(value)
        onSubmitData(data)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
