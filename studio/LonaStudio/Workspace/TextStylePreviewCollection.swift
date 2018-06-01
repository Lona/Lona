//
//  TextStylePreviewCollection.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/10/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

private let ITEM_IDENTIFIER = NSUserInterfaceItemIdentifier(rawValue: "color")
private let COLOR_PASTEBOARD_TYPE = NSPasteboard.PasteboardType("textStyle")

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
    public var onClickTextStyle: ((String) -> Void)?

    // MARK: - Private

    private let collectionView = NSCollectionView(frame: .zero)
    private let scrollView = NSScrollView()

    private func setUpViews() {
        wantsLayer = true

        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 24
        flowLayout.minimumInteritemSpacing = 24

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

    private func update() {
        collectionView.reloadData()
    }
}

// MARK: - Imperative API

extension TextStylePreviewCollectionView {
    func cardView(at index: Int) -> DoubleClickableTextStylePreviewCard? {
        guard let item = collectionView.item(at: index) as? TextStylePreviewItemViewController else { return nil }
        return item.view as? DoubleClickableTextStylePreviewCard
    }

    func reloadData() {
        collectionView.reloadData()
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
            height: textStyle.font.lineHeight + 81)
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
        NSPasteboard.general.declareTypes([NSPasteboard.PasteboardType(kUTTypeItem as String)], owner: self)

        return true
    }

    func collectionView(_ collectionView: NSCollectionView, writeItemsAt indexPaths: Set<IndexPath>, to pasteboard: NSPasteboard) -> Bool {
        return true
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
            textStylePreviewCard.previewBackgroundColor = textStyle.color?.contrastingLabelColor ?? .clear
            textStylePreviewCard.onDoubleClick = {
                
            }
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

    public var onClickTextStyle: ((String) -> Void)?

    // MARK: Private

    private let collectionView = TextStylePreviewCollectionView(frame: .zero)

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        collectionView.items = CSTypography.styles

        // TODO: Not this
        _ = LonaPlugins.current.register(eventTypes: [.onSaveTextStyles, .onReloadWorkspace], handler: {
            self.collectionView.items = CSTypography.styles
            self.collectionView.reloadData()
        })

//        collectionView.onMoveColor = { sourceIndex, targetIndex in
//            CSColors.moveColor(from: sourceIndex, to: targetIndex)
//            self.collectionView.items = CSColors.colors
//            self.collectionView.moveItem(from: sourceIndex, to: targetIndex)
//        }
//
//        collectionView.onDeleteColor = { index in
//            CSColors.deleteColor(at: index)
//            self.collectionView.items = CSColors.colors
//            self.collectionView.deleteItem(at: index)
//        }

        // TODO: This callback should propagate up to the root. Currently Lona doesn't
        // generate callbacks with params, so we'll handle it here for now.
        collectionView.onClickTextStyle = { color in
//            guard let csTextStyle = CSTypography.styles.first(where: { $0.id == color }) else { return }
//            guard let index = CSTypography.styles.index(where: { $0.id == color }) else { return }
//
//            let editor = DictionaryEditor(
//                value: csTextStyle.toValue(),
//                onChange: { updated in
//                    CSTextStyles.updateAndSave(color: updated.data, at: index)
//            },
//                layout: CSConstraint.size(width: 300, height: 200)
//            )
//
//            let viewController = NSViewController(view: editor)
//            let popover = NSPopover(contentViewController: viewController, delegate: self)
//
//            guard let cardView = self.collectionView.cardView(at: index) else { return }
//            popover.show(relativeTo: NSRect.zero, of: cardView, preferredEdge: .maxY)
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

extension TextStylePreviewCollection: NSPopoverDelegate {

}
