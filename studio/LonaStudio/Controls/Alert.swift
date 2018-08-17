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
         informativeText: String? = nil) {
        self.items = items
        self.messageText = messageText
        self.informativeText = informativeText
    }

    // MARK: - Public

    public var items: [Item]
    public var messageText: String?
    public var informativeText: String?

    public func run() -> Item? {
        let response = alert.runModal()

        switch response {
        case .alertFirstButtonReturn:
            return items[0]
        case .alertSecondButtonReturn:
            return items[1]
        case .alertThirdButtonReturn:
            return items[2]
        default:
            return nil
        }
    }

    // MARK: - Private

    private var alert: NSAlert {
        let alert = NSAlert()
        alert.messageText = messageText ?? ""
        alert.informativeText = informativeText ?? ""

        items.forEach { item in
            alert.addButton(withTitle: item.rawValue)
        }

        return alert
    }
}
