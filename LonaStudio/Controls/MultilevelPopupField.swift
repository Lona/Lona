import Foundation
import Cocoa

class MultilevelPopupField: NSPopUpButton, CSControl, NSMenuDelegate {
    
    var options: CSData = CSData.Object([:])
    var data: CSData = CSData.Array([])
    var onChangeData: (CSData) -> () = { _ in }
    
    override init(frame buttonFrame: NSRect, pullsDown flag: Bool) {
        super.init(frame: buttonFrame, pullsDown: flag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    func setupMenu(data: CSData, currentItem: NSMenuItem? = nil) {
        self.options = data
        
        func addSubmenu(object: CSData, keyPath: [String] = [], isTopLevel: Bool) -> NSMenu {
            let menu = NSMenu()
            
            if isTopLevel, let item = currentItem {
                menu.addItem(item)
                menu.addItem(NSMenuItem.separator())
            }
            
            // Sort alphabetically by key
            for (key, value) in object.objectValue.sorted(by: { (a, b) -> Bool in
                return a.key < b.key
            }) {
                let keyPath = keyPath + [key]
                let item = NSMenuItem(title: key, action: #selector(handleChange(menuItem:)), keyEquivalent: "")
                item.target = self
                item.representedObject = keyPath
                menu.addItem(item)
                
                if value.object != nil, let mainItem = menu.item(withTitle: key) {
                    mainItem.submenu = addSubmenu(object: value, keyPath: keyPath, isTopLevel: false)
                }
            }
            
            return menu
        }
        
        self.menu = addSubmenu(object: data, isTopLevel: true)
    }
    
    init(frame frameRect: NSRect, data: CSData, initialValue: [String]?) {
        super.init(frame: frameRect)
        
        if let value = initialValue /*, value.count > 1*/ {
            let item = NSMenuItem(title: value.joined(separator: " → "), action: nil, keyEquivalent: "")
            setupMenu(data: data, currentItem: item)
            select(item)
        } else {
            setupMenu(data: data)
            if let value = initialValue, value.count > 0 {
                select(item(withTitle: value[0]))
            }
        }
    }
    
    @objc func handleChange(menuItem: NSMenuItem) {
        if let value = menuItem.representedObject as? [String] {
            Swift.print("Changed", value)
            
            // Item is not in top level
            if value.count > 1 {
                let item = NSMenuItem(title: value.joined(separator: " → "), action: nil, keyEquivalent: "")
                setupMenu(data: self.data, currentItem: item)
            } else {
                setupMenu(data: self.data)
            }
            
            onChangeData(CSData.Array(value.map({ CSData.String($0)})))
        }
    }
}

