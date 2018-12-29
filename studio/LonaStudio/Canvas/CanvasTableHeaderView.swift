//
//  CanvasTableHeaderView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 9/24/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit
import Foundation

class CanvasTableHeaderView: NSTableHeaderView {

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

    var onClickItem: ((Int) -> Void)?

    var onDeleteItem: ((Int) -> Void)?

    var selectedItem: Int? {
        didSet {
            if oldValue != selectedItem {
                update()
            }
        }
    }

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

    override func keyDown(with event: NSEvent) {
        guard let selectedItem = selectedItem else { return }

        let characters = event.charactersIgnoringModifiers!

        if characters == String(Character(UnicodeScalar(NSDeleteCharacter)!)) {
            onDeleteItem?(selectedItem)
        }
    }

    func update() {
        guard let tableView = tableView else { return }

        if segmentViews.count != tableView.tableColumns.count {
            segmentViews.forEach { $0.removeFromSuperview() }

            tableView.tableColumns.enumerated().forEach { index, column in
                let view = CanvasTableHeaderItem(titleText: column.title, dividerColor: NSSplitView.defaultDividerColor, selected: index == selectedItem)
                view.onClick = { [unowned self] in
                    self.window?.makeFirstResponder(self)
                    self.onClickItem?(index)
                }
                view.frame = headerRect(ofColumn: index)
                view.translatesAutoresizingMaskIntoConstraints = true

                addSubview(view)
                segmentViews.append(view)
            }
        }

        tableView.tableColumns.enumerated().forEach { index, column in
            if let segmentView = segmentViews[index] as? CanvasTableHeaderItem {
                segmentView.titleText = column.title
                segmentView.selected = index == selectedItem
            }

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
