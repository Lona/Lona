//
//  LayerList.swift
//  ComponentStudio
//
//  Created by Devin Abbott on 5/7/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class LayerList: NSOutlineView {
    
    var component: CSComponent? = nil
    
    var onChange: () -> Void = {_ in}
    
    var selectedLayer: CSLayer? {
        return item(atRow: selectedRow) as! CSLayer?
    }
    
    var selectedLayerOrRoot: CSLayer {
        return selectedLayer ?? (item(atRow: 0) as! CSLayer)
    }
    
    func componentName(for url: URL) -> String {
        return url.deletingPathExtension().lastPathComponent
    }
    
    func createComponentLayer(from url: URL) -> CSComponentLayer {
        let file = CSComponent(url: url)!
        let name = componentName(for: url)
        
        let newLayer = CSComponentLayer(name: name, url: url.absoluteString)
        newLayer.component = file
        
        // Set default values for component parameters
        // TODO: Look at parameter.defaultValue if it exists
        file.parameters.forEach({ parameter in
            switch parameter.type {
            case .bool: newLayer.parameters[parameter.name] = false.toData()
            default: break
            }
        })
        
        return newLayer
    }
    
    func add(layer newLayer: CSLayer, to targetLayer: CSLayer) {
        let targetRow = row(forItem: targetLayer)
        
        // Root layer
        if (targetRow == 0) {
            targetLayer.appendChild(newLayer)
        } else {
            let parentLayer = parent(forItem: targetLayer) as! CSLayer
            let index = childIndex(forItem: targetLayer)
            parentLayer.insertChild(newLayer, at: index + 1)
        }
    }
    
    func replace(layer oldLayer: CSLayer, with newLayer: CSLayer) {
        // TODO Should we be able to replace the root?
        if row(forItem: oldLayer) == 0 { return }
        
        let parent = self.parent(forItem: oldLayer) as! CSLayer
        parent.children = parent.children.map({ $0 === oldLayer ? newLayer : $0 })
        
        onChange()
    }
    
    @discardableResult func duplicate(layer: CSLayer) -> CSLayer {
        let copy = layer.copy() as! CSLayer
        
        if copy is CSComponentLayer {
            copy.name += " copy"
        }
        
        add(layer: copy, to: layer)
        
        onChange()
        
        return copy
    }
    
    func duplicateAction(menuItem: NSMenuItem) {
        let layer = menuItem.representedObject as! CSLayer
        let copy = duplicate(layer: layer)
        
        select(item: copy)
    }
    
    func openComponentAction(menuItem: NSMenuItem) {
        let layer = menuItem.representedObject as! CSComponentLayer
        let url = URL(string: layer.url!)!
        
        let documentController = NSDocumentController.shared()
        
        documentController.openDocument(withContentsOf: url, display: true) {
            (document, documentWasAlreadyOpen, error) in
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
    
    func requestSaveFileURL() -> URL? {
        let dialog = NSSavePanel()
        
        dialog.title                   = "Save .component file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canCreateDirectories    = true
        dialog.allowedFileTypes        = ["component"]
        
        if dialog.runModal() == NSModalResponseOK {
            return dialog.url
        } else {
            // User clicked on "Cancel"
            return nil
        }
    }
    
    func extractComponentAction(menuItem: NSMenuItem) {
        let layer = menuItem.representedObject as! CSLayer
        
        guard let url = requestSaveFileURL() else { return }
        
        let documentController = NSDocumentController.shared()
        
        let document = Document()
        
        document.data = CSComponent(name: layer.name, canvas: component?.canvas ?? [], rootLayer: layer, parameters: [], cases: [CSCase.defaultCase], logic: [], config: component?.config ?? CSData.Object([:]), metadata: component?.metadata ?? CSData.Object([:]))
        
        Swift.print("Writing to", url)
        
        do {
            try document.write(to: url, ofType: ".component")
        } catch {
            return
        }
        
        documentController.openDocument(withContentsOf: url, display: true, completionHandler: {
            (document, documentWasAlreadyOpen, error) in
            
            let componentLayer = self.createComponentLayer(from: url)
            self.replace(layer: layer, with: componentLayer)
            
            self.onChange()
        })
    }
    
    func forkComponentAction(menuItem: NSMenuItem) {
        let layer = menuItem.representedObject as! CSComponentLayer
        
        guard let url = requestSaveFileURL() else { return }
        
        let documentController = NSDocumentController.shared()
        
        let existingURL = URL(string: layer.url!)!
        let existingFile = CSComponent(url: existingURL)!
        
        let document = Document()
        document.data = existingFile
        
        do {
            try document.write(to: url, ofType: ".component")
        } catch {
            return
        }
        
        documentController.openDocument(withContentsOf: url, display: true, completionHandler: {
            (document, documentWasAlreadyOpen, error) in
            
            layer.component = (document as! Document).file
            layer.url = url.absoluteString
            layer.name = self.componentName(for: url)
            
            self.onChange()
        })
    }
    
    func extractLayersAction(menuItem: NSMenuItem) {
        let layer = menuItem.representedObject as! CSComponentLayer
        
        replace(layer: layer, with: layer.component.rootLayer)
    }
    
    func buildMenu(for layer: CSLayer) -> NSMenu {
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
    
    override func menu(for event: NSEvent) -> NSMenu? {
        let point = convert(event.locationInWindow, from: nil)
        let index = row(at: point)
        guard let layer = item(atRow: index) as? CSLayer else { return nil }
        
        select(item: layer)
        
        return buildMenu(for: layer)
    }
}
