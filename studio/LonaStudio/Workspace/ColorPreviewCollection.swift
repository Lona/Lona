//
//  ColorPreviewCollection.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/10/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

private let ITEM_IDENTIFIER = NSUserInterfaceItemIdentifier(rawValue: "color")
private let COLOR_PASTEBOARD_TYPE = NSPasteboard.PasteboardType("lona.color")

class DoubleClickableColorPreviewCard: ColorPreviewCard {
    var onDoubleClick: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            onDoubleClick?()
        } else {
            super.mouseDown(with: event)
        }
    }
}

class KeyHandlingCollectionView: NSCollectionView {
    public var onDeleteItem: ((Int) -> Void)?

    override func keyDown(with event: NSEvent) {
        guard let characters = event.charactersIgnoringModifiers,
            let item = selectionIndexPaths.first?.item else { return }

        if characters == String(Character(UnicodeScalar(NSDeleteCharacter)!)) {
            onDeleteItem?(item)
        }
    }
}

class ColorPreviewCollectionView: NSView {

    // MARK: - Lifecycle

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        setUpViews()
        setUpConstraints()

        update()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    public var items: [CSColor] = [] { didSet { update() } }
    public var onClickColor: ((String) -> Void)? { didSet { update(withoutReloading: true) } }
    public var onMoveColor: ((Int, Int) -> Void)? { didSet { update(withoutReloading: true) } }
    public var onDeleteColor: ((Int) -> Void)? { didSet { update(withoutReloading: true) } }

    // MARK: - Private

    private let collectionView = KeyHandlingCollectionView(frame: .zero)
    private let scrollView = NSScrollView()

    private func setUpViews() {
        wantsLayer = true

        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 24
        flowLayout.minimumInteritemSpacing = 12
        flowLayout.itemSize = NSSize(width: 140, height: 160)

        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColors = [NSColor.clear]

        collectionView.registerForDraggedTypes([COLOR_PASTEBOARD_TYPE])
        collectionView.setDraggingSourceOperationMask(.move, forLocal: true)
        collectionView.isSelectable = true
//        collectionView.allowsMultipleSelection = true
        collectionView.allowsEmptySelection = true

        collectionView.register(
            ColorPreviewItemViewController.self,
            forItemWithIdentifier: ITEM_IDENTIFIER)

        scrollView.verticalScrollElasticity = .allowed
        scrollView.horizontalScrollElasticity = .allowed
        scrollView.allowsMagnification = true
        scrollView.backgroundColor = NSColor.red
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.documentView = collectionView

        addSubviewStretched(subview: scrollView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func update(withoutReloading: Bool = false) {
        if !withoutReloading {
            collectionView.reloadData()
        }

        collectionView.onDeleteItem = onDeleteColor
    }
}

// MARK: - Imperative API

extension ColorPreviewCollectionView {
    func cardView(at index: Int) -> ColorPreviewCard? {
        guard let item = collectionView.item(at: index) as? ColorPreviewItemViewController else { return nil }
        return item.view as? ColorPreviewCard
    }

    func reloadData() {
        collectionView.reloadData()
    }

    func moveItem(from sourceIndex: Int, to targetIndex: Int) {
        collectionView.animator().moveItem(
            at: IndexPath(item: sourceIndex, section: 0),
            to: IndexPath(item: sourceIndex < targetIndex ? targetIndex - 1 : targetIndex, section: 0))
    }

    func deleteItem(at index: Int) {
        collectionView.animator().deleteItems(at: [IndexPath(item: index, section: 0)])
    }
}

// MARK: - NSCollectionViewDelegate

extension ColorPreviewCollectionView: NSCollectionViewDelegate {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
        return true
    }

    func collectionView(_ collectionView: NSCollectionView, writeItemsAt indexPaths: Set<IndexPath>, to pasteboard: NSPasteboard) -> Bool {

        guard let sourceIndex = indexPaths.first?.item,
            let data = CSData.Array([sourceIndex.toData()]).toData()
            else { return false }

        pasteboard.declareTypes([COLOR_PASTEBOARD_TYPE], owner: self)
        pasteboard.setData(data, forType: COLOR_PASTEBOARD_TYPE)

        return true
    }

    func collectionView(
        _ collectionView: NSCollectionView,
        validateDrop draggingInfo: NSDraggingInfo,
        proposedIndexPath proposedDropIndexPath: AutoreleasingUnsafeMutablePointer<NSIndexPath>,
        dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {

        if proposedDropOperation.pointee == NSCollectionView.DropOperation.on {
            proposedDropOperation.pointee = NSCollectionView.DropOperation.before
        }

        return NSDragOperation.move
    }

    func collectionView(
        _ collectionView: NSCollectionView,
        acceptDrop draggingInfo: NSDraggingInfo,
        indexPath: IndexPath,
        dropOperation: NSCollectionView.DropOperation) -> Bool {
        guard let data = draggingInfo.draggingPasteboard().data(forType: COLOR_PASTEBOARD_TYPE),
            let sourceIndexPath = CSData.from(data: data)?.array?.first?.number else {
            Swift.print("Can't move color item - bad pasteboard data")
            return false
        }

        onMoveColor?(Int(sourceIndexPath), indexPath.item)

        return true
    }
}

// MARK: - NSCollectionViewDataSource

extension ColorPreviewCollectionView: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: ITEM_IDENTIFIER,
            for: indexPath) as! ColorPreviewItemViewController

