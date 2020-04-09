//
//  MarkdownOutlineView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/8/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit
import FileTree
import Logic
import NavigationComponents

public class MarkdownOutlineView: NSBox {

    public final class Item {
        public init(id: UUID, sizeLevel: TextBlockView.SizeLevel?, description: String, sectionPath: [Int], children: [Item] = []) {
            self.id = id
            self.sizeLevel = sizeLevel
            self.description = description
            self.sectionPath = sectionPath
            self.children = children
        }

        public var id: UUID
        public var sizeLevel: TextBlockView.SizeLevel?
        public var description: String
        public var sectionPath: [Int]
        public var children: [Item]
    }

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

    public var onSelectItem: ((Item?) -> Void)?

    public var selectedID: UUID? {
        didSet {
            func find(item: Item, id: UUID?) -> Item? {
                if item.id == id { return item }

                return item.children.compactMap({ find(item: $0, id: id) }).first
            }

            let selectedItem: Item? = rootItems.compactMap({ find(item: $0, id: selectedID) }).first
            let oldItem: Item? = rootItems.compactMap({ find(item: $0, id: oldValue) }).first

            self.setSelectedItem(selectedItem, oldPath: oldItem)
        }
    }

    public var blocks: [EditableBlock] = [] {
        didSet {
            rootItems = blocks.items(level: .h1)
        }
    }

    private var rootItems: [Item] = [] {
        didSet {
            outlineView.reloadData()
            outlineView.expandItem(nil, expandChildren: true)
        }
    }

    public func setSelectedItem(_ selectedPath: Item?, oldPath oldValue: Item?) {
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

    private var outlineView = ControlledOutlineView(style: .singleColumn)
    private var scrollView = NSScrollView(frame: .zero)

    private func ancestors(for element: Item) -> [Item]? {
        var ancestors: [Item] = []
        var current: Item = element
        while let parent = outlineView.parent(forItem: current) as? Item {
            ancestors.append(parent)
            current = parent
        }

        return ancestors
    }

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        fillColor = Colors.vibrantWell

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

        outlineView.sizeToFit()

        addSubview(scrollView)

        outlineView.onSelect = { [unowned self] row in
            let element = self.outlineView.item(atRow: row) as? Item
            self.onSelectItem?(element)
        }
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func update() {}
}

extension MarkdownOutlineView: NSOutlineViewDelegate {

    public func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        let item = item as! Item

        return item.sizeLevel == .h1 ? EditorViewController.navigationBarHeight - 2 : 28
    }

    public func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        let item = item as! Item

        let view = FileTreeRowView(style:  item.sizeLevel == .h1 ? .custom(.firstRowStyle) : .rounded)

        return view
    }

    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? Item else { return nil }

        let view = FileTreeCellView()

        let isRootNode = item.sizeLevel == .h1

        let attributedString = [
            NSAttributedString(
                string: item.sectionPath.count == 1
                    ? ""
                    : " " + item.sectionPath.dropFirst().map({ $0.description }).joined(separator: ".") + "   ",
                attributes: [
                    .font: NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize(for: .small), weight: .bold)
                ]
            ),
            NSAttributedString(string: item.description, attributes: [
                .font : isRootNode
                    ? NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular))
                    : NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small))
            ])
        ].joined()

        let nameView = NSTextField(labelWithAttributedString: attributedString)
        nameView.maximumNumberOfLines = 1
        nameView.lineBreakMode = .byTruncatingTail

        view.addSubview(nameView)

        nameView.translatesAutoresizingMaskIntoConstraints = false

        nameView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        nameView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -4).isActive = true
        nameView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8).isActive = true

        return view
    }
}

extension MarkdownOutlineView: NSOutlineViewDataSource {
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil { return rootItems.count }

        let item = item as! Item

        return item.children.count
    }

    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        let item = item as! Item

        return item.children.count > 0
    }

    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil { return rootItems[index] }

        let item = item as! Item

        return item.children[index]
    }
}

extension Array where Element == EditableBlock {
    public func items(level: TextBlockView.SizeLevel, sectionPath parentPath: [Int] = []) -> [MarkdownOutlineView.Item] {
        let headings = textElements(level: level)
        let betweenHeadings: [[EditableBlock]] = headings.enumerated().map { offset, heading in
            let startIndex = self.firstIndex(of: heading)!
            let endIndex = offset < headings.count - 1
                ? self.firstIndex(of: headings[offset + 1])!
                : self.count
            return Array(self[startIndex..<endIndex])
        }

        let items: [MarkdownOutlineView.Item] = zip(headings, betweenHeadings).enumerated().map { offset, pair in
            let sectionIndex = offset + 1
            let (heading, blocks) = pair
            let headingLevel = heading.textSizeLevel!

            var children: [MarkdownOutlineView.Item]

            let sectionPath = parentPath + [sectionIndex]

            switch headingLevel {
            case .h1:
                children = Array(blocks).items(level: .h2, sectionPath: sectionPath)

                if children.isEmpty {
                    children = Array(blocks).items(level: .h3, sectionPath: sectionPath)
                }
            case .h2:
                children = Array(blocks).items(level: .h3, sectionPath: sectionPath)
            default:
                children = []
            }

            return .init(
                id: heading.id,
                sizeLevel: heading.textSizeLevel!,
                description: String((heading.text ?? "").prefix(50)),
                sectionPath: sectionPath,
                children: children
            )
        }

        return items
    }

    public func textElements(level: TextBlockView.SizeLevel) -> [EditableBlock] {
        return self.filter { block in
            switch block.content {
            case .text(_, level):
                return true
            default:
                return false
            }
        }
    }
}

extension EditableBlock {
    public func isTextElement(level: TextBlockView.SizeLevel) -> Bool {
        switch content {
        case .text(_, level):
            return true
        default:
            return false
        }
    }

    public var textSizeLevel: TextBlockView.SizeLevel? {
        switch content {
        case .text(_, let level):
            return level
        default:
            return nil
        }
    }

    public var text: String? {
        switch content {
        case .text(let attributedString, _):
            return attributedString.string
        default:
            return nil
        }
    }
}

extension NavigationItemView.Style {
    public static var treeIcon: NavigationItemView.Style = {
        var style: NavigationItemView.Style = .default
        style.font = NSFont.boldSystemFont(ofSize: NSFont.systemFontSize(for: .mini))
        style.padding = .init(top: 1, left: 3, bottom: 1, right: 2)
        style.cornerRadius = 2
//        style.padding = .init(top: 2, left: 2, bottom: 2, right: 0.5)
//        style.cornerRadius = 1
        return style
    }()
}
