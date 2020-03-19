//
//  RecentProjectsList.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/9/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

private let HOME_DIRECTORY_PATH = FileManager.default.homeDirectoryForCurrentUser.path

class RecentProjectsTableCellView: NSTableCellView {

    // MARK: - Lifecycle

    init(project: URL) {
        self.project = project

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    convenience init() {
        self.init(project: URL(fileURLWithPath: ""))
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    public var project: URL { didSet { update() } }

    // MARK: - Override

    private var selected: Bool = false { didSet { update() } }

    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            if self.backgroundStyle == .light {
                selected = false
            } else if self.backgroundStyle == .dark {
                selected = true
            }
        }
    }

    // MARK: - Private

    private let recentProjectView = RecentProjectItem()

    private func setUpViews() {
        addSubview(recentProjectView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        recentProjectView.translatesAutoresizingMaskIntoConstraints = false

        topAnchor.constraint(equalTo: recentProjectView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: recentProjectView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: recentProjectView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: recentProjectView.bottomAnchor).isActive = true
    }

    private func update() {
        let projectName = CSData.from(fileAtPath: project.appendingPathComponent("lona.json").path)?
            .get(key: "workspaceName").string ?? project.lastPathComponent

        let normalizedPath = project.deletingTrailingSlash().deletingLastPathComponent().path

        recentProjectView.projectName = projectName
        recentProjectView.projectDirectoryPath = normalizedPath.starts(with: HOME_DIRECTORY_PATH)
            ? normalizedPath.replacingOccurrences(of: HOME_DIRECTORY_PATH, with: "~")
            : normalizedPath
        recentProjectView.selected = selected
    }
}

class RecentProjectsTableView: NSView {

    // MARK: - Lifecycle

    init(projects: [URL]) {
        self.projects = projects

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    convenience init() {
        self.init(projects: [])
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    public var projects: [URL] { didSet { update() } }
    public var onOpenProject: ((URL) -> Void)?

    // MARK: - Private

    private let tableView = NSTableView()
    private let scrollView = NSScrollView()
    private let tableColumn = NSUserInterfaceItemIdentifier(rawValue: "items")

    private func setUpViews() {
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true

        tableView.backgroundColor = NSColor.clear
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle

        let column = NSTableColumn(identifier: tableColumn)
        column.title = "Items"
        column.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
        column.maxWidth = 1000

        tableView.addTableColumn(column)
        tableView.intercellSpacing = NSSize.zero
        tableView.headerView = nil
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        scrollView.documentView = tableView
        tableView.sizeToFit()
        tableView.doubleAction = #selector(handleClickItem(_:))
//        tableView.selectionHighlightStyle = .sourceList

        addSubview(scrollView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }

    private func update() {
        tableView.reloadData()
    }
}

extension RecentProjectsTableView: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        let result: CustomTableCellView = tableView.makeView(
//            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "defaultRow"),
//            owner: self) as! CustomTableCellView
//
//        return result
        return RecentProjectsTableCellView(project: projects[row])
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 54
    }

    @objc func handleClickItem(_ sender: AnyObject) {
        guard tableView.selectedRow >= 0 else { return }

        onOpenProject?(projects[tableView.selectedRow])
    }

	override func keyDown(with event: NSEvent) {
		let carriageReturnKeyCode = 36
		if event.keyCode == carriageReturnKeyCode, tableView.selectedRow >= 0 {
			onOpenProject?(projects[tableView.selectedRow])
		}
	}
}

extension RecentProjectsTableView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return projects.count
    }
}

// MARK: RecentProjectsList

class RecentProjectsList: NSBox {

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private

    private let recentProjectsTableView = RecentProjectsTableView()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        recentProjectsTableView.projects = DocumentController.shared.recentDocumentURLs
        recentProjectsTableView.onOpenProject = { filename in
            DocumentController.shared.openDocument(withContentsOf: filename, display: true)
        }

        DocumentController.shared.recentProjectsEmitter.addListener { [unowned self] projects in
            self.recentProjectsTableView.projects = projects
        }

        addSubview(recentProjectsTableView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        recentProjectsTableView.translatesAutoresizingMaskIntoConstraints = false

        topAnchor.constraint(equalTo: recentProjectsTableView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: recentProjectsTableView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: recentProjectsTableView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: recentProjectsTableView.bottomAnchor).isActive = true
    }

    private func update() {}
}
