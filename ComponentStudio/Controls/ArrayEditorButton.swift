//
//  ArrayEditorButton.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

class ArrayEditorButton: NSButton, CSControl, NSPopoverDelegate {
    
    var data: CSData {
        get { return value.toData() }
        set { value = CSValue(newValue) }
    }
    
    var onChangeData: CSControl.Handler = { _ in }
    
    var value: CSValue = CSValue(type: CSType.array(CSType.any), data: CSData.Array([])) {
        didSet {
            setButtonTitle(value: "[\(listValue(from: value).count) Values]")
        }
    }
    
    var itemType: CSType {
        guard case CSType.array(let type) = value.type else { return CSType.undefined }
        return type
    }
    
    var onChange: (CSValue) -> Void = {_ in}
    
    func setup() {
        action = #selector(handleClick)
        target = self
        
        setButtonType(.momentaryPushIn)
        imagePosition = .imageLeft
        alignment = .left
        bezelStyle = .rounded
        
        setButtonTitle(value: "[0 Values]")
    }
    
    func setButtonTitle(value: String) {
        title = value
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    class ArrayItem: DataNode {
        var value: CSValue = CSUndefinedValue
        
        init(value: CSValue) {
            self.value = value
        }
        
        func childCount() -> Int { return 0 }
        func child(at index: Int) -> Any { return 0 }
    }
    
    func listValue(from array: CSValue) -> [ArrayItem] {
        return array.data.arrayValue.map({ item in ArrayItem(value: CSValue(type: itemType, data: item)) })
    }
    
    func arrayValue(from list: [ArrayItem]) -> CSValue {
        let data = list.map({ item in item.value.data })
        return CSValue(type: self.value.type, data: CSData.Array(data))
    }
    
    var editor: ListEditor<ArrayItem>? = nil
    
    func popoverWillClose(_ notification: Notification) {
        self.onChange(self.value)
        self.onChangeData(self.value.toData())
    }
    
    func showPopover() {
        Swift.print("Show", self.value)
        
        let frame = NSRect(x: 0, y: 0, width: 250, height: 400)
        
        editor = ListEditor<ArrayItem>(frame: frame, options: [
            .onAddElement({
                let defaultItem = ArrayItem(value: CSValue.exampleValue(for: self.itemType))
                
                guard let editor = self.editor else { return }
                
                editor.list.append(defaultItem)
                editor.reloadData()
                editor.select(item: defaultItem, ensureVisible: true)
                self.value = self.arrayValue(from: editor.list)
            }),
            .onRemoveElement({ item in
                guard let editor = self.editor else { return }
                
                if let index = editor.list.index(where: { $0 === item }) {
                    editor.list.remove(at: index)
                }
                
                editor.reloadData()
                self.value = self.arrayValue(from: editor.list)
            }),
            .viewFor({ item in
                let frame = NSRect(x: 0, y: 0, width: 2000, height: 26)
                
                let components: [CSStatementView.Component] = [
                    .value("value", CSValue(type: item.value.type, data: item.value.data), []),
                    ]
                
                let cell = CSStatementView(
                    frame: frame,
                    components: components
                )
                
                cell.onChangeValue = { name, value, _ in
                    switch name {
                    case "value":
                        item.value = value
                    default:
                        break
                    }
                    
                    guard let editor = self.editor else { return }
                    
                    editor.reloadData()
                    self.value = self.arrayValue(from: editor.list)
                }
                
                return cell
            })
            ])
        
        let vc = NSViewController()
        vc.view = editor!
        
        editor!.list = listValue(from: value)
        editor!.reloadData()
        
        let popover = NSPopover()
        popover.delegate = self
        popover.contentSize = NSSize(width: 300, height: 200)
        popover.behavior = .semitransient
        popover.animates = false
        popover.contentViewController = vc
        
        popover.show(relativeTo: NSRect.zero, of: self, preferredEdge: .maxY)
    }
    
    func handleClick() {
        showPopover()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

