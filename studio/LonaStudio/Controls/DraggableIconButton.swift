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

    public var getPasteboardItem: (() -> NSPasteboardItem)?

    // MARK: Private

    private func setUpViews() {}

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func update() {}

    public override func mouseDragged(with event: NSEvent) {
        guard let getPasteboardItem = getPasteboardItem else { return }

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
