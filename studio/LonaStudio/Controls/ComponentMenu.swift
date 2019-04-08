//
//  ComponentMenu.swift
//  LonaStudio
//
//  Created by devin_abbott on 3/22/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

enum ComponentMenu {
    static func menuItems(componentParameterNames: [String]) -> [NSMenuItem] {
        return componentParameterNames.map({ name in
            NSMenuItem(title: name, onClick: {
                guard let viewController = NSApplication.shared.mainWindow?.contentViewController as? WorkspaceViewController else { return }

                viewController.addLayer(CSParameterLayer(name: name, parameterName: name))
            })
        })
    }

    static func menuItemsForCoreComponents() -> [NSMenuItem] {
        let types = [
            CSLayer.BuiltInLayerType.view,
            CSLayer.BuiltInLayerType.text,
            CSLayer.BuiltInLayerType.image,
            CSLayer.BuiltInLayerType.vectorGraphic,
            CSLayer.BuiltInLayerType.animation,
            CSLayer.BuiltInLayerType.children]

        return types.map { layerType in
            let name = layerType.rawValue
            let uppercased = name.prefix(1).uppercased() + name.dropFirst()
            return NSMenuItem(title: uppercased, onClick: {
                guard let viewController = NSApplication.shared.mainWindow?.contentViewController as? WorkspaceViewController else { return }

                viewController.addLayer(forType: .builtIn(layerType))
            })
        }
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

    static func menuItems() -> [NSMenuItem] {
        var items = menuItemsForCoreComponents()
        items.append(NSMenuItem.separator())
        items.append(contentsOf: menuItemsForModule())
        return items
    }
}
