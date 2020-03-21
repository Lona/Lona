//
//  CanvasTableHeaderView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 9/24/18.
//  Copyright © 2018 BitDisco, Inc. All rights reserved.
//

import AppKit
import Foundation

private let CANVAS_PASTEBOARD_TYPE = NSPasteboard.PasteboardType("lona.canvas")

// MARK: - DraggableCanvasTableHeaderItem

private class DraggableCanvasTableHeaderItem: CanvasTableHeaderItem {
    override func mouseDragged(with event: NSEvent) {
        guard (abs(event.deltaX) > 0 || abs(event.deltaY) > 0),
            let dragPreview = imageRepresentation(),
            let headerItemViews = superview?.subviews.filter({ $0 is DraggableCanvasTableHeaderItem }),
            let index = headerItemViews.firstIndex(of: self) else { return }

        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setString(index.description, forType: .string)

        let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)

        draggingItem.setDraggingFrame(self.bounds, contents: dragPreview)

        beginDraggingSession(with: [draggingItem], event: event, source: self)
    }
}

extension DraggableCanvasTableHeaderItem: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return NSDragOperation.move
    }
}

// MARK: - CanvasTableHeaderView

class CanvasTableHeaderView: NSTableHeaderView {

    // MARK: Lifecycle

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        setUpViews()
        setUpConstraints()

        update()

        registerForDraggedTypes([NSPasteboard.PasteboardType.string])
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var onClickItem: ((Int) -> Void)?

    var onDeleteItem: ((Int) -> Void)?

    var onClickPlus: (() -> Void)?

    var onMoveItem: ((Int, Int) -> Void)?

    var selectedItem: Int? {
        didSet {
            if oldValue != selectedItem {
                update()
            }
        }
    }

    // MARK: Private

    private var proposedDropIndex: Int?

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

        if characters == String(Character(UnicodeScalar(NSEvent.SpecialKey.delete.rawValue)!)) {
            onDeleteItem?(selectedItem)
        }
    }

    func update() {
        guard let tableView = tableView else { return }

        if segmentViews.count != tableView.tableColumns.count {
            segmentViews.forEach { $0.removeFromSuperview() }
            segmentViews = []

            tableView.tableColumns.enumerated().forEach { index, column in
                if index == tableView.tableColumns.count - 1 {
                    let view = CanvasTableHeaderExtra(dividerColor: NSSplitView.defaultDividerColor)
                    view.onClickPlus = { [unowned self] in
                        self.onClickPlus?()
                    }
                    view.frame = headerRect(ofColumn: index)
                    view.translatesAutoresizingMaskIntoConstraints = true

                    addSubview(view)
                    segmentViews.append(view)
                } else {
                    let view = DraggableCanvasTableHeaderItem(
                        titleText: column.title,
                        dividerColor: NSSplitView.defaultDividerColor,
                        selected: index == selectedItem,
                        dropTargetIndicator: .none)
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
        }

        tableView.tableColumns.enumerated().forEach { index, column in
            if let segmentView = segmentViews[index] as? CanvasTableHeaderItem {
                segmentView.titleText = column.title
                segmentView.selected = index == selectedItem
            }

            segmentViews[index].frame = headerRect(ofColumn: index)
        }
    }

    func updateDropTarget() {
        guard let tableView = tableView else { return }

        tableView.tableColumns.enumerated().forEach { index, column in
            if let segmentView = segmentViews[index] as? CanvasTableHeaderItem {
                if proposedDropIndex == index {
                    segmentView.dropTargetIndicator = .left
                } else {
                    segmentView.dropTargetIndicator = .none
                }
            }
        }
    }

    // MARK: Dragging

    private func determineProposedDropIndex(_ sender: NSDraggingInfo) -> Int? {
        guard let tableView = tableView else { return nil }

        let point = convert(sender.draggingLocation, from: nil)

        for i in 0..<tableView.numberOfColumns - 1 {
            let rect = headerRect(ofColumn: i)

            if point.x >= rect.minX && point.x < rect.maxX {
                return i
            }
        }

        let lastIndex = tableView.numberOfColumns - 2

        return lastIndex
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        proposedDropIndex = nil

        updateDropTarget()
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        proposedDropIndex = determineProposedDropIndex(sender)

        updateDropTarget()

        return NSDragOperation.move
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        proposedDropIndex = determineProposedDropIndex(sender)

        updateDropTarget()

        return NSDragOperation.move
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard

        guard
            let value = pasteboard.string(forType: NSPasteboard.PasteboardType.string),
            let sourceIndex = Int(value),
            let targetIndex = determineProposedDropIndex(sender)
            else { return false }

        proposedDropIndex = nil

        updateDropTarget()

        if sourceIndex != targetIndex {
            onMoveItem?(sourceIndex, targetIndex)
        }

        return true
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