        if let componentPreviewCard = item.view as? DoubleClickableColorPreviewCard {
            let componentFile = items[indexPath.item]
            componentPreviewCard.colorName = componentFile.name
            componentPreviewCard.colorCode = componentFile.value
            componentPreviewCard.color = componentFile.color
            componentPreviewCard.onDoubleClick = {
                self.onClickColor?(componentFile.id)
            }
        }

        return item
    }
}

// MARK: - ColorPreviewItemViewController

class ColorPreviewItemViewController: NSCollectionViewItem {
    override func loadView() {
        view = DoubleClickableColorPreviewCard()
    }

    override var isSelected: Bool {
        get {
            return (view as? DoubleClickableColorPreviewCard)?.selected ?? false
        }
        set {
            (view as? DoubleClickableColorPreviewCard)?.selected = newValue
        }
    }
}

// MARK: - ColorPreviewCollection

public class ColorPreviewCollection: NSBox {

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

    public var onClickColor: ((String) -> Void)?

    // MARK: Private

    private let collectionView = ColorPreviewCollectionView(frame: .zero)

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        collectionView.items = CSColors.colors

        _ = LonaPlugins.current.register(eventTypes: [.onSaveColors, .onReloadWorkspace], handler: {
            self.collectionView.items = CSColors.colors
            self.collectionView.reloadData()
        })

        collectionView.onMoveColor = { sourceIndex, targetIndex in
            CSColors.moveColor(from: sourceIndex, to: targetIndex)
            self.collectionView.items = CSColors.colors
            self.collectionView.moveItem(from: sourceIndex, to: targetIndex)
        }

        collectionView.onDeleteColor = { index in
            CSColors.deleteColor(at: index)
            self.collectionView.items = CSColors.colors
            self.collectionView.deleteItem(at: index)
        }

        // TODO: This callback should propagate up to the root. Currently Lona doesn't
        // generate callbacks with params, so we'll handle it here for now.
        collectionView.onClickColor = { color in
            guard let csColor = CSColors.colors.first(where: { $0.id == color }) else { return }
            guard let index = CSColors.colors.index(where: { $0.id == color }) else { return }

            let editor = DictionaryEditor(
                value: csColor.toValue(),
                onChange: { updated in
                    CSColors.update(color: updated.data, at: index)
            },
                layout: CSConstraint.size(width: 300, height: 200)
            )

            let viewController = NSViewController(view: editor)
            let popover = NSPopover(contentViewController: viewController, delegate: self)

            guard let cardView = self.collectionView.cardView(at: index) else { return }
            popover.show(relativeTo: NSRect.zero, of: cardView, preferredEdge: .maxY)
        }

        addSubview(collectionView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: collectionView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: collectionView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
    }

    private func update() {}
}

extension ColorPreviewCollection: NSPopoverDelegate {

}
