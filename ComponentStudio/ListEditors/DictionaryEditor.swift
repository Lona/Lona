//
//  DictionaryEditor.swift
//  ComponentStudio
//
//  Created by devin_abbott on 11/13/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

class DictionaryEditor: NSView, CSControl {
    
    class DictionaryItem: DataNode {
        var name: String = "name"
        var value: CSValue = CSUndefinedValue
        
        init(name: String, value: CSValue) {
            self.name = name
            self.value = value
        }
        
        func childCount() -> Int { return 0 }
        func child(at index: Int) -> Any { return 0 }
    }
    
    var value: CSValue
    
    var onChange: (CSValue) -> Void
    
    var data: CSData {
        get { return value.data }
        set { value = CSValue(type: value.type, data: newValue) }
    }
    
    var onChangeData: (CSData) -> Void
    
    var editor: ListEditor<DictionaryItem>? = nil
    
    func setState(value: CSValue) {
        self.value = value
        
        self.onChange(value)
        self.onChangeData(value.data)
    }
    
    init(
        value: CSValue = CSEmptyDictionaryValue,
        onChange: @escaping CSValueChangeHandler = CSValueDefaultChangeHandler,
        onChangeData: @escaping CSDataChangeHandler = CSDataDefaultChangeHandler,
        layout: [CSConstraint] = []
    ) {
        self.value = value
        self.onChange = onChange
        self.onChangeData = onChangeData
        
        super.init(frame: NSRect.zero)
        
        CSConstraint.apply(layout, to: self)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        var editor: ListEditor<DictionaryItem>? = nil
        
        editor = ListEditor<DictionaryItem>(frame: frame, options: [
            .onAddElement({
                let nextKey = self.remainingKeys(from: self.value).first ?? "none"
                let nextType = self.typeFor(key: nextKey) ?? CSType.string
                let defaultItem = DictionaryItem(name: nextKey, value: CSValue(type: nextType, data: CSValue.exampleValue(for: nextType).data))
                
                guard let editor = self.editor else { return }
                
                editor.list.append(defaultItem)
                editor.reloadData()
                editor.select(item: defaultItem, ensureVisible: true)
                
                self.setState(value: self.dictionaryValue(from: editor.list))
            }),
            .onRemoveElement({ item in
                guard let editor = self.editor else { return }
                
                if let index = editor.list.index(where: { $0 === item }) {
                    editor.list.remove(at: index)
                }
                
                editor.reloadData()
                
                self.setState(value: self.dictionaryValue(from: editor.list))
            }),
            .viewFor({ item in
                let frame = NSRect(x: 0, y: 0, width: 2000, height: 26)
                
                let components: [CSStatementView.Component] = [
                    .text("Set"),
                    .value("name", CSValue(type: self.remainingKeysEnum(from: self.value, ensuringOption: item.name), data: CSData.String(item.name)), []),
                    .text("to"),
                    .value("value", CSValue(type: item.value.type, data: item.value.data), []),
                    ]
                
                let cell = CSStatementView(
                    frame: frame,
                    components: components
                )
                
                cell.onChangeValue = { name, value, _ in
                    switch name {
                    case "name":
                        item.name = value.data.stringValue
                        
                        if let type = self.typeFor(key: item.name) {
                            item.value = item.value.cast(to: type)
                        }
                    case "value":
                        item.value = value
                    default:
                        break
                    }
                    
                    guard let editor = self.editor else { return }
                    
                    editor.reloadData()
                    
                    self.setState(value: self.dictionaryValue(from: editor.list))
                }
                
                return cell
            })
        ])
        
        if let editor = editor {
            editor.translatesAutoresizingMaskIntoConstraints = false
            editor.list = DictionaryEditor.listValue(from: value)
            editor.reloadData()
            
            addSubviewStretched(subview: editor)
        }
        
        self.editor = editor
    }
    
    func typeFor(key: String) -> CSType? {
        guard case CSType.dictionary(let schema) = self.value.type else { return nil }
        guard let record = schema[key] else { return nil }
        return record.type
    }
    
    func remainingKeys(from dictionary: CSValue, ensuringOption currentKey: String? = nil) -> [String] {
        guard case CSType.dictionary(let schema) = value.type else { return [] }
        
        var keys = schema.enumerated().map({ item -> String? in
            let key = item.element.key
            
            // If there's already a value, we don't want to include this key
            if dictionary.data[key] != nil { return nil }
            
            return key
        }).flatMap({ $0 })
        
        // If we didn't include this key
        if let currentKey = currentKey, dictionary.data[currentKey] != nil {
            keys.append(currentKey)
        }
        
        return keys
    }
    
    func remainingKeysEnum(from dictionary: CSValue, ensuringOption currentKey: String? = nil) -> CSType {
        let values: [CSValue] = remainingKeys(from: dictionary, ensuringOption: currentKey).map({ key in
            return CSValue(type: CSType.string, data: CSData.String(key))
        })
        
        return CSType.enumeration(values)
    }
    
    static func listValue(from dictionary: CSValue) -> [DictionaryItem] {
        guard case CSType.dictionary(let schema) = dictionary.type else { return [] }
        
        return schema.enumerated().map({ item -> DictionaryItem? in
            let key = item.element.key
            guard let data = dictionary.data[key] else { return nil }
            
            let value = CSValue(type: item.element.value.type, data: data)
            return DictionaryItem(name: key, value: value)
        }).flatMap({ $0 })
    }
    
    func dictionaryValue(from list: [DictionaryItem]) -> CSValue {
        let data: [String: CSData] = list.key {
            (item) -> (key: String, value: CSData) in
            return (key: item.name, value: item.value.data)
        }
        
        return CSValue(type: self.value.type, data: CSData.Object(data))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

