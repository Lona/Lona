//
//  WorkspaceToolbar.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/31/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation
import Logic

extension NSToolbarItem.Identifier {
    static let paneToggle = NSToolbarItem.Identifier("Navigation")
    static let splitterToggle = NSToolbarItem.Identifier("Splitter")
    static let playButton = NSToolbarItem.Identifier("Play")
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

    private var isRunningProcess: Bool = false {
        didSet {
            if isRunningProcess {
                playButton.image = stopIcon
            } else {
                playButton.image = playIcon
            }
        }
    }

    private var taskTitle: String? {
        didSet {
            if let taskTitle = taskTitle {
                statusBar.titleText = "\(CSWorkspacePreferences.workspaceName) – \(taskTitle)"
            } else {
                statusBar.titleText = CSWorkspacePreferences.workspaceName
            }
        }
    }

    private var playButtonItem = NSToolbarItem(itemIdentifier: .playButton)
    private var compilerConfigButtonItem = NSToolbarItem(itemIdentifier: .compilerConfigButton)
    private var statusBarItem = NSToolbarItem(itemIdentifier: .statusBar)
    private var splitterToggleItem = NSToolbarItem(itemIdentifier: .splitterToggle)
    private var paneToggleToolbarItem = NSToolbarItemGroup(itemIdentifier: .paneToggle)

    private let playButton = Button(titleText: "")
    private let statusBar = ToolbarStatusBar(frame: .zero)

    private var playIcon: NSImage = {
        let icon = NSImage(named: "icon-play")!
        icon.isTemplate = true
        return icon
    }()

    private var stopIcon: NSImage = {
        let icon = NSImage(named: "icon-stop")!
        icon.isTemplate = true
        return icon
    }()

    private static var compilerConfigurationKey = "Workspace compiler configuration"

    static var compilerConfigurationLogic: LGCSyntaxNode? {
        get {
            guard let rawValue = UserDefaults.standard.data(forKey: compilerConfigurationKey),
                let value = try? JSONDecoder().decode(LGCSyntaxNode.self, from: rawValue) else {
                    return nil
            }
            return value
        }
        set {
            guard let value = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.set(value, forKey: compilerConfigurationKey)
        }
    }

    private func setUpPlayButton() {
        // TODO: Terminate task on stop
        playButton.onPress = { [unowned self] in
            guard let workspaceViewController = WorkspaceWindowController.first?.contentViewController else { return }

            let sheet = CustomParametersEditorSheet(
                titleText: "Configure code generation",
                cancelText: "Cancel",
                submitText: "Continue"
            )

            let logicEditor = LogicCompilerConfigurationInput()
            if let rootNode = WorkspaceToolbar.compilerConfigurationLogic {
                logicEditor.rootNode = rootNode
            }

            var config = LogicCompilerConfigurationInput.evaluateConfiguration(rootNode: logicEditor.rootNode)
                ?? .init(target: "js", framework: "reactdom")

            logicEditor.onChangeRootNode = { rootNode in
                logicEditor.rootNode = rootNode
                WorkspaceToolbar.compilerConfigurationLogic = rootNode
                if let value = LogicCompilerConfigurationInput.evaluateConfiguration(rootNode: rootNode) {
                    config = value
                }
                return true
            }

            sheet.present(
                contentView: logicEditor,
                in: workspaceViewController,
                onSubmit: ({
                    let running = LonaModule.build(target: config.target, framework: config.framework) { [unowned self] result in
                        self.isRunningProcess = false

                        switch result {
                        case .failure(let message):
                            Swift.print(message)
                            self.taskTitle = "Failed to generate code"
                        case .success(let output):
                            Swift.print("Completed", output)
                            self.taskTitle = "Code generation complete"
                        }
                    }

                    if running {
                        self.isRunningProcess = true
                        self.taskTitle = "Generating code using custom configuration..."
                    }
                }),
                onCancel: {}
            )
        }
        playButton.image = playIcon
        playButton.bezelStyle = .texturedRounded

        playButtonItem.maxSize.width = 31
        playButtonItem.view = playButton
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

        compilerConfigButtonItem.view = segmented
    }

    private func setUpStatusBar() {

//        view.inProgress = true
//        view.progress = 0.5

        statusBarItem.minSize.width = 400
        statusBarItem.maxSize.width = 650

        statusBarItem.view = statusBar
    }

    private func setUpSplitterToggle() {
        let segmented = NSSegmentedControl(frame: NSRect(x: 0, y: 0, width: 31 + 4, height: 40))
        segmented.segmentStyle = .texturedRounded
        segmented.trackingMode = .selectAny
        segmented.segmentCount = 1
        segmented.target = self
        segmented.action = #selector(handleSplitterPane(_:))

        let icon = NSImage(named: "icon-pane-splitter")!
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
        taskTitle = nil

        setUpPlayButton()
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
//            .compilerConfigButton,
            .flexibleSpace,
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
            return playButtonItem
        } else if itemIdentifier == .compilerConfigButton {
            return compilerConfigButtonItem
        } else if itemIdentifier == .statusBar {
            return statusBarItem
        }

        return nil
    }
}
