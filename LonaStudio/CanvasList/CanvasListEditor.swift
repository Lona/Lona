//
//  CanvasListEditor.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/26/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class CanvasListEditor: NSOutlineView, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate {
    
    func setup() {
        let columnVisible = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Visible"))
        columnVisible.width = 20
        columnVisible.title = ""
        
        let columnName = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Name"))
        columnName.width = 150
        columnName.title = "Name"
        
        let columnWidth = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Width"))
        columnWidth.width = 100
        columnWidth.title = "Width"
        
        let columnHeightMode = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "HeightMode"))
        columnHeightMode.width = 100
        columnHeightMode.title = "Height Mode"
        
        let columnHeight = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Height"))
        columnHeight.width = 100
        columnHeight.title = "Height"
        
        let columnBackground = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Background"))
        columnBackground.width = 120
        columnBackground.title = "Background"
        
        let columnScale = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Scale"))
        columnScale.width = 60
        columnScale.title = "Export At"
        
        let columnParameters = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "Parameters"))
        columnParameters.width = 120
        columnParameters.title = "Default Parameters"
        
        self.addTableColumn(columnVisible)
        self.addTableColumn(columnName)
        self.addTableColumn(columnWidth)
        self.addTableColumn(columnHeightMode)
        self.addTableColumn(columnHeight)
        self.addTableColumn(columnScale)
        self.addTableColumn(columnBackground)
        self.addTableColumn(columnParameters)
        
        self.dataSource = self
        self.delegate = self
        
        self.focusRingType = .none
        self.rowSizeStyle = .medium
        
        self.registerForDraggedTypes([NSPasteboard.PasteboardType(rawValue: "component.canvas")])
        
        self.reloadData()
        
        self.doubleAction = #selector(doubleClick(sender:))
    }
    
    var component: CSComponent? = nil
    
    @objc func doubleClick(sender: AnyObject) {
        editColumn(clickedColumn, row: clickedRow, with: nil, select: true)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    var canvasList: [Canvas] = [Canvas]() {
        didSet {
            self.reloadData()
            onChange(canvasList)
        }
    }
    
    var onChange: ([Canvas]) -> Void = {_ in }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return canvasList.count
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return canvasList[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0
    }

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let canvas = item as! Canvas
        let cellView = NSTableCellView()
        
        switch tableColumn!.identifier {
        case "Visible":
            let field = CSValueField(value: CSValue(type: CSType.bool, data: CSData.Bool(canvas.visible)))
            field.onChangeData = { value in
                canvas.visible = value.boolValue
                self.onChange(self.canvasList)
            }
            return field.view
        case "Name":
            let field = TextField()
            field.isBordered = false
            field.drawsBackground = false
            field.value = canvas.name
            
            field.onChange = { value in
                canvas.name = value
                self.onChange(self.canvasList)
            }
            
            cellView.textField = field
            cellView.addSubview(field)
        case "Width":
            let field = NumberField()
            field.isBordered = false
            field.drawsBackground = false
            field.value = canvas.width
            
            cellView.textField = field
            cellView.addSubview(field)
            
            field.onChange = { value in
                canvas.width = value
                self.onChange(self.canvasList)
            }
            
            return cellView
        case "Height":
            let field = NumberField()
            field.isBordered = false
            field.drawsBackground = false
            field.isEditable = true
            field.value = canvas.height
            
            cellView.textField = field
            cellView.addSubview(field)
            
            field.onChange = { value in
                canvas.height = value
                self.onChange(self.canvasList)
            }
            
            return cellView
        case "HeightMode":
            let field = PopupField(frame: NSRect.zero, values: ["Exactly", "At Least"], initialValue: canvas.heightMode)
            field.isBordered = false
            
            field.onChange = { value in
                canvas.heightMode = value
                self.onChange(self.canvasList)
            }
            
            return field
        case "Scale":
            let field = PopupField(frame: NSRect.zero, values: ["1x", "2x"], initialValue: String(format: "%.0fx", canvas.exportScale))
            field.isBordered = false
            
            field.onChange = { value in
                canvas.exportScale = value == "2x" ? 2 : 1
                self.onChange(self.canvasList)
            }
            
            return field
        case "Background":
            let colorValue = CSValue(type: CSColorType, data: CSData.String(canvas.backgroundColor))
            let field = CSValueField(value: colorValue)
            field.onChangeData = { value in
                canvas.backgroundColor = value.stringValue
                self.onChange(self.canvasList)
            }
            return field.view
        case "Parameters":
            guard let component = component else { break }
            
            let field = CSValueField(value: CSValue(type: component.parametersType(), data: canvas.parameters))
            field.onChangeData = { value in
                canvas.parameters = value
                self.onChange(self.canvasList)
            }
            return field.view
        default:
            break
        }
        
        return cellView
    }
    
    var selectedItem: Canvas? {
        return item(atRow: selectedRow) as! Canvas?
    }
    
    override func keyDown(with event: NSEvent) {
        let characters = event.charactersIgnoringModifiers!
        
        if (characters == String(Character(UnicodeScalar(NSDeleteCharacter)!))) {
            if selectedItem == nil { return }
            
            canvasList.remove(at: selectedRow)
        }
    }
    
    // <DragAndDrop>
    
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        
        let pasteboardItem = NSPasteboardItem()
        
        let index = outlineView.row(forItem: item)
            
        pasteboardItem.setString(String(index), forType: NSPasteboard.PasteboardType(rawValue: "component.canvas"))
        
        return pasteboardItem
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        
        // If we're dragging onto an item (item != nil),
        // or into the list but not above or below a specific item (index == -1)
        if item != nil || index == -1 {
            return NSDragOperation()
        }
        
        return NSDragOperation.move
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        
        let sourceIndexString = info.draggingPasteboard().string(forType: NSPasteboard.PasteboardType(rawValue: "component.canvas"))
        
        if sourceIndexString != nil, let sourceIndex = Int(sourceIndexString!) {
            
            let sourceItem = outlineView.item(atRow: sourceIndex) as! Canvas
            
            canvasList.remove(at: sourceIndex)
            
            if sourceIndex < index {
                canvasList.insert(sourceItem, at: index - 1)
            } else {
                canvasList.insert(sourceItem, at: index)
            }
            
            return true
        }
        
        return false
    }
    
    // </DragAndDrop>
    
}
