//
//  NSImageExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 10/3/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

extension NSImage {
    func tinted(color tintColor: NSColor) -> NSImage {
//        if !isTemplate { return self }
        
        let image = self.copy() as! NSImage
        image.lockFocus()
        
        tintColor.set()
        let rect = NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        NSRectFillUsingOperation(rect, NSCompositingOperation.sourceAtop)
        
        image.unlockFocus()
//        image.isTemplate = false
        
        return image
    }
}


