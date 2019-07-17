//
//  ToolbarStatusBar.swift
//  LonaStudio
//
//  Created by Devin Abbott on 7/9/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

public class ToolbarStatusBar: NSTextField {

    // MARK: Lifecycle

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        isEnabled = true
        isEditable = false

//        alignment = .center
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var titleText: String = "" {
        willSet {
            // Pad value with thin spaces
            stringValue = "  " + newValue
        }
    }

    public var inProgress: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    public var progress: CGFloat = 0.0 {
        didSet {
            needsDisplay = true
        }
    }

    // MARK: Private

    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        if inProgress {
            var progressRect = bounds
            progressRect.origin.y = progressRect.size.height - 4
            progressRect.size.height = 2
            progressRect.size.width *= progress

            NSColor.alternateSelectedControlColor.set()
            progressRect.fill(using: NSCompositingOperation.sourceIn)
        }
    }

}
