//
//  ElementEditor.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/30/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit
import FileTree
import Logic
import NavigationComponents

class ElementButton: NavigationItemView {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }
}

public final class ElementItem {
    public init(id: UUID, type: String, name: String? = nil, visible: Bool = true, children: [ElementItem] = []) {
        self.id = id
        self.type = type
        self.name = name
        self.visible = visible
        self.children = children
    }

    public var id: UUID
    public var type: String
    public var name: String?
    public var visible: Bool
    public var children: [ElementItem]
}

extension ElementItem: Reducible {
    public func reduceChildren<R>(
        config: TraversalConfig,
        initialResult: R,
        f: @escaping (R, ElementItem, TraversalConfig) throws -> R
    ) rethrows -> R {
        return try children.reduce(initialResult) { (result, element) in
            return try f(result, element, config)
        }
    }
}

public class ElementEditor: NSBox {

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var onRenameItem: ((ElementItem, String) -> Void)?

    public var onSelectItem: ((ElementItem?) -> Void)?

    public var selectedItem: ElementItem? {
        didSet {
            self.setSelectedItem(selectedItem, oldPath: oldValue)
        }
    }

    public var rootItem: ElementItem? {
        didSet {
            elementForID.removeAll(keepingCapacity: true)
            parentForID.removeAll(keepingCapacity: true)

            var prefixMap: [String: Int] = [:]

            if let rootItem = rootItem {
                rootItem.forEachDescendant(config: .init()) { (item, _) in
                    if item.name == nil {
                        let counter = (prefixMap[item.type] ?? 0) + 1
                        Swift.print("item name", item.type, counter)
                        self.automaticNameForID[item.id] = item.type + String(describing: counter)
                        prefixMap[item.type] = counter
                    }

                    self.elementForID[item.id] = item

                    item.children.forEach { child in
                        self.parentForID[child.id] = item
                    }
                }
            }

            outlineView.reloadData()
            outlineView.expandItem(nil, expandChildren: true)
        }
    }

    public func setSelectedItem(_ selectedPath: ElementItem?, oldPath oldValue: ElementItem?) {
        if let selectedPath = selectedPath {
            var selectedIndex = outlineView.row(forItem: selectedPath)

            // File is either not in the tree or in a collapsed parent
            if selectedIndex == -1 {
                let ancestorPaths = ancestors(for: selectedPath)?.reversed() ?? []

                for path in ancestorPaths {
                    let index = outlineView.row(forItem: path)

                    if index != -1 {
                        outlineView.expandItem(path)
                    }
                }

                selectedIndex = outlineView.row(forItem: selectedPath)
            }

            outlineView.selectRowIndexes(IndexSet(integer: selectedIndex), byExtendingSelection: false)

            // Check that the view is currently visible, otherwise it will scroll to the bottom
            if visibleRect != .zero {
                outlineView.scrollRowToVisible(selectedIndex)
            }

            var reloadIndexSet = IndexSet(integer: selectedIndex)

            if let oldValue = oldValue {
                let oldSelectedIndex = outlineView.row(forItem: oldValue)
                reloadIndexSet.insert(oldSelectedIndex)
            }

            outlineView.reloadData(forRowIndexes: reloadIndexSet, columnIndexes: IndexSet(integer: 0))
        } else {
            outlineView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
        }
    }

    // MARK: Private

    private var elementForID: [UUID: ElementItem] = [:]
    private var parentForID: [UUID: ElementItem] = [:]
    private var automaticNameForID: [UUID: String] = [:]

    private var outlineView = ControlledOutlineView(style: .singleColumn)
    private var scrollView = NSScrollView(frame: .zero)
    private var headerView = LayerListHeader()
    private var dividerView = NSBox()

    private func ancestors(for element: ElementItem) -> [ElementItem]? {
        if elementForID[element.id] == nil { return nil }

        var ancestors: [ElementItem] = []
        var current: ElementItem = element
        while let parent = parentForID[current.id] {
            ancestors.append(parent)
            current = parent
        }

        return ancestors
    }

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        dividerView.boxType = .custom
        dividerView.borderType = .noBorder
        dividerView.contentViewMargins = .zero
        dividerView.fillColor = NSSplitView.defaultDividerColor

        addSubview(dividerView)
        addSubview(headerView)

        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        scrollView.addSubview(outlineView)
        scrollView.documentView = outlineView
        scrollView.backgroundColor = .clear

        outlineView.autosaveExpandedItems = true
        outlineView.dataSource = self
        outlineView.delegate = self
//        outlineView.autosaveName = autosaveName

        outlineView.rowHeight = 28
        outlineView.sizeToFit()

        addSubview(scrollView)

