//
//  ListEditor.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

//
//  ListEditor.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/26/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class ListView<Element: DataNode>: NSOutlineView, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate {

    func setup() {
        let columnName = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Element"))
        columnName.title = "Element"

        self.addTableColumn(columnName)
        self.outlineTableColumn = columnName

        self.dataSource = self
        self.delegate = self

        self.focusRingType = .none
        self.rowSizeStyle = .medium
        self.headerView = nil

        // TODO Make this a parameter
        self.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: "component.element")])

        self.reloadData()

        columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        columnName.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
    }

    let options: ListEditor<Element>.Options

    init(
        frame frameRect: NSRect,
        options: ListEditor<Element>.Options
    ) {
        self.options = options
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var component: CSComponent?

    var list: [Element] = []

    var onChange: ([Element]) -> Void = {_ in }

    override func viewWillDraw() {
        sizeLastColumnToFit()
        super.viewWillDraw()
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return list.count
        }

        if let caseItem = item as? Element {
            return caseItem.childCount()
        }

        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return list[index]
        }

        if let caseItem = item as? Element {
            return caseItem.child(at: index)
        }

        // Should never get here
        Swift.print("Bad parameter child")
        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let element = item as? Element {
            return options.viewFor(element)
        }

        return CSStatementView(frame: NSRect.zero, components: [])
    }

    var selectedItem: Any? {
        return item(atRow: selectedRow)
    }

    override func mouseDown(with event: NSEvent) {
        let selfPoint = convert(event.locationInWindow, from: nil)
        let row = self.row(at: selfPoint)

        if row >= 0 {
            let cell = view(atColumn: 0, row: row, makeIfNecessary: false)

            if let cell = cell as? CSStatementView {
                let activated = cell.mouseDownForTextFields(with: event)

                if activated { return }
            }
        }

        super.mouseDown(with: event)
    }

    override func keyDown(with event: NSEvent) {
        let characters = event.charactersIgnoringModifiers!

        if characters == String(Character(UnicodeScalar(NSDeleteCharacter)!)) {
            if selectedItem == nil { return }

            if let item = selectedItem as? Element {
                options.onRemoveElement(item)
            }
        }
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        let point = convert(event.locationInWindow, from: nil)
        let index = row(at: point)
        guard let element = item(atRow: index) as? Element else { return nil }

        select(item: element)

        var items: [NSMenuItem] = []

//        if let menuProvider = element as? MenuProvider {
//            items.append(contentsOf: menuProvider.defaultMenu(for: self))
//        }

        if let onContextMenu = options.onContextMenu {
            items.append(contentsOf: onContextMenu(element))
        }

        return NSMenu(items: items)
    }

    // <DragAndDrop>

    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {

        let pasteboardItem = NSPasteboardItem()

        let index = outlineView.row(forItem: item)

        pasteboardItem.setString(String(index), forType: NSPasteboard.PasteboardType(rawValue: "component.element"))

        return pasteboardItem
    }

    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {

        let sourceIndexString = info.draggingPasteboard().string(forType: NSPasteboard.PasteboardType(rawValue: "component.element"))

        if  let sourceIndexString = sourceIndexString,
            let sourceIndex = Int(sourceIndexString),
            let sourceItem = outlineView.item(atRow: sourceIndex) as? Element,
            let relativeItem = item as? Element? {
            let acceptanceCategory = shouldAccept(dropping: sourceItem, relativeTo: relativeItem, at: index)

            switch acceptanceCategory {
            case .into(parent: _, at: _):
                if relativeItem is DataNodeParent {
                    return NSDragOperation.move
                }
            case .intoContainer: return NSDragOperation.move
            default: break
            }
        }

        return NSDragOperation()
    }

    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {

        let sourceIndexString = info.draggingPasteboard().string(forType: NSPasteboard.PasteboardType(rawValue: "component.element"))

        if  let sourceIndexString = sourceIndexString,
            let sourceIndex = Int(sourceIndexString),
            let sourceItem = outlineView.item(atRow: sourceIndex) as? Element,
            let relativeItem = item as? Element? {
            let acceptanceCategory = shouldAccept(dropping: sourceItem, relativeTo: relativeItem, at: index)

            switch acceptanceCategory {
            case .into(parent: let parentItem, at: let targetIndex):
                let (oldParent, oldIndex) = relativePosition(for: sourceItem)
                if let oldParent = oldParent as? DataNodeParent {
                    oldParent.remove(at: oldIndex)
                } else {
                    list.remove(at: oldIndex)
                }
                if let newParent = parentItem as? DataNodeParent {
                    if let targetIndex = targetIndex {
                        if oldParent === newParent && oldIndex < targetIndex {
                            newParent.insert(sourceItem, at: targetIndex - 1)
                        } else {
                            newParent.insert(sourceItem, at: targetIndex)
                        }
                    } else {
                        newParent.append(sourceItem)
                    }
                }
                reloadData()
                self.onChange(list)
                options.onMoveElement(sourceItem)
                return true
            case .intoContainer(let targetIndex):
                let (oldParent, oldIndex) = relativePosition(for: sourceItem)
                if let oldParent = oldParent as? DataNodeParent {
                    oldParent.remove(at: oldIndex)
                } else {
                    list.remove(at: oldIndex)
                }
                if let targetIndex = targetIndex {
                    if oldParent == nil && oldIndex < targetIndex {
                        list.insert(sourceItem, at: targetIndex - 1)
                    } else {
                        list.insert(sourceItem, at: targetIndex)
                    }
                } else {
                    list.append(sourceItem)
                }
                reloadData()
                self.onChange(list)
                options.onMoveElement(sourceItem)
                return true
            default: break
            }

//            if let onDropElement = options.onDropElement {
//                let targetItem = item as? Element
//                return onDropElement(sourceItem, targetItem, index)
//            } else {
//                list.remove(at: sourceIndex)
//
//                if sourceIndex < index {
//                    list.insert(sourceItem, at: index - 1)
//                } else {
//                    list.insert(sourceItem, at: index)
//                }
//
//                return true
//            }
        }

        return false
    }

    // </DragAndDrop>

}

