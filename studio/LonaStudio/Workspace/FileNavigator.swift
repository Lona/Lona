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

        subscriptions.append(LonaPlugins.current.register(eventType: .onReloadWorkspace) { [unowned self] in
            self.fileTree.reloadData()
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

    public var onAction: ((FileTree.Path) -> Void)? {
        get { return fileTree.onAction }
        set { fileTree.onAction = newValue }
    }

    public var onSelect: ((FileTree.Path?) -> Void)? {
        get { return fileTree.onSelect }
        set { fileTree.onSelect = newValue }
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

    public var selectedFile: FileTree.Path? {
        get { return fileTree.selectedFile }
        set { fileTree.selectedFile = newValue }
    }

    public var performDeleteFile: ((FileTree.Path) -> Void)?

    public var performCreateComponent: ((FileTree.Path) -> Bool)?

    public var performCreatePage: ((String, FileTree.Path) -> Void)?

    // MARK: - Private

    private lazy var fileTree: FileTree = {
        return FileTree(rootPath: rootPath)
    }()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        fillColor = Colors.headerBackground

        fileTree.showRootFile = true
        fileTree.rowHeightForFile = { [unowned self] path in self.rowHeightForFile(atPath: path) }
        fileTree.rowViewForFile = { [unowned self] path, _ in self.rowViewForFile(atPath: path) }
        fileTree.imageForFile = { [unowned self] path, size in self.imageForFile(atPath: path, size: size) }
        fileTree.displayNameForFile = { [unowned self] path in self.displayNameForFile(atPath: path) }
        fileTree.menuForFile = { [unowned self] path in self.menuForFile(atPath: path) }
        fileTree.filterFiles = { path in
            return !(
                path.hasPrefix(".") ||
                path.hasSuffix("lona.json") ||
                path.hasSuffix("README.md") ||
                URL(fileURLWithPath: path).deletingPathExtension().path.hasSuffix("~")
            )
        }
        fileTree.onPressDelete = { [unowned self] path in self.deleteAlertForFile(atPath: path) }

        addSubview(fileTree)
    }

    private func deleteAlertForFile(atPath path: String) {
        let fileURL = URL(fileURLWithPath: path)
        let fileName = fileURL.lastPathComponent

        let response = Alert(
            items: ["Cancel", "Delete"],
            messageText: "Are you sure you want to delete \(fileName)?"
        ).run()

        if response == "Delete" {
            self.performDeleteFile?(path)
        }
    }

    private func menuForFile(atPath path: String) -> NSMenu {

        // Allow the user to enter a file name with or without a path extension
        func normalizeInputPath(_ path: String, filename: String, withExtension pathExtension: String) -> String {
            let newFileURL = URL(fileURLWithPath: path).appendingPathComponent(filename)
            let newFilePath = newFileURL.pathExtension == pathExtension ?
                newFileURL.path : newFileURL.appendingPathExtension(pathExtension).path
            return newFilePath
        }

        let url = URL(fileURLWithPath: path)

        let menu = NSMenu(title: "Menu")

        menu.addItem(NSMenuItem(title: "Reveal in Finder", onClick: {
            let parentPath = URL(fileURLWithPath: path).deletingLastPathComponent().path
            NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: parentPath)
        }))

        if FileManager.default.isDirectory(path: path) {
            if !menu.items.isEmpty {
                menu.addItem(NSMenuItem.separator())
            }

            if CSUserPreferences.useExperimentalFeatures {
                menu.addItem(NSMenuItem(title: "New Component", onClick: { [unowned self] in
                    guard let newFileName = Alert.runTextInputAlert(
                        messageText: "Enter a new component name",
                        placeholderText: "Component name") else { return }

                    _ = self.performCreateComponent?(normalizeInputPath(path, filename: newFileName, withExtension: "component"))
                }))
            }

            menu.addItem(NSMenuItem(title: "New Folder", onClick: { [unowned self] in
                guard let newFileName = Alert.runTextInputAlert(
                    messageText: "Enter a new folder name",
                    placeholderText: "Folder name") else { return }

                let parentURL = URL(fileURLWithPath: path)

                let newDirectory = VirtualDirectory(name: newFileName)

                do {
                    try VirtualFileSystem.write(node: newDirectory, relativeTo: parentURL)

                    self.fileTree.reloadData()
                } catch {
                    Swift.print("Failed to create directory \(newFileName)")
                }
            }))
        }

        if url.isLonaPage() {
            menu.addItem(NSMenuItem(title: "New Page", onClick: { [unowned self] in
                guard var pageName = Alert.runTextInputAlert(
                    messageText: "Enter a new page name",
                    placeholderText: "Page name") else { return }
                if pageName.hasSuffix(".md") {
                    pageName.removeLast(3)
                }
                self.performCreatePage?(pageName, path)
            }))
        }

        if path != rootPath {
            if !menu.items.isEmpty {
                menu.addItem(NSMenuItem.separator())
            }

            let fileURL = URL(fileURLWithPath: path)
            if fileURL.pathExtension == "component" {
                menu.addItem(NSMenuItem(title: "Duplicate As...", onClick: {
                    let dialog = NSSavePanel()

                    dialog.title                   = "Save .component file"
                    dialog.showsResizeIndicator    = true
                    dialog.showsHiddenFiles        = false
                    dialog.canCreateDirectories    = true
                    dialog.allowedFileTypes        = ["component"]
                    dialog.directoryURL = fileURL.deletingLastPathComponent()

                    // User canceled the save. Don't swap out the document.
                    if dialog.runModal() != NSApplication.ModalResponse.OK {
                        return
                    }

                    guard let url = dialog.url else { return }
                    do {
                        try FileManager.default.copyItem(atPath: path, toPath: url.path)
                    } catch {
                        Alert(items: ["OK"], messageText: "Couldn't copy component to \(url.path)").run()
                        return
                    }

                    self.onAction?(url.path)
                }))
            }

            menu.addItem(NSMenuItem(title: "Delete", onClick: {
                self.deleteAlertForFile(atPath: path)
            }))
        }

        return menu
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        fileTree.translatesAutoresizingMaskIntoConstraints = false

        fileTree.topAnchor.constraint(equalTo: topAnchor, constant: 24).isActive = true
        fileTree.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        fileTree.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        fileTree.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func update() {}

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
        } else if url.pathExtension == "logic" || url.pathExtension == "tokens" {
            return LogicViewController.thumbnail(for: url, within: size, style: .bordered)
        } else {
            return defaultImage(for: path)
        }
    }

    private func displayNameForFile(atPath path: String) -> String {
        if path == rootPath {
            return CSWorkspacePreferences.workspaceName
        }

        let url = URL(fileURLWithPath: path)
        switch url.pathExtension {
        case "component", "logic", "tokens", "md":
            return url.deletingPathExtension().lastPathComponent
        default:
            return url.lastPathComponent
        }
    }

    private func rowHeightForFile(atPath path: String) -> CGFloat {
        return path == rootPath ? 38 : fileTree.defaultRowHeight
    }

    private func rowViewForFile(atPath path: String) -> NSView {
        let thumbnailSize = fileTree.defaultThumbnailSize
        let thumbnailMargin = fileTree.defaultThumbnailMargin
        let name = displayNameForFile(atPath: path)

        let view = FileTreeCellView()

        let textView = NSTextField(labelWithString: name)
        let iconView: NSView

        if FileManager.default.isDirectory(path: path) {
            if path == rootPath {
                let image = NSImage(byReferencing: CSWorkspacePreferences.workspaceIconURL)
                let imageView = NSImageView(image: image)
                imageView.imageScaling = .scaleProportionallyUpOrDown
                iconView = imageView
            } else if URL(fileURLWithPath: path).isLonaMarkdownDirectory() {
                iconView = FileIcon()
            } else {
                iconView = FolderIcon()
            }
        } else if path.hasSuffix("lona.json") {
            iconView = LonaFileIcon()
        } else if path.hasSuffix("colors.json") {
            iconView = ColorsFileIcon()
        } else if path.hasSuffix(".component") || path.hasSuffix(".logic") || path.hasSuffix(".tokens") {
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
        textView.font = path == rootPath
            ? NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
            : NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small))
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
