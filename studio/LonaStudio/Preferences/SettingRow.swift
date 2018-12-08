//
//  SettingRow.swift
//  ComponentStudio
//
//  Created by devin_abbott on 7/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

let ROW_HEIGHT: CGFloat = 24

class SettingRow: NSStackView {
    static func create(title: String, value: CSData) -> SettingRow {
        switch value {
        case .Bool(let raw):
            return BooleanSettingRow(title: title, value: raw)
        default:
            return SettingRow()
        }
    }

    var onChange: ((CSData) -> Void)?

    init(onChange: ((CSData) -> Void)? = nil) {
        super.init(frame: NSRect.zero)

        orientation = .horizontal
        alignment = .centerY
        translatesAutoresizingMaskIntoConstraints = false

        self.onChange = onChange
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ValueSettingRow: SettingRow {
    init(title: String, value: CSValue, onChange: ((CSData) -> Void)? = nil) {
        super.init(onChange: onChange)

        let titleView = NSTextField(labelWithString: title)
        titleView.translatesAutoresizingMaskIntoConstraints = false

        let valueField = CSValueField(value: value, options: [
            CSValueField.Options.isBordered: true,
            CSValueField.Options.drawsBackground: true,
            CSValueField.Options.submitOnChange: false,
            CSValueField.Options.usesLinkStyle: false,
            CSValueField.Options.usesYogaLayout: false
            ])
        valueField.view.translatesAutoresizingMaskIntoConstraints = false
        valueField.onChangeData = { value in self.onChange?(value) }

        addArrangedSubview(titleView)
        addArrangedSubview(valueField.view)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BooleanSettingRow: SettingRow {
    init(title: String, value: Bool) {
        super.init()

        let checkboxField = CheckboxField(frame: NSRect.zero)
        checkboxField.translatesAutoresizingMaskIntoConstraints = false
        checkboxField.value = value
        checkboxField.title = title

        checkboxField.onChange = { value in self.onChange?(CSData.Bool(value)) }

        addArrangedSubview(checkboxField)

        heightAnchor.constraint(equalToConstant: ROW_HEIGHT).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PathSettingRow: SettingRow {
    init(title: String, value: String, onChange: ((CSData) -> Void)? = nil) {
        super.init(onChange: onChange)

        let titleView = NSTextField(labelWithString: title)
        titleView.translatesAutoresizingMaskIntoConstraints = false

        let textField = TextField(frame: NSRect.zero)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.value = value

        // Don't allow direct editing of the path
        textField.isEnabled = false

        textField.onChange = { value in self.onChange?(CSData.String(value)) }

        let button = Button()
        button.title = "Choose path..."
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bezelStyle = .rounded

        button.onPress = {
            let dialog = NSOpenPanel()

            dialog.title = "Choose \(title)"
            dialog.showsResizeIndicator = true
            dialog.showsHiddenFiles = false
            dialog.canCreateDirectories = true
            dialog.canChooseDirectories = true
            dialog.canChooseFiles = false
            dialog.allowsMultipleSelection = false

            if dialog.runModal() == NSApplication.ModalResponse.OK {
                self.onChange?(CSData.String(dialog.url!.path))
            }
        }

        addArrangedSubview(titleView)
        addArrangedSubview(textField)
        addArrangedSubview(button)

        titleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        heightAnchor.constraint(equalToConstant: ROW_HEIGHT).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
