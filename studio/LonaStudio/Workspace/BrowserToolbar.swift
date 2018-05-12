//
//  AppDelegate.swift
//  ComponentStudio
//
//  Created by Devin Abbott on 5/7/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

fileprivate extension NSToolbarItem.Identifier {
    static let tabs = NSToolbarItem.Identifier("com.devinabbott.lona.WorkspaceTabs")
}

class BrowserToolbar: NSToolbar {

    enum Tab: String {
        case components = "Components"
        case colors = "Colors"
    }

    // MARK: - Lifecycle

    init() {
        super.init(identifier: NSToolbar.Identifier("com.devinabbott.lona.BrowserToolbar"))

        delegate = self
    }

    // MARK: - Public

    public var onChangeTab: ((BrowserToolbar.Tab) -> Void)?
}

extension BrowserToolbar: NSToolbarDelegate {
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.tabs, .flexibleSpace]
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.flexibleSpace, .tabs, .flexibleSpace]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .tabs:
            let segmentedControl = SegmentedControlField(
                frame: NSRect(x: 0, y: 0, width: 200, height: 24),
                values: [Tab.components.rawValue, Tab.colors.rawValue])
            segmentedControl.value = Tab.components.rawValue
            segmentedControl.onChange = { value in
                guard let tab = Tab(rawValue: value) else { return }
                self.onChangeTab?(tab)
            }

            let toolbarItem = NSToolbarItem(itemIdentifier: .tabs)

            toolbarItem.view = segmentedControl

            return toolbarItem
        default:
            return nil
        }
    }
}
