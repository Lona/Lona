//
//  FileNavigator.swift
//  LonaStudio
//
//  Created by Devin Abbott on 10/15/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import FileTree
import Foundation
import Logic

private class FileTreeCellView: NSTableCellView {
    public var onChangeBackgroundStyle: ((NSView.BackgroundStyle) -> Void)?

    override var backgroundStyle: NSView.BackgroundStyle {
        didSet { onChangeBackgroundStyle?(backgroundStyle) }
    }
}

private func isDirectory(path: String) -> Bool {
    var isDir: ObjCBool = false
    if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
        return isDir.boolValue
    } else {
        return false
    }
}

class FileNavigatorHeaderWithMenu: FileNavigatorHeader {
    public var menuForHeader: (() -> NSMenu)?

    override func menu(for event: NSEvent) -> NSMenu? {
        return menuForHeader?()
    }
}

class FileNavigator: NSBox {

    // MARK: - Lifecycle

    init(rootPath: String) {
        self.rootPath = rootPath

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()

        subscriptions.append(LonaPlugins.current.register(eventType: .onReloadWorkspace) {
            self.headerView.fileIcon = NSImage(byReferencing: CSWorkspacePreferences.workspaceIconURL)
        })
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var subscriptions: [() -> Void] = []

    deinit {
        subscriptions.forEach({ sub in sub() })
    }

    // MARK: - Public

    public func reloadData() {
        fileTree.reloadData()
    }

    public var rootPath: String

    public var titleText: String {
        get { return headerView.titleText }
        set { headerView.titleText = newValue }
    }

    public var onAction: ((FileTree.Path) -> Void)? {
        get { return fileTree.onAction }
        set { fileTree.onAction = newValue }
    }

    public var onCreateFile: ((FileTree.Path, FileTree.FileEventOptions) -> Void)? {
        get { return fileTree.onCreateFile }
        set { fileTree.onCreateFile = newValue}
    }

    public var onDeleteFile: ((FileTree.Path, FileTree.FileEventOptions) -> Void)? {
        get { return fileTree.onDeleteFile }
        set { fileTree.onDeleteFile = newValue }
    }

    public var validateProposedMove: ((FileTree.Path, FileTree.Path) -> Bool)? {
        get { return fileTree.validateProposedMove }
        set { fileTree.validateProposedMove = newValue }
    }

    public var performMoveFile: ((FileTree.Path, FileTree.Path) -> Bool)? {
        get { return fileTree.performMoveFile }
        set { fileTree.performMoveFile = newValue }
    }

    public var performCreateComponent: ((FileTree.Path) -> Bool)?

    public var performCreateLogicFile: ((FileTree.Path) -> Bool)?

    public var performCreateMarkdownFile: ((FileTree.Path) -> Bool)?

    // MARK: - Private

    private var headerView = FileNavigatorHeaderWithMenu()

    private lazy var fileTree: FileTree = {
        return FileTree(rootPath: rootPath)
    }()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        fileTree.showRootFile = false
        fileTree.rowViewForFile = { [unowned self] path, _ in self.rowViewForFile(atPath: path) }
        fileTree.imageForFile = { [unowned self] path, size in self.imageForFile(atPath: path, size: size) }
        fileTree.displayNameForFile = { [unowned self] path in self.displayNameForFile(atPath: path) }
        fileTree.menuForFile = { [unowned self] path in self.menuForFile(atPath: path) }
        fileTree.filterFiles = { path in
            return !(path.hasPrefix(".") || URL(fileURLWithPath: path).deletingPathExtension().path.hasSuffix("~"))
        }

        headerView.fileIcon = NSImage(byReferencing: CSWorkspacePreferences.workspaceIconURL)
        headerView.dividerColor = NSSplitView.defaultDividerColor
        headerView.onClick = { [unowned self] in self.onAction?(self.rootPath) }
        headerView.menuForHeader = { [unowned self] in self.menuForFile(atPath: self.rootPath) }

        addSubview(headerView)
        addSubview(fileTree)
    }

    private func menuForFile(atPath path: String) -> NSMenu {
        let menu = NSMenu(title: "Menu")

        menu.addItem(NSMenuItem(title: "Reveal in Finder", onClick: {
            let parentPath = URL(fileURLWithPath: path).deletingLastPathComponent().path
            NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: parentPath)
        }))

