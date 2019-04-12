//
//  LayerListOutlineView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 5/7/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation
import FileTree

// MARK: - NSPasteboard.PasteboardType

public extension NSPasteboard.PasteboardType {
    static let lonaLayerTemplateType = NSPasteboard.PasteboardType(rawValue: "lona.layerTemplateType")
    static let lonaLayerIndex = NSPasteboard.PasteboardType(rawValue: "lona.layerIndex")
}

// MARK: - LayerListOutlineView

final class LayerListOutlineView: NSOutlineView, NSTextFieldDelegate {

    fileprivate struct Constants {
        static let CheckBoxTag = 20
    }

    fileprivate var shouldRenderOnSelectionChange = true
    fileprivate var previousRow = -1
    fileprivate var dataRoot: CSLayer? {
        return component?.rootLayer
    }

    var onChange: (() -> Void)?

    var onSelectLayer: ((CSLayer?) -> Void)?

    fileprivate var selectedLayer: CSLayer? {
        guard let item = item(atRow: selectedRow) else { return nil }
        return item as? CSLayer
    }

    fileprivate var selectedLayerOrRoot: CSLayer {
        return selectedLayer ?? (item(atRow: 0) as! CSLayer)
    }

    static func componentName(for url: URL) -> String {
        return url.deletingPathExtension().lastPathComponent
    }

    // MARK: - Lifecycle

    init() {
        super.init(frame: NSRect.zero)

        initCommon()
        setupDefaultColumns()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    var component: CSComponent? {
        didSet {
            render(fullRender: true)
        }
    }

    func addLayer(layer newLayer: CSLayer) {
        let targetLayer = selectedLayerOrRoot
        var parent: CSLayer!
        var index: Int!

        if targetLayer === self.dataRoot {
            parent = targetLayer
            index = parent.children.count
        } else {
            parent = self.parent(forItem: targetLayer) as? CSLayer
            index = self.childIndex(forItem: targetLayer) + 1
        }

        // Undo
        let oldChildren = parent.children
        UndoManager.shared.run(
            name: "Add",
            execute: {[unowned self] in
                parent.insertChild(newLayer, at: index)
                self.relayoutLayerList(newLayer)
                self.onChange?()
            },
            undo: {[unowned self] in
                parent.children = oldChildren
                self.relayoutLayerList()
                self.onChange?()
            }
        )
    }

    override func menu(for event: NSEvent) -> NSMenu? {
        let point = convert(event.locationInWindow, from: nil)
        let index = row(at: point)
        guard let layer = item(atRow: index) as? CSLayer else { return nil }

        select(item: layer)

        return buildMenu(for: layer)
    }

    func render(fullRender: Bool = false) {
        let selection = selectedRow

        // Editing during a reload can cause a crash
        stopEditing()
        reloadData()

        // TODO Is this what we want here? Won't this get rid of all expand/collapse
        expandItem(dataRoot, expandChildren: true)

        if fullRender {
            select(row: selection)
        } else {
            makeChangeWithoutRendering {
                // Currently rendering resets the selection, so we set it again manually
                select(row: selection)
            }
        }
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        selectedLayer?.name = (obj.object as! NSTextField).stringValue
        render()
    }
}

// MARK: - Private

extension LayerListOutlineView {

    private func relayoutLayerList(_ newLayer: CSLayer? = nil) {
        render()

        // Selection
        if let newLayer = newLayer {
            let newLayerIndex = row(forItem: newLayer)
            let selection: IndexSet = [newLayerIndex]
            selectRowIndexes(selection, byExtendingSelection: false)
        }

        render()
    }

    fileprivate func initCommon() {
        backgroundColor = NSColor.clear
        wantsLayer = true
        columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
        rowSizeStyle = NSTableView.RowSizeStyle.small

        dataSource = self
        delegate = self

        focusRingType = .none
        intercellSpacing = NSSize(width: 10, height: 10)

        registerForDraggedTypes([.lonaLayerIndex, .lonaLayerTemplateType, .fileTreeURL])

        headerView = nil
        doubleAction = #selector(doubleClick(sender:))
    }

    fileprivate func setupDefaultColumns() {

        // Data
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "layer"))
        column.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
        column.title = "Song title"

