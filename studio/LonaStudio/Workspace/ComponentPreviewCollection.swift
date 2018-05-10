//
//  ComponentPreviewCollection.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/10/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

private let ITEM_IDENTIFIER = NSUserInterfaceItemIdentifier(rawValue: "component")

class ComponentPreviewCollectionView: NSView {

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

    public var items: [LonaModule.ComponentFile] = [] { didSet { update() } }
    public var onClickComponent: ((URL) -> Void)?

    // MARK: - Private

    private let collectionView = NSCollectionView(frame: .zero)
    private let scrollView = NSScrollView()

    private func setUpViews() {
        wantsLayer = true

        let gridLayout = NSCollectionViewGridLayout()
        gridLayout.minimumItemSize = NSSize(width: 240, height: 240)
        gridLayout.maximumItemSize = NSSize(width: 264, height: 240)
        gridLayout.minimumLineSpacing = 24
        gridLayout.minimumInteritemSpacing = 24
        gridLayout.margins = NSEdgeInsetsZero
        gridLayout.maximumNumberOfColumns = 3

        collectionView.collectionViewLayout = gridLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColors = [NSColor.clear]
        collectionView.register(
            ComponentPreviewItemViewController.self,
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

// MARK: - NSCollectionViewDelegate

extension ComponentPreviewCollectionView: NSCollectionViewDelegate {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
}

// MARK: - NSCollectionViewDataSource

extension ComponentPreviewCollectionView: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: ITEM_IDENTIFIER,
            for: indexPath) as! ComponentPreviewItemViewController

        if let componentPreviewCard = item.view as? ComponentPreviewCard {
            let componentFile = items[indexPath.item]
            componentPreviewCard.componentName = componentFile.name
            componentPreviewCard.onClick = {
                self.onClickComponent?(componentFile.url)
            }
        }

        return item
    }
}

// MARK: - ComponentPreviewItemViewController

class ComponentPreviewItemViewController: NSCollectionViewItem {
    override func loadView() {
        view = ComponentPreviewCard()
    }
}

// MARK: - ComponentPreviewCollection

public class ComponentPreviewCollection: NSBox {

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

    public var onClickComponent: ((URL) -> Void)?

    // MARK: Private

    private let collectionView = ComponentPreviewCollectionView(frame: .zero)

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        collectionView.items = LonaModule.current.componentFiles().sorted(by: { a, b in
            return a.name < b.name
        })

        // TODO: This callback should propagate up to the root. Currently Lona doesn't
        // generate callbacks with params, so we'll handle it here for now.
        collectionView.onClickComponent = { url in
            let documentController = NSDocumentController.shared

            documentController.openDocument(withContentsOf: url, display: true) { (_, documentWasAlreadyOpen, error) in
                if error != nil {
                    Swift.print("An error occurred")
                } else {
                    if documentWasAlreadyOpen {
                        Swift.print("documentWasAlreadyOpen: true")
                    } else {
                        Swift.print("documentWasAlreadyOpen: false")
                    }
                }
            }
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