        if isDirectory(path: path) {
            if !menu.items.isEmpty {
                menu.addItem(NSMenuItem.separator())
            }

            func makePath(filename: String, withExtension pathExtension: String) -> String {
                let newFileURL = URL(fileURLWithPath: path).appendingPathComponent(filename)
                let newFilePath = newFileURL.pathExtension == pathExtension ?
                    newFileURL.path : newFileURL.appendingPathExtension(pathExtension).path
                return newFilePath
            }

            menu.addItem(NSMenuItem(title: "New Component", onClick: { [unowned self] in
                guard let newFileName = self.promptForName(
                    messageText: "Enter a new component name",
                    placeholderText: "Component name") else { return }

                _ = self.performCreateComponent?(makePath(filename: newFileName, withExtension: "component"))
            }))

            menu.addItem(NSMenuItem(title: "New Markdown File", onClick: { [unowned self] in
                guard let newFileName = self.promptForName(
                    messageText: "Enter a new markdown file name",
                    placeholderText: "File name") else { return }

                _ = self.performCreateMarkdownFile?(makePath(filename: newFileName, withExtension: "md"))
            }))


            menu.addItem(NSMenuItem(title: "New Logic File", onClick: { [unowned self] in
                guard let newFileName = self.promptForName(
                    messageText: "Enter a new logic file name",
                    placeholderText: "File name") else { return }

                _ = self.performCreateLogicFile?(makePath(filename: newFileName, withExtension: "logic"))
            }))

            menu.addItem(NSMenuItem(title: "New Folder", onClick: { [unowned self] in
                guard let newFileName = self.promptForName(
                    messageText: "Enter a new folder name",
                    placeholderText: "Folder name") else { return }

                let newFilePath = URL(fileURLWithPath: path).appendingPathComponent(newFileName).path

                do {
                    try FileManager.default.createDirectory(
                        atPath: newFilePath,
                        withIntermediateDirectories: true,
                        attributes: nil)

                    self.fileTree.reloadData()
                } catch {
                    Swift.print("Failed to create directory \(newFileName)")
                }
            }))
        }

