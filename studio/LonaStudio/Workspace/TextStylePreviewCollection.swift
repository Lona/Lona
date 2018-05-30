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
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 24
        flowLayout.minimumInteritemSpacing = 24

        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColors = [NSColor.clear]
        collectionView.register(
            TextStylePreviewItemViewController.self,
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

    private func update() {
        collectionView.reloadData()
    }
}

// MARK: - Imperative API

extension TextStylePreviewCollectionView {
    func cardView(at index: Int) -> TextStylePreviewCard? {
        guard let item = collectionView.item(at: index) as? TextStylePreviewItemViewController else { return nil }
        return item.view as? TextStylePreviewCard
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
            width: collectionView.frame.size.width,
            height: textStyle.font.lineHeight + 104)
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
}

// MARK: - NSCollectionViewDataSource

extension TextStylePreviewCollectionView: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: ITEM_IDENTIFIER,
            for: indexPath) as! TextStylePreviewItemViewController

        if let textStylePreviewCard = item.view as? TextStylePreviewCard {
            let textStyle = items[indexPath.item]
            textStylePreviewCard.example = "The quick brown fox jumped over the lazy dog"
            textStylePreviewCard.textStyleName = textStyle.name
            textStylePreviewCard.textStyleSummary = textStyle.summary
            textStylePreviewCard.textStyle = textStyle.font
            textStylePreviewCard.onClick = {
                self.onClickTextStyle?(textStyle.id)
            }
        }

        return item
    }
}

// MARK: - TextStylePreviewItemViewController

class TextStylePreviewItemViewController: NSCollectionViewItem {
    override func loadView() {
        view = TextStylePreviewCard()
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
