//
//  Alert.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/17/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

class Alert<Item: RawRepresentable> where Item.RawValue == String {

    // MARK: - Lifecycle

    init(items: [Item] = [],
         messageText: String? = nil,
         informativeText: String? = nil,
         accessoryView: NSView? = nil) {
        self.items = items
        self.messageText = messageText
        self.informativeText = informativeText
        self.accessoryView = accessoryView
    }

    // MARK: - Public

    public var items: [Item]
    public var messageText: String?
    public var informativeText: String?
    public var accessoryView: NSView?

    @discardableResult public func run() -> Item? {
        let response = alert.runModal()

        switch response {
        case .alertFirstButtonReturn:
            return items.reversed()[0]
        case .alertSecondButtonReturn:
            return items.reversed()[1]
        case .alertThirdButtonReturn:
            return items.reversed()[2]
        default:
            return nil
        }
    }

    // MARK: - Private

    private var alert: NSAlert {
        let alert = NSAlert()
        alert.messageText = messageText ?? ""
        alert.informativeText = informativeText ?? ""

        items.reversed().forEach { item in
            alert.addButton(withTitle: item.rawValue)
        }

        if let accessoryView = accessoryView {
            alert.accessoryView = accessoryView
            alert.window.initialFirstResponder = accessoryView
            alert.layout()
        }

        return alert
    }
}

extension Alert where Item == String {
    static func runConfirmationAlert(
        confirmationText: String,
        messageText: String? = nil,
        informativeText: String? = nil
    ) -> Bool {
        let alert = Alert<String>(
            items: ["Cancel", confirmationText],
            messageText: messageText
        )

        switch alert.run() {
        case confirmationText:
            return true
        default:
            return false
        }
    }

    static func runTextInputAlert(
        messageText: String? = nil,
        informativeText: String? = nil,
        inputText: String = "",
        placeholderText: String = ""
    ) -> String? {
        let textView = TextInput(frame: NSRect(x: 0, y: 0, width: 300, height: 20))
        var textValue = inputText
        textView.onChangeTextValue = { [unowned textView] value in
            textView.textValue = value
            textValue = value
        }
        textView.stringValue = textValue
        textView.placeholderString = placeholderText

        let alert = Alert<String>(
            items: ["Cancel", "OK"],
            messageText: messageText,
            informativeText: informativeText,
            accessoryView: textView
        )

        switch alert.run() {
        case "OK":
            return textValue
        default:
            return nil
        }
    }
}
