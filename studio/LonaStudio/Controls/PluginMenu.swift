//
//  PluginMenu.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/4/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

class PluginMenu: NSMenu {
    var additionalMenuItems: [NSMenuItem] = []

    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)

        updateComponentsFromModule()

        PluginMenu.shared = self
    }

    func updateComponentsFromModule() {
        self.additionalMenuItems.forEach({ item in
            self.removeItem(item)
        })

        let pluginGroups = Dictionary(grouping: LonaPlugins.current.pluginFiles(), by: { file in
            return file.url.deletingLastPathComponent().lastPathComponent
        })

        let menuItemLists: [[NSMenuItem]] = pluginGroups.keys.map({ key in
            guard let files = pluginGroups[key] else { return [] }

            let header = NSMenuItem(title: key.prefix(1).uppercased() + key.dropFirst(), action: nil, keyEquivalent: "")
            header.isEnabled = false

            var results = [header]

            results.append(contentsOf: files.map({ file in
                NSMenuItem(title: file.name, onClick: {
                    file.run(onSuccess: { result in
                        Swift.print("Result:", result)
                    })
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

    static var shared: PluginMenu?
}
