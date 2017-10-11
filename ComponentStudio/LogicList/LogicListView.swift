//
//  listEditor.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/26/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

//
//  CaseList.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

class LogicListView {
    
    var component: CSComponent? = nil
    var editor: ListEditor<LogicNode>? = nil
    
    var list: [LogicNode] {
        get { return editor?.list ?? [] }
        set { editor?.list = newValue }
    }
    
    var onChange: ([LogicNode]) -> Void {
        get { return editor?.onChange ?? {_ in}}
        set { editor?.onChange = newValue }
    }
    
    init(frame frameRect: NSRect) {
        editor = ListEditor<LogicNode>(frame: frameRect, options: [
            ListEditor.Option.backgroundColor(NSColor.white),
            ListEditor.Option.drawsTopBorder(true),
            ListEditor.Option.onAddElement({ self.editor?.add(element: LogicNode()) }),
            ListEditor.Option.onContextMenu({ item -> [NSMenuItem] in
                return [
                    NSMenuItem(title: "Duplicate", onClick: { self.editor?.duplicate(element: item) })
                ]
            }),
            ListEditor.Option.onRemoveElement({ item in
                self.editor?.remove(element: item)
            }),
            ListEditor.Option.viewFor({ item -> NSView in
                guard let component = self.component, let editor = self.editor else {
                    return CSStatementView(frame: NSRect.zero, components: [])
                }
                
                let scope = component.rootScope()
                let cell = CSStatementView.view(for: item.invocation, in: scope)
                
                cell.onChangeValue = { name, value, keyPath in
                    if name == "functionName" {
                        item.invocation.name = value.data.stringValue
                    } else {
                        if keyPath.count == 0 ||
                            keyPath == CSFunction.Argument.customKeyPath ||
                            keyPath == CSFunction.Argument.customValueKeyPath {
                            item.invocation.arguments[name] = CSFunction.Argument.value(value)
                        } else if keyPath == CSFunction.Argument.customTypeKeyPath {
                            let argument = item.invocation.arguments[name] ?? CSFunction.Argument.value(CSUndefinedValue)
                            let newType = CSType.from(string: value.data.stringValue)
                            let newValue = argument.resolve(in: scope).cast(to: newType)
                            item.invocation.arguments[name] = CSFunction.Argument.value(newValue)
                        } else {
                            item.invocation.arguments[name] = CSFunction.Argument.identifier(value.type, keyPath)
                        }
                    }
                    
                    editor.reloadData()
                    self.onChange(self.list)
                }
                
                cell.onAddChild = { _ in self.editor?.add(element: LogicNode(), to: item) }
                
                return cell
            }),
            ListEditor.Option.onDropElement({ (sourceItem, targetItem, index) -> Bool in
                guard let outlineView = self.editor?.listView else { return false }
                
                let sourceParent = outlineView.parent(forItem: sourceItem) as? LogicNode
                let oldIndexWithinParent = outlineView.childIndex(forItem: sourceItem)
    
                if let sourceParent = sourceParent {
                    sourceParent.nodes = sourceParent.nodes.filter({ $0 !== sourceItem })
                } else {
                    self.list = self.list.filter({ $0 !== sourceItem })
                }
    
                // Index is -1 when item is dropped directly on another item, rather than above or below
                if index == -1 {
                    if let targetItem = targetItem {
                        targetItem.nodes.append(sourceItem)
                    } else {
                        self.list.append(sourceItem)
                    }
                } else {
                    if let targetItem = targetItem {
                        if sourceParent === targetItem &&
                            oldIndexWithinParent >= 0 &&
                            oldIndexWithinParent < index
                        {
                            targetItem.nodes.insert(sourceItem, at: index - 1)
                        } else {
                            targetItem.nodes.insert(sourceItem, at: index)
                        }
                    } else {
                        if oldIndexWithinParent >= 0 && oldIndexWithinParent < index {
                            self.list.insert(sourceItem, at: index - 1)
                        } else {
                            self.list.insert(sourceItem, at: index)
                        }
                    }
                }
    
                return true
            })
        ])
    }
}


//    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
//
//
//    }
//
//    var selectedItem: Any? {
//        return item(atRow: selectedRow)
//    }
//
//    @discardableResult func remove(item: Any) -> Int {
//        let parentItem = parent(forItem: item) as! LogicNode?
//
//        if let parentItem = parentItem {
//            let index = parentItem.nodes.index(where: { $0 === item as! LogicNode })!
//            parentItem.nodes.remove(at: index)
//            return index
//        } else {
//            let index = list.index(where: { $0 === item as! LogicNode })!
//            list.remove(at: index)
//            return index
//        }
//    }
//
//    // <DragAndDrop>

//    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
//
//        let sourceIndexString = info.draggingPasteboard().string(forType: "component.logic")
//
//        if let sourceIndexString = sourceIndexString,
//            let sourceIndex = Int(sourceIndexString),
//            let sourceItem = outlineView.item(atRow: sourceIndex) as? LogicNode
//        {
//            let targetItem = item as? LogicNode
//            let sourceParent = outlineView.parent(forItem: sourceItem) as? LogicNode
//            let oldIndexWithinParent = outlineView.childIndex(forItem: sourceItem)
//
//            if let sourceParent = sourceParent {
//                sourceParent.nodes = sourceParent.nodes.filter({ $0 !== sourceItem })
//            } else {
//                list = list.filter({ $0 !== sourceItem })
//            }
//
//            // Index is -1 when item is dropped directly on another item, rather than above or below
//            if index == -1 {
//                if let targetItem = targetItem {
//                    targetItem.nodes.append(sourceItem)
//                } else {
//                    list.append(sourceItem)
//                }
//            } else {
//                if let targetItem = targetItem {
//                    if sourceParent === targetItem &&
//                        oldIndexWithinParent >= 0 &&
//                        oldIndexWithinParent < index
//                    {
//                        targetItem.nodes.insert(sourceItem, at: index - 1)
//                    } else {
//                        targetItem.nodes.insert(sourceItem, at: index)
//                    }
//                } else {
//                    if oldIndexWithinParent >= 0 && oldIndexWithinParent < index {
//                        list.insert(sourceItem, at: index - 1)
//                    } else {
//                        list.insert(sourceItem, at: index)
//                    }
//                }
//            }
//
//            return true
//        }
//
//        return false
//    }
//
//    // </DragAndDrop>
//
//}

