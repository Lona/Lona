//
//  CSView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/3/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import AppKit

// Handle flipping the coordinate system, since overriding isFlipped on NSBox
// doesn't seem to do anything.
private class InnerView: LNAImageView, CSRendering {
    override var isFlipped: Bool { return true }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
    }

    override var alphaValue: CGFloat {
        get { return multipliedAlpha }
        set {}
    }
}

class CSView: NSBox, CSRendering {

    // MARK: Lifecycle

    override init(frame frameRect: NSRect) {
        innerView = InnerView(frame: NSRect(origin: .zero, size: frameRect.size))

        super.init(frame: frameRect)

        setUpViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var layerName: String?

    var onClick: (() -> Void)?

    var resizingMode: CGSize.ResizingMode {
        get { return innerView.resizingMode }
        set { innerView.resizingMode = newValue }
    }

    var backgroundImage: NSImage? {
        get { return innerView.image }
        set { innerView.image = newValue }
    }

    override var fillColor: NSColor {
        get {
            if multipliedFillColor.alphaComponent <= 0 { return .clear }
            return multipliedAlpha <= 0
                ? .clear
                : multipliedFillColor.withAlphaComponent(multipliedFillColor.alphaComponent * multipliedAlpha)
        }
        set {}
    }

    override var borderColor: NSColor {
        get {
            if multipliedBorderColor.alphaComponent <= 0 { return .clear }
            return multipliedAlpha <= 0
                ? .clear
                : multipliedBorderColor.withAlphaComponent(multipliedBorderColor.alphaComponent * multipliedAlpha)
        }
        set {}
    }

    var multipliedBorderColor: NSColor = .clear
    var multipliedFillColor: NSColor = .clear

    var opacity: CGFloat = 1

    override var isOpaque: Bool {
        return false
    }

//    private var _drawingToImage = false
//
//    override func draw(_ dirtyRect: NSRect) {
//        if _drawingToImage || opacity >= 1 {
//            super.draw(dirtyRect)
//            return
//        }
//
//        drawToImage()
//    }
//
//    private func drawToImage() {
//        _drawingToImage = true
//
//        let rep = bitmapImageRepForCachingDisplay(in: bounds)!
//        cacheDisplay(in: bounds, to: rep)
//
//        let img = NSImage(size: bounds.size)
//        img.addRepresentation(rep)
//
//        img.draw(at: bounds.origin, from: bounds, operation: .copy, fraction: opacity)
//
//        _drawingToImage = false
//    }

    // By default, clicking more than once on the parent will cause all subsequent mouseDown
    // events to be sent to the parent, even if they are in the coordinates of its child.
    // Here we override this behavior to always click the innermost view.
    override func mouseDown(with event: NSEvent) {
        let selfPoint = convert(event.locationInWindow, from: nil)
        let clickedView = hitTest(selfPoint)

        // If we're in the coordinates of this view (`self`)
        if let view = clickedView as? CSView {
            view.onClick?()
        } else if let view = clickedView?.superview?.superview as? CSView {
            view.onClick?()
        // If we're outside the coordinates of this view
        } else if clickedView == nil {
            super.mouseDown(with: event)
        }
    }

    override func addSubview(_ view: NSView) {
        innerView.addSubview(view)
    }

    // MARK: Private

    private let innerView: InnerView

    private func setUpViews() {
        boxType = .custom
        borderType = .lineBorder
        borderWidth = 0
        borderColor = .clear
        contentViewMargins = .zero

        innerView.imageScaling = .scaleProportionallyUpOrDown

        super.addSubview(innerView)
    }
}
