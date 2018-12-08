//
//  TypeListHeaderView.swift
//  Logic
//
//  Created by Devin Abbott on 9/24/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit
import Foundation

class TypeListHeaderCellView: NSBox {

    // MARK: Lifecycle

    override init(frame frameRect: NSRect) {
        self.titleText = ""

        super.init(frame: frameRect)

        setUpViews()
        setUpConstraints()

        update()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var titleText: String { didSet { update() } }

    var titleTextFont: NSFont = NSFont.systemFont(ofSize: 12, weight: NSFont.Weight.bold)
    var titleTextColor: NSColor = NSColor.init(calibratedRed: 0, green: 0, blue: 0, alpha: 0.4)

    var onPressPlus: (() -> Void)? { didSet { update() } }

    // MARK: Private

    let titleView = NSTextField(labelWithString: "Testing")

    private var plusButton = NSButton(
        image: NSImage(named: NSImage.Name.addTemplate)!,
        target: nil,
        action: nil)

    @objc func handlePressPlus(_ sender: AnyObject) {
        onPressPlus?()
    }

    func setUpViews() {
        boxType = .custom
        borderType = .lineBorder
        contentViewMargins = .zero
        borderWidth = 0

        plusButton.target = self
        plusButton.bezelStyle = .inline
        plusButton.action = #selector(handlePressPlus(_:))
        plusButton.image?.size = NSSize(width: 9, height: 9)

        addSubview(titleView)
        addSubview(plusButton)
    }

    func setUpConstraints() {
        titleView.translatesAutoresizingMaskIntoConstraints = false
        plusButton.translatesAutoresizingMaskIntoConstraints = false

        titleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
        titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true

        plusButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        plusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 15).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 15).isActive = true
    }

    func update() {
        plusButton.isHidden = onPressPlus == nil

        titleView.attributedStringValue = TextStyles.sectionTitle.apply(to: titleText)
    }
}

class TypeListHeaderView: NSTableHeaderView {

    // MARK: Lifecycle

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        setUpViews()
        setUpConstraints()

        update()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var onPressPlus: (() -> Void)? { didSet { update() } }

    // MARK: Private

    var segmentViews: [NSView] = []

    let bottomDividerView = NSBox(frame: .zero)

    func setUpViews() {
        bottomDividerView.boxType = .custom
        bottomDividerView.borderType = .lineBorder
        bottomDividerView.contentViewMargins = .zero
        bottomDividerView.borderWidth = 0
        bottomDividerView.fillColor = NSSplitView.defaultDividerColor

        addSubview(bottomDividerView)
    }

    func setUpConstraints() {
        bottomDividerView.translatesAutoresizingMaskIntoConstraints = false

        bottomDividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        bottomDividerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomDividerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        bottomDividerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    func update() {
        guard let tableView = tableView else { return }

        if segmentViews.count != tableView.tableColumns.count {
            segmentViews.forEach { $0.removeFromSuperview() }

            tableView.tableColumns.enumerated().forEach { index, column in
                let view = CanvasTableHeaderItem(titleText: column.title, dividerColor: NSSplitView.defaultDividerColor)
                view.frame = headerRect(ofColumn: index)
                view.translatesAutoresizingMaskIntoConstraints = true

//                if index == 0 {
//                    view.onPressPlus = { self.onPressPlus?() }
//                }

                addSubview(view)
                segmentViews.append(view)
            }
        }

        tableView.tableColumns.enumerated().forEach { index, column in
            segmentViews[index].frame = headerRect(ofColumn: index)
        }
    }
}

final class EmptyHeaderCell: NSTableHeaderCell {
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(textCell: String) {
        super.init(textCell: textCell)
    }

    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {}

    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {}
}
