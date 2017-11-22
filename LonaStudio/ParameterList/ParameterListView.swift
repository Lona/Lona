//
//  listEditor.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/26/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class ParameterListView: NSOutlineView, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate {
    
    func setup() {
        let columnName = NSTableColumn(identifier: "Parameter")
        columnName.title = "Parameter"
        
        self.addTableColumn(columnName)
        self.outlineTableColumn = columnName
        
        self.dataSource = self
        self.delegate = self
        
        self.focusRingType = .none
        self.rowSizeStyle = .medium
        self.headerView = nil
        
        self.register(forDraggedTypes: ["component.parameter"])
        
        self.reloadData()
        
        columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        columnName.resizingMask = .autoresizingMask
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    var list: [CSParameter] = [CSParameter]() {
        didSet {
            self.reloadData()
            onChange(list)
        }
    }
    
    var onChange: ([CSParameter]) -> Void = {_ in }
    
    override func viewWillDraw() {
        sizeLastColumnToFit()
        super.viewWillDraw()
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return list.count
        }
        
        if let parameter = item as? CSParameter {
            return parameter.childCount()
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return list[index]
        }
        
        if let parameter = item as? CSParameter {
            return parameter.child(at: index)
        }
        
        // Should never get here
        Swift.print("Bad parameter child")
        return CSParameter()
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return self.outlineView(outlineView, numberOfChildrenOfItem: item) > 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        let frame = NSRect(x: 0, y: 0, width: 2000, height: 26)
        
        if let parameter = item as? CSParameter {
//            Swift.print("param", parameter.name, parameter.type.toString(), parameter.type)
            
            let defaultValueType = CSType.enumeration([
                CSValue(type: .string, data: .String("no default")),
                CSValue(type: .string, data: .String("default"))
            ])
            
            var components: [CSStatementView.Component] = [
                .text("Parameter"),
                .value("name", CSValue(type: .string, data: CSData.String(parameter.name)), []),
                .text("of type"),
                .value("type", CSValue(type: CSType.parameterType(), data: .String(parameter.type.toString())), []),
                .text("with"),
                .value("hasDefaultValue", CSValue(type: defaultValueType, data: parameter.hasDefaultValue ? .String("default") : .String("no default")), []),
            ]
            
            if (parameter.hasDefaultValue) {
                components.append(.text("of"))
                components.append(.value("defaultValue", parameter.defaultValue, []))
            }
            
            let cell = CSStatementView(
                frame: frame,
                components: components
            )
            
            cell.onChangeValue = { name, value, _ in
                switch name {
                case "name":
                    parameter.name = value.data.stringValue
                case "type":
                    parameter.type = CSType.from(string: value.data.stringValue)
                    
                    if parameter.hasDefaultValue {
                        parameter.defaultValue = parameter.defaultValue.cast(to: parameter.type)
                    }
                    
                    // TODO: Cast all cases to their new type (?)
//                    parameter.examples = parameter.examples.map({ $0.cast(to: parameter.type) })
                    break
                case "hasDefaultValue":
                    if value.data.stringValue == "no default" {
                        parameter.defaultValue = CSUndefinedValue
                    } else {
                        parameter.defaultValue = parameter.defaultValue.cast(to: parameter.type)
                    }
                case "defaultValue":
                    parameter.defaultValue = value
                default:
                    break
                }
                
                // Async to fix a crash. Without this, clicking the table view when a text field is active
                // will crash.
                DispatchQueue.main.async {
                    self.reloadData()
                }
                
                self.onChange(self.list)
            }
            
            return cell
        }
        
        return CSStatementView(frame: NSRect.zero, components: [])
    }
    
    
    var selectedItem: Any? {
        return item(atRow: selectedRow) 
    }
    
    override func mouseDown(with event: NSEvent) {
        let selfPoint = convert(event.locationInWindow, from: nil)
        let row = self.row(at: selfPoint)
        
        if (row >= 0) {
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
        
        if (characters == String(Character(UnicodeScalar(NSDeleteCharacter)!))) {
            if selectedItem == nil { return }

            if let parameter = selectedItem as? CSParameter {
                for (index, item) in list.enumerated() {
                    if item === parameter {
                        list.remove(at: index)
                        break
                    }
                }
            }
            
            self.reloadData()
            self.onChange(self.list)
        }
    }
    
    // <DragAndDrop>
    
    func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
        
        let pasteboardItem = NSPasteboardItem()
        
        let index = outlineView.row(forItem: item)
        
        pasteboardItem.setString(String(index), forType: "component.parameter")
        
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
        
        let sourceIndexString = info.draggingPasteboard().string(forType: "component.parameter")
        
        if sourceIndexString != nil, let sourceIndex = Int(sourceIndexString!) {
            
            let sourceItem = outlineView.item(atRow: sourceIndex) as! CSParameter
            
            list.remove(at: sourceIndex)
            
            if sourceIndex < index {
                list.insert(sourceItem, at: index - 1)
            } else {
                list.insert(sourceItem, at: index)
            }
            
            return true
        }
        
        return false
    }
    
    // </DragAndDrop>
    
}
