//
//  DictionaryEditorButton.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

private func buttonTitle(for value: CSValue) -> String {
    let count = DictionaryEditor.listValue(from: value).count
    return "[\(count) Values]"
}

class DictionaryEditorButton: Button, CSControl, NSPopoverDelegate {

    var data: CSData {
        get { return value.toData() }
        set { value = CSValue(newValue) }
    }

    var onChangeData: CSDataChangeHandler

    var value: CSValue

    var onChange: (CSValue) -> Void = {_ in}

    func setState(value: CSValue) {
        self.value = value
        self.title = buttonTitle(for: value)
    }

    init(value: CSValue, onChangeData: @escaping CSDataChangeHandler) {
        self.value = value
        self.onChangeData = onChangeData

        super.init(title: buttonTitle(for: value))

        self.onPress = {
            let editor = DictionaryEditor(
                value: value,
                onChange: { self.setState(value: $0) },
                layout: CSConstraint.size(width: 300, height: 200)
            )

            let viewController = NSViewController(view: editor)
            let popover = NSPopover(contentViewController: viewController, delegate: self)

            popover.show(relativeTo: NSRect.zero, of: self, preferredEdge: .maxY)
        }
    }

    func popoverWillClose(_ notification: Notification) {
        self.onChange(self.value)
        self.onChangeData(self.value.data)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