        outlineView.onSelect = { [unowned self] row in
            let element = self.outlineView.item(atRow: row) as? ElementItem
            self.onSelectItem?(element)
        }
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        headerView.heightAnchor.constraint(equalToConstant: EditorViewController.navigationBarHeight - 1).isActive = true
        headerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        headerView.bottomAnchor.constraint(equalTo: dividerView.topAnchor).isActive = true

        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        dividerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dividerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        dividerView.bottomAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true

        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func update() {
//        outlineView.component = component
    }
}

extension ElementEditor: NSOutlineViewDelegate {
    public func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        return ElementEditorRowView(style: .rounded)
    }

    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? ElementItem else { return nil }

        let view = FileTreeCellView()

        let typeView = ElementButton(titleText: item.type)
        var typeViewStyle: NavigationItemView.Style = .treeRowButton
        typeViewStyle.backgroundColor = NSColor.textColor.withAlphaComponent(0.08)
        typeView.style = typeViewStyle
//        typeView.style.padding = .init(top: 4, left: 8, bottom: 4, right: 8)

        let nameView = ElementButton(titleText: item.name ?? automaticNameForID[item.id] ?? "<no name>")
        var nameViewStyle: NavigationItemView.Style = .treeRowButton
        if item.name == nil, let newColor = nameView.style.textColor.shadow(withLevel: 0.5) {
            nameViewStyle.textColor = newColor
        }
        nameView.style = nameViewStyle

        view.addSubview(typeView)
        view.addSubview(nameView)

        typeView.translatesAutoresizingMaskIntoConstraints = false
        nameView.translatesAutoresizingMaskIntoConstraints = false

        typeView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        typeView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 4).isActive = true

        nameView.leadingAnchor.constraint(equalTo: typeView.trailingAnchor, constant: 4).isActive = true

        nameView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        nameView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -4).isActive = true

        nameView.isEnabled = true
        nameView.onClick = { [unowned self] in
            self.showNameEditor(
                currentName: item.name ?? self.automaticNameForID[item.id] ?? "",
                at: nameView.convert(nameView.bounds, to: nil),
                onSubmit: ({ [unowned self] newName in self.onRenameItem?(item, newName) })
            )
        }

        return view
    }
}

extension ElementEditor: NSOutlineViewDataSource {
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if rootItem == nil { return 0 }

        if item == nil { return 1 }

        let item = item as! ElementItem

        return item.children.count
    }

    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let item = item as! ElementItem

        return item.children.count > 0
    }

    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil { return rootItem! }

        let item = item as! ElementItem

        return item.children[index]
    }
}

class ElementEditorRowView: FileTreeRowView {
//    override func hitTest(_ point: NSPoint) -> NSView? {
//        let result = super.hitTest(point)
//        Swift.print("ht", point, result?.superview?.superview)
//        return result?.superview?.superview
//    }
}

//class ElementOutlineView: ControlledOutlineView {}

// MARK: - Suggestions

extension ElementEditor {
    func showNameEditor(currentName: String, at windowRect: NSRect, onSubmit: @escaping (String) -> Void) {
        guard let window = self.window else { return }

        let suggestionWindow = SuggestionWindow.shared

        suggestionWindow.suggestionText = currentName
        suggestionWindow.suggestionItems = []
        suggestionWindow.placeholderText = "Type a new element name and press Enter"
        suggestionWindow.style = .textInput
        suggestionWindow.onRequestHide = { suggestionWindow.orderOut(nil) }
        suggestionWindow.onPressEscapeKey = { suggestionWindow.orderOut(nil) }
        suggestionWindow.onSelectIndex = { index in
            suggestionWindow.selectedIndex = index
        }
        suggestionWindow.onChangeSuggestionText = { text in
            suggestionWindow.suggestionText = text
            suggestionWindow.suggestionItems = []
        }
        suggestionWindow.onPressEnter = {
            onSubmit(suggestionWindow.suggestionText)
            suggestionWindow.onPressEnter = nil
            suggestionWindow.orderOut(nil)
        }
        suggestionWindow.onRequestHide = {
            suggestionWindow.onPressEnter = nil
            suggestionWindow.orderOut(nil)
        }

        window.addChildWindow(suggestionWindow, ordered: .above)

        let screenRect = window.convertToScreen(windowRect)
        let adjustedRect = NSRect(
            x: screenRect.minX - 12 + 4,
            y: screenRect.origin.y,
            width: screenRect.width,
            height: screenRect.height
        )

        suggestionWindow.anchorTo(rect: adjustedRect, verticalOffset: 4)
        suggestionWindow.focusSearchField()
    }
}

extension NavigationItemView.Style {
    public static var treeRowButton: NavigationItemView.Style = {
        var style: NavigationItemView.Style = .default
        style.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small))
        return style
    }()
}
