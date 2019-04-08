//
//  DraggableIconButton.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/8/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

// MARK: - DraggableIconButton

public class DraggableIconButton: LNAImageView {

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var onClick: (() -> Void)?

    public var getPasteboardItem: (() -> NSPasteboardItem)?

    public var draggingThreshold: CGFloat = 2.0

    // MARK: Private

    private func setUpViews() {}

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func update() {
        alphaValue = pressed ? 0.5 : 1
    }

    // MARK: Interactions

    var pressed = false
    var pressedPoint = CGPoint.zero

    public override func mouseDown(with event: NSEvent) {
        let point = convert(event.locationInWindow, from: nil)

        if bounds.contains(point) {
            pressed = true
            pressedPoint = point
            update()
        }
    }

    public override func mouseUp(with event: NSEvent) {
        if pressed && bounds.contains(convert(event.locationInWindow, from: nil)) {
            onClick?()
        }

        pressed = false
        update()
    }

    public override func mouseDragged(with event: NSEvent) {
        guard let getPasteboardItem = getPasteboardItem else { return }

        let point = convert(event.locationInWindow, from: nil)

        if abs(point.x - pressedPoint.x) < draggingThreshold && abs(point.y - pressedPoint.y) < draggingThreshold {
            return
        }

        pressed = false
        update()

        let pasteboardItem = getPasteboardItem()

        let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)

        let pdf = dataWithPDF(inside: bounds)
        guard let snapshot = NSImage(data: pdf) else { return }

        draggingItem.setDraggingFrame(bounds, contents: snapshot)

        beginDraggingSession(with: [draggingItem], event: event, source: self)
    }

}

// MARK: - NSDraggingSource

extension DraggableIconButton: NSDraggingSource {
    public func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy
    }
}
