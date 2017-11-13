//
//  DictionaryEditorButton.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

class DictionaryEditorButton: NSButton, CSControl, NSPopoverDelegate {
    
    var data: CSData {
        get { return value.toData() }
        set { value = CSValue(newValue) }
    }
    
    var onChangeData: CSDataChangeHandler
    
    var value: CSValue {
        didSet {
            updateTitle()
        }
    }
    
    var onChange: (CSValue) -> Void = {_ in}
    
    init(
        value: CSValue,
        onChangeData: @escaping CSDataChangeHandler,
        frame frameRect: NSRect = NSRect.zero
    ) {
        self.value = value
        self.onChangeData = onChangeData
        
        super.init(frame: frameRect)
        
        action = #selector(handleClick)
        target = self
        
        setButtonType(.momentaryPushIn)
        imagePosition = .imageLeft
        alignment = .left
        bezelStyle = .rounded
        
        updateTitle()
    }
    
    func updateTitle() {
        let count = DictionaryEditor.listValue(from: value).count
        title = "[\(count) Values]"
    }
    
    func popoverWillClose(_ notification: Notification) {
        self.onChange(self.value)
        self.onChangeData(self.value.data)
    }
    
    var editor: DictionaryEditor? = nil
    
    func showPopover() {
        Swift.print("Show", self.value)
        
        let editor = DictionaryEditor(
            value: value,
            onChange: { self.value = $0 },
            layout: CSConstraint.size(width: 300, height: 200)
        )
        
        let viewController = NSViewController(view: editor)
        let popover = NSPopover(contentViewController: viewController, delegate: self)
        
        popover.show(relativeTo: NSRect.zero, of: self, preferredEdge: .maxY)
        
        self.editor = editor
    }
    
    func handleClick() {
        showPopover()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
