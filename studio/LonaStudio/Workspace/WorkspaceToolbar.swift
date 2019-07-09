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
    static let splitterToggle = NSToolbarItem.Identifier("Splitter")
    static let playButton = NSToolbarItem.Identifier("Play")
    static let stopButton = NSToolbarItem.Identifier("Stop")
    static let compilerConfigButton = NSToolbarItem.Identifier("CompilerConfig")
    static let statusBar = NSToolbarItem.Identifier("StatusBar")
}

// MARK: - WorkspacePane

enum WorkspacePane: String {
    case left, bottom, right

    var image: NSImage {
        guard let icon = NSImage(named: "icon-pane-\(rawValue)") else {
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

    init?(index: Int) {
        switch index {
        case 0:
            self = .left
        case 1:
            self = .bottom
        case 2:
            self = .right
        default:
            return nil
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
        update()
    }

    // MARK: Public

    public var splitterState: Bool = false { didSet { update() } }
    public var onChangeSplitterState: ((Bool) -> Void)?

    public var activePanes: [WorkspacePane] = WorkspacePane.all { didSet { update() } }
    public var onChangeActivePanes: (([WorkspacePane]) -> Void)?

    public static let identifier = "Workspace Toolbar"

    // MARK: Private

    private var playButton = NSToolbarItem(itemIdentifier: .playButton)

    private var stopButton = NSToolbarItem(itemIdentifier: .stopButton)

    private var compilerConfigButton = NSToolbarItem(itemIdentifier: .compilerConfigButton)

    private var statusBar = NSToolbarItem(itemIdentifier: .statusBar)

    private var splitterToggleItem = NSToolbarItem(itemIdentifier: .splitterToggle)

    private var paneToggleToolbarItem = NSToolbarItemGroup(itemIdentifier: .paneToggle)

    private func setUpPlayButton() {
        let button = Button(titleText: "")
        button.onPress = {
            LonaModule.build()
        }
//        let button = NSButton(frame: .zero)
        let icon = NSImage(named: "icon-play") ?? NSImage()
        icon.isTemplate = true
        button.image = icon
        button.bezelStyle = .texturedRounded

        playButton.maxSize.width = 31
        playButton.view = button
    }

    private func setUpStopButton() {
        let button = NSButton(frame: .zero)
        let icon = NSImage(named: "icon-stop") ?? NSImage()
        icon.isTemplate = true
        button.image = icon
        button.bezelStyle = .texturedRounded

        stopButton.maxSize.width = 32
        stopButton.view = button
    }

    private func setUpCompilerConfigButton() {
        let menu = NSMenu(
            items: [
                .init(title: "Custom Configuration", action: nil, keyEquivalent: ""),
                .init(title: "New Configuration...", action: nil, keyEquivalent: "")
            ]
        )

        let segmented = NSSegmentedControl(frame: .zero)
        segmented.segmentStyle = .texturedRounded
        segmented.trackingMode = .momentary
        segmented.segmentCount = 2
        segmented.target = self
//        segmented.action = #selector(handleTogglePane(_:))

        let label = "Custom"
        let labelWidth = NSAttributedString(
            string: label,
            attributes: [NSAttributedString.Key.font: segmented.font!]
            ).measure(width: .greatestFiniteMagnitude).width + 12

        segmented.setLabel(label, forSegment: 0)
        segmented.setWidth(labelWidth, forSegment: 0)
        segmented.setMenu(menu, forSegment: 1)
        segmented.setWidth(16, forSegment: 1)
        segmented.sizeToFit()

        if #available(OSX 10.13, *) {
            segmented.setShowsMenuIndicator(true, forSegment: 1)
        } else {
            // Fallback on earlier versions
        }

        segmented.isEnabled = true
        segmented.isEnabled(forSegment: 1)

        compilerConfigButton.view = segmented
    }

    private func setUpStatusBar() {
        let view = ToolbarStatusBar(frame: .zero)
//        view.inProgress = true
//        view.progress = 0.5

        statusBar.minSize.width = 400
        statusBar.maxSize.width = 650

        statusBar.view = view
    }

    private func setUpSplitterToggle() {
        let segmented = NSSegmentedControl(frame: NSRect(x: 0, y: 0, width: 31 + 4, height: 40))
        segmented.segmentStyle = .texturedRounded
        segmented.trackingMode = .selectAny
        segmented.segmentCount = 1
        segmented.target = self
        segmented.action = #selector(handleSplitterPane(_:))

        let icon = NSImage(named: "icon-pane-splitter") ?? NSImage()
        icon.isTemplate = true

        segmented.setImage(icon, forSegment: 0)
        segmented.setWidth(31, forSegment: WorkspacePane.left.index)

        splitterToggleItem.view = segmented
    }

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
        setUpPlayButton()
        setUpStopButton()
        setUpCompilerConfigButton()
        setUpStatusBar()
        setUpSplitterToggle()
        setUpPaneToggle()
    }

    private func update() {
        if let segmentedControl = paneToggleToolbarItem.view as? NSSegmentedControl {
            WorkspacePane.all.forEach { pane in
                segmentedControl.setSelected(activePanes.contains(pane), forSegment: pane.index)
            }
        }

        if let segmentedControl = splitterToggleItem.view as? NSSegmentedControl {
            segmentedControl.setSelected(splitterState, forSegment: 0)
        }
    }

    @objc func handleSplitterPane(_ sender: NSSegmentedControl) {
        onChangeSplitterState?(sender.isSelected(forSegment: 0))
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
        return [
            .playButton,
//            .stopButton,
            .compilerConfigButton,
            .flexibleSpace,
            .statusBar,
            .flexibleSpace,
            .splitterToggle,
            .paneToggle
        ]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [
            .playButton,
            .stopButton,
            .compilerConfigButton,
            .statusBar,
            .splitterToggle,
            .paneToggle,
            .flexibleSpace,
            .separator
        ]
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {

        if itemIdentifier == NSToolbarItem.Identifier.paneToggle {
            return paneToggleToolbarItem
        } else if itemIdentifier == NSToolbarItem.Identifier.splitterToggle {
            return splitterToggleItem
        } else if itemIdentifier == .playButton {
            return playButton
        } else if itemIdentifier == .compilerConfigButton {
            return compilerConfigButton
        } else if itemIdentifier == .stopButton {
            return stopButton
        } else if itemIdentifier == .statusBar {
            return statusBar
        }

        return nil
    }
}
