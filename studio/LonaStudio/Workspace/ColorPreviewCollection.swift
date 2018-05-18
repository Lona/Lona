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
    public var onClickColor: ((String) -> Void)?

    // MARK: - Private

    private let collectionView = NSCollectionView(frame: .zero)
    private let scrollView = NSScrollView()

    private func setUpViews() {
        wantsLayer = true

        let gridLayout = NSCollectionViewGridLayout()
        gridLayout.minimumItemSize = NSSize(width: 140, height: 160)
        gridLayout.maximumItemSize = NSSize(width: 160, height: 160)
        gridLayout.minimumLineSpacing = 24
        gridLayout.minimumInteritemSpacing = 24
        gridLayout.margins = NSEdgeInsetsZero
        gridLayout.maximumNumberOfColumns = 5

        collectionView.collectionViewLayout = gridLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColors = [NSColor.clear]
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

    private func update() {
        collectionView.reloadData()
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
}

// MARK: - NSCollectionViewDelegate

extension ColorPreviewCollectionView: NSCollectionViewDelegate {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
}

// MARK: - NSCollectionViewDataSource

extension ColorPreviewCollectionView: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: ITEM_IDENTIFIER,
            for: indexPath) as! ColorPreviewItemViewController

        if let componentPreviewCard = item.view as? ColorPreviewCard {
            let componentFile = items[indexPath.item]
            componentPreviewCard.colorName = componentFile.name
            componentPreviewCard.colorCode = componentFile.value
            componentPreviewCard.color = componentFile.color
            componentPreviewCard.onClick = {
                self.onClickColor?(componentFile.id)
            }
        }

        return item
    }
}

// MARK: - ColorPreviewItemViewController

class ColorPreviewItemViewController: NSCollectionViewItem {
    override func loadView() {
        view = ColorPreviewCard()
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

        // TODO: Not this
        LonaPlugins.current.register(handler: {
            self.collectionView.items = CSColors.colors
            self.collectionView.reloadData()
        }, for: .onSaveColors)

        // TODO: This callback should propagate up to the root. Currently Lona doesn't
        // generate callbacks with params, so we'll handle it here for now.
        collectionView.onClickColor = { color in
            guard let csColor = CSColors.colors.first(where: { $0.id == color }) else { return }
            guard let index = CSColors.colors.index(where: { $0.id == color }) else { return }

            let editor = DictionaryEditor(
                value: csColor.toValue(),
                onChange: { updated in
                    CSColors.updateAndSave(color: updated.data, at: index)
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
