//
//  NSMenuExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/25/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

extension NSMenuItem {
    func handleAction(_ menuItem: NSMenuItem) {
        guard let onClick = menuItem.representedObject as? () -> Void else { return }
        onClick()
    }
    
    convenience init(title: String, onClick: @escaping () -> Void, keyEquivalent charCode: String? = nil) {
        self.init(title: title, action: #selector(handleAction), keyEquivalent: charCode ?? "")
        target = self
        representedObject = onClick
    }
}

extension NSMenu {
    convenience init(items: [NSMenuItem]) {
        self.init()
        
        for item in items {
            addItem(item)
        }
    }
}
