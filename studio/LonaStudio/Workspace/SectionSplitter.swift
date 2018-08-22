//
//  SectionSplitter.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/27/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

extension NSRect {
    static func square(ofSize size: CGFloat) -> NSRect {
        return NSRect(x: 0, y: 0, width: size, height: size)
    }
}

class SectionSplitter: NSSplitView {
    var splitterView: NSView?
    var passthroughViews: [NSView] = []

    override var dividerThickness: CGFloat { return 30 }

    override func drawDivider(in rect: NSRect) {
        lockFocus()
        #colorLiteral(red: 0.9486700892, green: 0.9493889213, blue: 0.9487814307, alpha: 1).set()
        rect.fill()
        unlockFocus()

        splitterView?.ygNode?.width = rect.width
        splitterView?.ygNode?.height = rect.height

        splitterView?.layoutWithYoga()

        splitterView?.frame = rect
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        for view in passthroughViews {
            let flippedPoint = NSPoint(x: point.x, y: self.frame.height - point.y)

//            Swift.print("Point", flippedPoint, "|", "View", splitterView!.frame.origin)
            let origin = splitterView!.frame.origin
            let frame = view.frame.offsetBy(dx: origin.x, dy: origin.y)

//            Swift.print("Test", point, frame)
            if frame.contains(flippedPoint) {
//                Swift.print("Found", flippedPoint, view)
                return view
            }
        }

        return super.hitTest(point)
    }

    func setup() {
        arrangesAllSubviews = false

        let view = FlippedView()

        view.useYogaLayout = true
        view.ygNode?.justifyContent = .center
        view.ygNode?.alignItems = .center

//        view.wantsLayer = true
//        view.layer = CALayer()
//        view.layer?.backgroundColor = CGColor.white

        let border = NSView(frame: NSRect.square(ofSize: 30))

        border.useYogaLayout = true
        border.ygNode?.top = 0
        border.ygNode?.left = 0
        border.ygNode?.right = 0
        border.ygNode?.height = 1
        border.ygNode?.width = -1
        border.ygNode?.position = .absolute

        border.wantsLayer = true
        border.layer = CALayer()
        border.layer?.backgroundColor = #colorLiteral(red: 0.8379167914, green: 0.8385563493, blue: 0.8380157948, alpha: 1).cgColor

        view.addSubview(border)

        addSubview(view)
        splitterView = view
    }

    func addSubviewToDivider(_ view: NSView) {
        splitterView?.addSubview(view)
        passthroughViews.append(view)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
}