class ListEditor<Element>: NSView where Element: DataNode {

    enum Option {
        case onAddElement(() -> Void)
        case onRemoveElement((Element) -> Void)
        case onMoveElement((Element) -> Void)
        case onContextMenu((Element) -> [NSMenuItem])
        case onDropElement((Element, Element?, Int) -> Bool)
        case viewFor((Element) -> NSView)
        case backgroundColor(NSColor)
        case drawsTopBorder(Bool)
    }

    struct Options {
        var onAddElement: () -> Void = {}
        var onRemoveElement: (Element) -> Void = {_ in}
        var onMoveElement: (Element) -> Void = {_ in}
        var onContextMenu: ((Element) -> [NSMenuItem])?
        var onDropElement: ((Element, Element?, Int) -> Bool)?
        var viewFor: (Element) -> NSView = {_ in CSStatementView(frame: NSRect.zero, components: [])}
        var backgroundColor = NSColor.clear
        var drawsTopBorder = false

        mutating func merge(options: [Option]) {
            options.forEach({ option in
                switch option {
                case .onAddElement(let f): onAddElement = f
                case .onRemoveElement(let f): onRemoveElement = f
                case .onMoveElement(let f): onMoveElement = f
                case .onContextMenu(let f): onContextMenu = f
                case .onDropElement(let f): onDropElement = f
                case .viewFor(let f): viewFor = f
                case .backgroundColor(let value): backgroundColor = value
                case .drawsTopBorder(let value): drawsTopBorder = value
                }
            })
        }

        init(_ options: [Option]) {
            merge(options: options)
        }
    }

    var listView: ListView<Element>

    func reloadData() {
        listView.stopEditing()

        // Async to fix a crash. Without this, clicking the table view when a text field is active
        // will crash.
        DispatchQueue.main.async {
            self.listView.reloadData()
        }
    }

    func select(item: Element, ensureVisible: Bool) {
        listView.select(item: item, ensureVisible: ensureVisible)
    }

    func renderScrollView() -> NSView {
        let scrollView = NSScrollView(frame: frame)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(listView)
        scrollView.documentView = listView
        scrollView.hasVerticalRuler = true
        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false

        return scrollView
    }

    func renderToolbar() -> NSView {
        let toolbar = NSView()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.backgroundFill = NSColor.controlBackgroundColor.cgColor
        toolbar.addBorderView(to: .top, color: NSSplitView.defaultDividerColor.cgColor)

        return toolbar
    }

