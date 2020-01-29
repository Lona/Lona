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
        set { _ = newValue }
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

    override var frame: NSRect {
        didSet {
            innerView.frame = NSRect(origin: .zero, size: frame.size)
        }
    }

    var layerName: String?
    var layerPath: [String] = []

    var onClick: (() -> Void)?

    override var borderWidth: CGFloat {
        didSet {
            updateContentMargins()
        }
    }

    override var cornerRadius: CGFloat {
        didSet {
            innerView.cornerRadius = cornerRadius
        }
    }

    var borderStyle: CSLayer.BorderStyle = .solid {
        didSet {
            switch borderStyle {
            case .solid:
                borderType = .lineBorder
            default:
                borderType = .noBorder
            }
            updateContentMargins()
        }
    }

    var resizingMode: CGSize.ResizingMode {
        get { return innerView.resizingMode }
        set { innerView.resizingMode = newValue }
    }

    var backgroundImage: NSImage? {
        get { return innerView.image }
        set { innerView.image = newValue }
    }

    var multipliedBorderColor: NSColor = .clear {
        didSet {
            if multipliedBorderColor != oldValue {
                updateBorderColor()
            }
        }
    }

    var multipliedFillColor: NSColor = .clear {
        didSet {
            if multipliedFillColor != oldValue {
                updateFillColor()
            }
        }
    }

    var opacity: CGFloat = 1 {
        didSet {
            if opacity != oldValue {
                updateFillColor()
                updateBorderColor()
                needsDisplay = true
            }
        }
    }

    override var isOpaque: Bool {
        return false
    }

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

    func addInnerSubview(_ view: NSView) {
        innerView.addSubview(view)
    }

    func getInnerSubviews() -> [NSView] {
        return innerView.subviews
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

    private func updateContentMargins() {
        switch borderStyle {
        case .solid:
            contentViewMargins = .zero
        default:
            contentViewMargins = CGSize(width: borderWidth, height: borderWidth)
        }
    }

    private func updateBorderColor() {
        if multipliedBorderColor.alphaComponent <= 0 {
            borderColor = .clear
        } else {
            borderColor = multipliedAlpha <= 0
                ? .clear
                : multipliedBorderColor.withAlphaComponent(multipliedBorderColor.alphaComponent * multipliedAlpha)
        }
    }

    private func updateFillColor() {
        if multipliedFillColor.alphaComponent <= 0 {
            fillColor = .clear
        } else {
            fillColor = multipliedAlpha <= 0
                ? .clear
                : multipliedFillColor.withAlphaComponent(multipliedFillColor.alphaComponent * multipliedAlpha)
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if borderStyle != .solid {
            let dashSize: CGFloat = borderWidth
            let dashLength: CGFloat = borderStyle == .dotted ? dashSize : dashSize * 2
            let dashColor: NSColor = borderColor

            if let currentContext = NSGraphicsContext.current?.cgContext {
                currentContext.setLineWidth(dashSize)
                if dashLength > 0 {
                    currentContext.setLineDash(phase: 0, lengths: [dashLength])
                }
                currentContext.setStrokeColor(dashColor.cgColor)

                let borderRect = bounds.insetBy(dx: dashSize / 2, dy: dashSize / 2)
                let borderPath = CGPath(roundedRect: borderRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
                currentContext.addPath(borderPath)
                currentContext.strokePath()
            }
        }
    }
}
