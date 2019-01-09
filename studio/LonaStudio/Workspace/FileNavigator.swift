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

    public var defaultFont: NSFont {
        get { return fileTree.defaultFont }
        set { fileTree.defaultFont = newValue }
    }

    public var displayNameForFile: ((FileTree.Path) -> FileTree.Name)? {
        get { return fileTree.displayNameForFile }
        set { fileTree.displayNameForFile = newValue }
    }

    public var imageForFile: ((FileTree.Path, NSSize) -> NSImage)? {
        get { return fileTree.imageForFile }
        set { fileTree.imageForFile = newValue }
    }

    public var onAction: ((FileTree.Path) -> Void)? {
        get { return fileTree.onAction }
        set { fileTree.onAction = newValue }
    }

    // MARK: - Private

    private var headerView = FileNavigatorHeader()

    private lazy var fileTree: FileTree = {
        return FileTree(rootPath: rootPath)
    }()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        fileTree.showRootFile = false
        fileTree.rowViewForFile = { path in self.rowViewForFile(atPath: path) }

        headerView.fileIcon = NSImage(byReferencing: CSWorkspacePreferences.workspaceIconURL)
        headerView.dividerColor = NSSplitView.defaultDividerColor
        headerView.onClick = { [unowned self] in self.onAction?(self.rootPath) }

        addSubview(headerView)
        addSubview(fileTree)
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

    private func rowViewForFile(atPath path: String) -> NSView {
        let thumbnailSize = fileTree.defaultThumbnailSize
        let thumbnailMargin = fileTree.defaultThumbnailMargin
        let name = displayNameForFile?(path) ?? URL(fileURLWithPath: path).lastPathComponent

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
            let imageView = NSImageView(image: imageForFile?(path, thumbnailSize) ?? NSImage())
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
        textView.font = defaultFont
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
