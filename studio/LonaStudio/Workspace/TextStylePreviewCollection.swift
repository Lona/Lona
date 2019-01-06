//
//  TextStylePreviewCollection.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/10/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

private let ITEM_IDENTIFIER = NSUserInterfaceItemIdentifier(rawValue: "textStyle")
private let TEXT_STYLE_PASTEBOARD_TYPE = NSPasteboard.PasteboardType("textStyle")

class DoubleClickableTextStylePreviewCard: TextStylePreviewCard {
    var onDoubleClick: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            onDoubleClick?()
        } else {
            super.mouseDown(with: event)
        }
    }
}

class TextStylePreviewCollectionView: NSView {

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

    public var items: [CSTextStyle] = [] { didSet { update() } }
    public var onSelectTextStyle: TextStyleHandler { didSet { update(withoutReloading: true) } }
    public var onMoveTextStyle: ItemMoveHandler { didSet { update(withoutReloading: true) } }
    public var onDeleteTextStyle: TextStyleHandler { didSet { update(withoutReloading: true) } }

    // MARK: - Private

    fileprivate let collectionView = KeyHandlingCollectionView(frame: .zero)
    private let scrollView = NSScrollView()

    private func setUpViews() {
        wantsLayer = true

        let flowLayout = NSCollectionViewFlowLayout()

        // Items have a built-in padding of 4
        flowLayout.sectionInset = NSEdgeInsets(top: 36, left: 64 - 4, bottom: 36, right: 64 - 4)

        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 12

        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColors = [NSColor.clear]
        collectionView.register(
            TextStylePreviewItemViewController.self,
            forItemWithIdentifier: ITEM_IDENTIFIER)
        collectionView.registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeItem as String)])
        collectionView.setDraggingSourceOperationMask(.move, forLocal: true)
        collectionView.isSelectable = true

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

        collectionView.onDeleteItem = { index in
            self.onDeleteTextStyle?(self.items[index])
        }
    }
}

// MARK: - Imperative API

extension TextStylePreviewCollectionView {
//    func cardView(at index: Int) -> DoubleClickableTextStylePreviewCard? {
//        guard let item = collectionView.item(at: index) as? TextStylePreviewItemViewController else { return nil }
//        return item.view as? DoubleClickableTextStylePreviewCard
//    }

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

extension TextStylePreviewCollectionView: NSCollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: NSCollectionView,
        layout collectionViewLayout: NSCollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> NSSize {

        let textStyle = items[indexPath.item]

        return NSSize(
            width: 260,
            height: 32 + (textStyle.font.lineHeight ??
                ceil(textStyle.font.nsFont.ascender - textStyle.font.nsFont.descender)))
    }
}

// MARK: - NSCollectionViewDelegate

extension TextStylePreviewCollectionView: NSCollectionViewDelegate {
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

        pasteboard.declareTypes([TEXT_STYLE_PASTEBOARD_TYPE], owner: self)
        pasteboard.setData(data, forType: TEXT_STYLE_PASTEBOARD_TYPE)

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
        guard let data = draggingInfo.draggingPasteboard().data(forType: TEXT_STYLE_PASTEBOARD_TYPE),
            let sourceIndexPath = CSData.from(data: data)?.array?.first?.number else {
                Swift.print("Can't move text style item - bad pasteboard data")
                return false
        }

        onMoveTextStyle?(Int(sourceIndexPath), indexPath.item)

        return true
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            self.onSelectTextStyle?(nil)
            return
        }

        self.onSelectTextStyle?(items[indexPath.item])
    }

    func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
        self.onSelectTextStyle?(nil)
    }
}

// MARK: - NSCollectionViewDataSource

extension TextStylePreviewCollectionView: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: ITEM_IDENTIFIER,
            for: indexPath) as! TextStylePreviewItemViewController

        if let textStylePreviewCard = item.view as? DoubleClickableTextStylePreviewCard {
            let textStyle = items[indexPath.item]
            textStylePreviewCard.example = textStyle.name
            textStylePreviewCard.textStyleSummary = textStyle.summary
            textStylePreviewCard.textStyle = textStyle.font
            textStylePreviewCard.inverse = textStyle.getCSColor().color.isLightColor
//            textStylePreviewCard.onDoubleClick = {
//                self.onSelectTextStyle?(textStyle)
//            }
        }

        return item
    }
}

// MARK: - TextStylePreviewItemViewController

class TextStylePreviewItemViewController: NSCollectionViewItem {
    override func loadView() {
        view = DoubleClickableTextStylePreviewCard()
    }

    override var isSelected: Bool {
        get {
            return (view as? DoubleClickableTextStylePreviewCard)?.selected ?? false
        }
        set {
            (view as? DoubleClickableTextStylePreviewCard)?.selected = newValue
        }
    }
}

// MARK: - TextStylePreviewCollection

public class TextStylePreviewCollection: NSBox {

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
    public var textStyles: [CSTextStyle]? = [] { didSet { update() } }
    public var onClickTextStyle: ((CSTextStyle) -> Void)?
    public var onSelectTextStyle: TextStyleHandler
    public var onMoveTextStyle: ItemMoveHandler
    public var onDeleteTextStyle: TextStyleHandler

    // MARK: Private

    private var selectedTextStyleId: String?

    private let collectionView = TextStylePreviewCollectionView(frame: .zero)

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        collectionView.items = CSTypography.styles

        collectionView.onMoveTextStyle = { sourceIndex, targetIndex in
            self.onMoveTextStyle?(sourceIndex, targetIndex)
        }

        collectionView.onDeleteTextStyle = { textStyle in
            self.selectedTextStyleId = nil
            self.onDeleteTextStyle?(textStyle)
        }

        collectionView.onSelectTextStyle = { textStyle in
            self.selectedTextStyleId = textStyle?.id
            self.onSelectTextStyle?(textStyle)
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

    private func update(withoutReloading: Bool = false) {
        collectionView.items = textStyles ?? []

        if let index = textStyles?.index(where: { $0.id == selectedTextStyleId }) {
            collectionView.collectionView.selectionIndexPaths = [IndexPath(item: index, section: 0)]
        }
    }
}

extension TextStylePreviewCollection: NSPopoverDelegate {

}
