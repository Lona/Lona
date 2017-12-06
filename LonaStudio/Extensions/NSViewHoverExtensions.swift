//
//  NSViewHoverExtensions.swift
//  LonaStudio
//
//  Created by Nghia Tran on 12/4/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

protocol Hoverable {
    
    func startHover(_ block: () -> Void)
    func stopHover(_ block: () -> Void)
}

private struct AssociatedKeys {
    static var HoverKey = "nsh_DescriptiveName"
}

extension Hoverable where Self: NSView {
    
    var trackingArea: NSTrackingArea {
        get {
            if let tracking = objc_getAssociatedObject(self, &AssociatedKeys.HoverKey) as? NSTrackingArea {
                return tracking
            }
            let tracking = NSTrackingArea(rect: CGRect.zero,
                                          options: [NSTrackingArea.Options.inVisibleRect,
                                                    NSTrackingArea.Options.mouseEnteredAndExited,
                                                    NSTrackingArea.Options.activeAlways],
                                          owner: self,
                                          userInfo: nil)
            objc_setAssociatedObject(self, &AssociatedKeys.HoverKey, tracking, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return tracking
        }
    }
    
    func startTrackingHover() {
        guard !trackingAreas.contains(trackingArea) else {
            return
        }
        addTrackingArea(trackingArea)
    }
    
    func removeTrackingHover() {
        removeTrackingArea(trackingArea)
    }
    
    func startHover(_ block: () -> Void) {
        animateHover(block)
    }
    
    func stopHover(_ block: () -> Void) {
        animateHover(block)
    }
    
    private func animateHover(_ block: () -> Void) {
        block()
    }
}
