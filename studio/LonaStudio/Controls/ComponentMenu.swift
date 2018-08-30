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

    // These represent parameters of type Component. This allows inserting
    // placeholders into the layer list.
    var componentParameterItems: [NSMenuItem] = []

    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)

        updateComponentsFromModule()

        ComponentMenu.shared = self

        _ = LonaPlugins.current.register(eventType: .onReloadWorkspace) {
            self.updateComponentsFromModule()
        }
    }

    static func menuItems(componentParameterNames: [String]) -> [NSMenuItem] {
        return componentParameterNames.map({ name in
            NSMenuItem(title: name, onClick: {
                guard let viewController = NSApplication.shared.mainWindow?.contentViewController as? WorkspaceViewController else { return }

                viewController.addLayer(CSParameterLayer(name: name, parameterName: name))
            })
        })
    }

    static func menuItemsForModule(_ module: LonaModule = LonaModule.current) -> [NSMenuItem] {
        let componentGroups = Dictionary(grouping: module.componentFiles(), by: { file in
            return file.url.deletingLastPathComponent().lastPathComponent
        })

        let menuItemLists: [[NSMenuItem]] = componentGroups.keys.map({ key in
            guard let files = componentGroups[key] else { return [] }

            let header = NSMenuItem(title: key.prefix(1).uppercased() + key.dropFirst(), action: nil, keyEquivalent: "")
            header.isEnabled = false

            var results = [header]

            results.append(contentsOf: files.sorted(by: { a, b in a.name < b.name }).map({ file in
                NSMenuItem(title: file.name, onClick: {
                    guard let viewController = NSApplication.shared.mainWindow?.contentViewController as? WorkspaceViewController else { return }

                    viewController.addLayer(CSComponentLayer.make(from: file.url))
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

        return additionalMenuItems
    }

    func update(componentParameterNames: [String]) {
        self.componentParameterItems.forEach({ item in
            self.removeItem(item)
        })

        // Create menu items

        let componentParameterItems = ComponentMenu.menuItems(componentParameterNames: componentParameterNames)

        self.componentParameterItems = componentParameterItems

        // Add to shared menu

        let childrenItemIndex = indexOfItem(withTitle: "Children")

        componentParameterItems.forEach({ item in
            self.insertItem(item, at: childrenItemIndex + 1)
        })
    }

    func updateComponentsFromModule() {
        self.additionalMenuItems.forEach({ item in
            self.removeItem(item)
        })

        // Create menu items

        let additionalMenuItems = ComponentMenu.menuItemsForModule()

        self.additionalMenuItems = additionalMenuItems

        // Add to shared menu

        additionalMenuItems.forEach({ item in
            self.addItem(item)
        })
    }

    static var shared: ComponentMenu?
}