    func renderPlusButton() -> Button {
        let button = Button(frame: NSRect(x: 0, y: 0, width: 24, height: 23))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.image = NSImage.init(named: NSImage.Name.addTemplate)!
        button.bezelStyle = .smallSquare
        button.setButtonType(.momentaryPushIn)
        button.isBordered = false

        return button
    }

    func renderMinusButton() -> Button {
        let button = Button(frame: NSRect(x: 0, y: 0, width: 24, height: 23))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.image = NSImage.init(named: NSImage.Name.removeTemplate)!
        button.bezelStyle = .smallSquare
        button.setButtonType(.momentaryPushIn)
        button.isBordered = false

        return button
    }

    var list: [Element] {
        get { return listView.list }
        set { listView.list = newValue }
    }

    var onChange: ([Element]) -> Void = {_ in }

    init(frame frameRect: NSRect, options list: [Option]) {
        let options = Options(list)

        listView = ListView<Element>(frame: frameRect, options: options)

        super.init(frame: NSRect.zero)

//        listView.listEditor = self

        // Create views

        let toolbar = renderToolbar()

        let scrollView = renderScrollView()
        let plusButton = renderPlusButton()
        let minusButton = renderMinusButton()

        toolbar.addSubview(plusButton)
        toolbar.addSubview(minusButton)
        addSubview(toolbar)
        addSubview(scrollView)

        if options.drawsTopBorder {
            addBorderView(to: .top, color: NSSplitView.defaultDividerColor.cgColor)
        }

        // Constraints

        constrain(to: scrollView, [.left, .width])
        scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: toolbar.topAnchor).isActive = true

        constrain(to: toolbar, [.bottom, .left, .width])
        toolbar.constrain(.height, as: 24)

        plusButton.leftAnchor.constraint(equalTo: toolbar.leftAnchor).isActive = true
        plusButton.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor).isActive = true
        plusButton.heightAnchor.constraint(equalTo: toolbar.heightAnchor).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 24).isActive = true

        minusButton.leftAnchor.constraint(equalTo: plusButton.rightAnchor).isActive = true
        minusButton.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor).isActive = true
        minusButton.heightAnchor.constraint(equalTo: toolbar.heightAnchor).isActive = true
        minusButton.widthAnchor.constraint(equalToConstant: 24).isActive = true

        // Event handlers

        minusButton.onPress = { [unowned self] in
            guard let item = self.listView.selectedItem as? Element else { return }
            options.onRemoveElement(item)
        }

        plusButton.onPress = options.onAddElement

        listView.onChange = { [unowned self] value in
            self.onChange(value)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ListEditor {
    func add(element: Element, at index: Int? = nil) {
        if let index = index {
            list.insert(element, at: index)
        } else {
            list.append(element)
        }

        reloadData()
        select(item: element, ensureVisible: true)

        self.onChange(list)
    }
}

extension ListEditor where Element: DataNodeParent {
    func add(element: Element, to: Element? = nil, at index: Int? = nil) {
        if let to = to {
            if let index = index {
                to.insert(element, at: index)
            } else {
                to.append(element)
            }
        } else {
            if let index = index {
                list.insert(element, at: index)
            } else {
                list.append(element)
            }
        }
        reloadData()
        select(item: element, ensureVisible: true)

        self.onChange(list)
    }

    func remove(element: Element) {
        let (parent, index) = listView.relativePosition(for: element)

        if let parent = parent {
            parent.remove(at: index)
        } else {
            list.remove(at: index)
        }

        reloadData()

        self.onChange(list)
    }
}

extension ListEditor where Element: DataNodeCopying {
    func duplicate(element: Element) {
        let (_, index) = listView.relativePosition(for: element)
        let copy = Element(element.toData())
        add(element: copy, at: index + 1)
    }
}

extension ListEditor where Element: DataNodeParent, Element: DataNodeCopying {
    func duplicate(element: Element) {
        let (parent, index) = listView.relativePosition(for: element)
        let copy = Element(element.toData())
        add(element: copy, to: parent, at: index + 1)
    }
}

//extension MenuProvider {
//    func defaultMenu<Element>(for listEditor: ListEditor<Element>) -> [NSMenuItem] {
//        var items: [NSMenuItem] = []
//        
//        if let item = self as? DataNodeCopying, let listEditor = listEditor as? ListEditor<DataNodeCopying> {
//        }
//        
//        return items
//    }
//}
//
