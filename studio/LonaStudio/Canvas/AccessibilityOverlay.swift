//
//  AccessibilityOverlay.swift
//  LonaStudio
//
//  Created by Devin Abbott on 1/24/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

class AccessibilityOverlay: NSView {
    var accessibilityOrderRects: [CGRect] = [] {
        didSet {
            needsDisplay = true
        }
    }

    static let labelTextStyle = TextStyle(weight: NSFont.Weight.bold, size: 12, color: NSColor.white)

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        accessibilityOrderRects.forEach { rect in
            NSColor.white.setStroke()

            let path = NSBezierPath(rect: rect.insetBy(dx: 0.5, dy: 0.5))
            path.lineWidth = 3
            path.stroke()
        }

        accessibilityOrderRects.enumerated().forEach { (index, rect) in
            NSColor.black.setStroke()

            let innerPath = NSBezierPath(rect: rect.insetBy(dx: 0.5, dy: 0.5))
            innerPath.lineWidth = 1
            innerPath.stroke()

            NSColor.black.setFill()

            let labelText = AccessibilityOverlay.labelTextStyle.apply(to: (index + 1).description)
            let labelSize = labelText.size()

            let labelRect = CGRect(
                origin: CGPoint(x: rect.minX, y: rect.maxY - labelSize.height),
                size: CGSize(width: max(16, labelSize.width + 2), height: labelSize.height))

            labelRect.fill()

            labelText.draw(at:
                NSPoint(
                    x: labelRect.origin.x + (labelRect.width - labelSize.width) / 2,
                    y: labelRect.origin.y))
        }
    }
}
