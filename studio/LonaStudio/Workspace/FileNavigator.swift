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

public class FileTreeCellView: NSTableCellView, NSTextFieldDelegate {
    public var onChangeBackgroundStyle: ((NSView.BackgroundStyle) -> Void)?

    public override var backgroundStyle: NSView.BackgroundStyle {
        didSet { onChangeBackgroundStyle?(backgroundStyle) }
    }

    public var onBeginRenaming: (() -> Void)?

    public var onEndRenaming: ((FileTree.Path) -> Void)?

    public func controlTextDidEndEditing(_ obj: Notification) {
        guard let textView = obj.object as? NSTextField else { return }

        if let cellView = textView.superview as? FileTreeCellView {
            cellView.onEndRenaming?(textView.stringValue)
        }
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

    public var performCreateLegacyComponent: ((FileTree.Path) -> Bool)?

    public var performCreatePage: ((String, FileTree.Path) -> Void)?

    // MARK: - Private

    private lazy var fileTree: FileTree = {
        return FileTree(rootPath: rootPath)
    }()

    private var visualEffectView: NSVisualEffectView = .init()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        fillColor = Colors.headerBackground

        fileTree.showRootFile = true
        fileTree.rowStyle = .rounded
        fileTree.rowHeightForFile = { [unowned self] path in self.rowHeightForFile(atPath: path) }
        fileTree.rowViewForFile = { [unowned self] path, options in self.rowViewForFile(atPath: path, options: options) }
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

        let parentView = isDarkMode ? visualEffectView : self

        if parentView != self {
            self.addSubview(parentView)
        }

        parentView.addSubview(fileTree)
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

    private func handleRenameFile(atPath path: String) {
        if let cellView = fileTree.beginRenamingFile(atPath: path) as? FileTreeCellView {
            cellView.onBeginRenaming?()
        }
    }

    // Allow the user to enter a file name with or without a path extension
    private static func normalizeInputPath(parentPath path: String, filename: String, withExtension pathExtension: String) -> String {
        let newFileURL = URL(fileURLWithPath: path).appendingPathComponent(filename)
        let newFilePath = newFileURL.pathExtension == pathExtension ?
            newFileURL.path : newFileURL.appendingPathExtension(pathExtension).path
        return newFilePath
    }

    private func menuForFile(atPath path: String) -> NSMenu {

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
                    let newPath = FileNavigator.normalizeInputPath(parentPath: path, filename: newFileName, withExtension: "cmp")
                    _ = self.performCreateComponent?(newPath)
                }))

                menu.addItem(NSMenuItem(title: "New Flexbox Component", onClick: { [unowned self] in
                    guard let newFileName = Alert.runTextInputAlert(
                        messageText: "Enter a new component name",
                        placeholderText: "Component name") else { return }
                    let newPath = FileNavigator.normalizeInputPath(parentPath: path, filename: newFileName, withExtension: "component")
                    _ = self.performCreateLegacyComponent?(newPath)
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

                    self.onSelect?(url.path)
                }))
            }

            menu.addItem(NSMenuItem(title: "Delete", onClick: {
                self.deleteAlertForFile(atPath: path)
            }))

            menu.addItem(NSMenuItem(title: "Rename", onClick: {
                self.handleRenameFile(atPath: path)
            }))
        }

        return menu
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        fileTree.translatesAutoresizingMaskIntoConstraints = false

        let parentView = isDarkMode ? visualEffectView : self

        parentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        parentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        parentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        parentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        fileTree.topAnchor.constraint(
            equalTo: parentView.topAnchor,
            constant: EditorViewController.navigationBarHeight - 1
        ).isActive = true
        fileTree.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        fileTree.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        fileTree.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
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
        case "component", "logic", "tokens", "md", "cmp":
            return url.deletingPathExtension().lastPathComponent
        default:
            return url.lastPathComponent
        }
    }

    private func rowHeightForFile(atPath path: String) -> CGFloat {
        return path == rootPath ? EditorViewController.navigationBarHeight : fileTree.defaultRowHeight
    }

    private func rowViewForFile(atPath path: String, options: FileTree.RowViewOptions) -> NSView {
        let thumbnailSize = fileTree.defaultThumbnailSize
        let thumbnailMargin = fileTree.defaultThumbnailMargin
        let name = displayNameForFile(atPath: path)

        let view = FileTreeCellView()

        let textView = NSTextField(labelWithString: name)
        let iconView: NSView

        if options.contains(.editable) {
            textView.isEditable = true
            textView.isEnabled = true
        }

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
        } else if path.hasSuffix(".component") || path.hasSuffix(".logic") || path.hasSuffix(".tokens") || path.hasSuffix(".cmp") {
            let imageView = NSImageView(image: imageForFile(atPath: path, size: thumbnailSize) )
            imageView.imageScaling = .scaleProportionallyUpOrDown
            iconView = imageView
        } else {
            iconView = FileIcon()
        }

        view.addSubview(textView)
        view.addSubview(iconView)

        view.textField = textView

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

        view.onChangeBackgroundStyle = { style in
            switch style {
            case .light:
                if let iconView = iconView as? FolderIcon {
                    iconView.selected = false
                } else if let iconView = iconView as? FileIcon {
                    iconView.selected = false
                }
                if !view.isDarkMode {
                    textView.textColor = NSColor.controlTextColor
                }
            case .dark:
                if let iconView = iconView as? FolderIcon {
                    iconView.selected = true
                } else if let iconView = iconView as? FileIcon {
                    iconView.selected = true
                }

                if !view.isDarkMode {
                    if options.contains(.editable) {
                        textView.textColor = NSColor.controlTextColor
                    } else {
                        textView.textColor = .white
                    }
                }
            default:
                break
            }
        }

        view.onBeginRenaming = { [unowned self] in
            textView.delegate = view
            NSApp.activate(ignoringOtherApps: true)
            self.fileTree.window?.makeFirstResponder(textView)
        }

        view.onEndRenaming = { [unowned self] newName in
            Swift.print("End renaming", newName)

            textView.delegate = nil

            self.fileTree.endRenamingFile()

            if newName != name {
                let url = URL(fileURLWithPath: path)
                let parentPath = url.deletingLastPathComponent().path
                let newPath = url.hasMarkdownExtension()
                    ? FileNavigator.normalizeInputPath(parentPath: parentPath, filename: newName, withExtension: "md")
                    : URL(fileURLWithPath: parentPath).appendingPathComponent(newName).path
                _ = self.fileTree.performMoveFile?(path, newPath)
            }
        }

        return view
    }
}
