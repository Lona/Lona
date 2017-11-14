//
//  CaseList.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

fileprivate class CaseNode: DataNode {
    var item: CSCase = CSCase()
    
    func childCount() -> Int { return 0 }
    func child(at index: Int) -> Any { return 0 }
}

class CaseList {
    
    var component: CSComponent? = nil
    var editor: ListEditor<CSCase>? = nil
    
    var list: [CSCase] {
        get { return editor?.list ?? [] }
        set { editor?.list = newValue }
    }
    
    var onChange: ([CSCase]) -> Void {
        get { return editor?.onChange ?? {_ in}}
        set { editor?.onChange = newValue }
    }
    
    init(frame frameRect: NSRect) {
        editor = ListEditor<CSCase>(frame: frameRect, options: [
            ListEditor.Option.backgroundColor(NSColor.white),
            ListEditor.Option.drawsTopBorder(true),
            ListEditor.Option.onAddElement({ self.editor?.add(element: CSCase()) }),
            ListEditor.Option.onContextMenu({ item -> [NSMenuItem] in
                return [
                    NSMenuItem(title: "Duplicate", onClick: {
                        self.editor?.duplicate(element: item)
                    })
                ]
            }),
            ListEditor.Option.onRemoveElement({ item in
                guard let editor = self.editor else { return }
                
                if let index = editor.list.index(where: { $0 === item }) {
                    editor.list.remove(at: index)
                }
                
                editor.reloadData()
                self.onChange(editor.list)
            }),
            ListEditor.Option.viewFor({ item -> NSView in
                let frame = NSRect(x: 0, y: 0, width: 2000, height: 26)
                
                guard let component = self.component, let editor = self.editor else {
                    return CSStatementView(frame: NSRect.zero, components: [])
                }
                
                let caseTypeEnum = CSType.enumeration([
                    CSValue(type: CSType.string, data: CSData.String("Case")),
                    CSValue(type: CSType.string, data: CSData.String("Import list")),
                ])
                let caseTypeData = CSData.String(item.caseType.typeName == "entry" ? "Case" : "Import list")
                
                switch item.caseType {
                case .entry(let entry):
                    let components: [CSStatementView.Component] = [
                        .value("type", CSValue(type: caseTypeEnum, data: caseTypeData), []),
                        .value("name", CSValue(type: .string, data: CSData.String(entry.name)), []),
                        .text("with parameters"),
                        .value("data", CSValue(type: component.parametersType(), data: entry.value), []),
                        .text("that is visible"),
                        .value("visible", CSValue(type: .bool, data: CSData.Bool(entry.visible)), [])
                    ]
                    
                    let cell = CSStatementView(
                        frame: frame,
                        components: components
                    )
                    
                    cell.onChangeValue = { key, value, _ in
                        switch key {
                        case "type":
                            item.caseType = CSCase.CaseType.importedList(CSWorkspacePreferences.workspaceURL)
                        case "name":
                            item.caseType = CSCase.CaseType.entry(CSCaseEntry(name: value.data.stringValue, value: entry.value, visible: entry.visible))
                        case "data":
                            item.caseType = CSCase.CaseType.entry(CSCaseEntry(name: entry.name, value: value.data, visible: entry.visible))
                        case "visible":
                            item.caseType = CSCase.CaseType.entry(CSCaseEntry(name: entry.name, value: entry.value, visible: value.data.boolValue))
                        default:
                            break
                        }
                        
                        editor.reloadData()
                        self.onChange(editor.list)
                    }
                    
                    return cell
                case .importedList(url: let url):
                    let components: [CSStatementView.Component] = [
                        .value("type", CSValue(type: caseTypeEnum, data: caseTypeData), []),
                        .text("from"),
                        .value("url", CSValue(type: CSURLType, data: CSData.String(url.absoluteString)), []),
                    ]
                    
                    let cell = CSStatementView(
                        frame: frame,
                        components: components
                    )
                    
                    cell.onChangeValue = { key, value, _ in
                        switch key {
                        case "type":
                            item.caseType = CSCase.CaseType.entry(CSCaseEntry(name: "name", value: CSData.Object([:]), visible: true))
                        case "url":
                            if let url = URL(string: value.data.stringValue) {
                                item.caseType = CSCase.CaseType.importedList(url)
                            }
                        default:
                            break
                        }
                        
                        editor.reloadData()
                        self.onChange(editor.list)
                    }
                    
                    return cell
                }
            })
        ])
    }
}