        // Visible
        let visibleColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "visible"))
        visibleColumn.maxWidth = 20

        addTableColumn(column)
        addTableColumn(visibleColumn)
        outlineTableColumn = column
    }

    @objc fileprivate func doubleClick(sender: AnyObject) {
        editColumn(clickedColumn, row: clickedRow, with: nil, select: true)
    }

    fileprivate func buildMenu(for layer: CSLayer) -> NSMenu {
        let menu = NSMenu(title: "Test")

        menu.addItem(withTitle: "Duplicate", action: #selector(duplicateAction(menuItem:)), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "New Component from Layer", action: #selector(extractComponentAction(menuItem:)), keyEquivalent: "")

        if layer is CSComponentLayer {
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: "Open Component", action: #selector(openComponentAction(menuItem:)), keyEquivalent: "")
            menu.addItem(withTitle: "Fork Component", action: #selector(forkComponentAction(menuItem:)), keyEquivalent: "")
            menu.addItem(withTitle: "Extract Layers", action: #selector(extractLayersAction(menuItem:)), keyEquivalent: "")
        }

        menu.items.forEach({ $0.representedObject = layer })

        return menu
    }

    fileprivate func add(layer newLayer: CSLayer, to targetLayer: CSLayer) {
        let targetRow = row(forItem: targetLayer)

        // Root layer
        if targetRow == 0 {
            targetLayer.appendChild(newLayer)
        } else {
            let parentLayer = parent(forItem: targetLayer) as! CSLayer
            let index = childIndex(forItem: targetLayer)
            parentLayer.insertChild(newLayer, at: index + 1)
        }
    }

    fileprivate func replace(layer oldLayer: CSLayer, with newLayer: CSLayer) {
        // TODO Should we be able to replace the root?
        if row(forItem: oldLayer) == 0 { return }

        let parent = self.parent(forItem: oldLayer) as! CSLayer
        parent.children = parent.children.map({ $0 === oldLayer ? newLayer : $0 })

        onChange?()
    }

    @discardableResult
    fileprivate func duplicate(layer: CSLayer) -> CSLayer {
        let copy = layer.copy() as! CSLayer

        if let component = component {
            var existingNames: [String] = []

            copy.descendantLayers.forEach { child in
                let name = component.getNewLayerName(basedOn: child.name, ignoring: existingNames)
                existingNames.append(name)
                child.name = name
            }
        }

        add(layer: copy, to: layer)

        onChange?()

        return copy
    }

    @objc
    fileprivate func duplicateAction(menuItem: NSMenuItem) {
        let layer = menuItem.representedObject as! CSLayer
        let copy = duplicate(layer: layer)

        select(item: copy)
    }

    @objc
    fileprivate func openComponentAction(menuItem: NSMenuItem) {
        guard
            let layer = menuItem.representedObject as? CSComponentLayer,
            case CSLayer.LayerType.custom(let name) = layer.type,
            let url = LonaModule.current.componentFile(named: name)?.url
        else {
            return
        }

        let documentController = NSDocumentController.shared

        documentController.openDocument(withContentsOf: url, display: true) { (_, documentWasAlreadyOpen, error) in
            if error != nil {
                Swift.print("An error occurred")
            } else {
                if documentWasAlreadyOpen {
                    Swift.print("documentWasAlreadyOpen: true")
                } else {
                    Swift.print("documentWasAlreadyOpen: false")
                }
            }
        }
    }

    fileprivate func requestSaveFileURL() -> URL? {
        let dialog = NSSavePanel()

        dialog.title                   = "Save .component file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canCreateDirectories    = true
        dialog.allowedFileTypes        = ["component"]

        if dialog.runModal() == NSApplication.ModalResponse.OK {
            return dialog.url
        } else {
            // User clicked on "Cancel"
            return nil
        }
    }

    @objc
    fileprivate func extractComponentAction(menuItem: NSMenuItem) {
        let layer = menuItem.representedObject as! CSLayer

        guard let url = requestSaveFileURL() else { return }

        let documentController = NSDocumentController.shared

        let document = ComponentDocument()

        document.component = CSComponent(name: layer.name, canvas: component?.canvas ?? [], rootLayer: layer, parameters: [], cases: [CSCase.defaultCase], logic: [], types: [], config: component?.config ?? CSData.Object([:]), metadata: component?.metadata ?? CSData.Object([:]))

        Swift.print("Writing to", url)

        do {
            try document.write(to: url, ofType: ".component")
        } catch {
            return
        }

        documentController.openDocument(withContentsOf: url, display: true, completionHandler: { (_, _, _) in
            let componentLayer = CSComponentLayer.make(from: url)
            self.replace(layer: layer, with: componentLayer)

            self.onChange?()
        })
    }

    @objc
    fileprivate func forkComponentAction(menuItem: NSMenuItem) {
        guard
            let layer = menuItem.representedObject as? CSComponentLayer,
            case CSLayer.LayerType.custom(let name) = layer.type,
            let existingComponent = LonaModule.current.component(named: name)
        else {
            return
        }

        guard let url = requestSaveFileURL() else { return }

        let document = ComponentDocument()
        document.component = existingComponent

        do {
            try document.write(to: url, ofType: ".component")
        } catch {
            return
        }

        NSDocumentController.shared.openDocument(
            withContentsOf: url, display: true, completionHandler: { (document, _, _) in
            layer.component = (document as! ComponentDocument).component!
            layer.name = CSComponent.componentName(from: url)
            layer.type = CSLayer.LayerType.custom(url.deletingPathExtension().lastPathComponent)
            self.onChange?()
        })
    }

    @objc
    fileprivate func extractLayersAction(menuItem: NSMenuItem) {
        let layer = menuItem.representedObject as! CSComponentLayer

        replace(layer: layer, with: layer.component.rootLayer)
    }

    override func keyDown(with event: NSEvent) {
        let characters = event.charactersIgnoringModifiers!

        if characters == String(Character(UnicodeScalar(NSEvent.SpecialKey.delete.rawValue)!)) {
            guard let targetLayer = selectedLayer else { return }
            if targetLayer === dataRoot { return }

            guard let parent = self.parent(forItem: targetLayer) as? CSLayer else { return }

            // Undo
            let oldChildren = parent.children
            let children = parent.children.filter({ $0 !== targetLayer })
            UndoManager.shared.run(name: "Delete", execute: {[unowned self] in
                parent.children = children
                self.relayoutLayerList()
                self.onChange?()
                self.onSelectLayer?(nil)
            }, undo: {[unowned self] in
                parent.children = oldChildren
                self.relayoutLayerList()
                self.onChange?()
                self.select(item: targetLayer)
            })

            return
        }

        super.keyDown(with: event)
    }
}

// MARK: - NSOutlineViewDataSource

extension LayerListOutlineView: NSOutlineViewDelegate, NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return 1
        } else {
            let node = item as! DataNode?
            return node!.childCount()
        }
    }
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return dataRoot ?? CSLayer()
        } else {
            let node = item as! DataNode
            return node.child(at: index)
        }
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0
    }

    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 18
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let cellView = NSTableCellView()

        switch tableColumn!.identifier.rawValue {
        case "layer":
            if let layer = item as? CSLayer {
                let textField = NSTextField()

                textField.isEditable = true
                textField.delegate = self
                textField.isBordered = false
                textField.drawsBackground = false
                textField.stringValue = layer.name

                if case CSLayer.LayerType.custom = layer.type {
                    textField.textColor = NSColor.parse(css: "rgb(101,53,160)")!
                }

                cellView.textField = textField
                cellView.addSubview(textField)

                if #available(OSX 10.12, *) {
                    if let image = LayerThumbnail.image(for: layer) {
                        let imageView = NSImageView(image: image)
                        cellView.imageView = imageView
                        cellView.addSubview(imageView)
                    }
                }
            }
        case "visible":
            if let layer = item as? CSLayer {
                let checkbox = CheckboxField(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
                checkbox.value = layer.visible
                checkbox.onChange = {[unowned self] value in

                    let oldValue = layer.visible
                    UndoManager.shared.run(name: "Visible", execute: {[unowned self] in
                        layer.visible = value
                        checkbox.state = value ? .on : .off
                        self.onChange?()
                    }, undo: {[unowned self] in
                        layer.visible = oldValue
                        checkbox.state = oldValue ? .on : .off
                        self.onChange?()
                    })
                }
                cellView.addSubview(checkbox)
                checkbox.tag = Constants.CheckBoxTag
                checkbox.isHidden = true
            }
        default:
            break
        }

        return cellView
    }

    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {

        let pp = NSPasteboardItem()

        // working as expected here
        if let item = item as? DataNode {
            let index = outlineView.row(forItem: item)
            pp.setString(String(index), forType: .lonaLayerIndex)
        }

        return pp
    }

    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {

        if let sourceIndexString = info.draggingPasteboard.string(forType: .lonaLayerIndex),
            let sourceIndex = Int(sourceIndexString),
            let targetLayer = item as? CSLayer {

            // Can't move the root
            if sourceIndex == 0 { return NSDragOperation() }

            let sourceLayer = outlineView.item(atRow: sourceIndex) as! CSLayer

            // Don't allow an item to be dragged into itself
            if targetLayer === sourceLayer { return NSDragOperation() }

            // Don't allow an item to be dragged into its own subtree
            var parent = outlineView.parent(forItem: item) as! CSLayer?
            while parent != nil {
                if parent === sourceLayer { return NSDragOperation() }

                parent = outlineView.parent(forItem: parent) as! CSLayer?
            }

            return NSDragOperation.move
        }

        if let _ = info.draggingPasteboard.string(forType: .lonaLayerTemplateType),
            let _ = item as? CSLayer {

            return NSDragOperation.copy
        }

        if let urlString = info.draggingPasteboard.string(forType: .fileTreeURL),
            let url = URL(string: urlString),
            url.pathExtension == "component",
            let _ = item as? CSLayer {

            return NSDragOperation.copy
        }

        return NSDragOperation()
    }

    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {

        if let sourceIndexString = info.draggingPasteboard.string(forType: .lonaLayerIndex),
            let sourceIndex = Int(sourceIndexString) {
            //            print( "accept drop", item, "index", index, "drag index", sourceIndex)
            let sourceLayer = outlineView.item(atRow: sourceIndex) as! CSLayer
            let targetLayer = item as! CSLayer
            let renderFunc = {[unowned self] in
                self.render()
                self.onChange?()
            }
            let oldParent = sourceLayer.parent!
            let oldIndex = oldParent.children.firstIndex(where: { (layer) -> Bool in
                return layer === sourceLayer
            })!

            UndoManager.shared.run(name: "Append", execute: {
                sourceLayer.removeFromParent()

                // Index is -1 when item is dropped directly on another item, rather than above or below
                if index == -1 {
                    targetLayer.appendChild(sourceLayer)
                } else {
                    let insertIndex = (sourceLayer.parent === targetLayer && oldIndex >= 0 && oldIndex < index) ? index - 1 : index
                    targetLayer.insertChild(sourceLayer, at: insertIndex)
                }
                renderFunc()
            }, undo: {
                sourceLayer.removeFromParent()
                oldParent.insertChild(sourceLayer, at: oldIndex)
                renderFunc()
            })

            return true
        }

        func appendOrInsert(targetLayer: CSLayer, newLayer: CSLayer, at index: Int) {
            UndoManager.shared.run(name: "Append", execute: {
                if index == -1 {
                    targetLayer.appendChild(newLayer)
                } else {
                    targetLayer.insertChild(newLayer, at: index)
                }

                self.render()
                self.onChange?()
            }, undo: {
                newLayer.removeFromParent()

                self.render()
                self.onChange?()
            })

        }

        if let templateTypeString = info.draggingPasteboard.string(forType: .lonaLayerTemplateType),
            let targetLayer = item as? CSLayer,
            let component = component {

            let templateType = CSLayer.LayerType.init(from: templateTypeString)
            let newLayer = component.makeLayer(forType: templateType)

            appendOrInsert(targetLayer: targetLayer, newLayer: newLayer, at: index)

            return true
        }

        if let urlString = info.draggingPasteboard.string(forType: .fileTreeURL),
            let url = URL(string: urlString),
            url.pathExtension == "component",
            let targetLayer = item as? CSLayer,
            let component = component {

            let templateType = CSLayer.LayerType.custom(CSComponent.componentName(from: url))
            let newLayer = component.makeLayer(forType: templateType)

            appendOrInsert(targetLayer: targetLayer, newLayer: newLayer, at: index)

            return true
        }

        return false
    }

    func outlineViewSelectionDidChange(_ notification: Notification) {
        if previousRow >= 0 && previousRow < numberOfRows {
            let view = self.view(atColumn: 1, row: previousRow, makeIfNecessary: true)
            if let checkbox = view?.viewWithTag(Constants.CheckBoxTag), !checkbox.isHidden {
                checkbox.isHidden = true
            }
        }

        if selectedRow != -1 {
            let item = self.item(atRow: selectedRow) as? CSLayer

            // Don't allow hiding the root layer
            if selectedRow != 0 {
                let view = self.view(atColumn: 1, row: selectedRow, makeIfNecessary: true)
                if let checkbox = view?.viewWithTag(Constants.CheckBoxTag), checkbox.isHidden {
                    checkbox.isHidden = false
                }
            }

            if shouldRenderOnSelectionChange {
                self.onSelectLayer?(item)
            }
        } else {
            if shouldRenderOnSelectionChange {
                self.onSelectLayer?(nil)
            }
        }

        previousRow = selectedRow
    }

    fileprivate func makeChangeWithoutRendering(f: () -> Void) {
        shouldRenderOnSelectionChange = false
        f()
        shouldRenderOnSelectionChange = true
    }
}
