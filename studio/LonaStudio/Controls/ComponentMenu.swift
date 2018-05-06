//
//  ComponentMenu.swift
//  LonaStudio
//
//  Created by devin_abbott on 3/22/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

class ComponentMenu: NSMenu {
    var additionalMenuItems: [NSMenuItem] = []

    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)

        updateComponentsFromModule()

        ComponentMenu.shared = self
    }

    func updateComponentsFromModule() {
        self.additionalMenuItems.forEach({ item in
            self.removeItem(item)
        })

        let componentGroups = Dictionary(grouping: LonaModule.current.componentFiles(), by: { file in
            return file.url.deletingLastPathComponent().lastPathComponent
        })

        let menuItemLists: [[NSMenuItem]] = componentGroups.keys.map({ key in
            guard let files = componentGroups[key] else { return [] }

            let header = NSMenuItem(title: key.prefix(1).uppercased() + key.dropFirst(), action: nil, keyEquivalent: "")
            header.isEnabled = false

            var results = [header]

            results.append(contentsOf: files.map({ file in
                NSMenuItem(title: file.name, onClick: {
                    guard let viewController = NSApplication.shared.mainWindow?.contentViewController as? ViewController else { return }
                    viewController.addLayer(layer: CSComponentLayer.make(from: file.url))
                })
            }))

            return results
        })

        let additionalMenuItems: [NSMenuItem] = menuItemLists.reduce([], { acc, items in
            var acc = acc
            acc.append(NSMenuItem.separator())
            acc.append(contentsOf: items)
            return acc
        })

        self.additionalMenuItems = additionalMenuItems

        additionalMenuItems.forEach({ item in
            self.addItem(item)
        })
    }

    static var shared: ComponentMenu?
}
