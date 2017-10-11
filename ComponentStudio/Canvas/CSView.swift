//
//  CSView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/3/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

class CSView: NSView {
    let onClick: () -> Void
    
    override var isFlipped: Bool { return true }
    
    // By default, clicking more than once on the parent will cause all subsequent mouseDown
    // events to be sent to the parent, even if they are in the coordinates of its child.
    // Here we override this behavior to always click the innermost view.
    override func mouseDown(with event: NSEvent) {
        let selfPoint = convert(event.locationInWindow, from: nil)
        let clickedView = hitTest(selfPoint)
        
        // If we're in the coordinates of this view (`self`)
        if let view = clickedView as? CSView {
            view.onClick()
        // If we're outside the coordinates of this view
        } else if clickedView == nil {
            super.mouseDown(with: event)
        }
    }
    
    override var wantsUpdateLayer: Bool { return true }

    init(frame frameRect: NSRect, onClick: @escaping () -> Void) {
        self.onClick = onClick
        
        super.init(frame: frameRect)
        
        wantsLayer = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
