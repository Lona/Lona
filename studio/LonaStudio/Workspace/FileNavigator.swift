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

        headerView.fileIcon = NSImage(byReferencing: CSWorkspacePreferences.workspaceIconURL)
        headerView.dividerColor = NSSplitView.defaultDividerColor

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
}