        if path != rootPath {
            if !menu.items.isEmpty {
                menu.addItem(NSMenuItem.separator())
            }

            if URL(fileURLWithPath: path).pathExtension == "component" {
                menu.addItem(NSMenuItem(title: "Duplicate As...", onClick: {
                    let dialog = NSSavePanel()

                    dialog.title                   = "Save .component file"
                    dialog.showsResizeIndicator    = true
                    dialog.showsHiddenFiles        = false
                    dialog.canCreateDirectories    = true
                    dialog.allowedFileTypes        = ["component"]
                    dialog.directoryURL = URL(fileURLWithPath: path).deletingLastPathComponent()

                    // User canceled the save. Don't swap out the document.
                    if dialog.runModal() != NSApplication.ModalResponse.OK {
                        return
                    }

                    guard let url = dialog.url else { return }
                    do {
                        try FileManager.default.copyItem(atPath: path, toPath: url.path)
                    } catch {
                        let alert = NSAlert()
                        alert.messageText = "Couldn't copy component to \(url.path)"
                        alert.addButton(withTitle: "OK")
                        alert.runModal()
                        return
                    }

                    self.onAction?(url.path)
                }))
            }

            menu.addItem(NSMenuItem(title: "Delete", onClick: {
                let fileName = URL(fileURLWithPath: path).lastPathComponent

                let alert = NSAlert()
                alert.messageText = "Are you sure you want to delete \(fileName)?"
                alert.addButton(withTitle: "Delete")
                alert.addButton(withTitle: "Cancel")

                let response = alert.runModal()

                if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                    do {
                        try FileManager.default.removeItem(atPath: path)
                    } catch {
                        Swift.print("Failed to delete \(path)")
                    }
                }
            }))
        }

        return menu
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        fileTree.translatesAutoresizingMaskIntoConstraints = false

        headerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        headerView.bottomAnchor.constraint(equalTo: fileTree.topAnchor).isActive = true

        fileTree.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        fileTree.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        fileTree.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func update() {}

    private func promptForName(messageText: String, placeholderText: String) -> String? {
        let alert = NSAlert()
        alert.messageText = messageText
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        let textView = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 20))
        textView.stringValue = ""
        textView.placeholderString = placeholderText
        alert.accessoryView = textView
        alert.window.initialFirstResponder = textView

        alert.layout()

        let response = alert.runModal()

        if response == NSApplication.ModalResponse.alertFirstButtonReturn {
            return textView.stringValue
        } else {
            return nil
        }
    }

    private func imageForFile(atPath path: String, size: NSSize) -> NSImage {
        let url = URL(fileURLWithPath: path)

        func defaultImage(for path: String) -> NSImage {
            return NSWorkspace.shared.icon(forFile: path)
        }

        if url.pathExtension == "component" {
            guard let component = LonaModule.current.component(named: url.deletingPathExtension().lastPathComponent),
                let canvas = component.computedCanvases().first,
                let caseItem = component.computedCases(for: canvas).first
                else { return defaultImage(for: path) }

            let config = ComponentConfiguration(
                component: component,
                arguments: caseItem.value.objectValue,
                canvas: canvas
            )

            let canvasView = CanvasView(
                canvas: canvas,
                rootLayer: component.rootLayer,
                config: config,
                options: [RenderOption.assetScale(1)]
            )

            guard let data = canvasView.dataRepresentation(scaledBy: 0.25),
                let image = NSImage(data: data)
                else { return defaultImage(for: path) }
            image.size = NSSize(width: size.width, height: (image.size.height / image.size.width) * size.height)
            return image
        } else if url.pathExtension == "logic" {
            return LogicViewController.thumbnail(for: url, within: size)
        } else {
            return defaultImage(for: path)
        }
    }

    private func displayNameForFile(atPath path: String) -> String {
        let url = URL(fileURLWithPath: path)
        switch url.pathExtension {
        case "component", "logic":
            return url.deletingPathExtension().lastPathComponent
        default:
            return url.lastPathComponent
        }
    }

    private func rowViewForFile(atPath path: String) -> NSView {
        let thumbnailSize = fileTree.defaultThumbnailSize
        let thumbnailMargin = fileTree.defaultThumbnailMargin
        let name = displayNameForFile(atPath: path)

        let view = FileTreeCellView()

        let textView = NSTextField(labelWithString: name)
        let iconView: NSView

        if isDirectory(path: path) {
            iconView = FolderIcon()
        } else if path.hasSuffix("lona.json") {
            iconView = LonaFileIcon()
        } else if path.hasSuffix("colors.json") {
            iconView = ColorsFileIcon()
        } else if path.hasSuffix(".component") || path.hasSuffix(".logic") {
            let imageView = NSImageView(image: imageForFile(atPath: path, size: thumbnailSize) )
            imageView.imageScaling = .scaleProportionallyUpOrDown
            iconView = imageView
        } else {
            iconView = FileIcon()
        }

        view.addSubview(textView)
        view.addSubview(iconView)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: thumbnailMargin).isActive = true
        iconView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: thumbnailSize.width).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: thumbnailSize.height).isActive = true

        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: thumbnailMargin * 2 + thumbnailSize.width).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        textView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small))
        textView.maximumNumberOfLines = 1
        textView.lineBreakMode = .byTruncatingMiddle

        if view.isDarkMode {
            if let iconView = iconView as? FolderIcon {
                iconView.selected = true
            } else if let iconView = iconView as? LonaFileIcon {
                iconView.selected = true
            } else if let iconView = iconView as? ColorsFileIcon {
                iconView.selected = true
            } else if let iconView = iconView as? FileIcon {
                iconView.selected = true
            }
        }

        view.onChangeBackgroundStyle = { style in
            if view.isDarkMode { return }

            switch style {
            case .light:
                if let iconView = iconView as? FolderIcon {
                    iconView.selected = false
                } else if let iconView = iconView as? LonaFileIcon {
                    iconView.selected = false
                } else if let iconView = iconView as? ColorsFileIcon {
                    iconView.selected = false
                } else if let iconView = iconView as? FileIcon {
                    iconView.selected = false
                }
                textView.textColor = NSColor.controlTextColor
            case .dark:
                if let iconView = iconView as? FolderIcon {
                    iconView.selected = true
                } else if let iconView = iconView as? LonaFileIcon {
                    iconView.selected = true
                } else if let iconView = iconView as? ColorsFileIcon {
                    iconView.selected = true
                } else if let iconView = iconView as? FileIcon {
                    iconView.selected = true
                }
                textView.textColor = .white
            default:
                break
            }
        }

        return view
    }
}
