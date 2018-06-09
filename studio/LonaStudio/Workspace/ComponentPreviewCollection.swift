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

private class DoubleClickableComponentPreviewCard: ComponentPreviewCard {
    var onDoubleClick: (() -> Void)?

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            onDoubleClick?()
        } else {
            super.mouseDown(with: event)
        }
    }
}

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
    public var onClickComponent: ((URL) -> Void)? { didSet { update(withoutReloading: true) } }
    public var onCopy: ((Int) -> Void)? { didSet { update(withoutReloading: true) } }

    // MARK: - Private

    private let collectionView = KeyHandlingCollectionView(frame: .zero)
    private let scrollView = NSScrollView()

    private func setUpViews() {
        wantsLayer = true

        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 24
        flowLayout.minimumInteritemSpacing = 12
        flowLayout.itemSize = NSSize(width: 260, height: 240)

        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColors = [NSColor.clear]
        collectionView.register(
            ComponentPreviewItemViewController.self,
            forItemWithIdentifier: ITEM_IDENTIFIER)
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

        collectionView.onCopy = onCopy
    }
}

extension ComponentPreviewCollectionView {
    func reloadData() {
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

        if let componentPreviewCard = item.view as? DoubleClickableComponentPreviewCard {
            let componentFile = items[indexPath.item]
            componentPreviewCard.componentName = componentFile.name
            componentPreviewCard.onDoubleClick = {
                self.onClickComponent?(componentFile.url)
            }
        }

        return item
    }
}

// MARK: - ComponentPreviewItemViewController

class ComponentPreviewItemViewController: NSCollectionViewItem {
    override func loadView() {
        view = DoubleClickableComponentPreviewCard()
    }

    override var isSelected: Bool {
        get {
            return (view as? DoubleClickableComponentPreviewCard)?.selected ?? false
        }
        set {
            (view as? DoubleClickableComponentPreviewCard)?.selected = newValue
        }
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

        let updateHandler: () -> Void = {
            self.collectionView.items = LonaModule.current.componentFiles().sorted(by: { a, b in
                return a.name < b.name
            })
            self.collectionView.reloadData()
        }

        _ = LonaPlugins.current.register(eventTypes: [.onSaveColors, .onSaveComponent, .onReloadWorkspace], handler: updateHandler)

        collectionView.onCopy = { index in
            let item = self.collectionView.items[index]

            guard let component = LonaModule.current.component(named: item.name),
                let canvas = component.computedCanvases().first,
                let caseItem = component.computedCases(for: canvas).first
                else { return }

            let config = ComponentConfiguration(
                component: component,
                arguments: caseItem.value.objectValue,
                canvas: canvas
            )

            let canvasView = CanvasView(
                canvas: canvas,
                rootLayer: component.rootLayer,
                config: config,
                options: [RenderOption.assetScale(1)]
            )

            NSPasteboard.general.clearContents()

            if let data = canvasView.dataRepresentation(scaledBy: 1), let image = NSImage(data: data) {
                NSPasteboard.general.writeObjects([image])
            }
        }

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
