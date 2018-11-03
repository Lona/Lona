//
//  CSView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/3/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

// Handle flipping the coordinate system, since overriding isFlipped on NSBox
// doesn't seem to do anything.
private class InnerView: NSImageView {
    override var isFlipped: Bool { return true }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
    }
}

class CSView: NSBox {

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

    var croppingMode = CGSize.CroppingMode.scaleAspectFill

    var backgroundImage: NSImage? {
        didSet {
            innerView.image = backgroundImage?.crop(within: bounds.size, usingCroppingMode: croppingMode)
        }
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
