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
        fileTree.rowViewForFile = { path, _ in self.rowViewForFile(atPath: path) }
        fileTree.imageForFile = self.imageForFile
        fileTree.displayNameForFile = self.displayNameForFile
        fileTree.menuForFile = { [unowned self] path in self.menuForFile(atPath: path) }

        fileTree.onDeleteFile = { path, options in
            Swift.print("Deleted", path)
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

        menu.addItem(NSMenuItem.separator())

        if isDirectory(path: path) {
            //                menu.addItem(withTitle: "New Component", action: #selector(self.handleNewFile), keyEquivalent: "")
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

            menu.addItem(NSMenuItem.separator())
        }

        if path != rootPath {
//            menu.addItem(NSMenuItem(title: "Rename", onClick: { [unowned self] in
//                let cellView = self.fileTree.beginRenamingFile(atPath: path) as? FileTree.DefaultCellView
//
//                Swift.print("Renaming cell", cellView)
//
//                self.fileTree.endRenamingFile()
//            }))

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

                self.fileTree.reloadData()
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
        } else {
            return defaultImage(for: path)
        }
    }

    private func displayNameForFile(atPath path: String) -> String {
        let url = URL(fileURLWithPath: path)
        return url.pathExtension == "component" ? url.deletingPathExtension().lastPathComponent : url.lastPathComponent
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
        } else if path.hasSuffix(".component") {
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
