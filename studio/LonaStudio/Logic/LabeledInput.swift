//
//  LabeledInput.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/10/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

// MARK: - LabeledInput

public class LabeledInput: NSBox {

    // MARK: Lifecycle

    public init(titleText: String = "") {
        self.titleText = titleText

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var inputView = NSView() {
        didSet {
            if oldValue != inputView {
                inputView.removeFromSuperview()

                addSubview(inputView)

                inputView.translatesAutoresizingMaskIntoConstraints = false

                inputView.leadingAnchor.constraint(equalTo: dividerView.trailingAnchor).isActive = true
                inputView.topAnchor.constraint(equalTo: topAnchor).isActive = true
                inputView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                inputView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            }
        }
    }

    public var titleText: String {
        didSet {
            if titleText != oldValue {
                update()
            }
        }
    }

    public var getPasteboardItem: (() -> NSPasteboardItem)?

    public var draggingThreshold: CGFloat = 2.0

    public var titleWidth: CGFloat? {
        didSet {
            if oldValue != titleWidth {
                switch (titleWidth, titleWidthConstraint) {
                case (.some(let width), .some(let constraint)):
                    constraint.constant = width
                case (.none, .some(let constraint)):
                    constraint.isActive = false
                case (.some(let width), .none):
                    let constraint = titleView.widthAnchor.constraint(equalToConstant: width)
                    constraint.isActive = true
                    titleWidthConstraint = constraint
                case (.none, .none):
                    break
                }
            }
        }
    }

    // MARK: Private

    private var titleView = LNATextField(labelWithString: "")
    private var dividerView = NSBox()
    private var titleWidthConstraint: NSLayoutConstraint?

    private func setUpViews() {
        boxType = .custom
        borderType = .lineBorder
        contentViewMargins = .zero
        cornerRadius = 2
        borderColor = Colors.divider
        fillColor = Colors.headerBackground

        titleView.maximumNumberOfLines = 1
        titleView.lineBreakMode = .byWordWrapping
        titleView.allowsDefaultTighteningForTruncation = false
        titleView.cell?.truncatesLastVisibleLine = true

        dividerView.boxType = .custom
        dividerView.borderType = .noBorder
        dividerView.contentViewMargins = .zero
        dividerView.fillColor = Colors.divider

        addSubview(titleView)
        addSubview(dividerView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false

        titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        titleView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1).isActive = true

        dividerView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        dividerView.leadingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: 8).isActive = true
        dividerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dividerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    private func update() {
        titleView.attributedStringValue = TextStyles.labelTitle.apply(to: titleText)
        titleView.toolTip = titleText
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
        pressed = false
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

extension LabeledInput: NSDraggingSource {
    public func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy
    }
}
