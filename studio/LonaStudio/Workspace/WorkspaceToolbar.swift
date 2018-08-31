//
//  WorkspaceToolbar.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/31/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

extension NSToolbarItem.Identifier {
    static let paneToggle = NSToolbarItem.Identifier("Navigation")
}

// MARK: - WorkspacePane

enum WorkspacePane: String {
    case left, bottom, right

    var image: NSImage {
        guard let icon = NSImage(named: NSImage.Name(rawValue: "icon-pane-\(rawValue)")) else {
            return NSImage()
        }
        icon.isTemplate = true
        return icon
    }

    var index: Int {
        switch self {
        case .left:
            return 0
        case .bottom:
            return 1
        case .right:
            return 2
        }
    }

    static let all: [WorkspacePane] = [.left, .bottom, .right]
}

// MARK: - WorkspaceToolbar

class WorkspaceToolbar: NSToolbar {

    // MARK: Lifecycle

    init() {
        super.init(identifier: WorkspaceToolbar.identifier)

        delegate = self
        displayMode = .iconOnly
        allowsUserCustomization = false

        setUpItems()
    }

    // MARK: Public

    public var activePanes: [WorkspacePane] = [] {
        didSet {
            guard let segmentedControl = paneToggleToolbarItem.view as? NSSegmentedControl else { return }

            WorkspacePane.all.forEach { pane in
                segmentedControl.setSelected(activePanes.contains(pane), forSegment: pane.index)
            }
        }
    }
    public var onChangeActivePanes: (([WorkspacePane]) -> Void)?

    static let identifier = NSToolbar.Identifier(rawValue: "Workspace Toolbar")

    // MARK: Private

    private var paneToggleToolbarItem = NSToolbarItemGroup(itemIdentifier: .paneToggle)

    private func setUpPaneToggle() {
        let group = paneToggleToolbarItem

        let leftItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: "paneToggleLeft"))
        let bottomItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: "paneToggleBottom"))
        let rightItem = NSToolbarItem(itemIdentifier: NSToolbarItem.Identifier(rawValue: "paneToggleRight"))

        let segmented = NSSegmentedControl(frame: NSRect(x: 0, y: 0, width: (29 + 31 + 29) + 6, height: 40))
        segmented.segmentStyle = .texturedRounded
        segmented.trackingMode = .selectAny
        segmented.segmentCount = 3
        segmented.target = self
        segmented.action = #selector(handleTogglePane(_:))

        segmented.setImage(WorkspacePane.left.image, forSegment: WorkspacePane.left.index)
        segmented.setWidth(29, forSegment: WorkspacePane.left.index)
        segmented.setImage(WorkspacePane.bottom.image, forSegment: WorkspacePane.bottom.index)
        segmented.setWidth(31, forSegment: WorkspacePane.bottom.index)
        segmented.setImage(WorkspacePane.right.image, forSegment: WorkspacePane.right.index)
        segmented.setWidth(29, forSegment: WorkspacePane.right.index)

        // `group.label` would overwrite segment labels
        group.paletteLabel = "Navigation"
        group.subitems = [leftItem, bottomItem, rightItem]
        group.view = segmented
    }

    private func setUpItems() {
        setUpPaneToggle()
    }

    @objc func handleTogglePane(_ sender: NSSegmentedControl) {
        let activePanes = WorkspacePane.all.filter { pane in
            sender.isSelected(forSegment: pane.index)
        }

        onChangeActivePanes?(activePanes)
    }
}

// MARK: - NSToolbarDelegate

extension WorkspaceToolbar: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.flexibleSpace, .paneToggle]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [.paneToggle, .flexibleSpace]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        if itemIdentifier == NSToolbarItem.Identifier.paneToggle {
            return paneToggleToolbarItem
        }

        return nil
    }
}
