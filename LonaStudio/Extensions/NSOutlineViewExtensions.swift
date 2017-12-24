//
//  NSOutlineViewExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/14/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

enum DropAcceptanceCategory<Element> {
    case into(parent: Element, at: Int?)
    case intoContainer(at: Int?)
    case intoDescendant()
}

extension NSOutlineView {
    func shouldAccept<Element: AnyObject>(dropping item: Element, relativeTo: Element?, at proposedIndex: Int) -> DropAcceptanceCategory<Element> {
        
        let targetIndex: Int? = proposedIndex == -1 ? nil : proposedIndex
        
        guard let relativeTo = relativeTo else {
            return DropAcceptanceCategory.intoContainer(at: targetIndex)
        }
        
        func isDescendant(_ descendant: Element, of ancestor: Element) -> Bool {
            var parentItem: Element? = descendant
            
            while parentItem != nil {
                if parentItem === ancestor {
                    return true
                }
                parentItem = parent(forItem: parentItem!) as? Element
            }
            
            return false
        }
        
        if isDescendant(relativeTo, of: item) {
            return DropAcceptanceCategory.intoDescendant()
        }
        
        return DropAcceptanceCategory.into(parent: relativeTo, at: targetIndex)
    }
    
    func scrollItemToVisible(item: Any) {
        let index = row(forItem: item)
        scrollRowToVisible(index)
    }
    
    func relativePosition<Element: AnyObject>(for element: Element) -> (parent: Element?, index: Int) {
        if let parentItem = parent(forItem: element) as? Element {
            let childItemIndex = childIndex(forItem: element)
            return (parentItem, childItemIndex)
        } else {
            var topLevelIndexCount = 0
            for index in 0..<numberOfRows {
                if let other = item(atRow: index) as? Element, other === element {
                    return (nil, topLevelIndexCount)
                }
                
                if level(forRow: index) == 0 {
                    topLevelIndexCount += 1
                }
            }

            // Should never happen
            return (nil, row(forItem: element))
        }
    }
    
    func select(row index: Int, ensureVisible: Bool = false) {
        var selection = IndexSet()
        selection.insert(index)
        selectRowIndexes(selection, byExtendingSelection: false)
        
        if ensureVisible {
            scrollRowToVisible(index)
        }
    }
    
    func select(item: Any, ensureVisible: Bool = false) {
        let index = row(forItem: item)
        select(row: index, ensureVisible: ensureVisible)
    }
    
    func stopEditing() {
        if selectedRow != -1 {
            // TODO: Traverse hierarchy and disable all text fields to make sure we don't crash.
            // E.g. click on another row in the Logic list table after editing a field in LogicNode
            let selectedView = view(atColumn: 0, row: selectedRow, makeIfNecessary: true) as! NSTableCellView
            
            selectedView.textField?.isEditable = false
            selectedView.textField?.isEnabled = false
        }
    }
}
