//
//  TemplatePreviewCollection.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/9/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit

private let ITEM_IDENTIFIER = NSUserInterfaceItemIdentifier(rawValue: "template")

// MARK: - TemplatePreviewCollection

public class TemplatePreviewCollection: NSBox {

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

    public var templateTitles: [String] = [] { didSet { update() } }

    public var templateDescriptions: [String] = [] { didSet { update() } }

    public var templateImages: [NSImage] = [] { didSet { update() } }

    public var selectedTemplateIndex: Int = 0 { didSet { update() } }

    public var onSelectTemplateIndex: ((Int) -> Void)? {
        get { collectionView.onSelectTemplateIndex }
        set { collectionView.onSelectTemplateIndex = newValue }
    }

    public var onDoubleClickTemplateIndex: ((Int) -> Void)?

    // MARK: Private

    private let collectionView = TemplatePreviewCollectionView(frame: .zero)

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        addSubview(collectionView)

        // Due to the collection view re-rendering (?), indexes change between the first and second click.
        // So we ignore the index pass to this function and use the selected index instead
        collectionView.onDoubleClickTemplateIndex = { [unowned self] _ in
            self.onDoubleClickTemplateIndex?(self.selectedTemplateIndex)
        }
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: collectionView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: collectionView.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: collectionView.bottomAnchor).isActive = true
    }

    private func update() {
        var templateCards: [WorkspaceTemplateCard.Parameters] = []

        zip(zip(templateTitles, templateDescriptions), templateImages).enumerated().forEach { index, data in
            templateCards.append(.init(titleText: data.0.0, descriptionText: data.0.1, isSelected: index == selectedTemplateIndex, image: data.1))
        }

        collectionView.items = templateCards
        collectionView.collectionView.selectionIndexPaths = [IndexPath(item: selectedTemplateIndex, section: 0)]
    }
}

// MARK: - TemplatePreviewCollectionView

class TemplatePreviewCollectionView: NSView {

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

    public var items: [WorkspaceTemplateCard.Parameters] = [] { didSet { update() } }
    public var onSelectTemplateIndex: ((Int) -> Void)?
    public var onDoubleClickTemplateIndex: ((Int) -> Void)?

    // MARK: Private

    fileprivate let collectionView = KeyHandlingCollectionView(frame: .zero)
    private let scrollView = NSScrollView()

    private func setUpViews() {
        wantsLayer = true

        let flowLayout = NSCollectionViewFlowLayout()

        flowLayout.sectionInset = .init(top: 0, left: 40 - 12, bottom: 16, right: 40 - 12)
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = NSSize(width: 216, height: 220)

        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColors = [NSColor.clear]

        collectionView.isSelectable = true
        collectionView.allowsEmptySelection = false

        collectionView.register(TemplatePreviewItemViewController.self, forItemWithIdentifier: ITEM_IDENTIFIER)

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
    }
}

// MARK: - DoubleClickableTemplatePreviewCard

private class DoubleClickableTemplatePreviewCard: WorkspaceTemplateCard {
    var onDoubleClick: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            onDoubleClick?()
        } else {
            super.mouseDown(with: event)
        }
    }
}

// MARK: - Imperative API

extension TemplatePreviewCollectionView {
    func reloadData() {
        collectionView.reloadData()
    }
}

// MARK: - NSCollectionViewDelegate

extension TemplatePreviewCollectionView: NSCollectionViewDelegate {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }

        self.onSelectTemplateIndex?(indexPath.item)
    }
}

// MARK: - NSCollectionViewDataSource

extension TemplatePreviewCollectionView: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: ITEM_IDENTIFIER, for: indexPath) as! TemplatePreviewItemViewController

        if let view = item.view as? DoubleClickableTemplatePreviewCard {
            let item = indexPath.item
            view.parameters = items[item]
            view.onPressCard = { [unowned self] in self.onSelectTemplateIndex?(item) }
            view.onDoubleClick = { [unowned self] in self.onDoubleClickTemplateIndex?(item) }
        }

        return item
    }
}

// MARK: - TemplatePreviewItemViewController

class TemplatePreviewItemViewController: NSCollectionViewItem {
    override func loadView() {
        view = DoubleClickableTemplatePreviewCard()
    }

    override var isSelected: Bool {
        get {
            return (view as? DoubleClickableTemplatePreviewCard)?.isSelected ?? false
        }
        set {
            (view as? DoubleClickableTemplatePreviewCard)?.isSelected = newValue
        }
    }
}
