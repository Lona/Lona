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
private let README_ITEM_IDENTIFIER = NSUserInterfaceItemIdentifier(rawValue: "readme")

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

    public var readme: String = "" { didSet { if oldValue != readme { update(withoutReloading: true) } } }
    public var items: [LonaModule.ComponentFile] = [] { didSet { update(withoutPrefixChange: true) } }
    public var onSelectItem: ((String) -> Void)? { didSet { update(withoutReloading: true, withoutPrefixChange: true) } }

    // MARK: - Private

    private let collectionView = NSCollectionView(frame: .zero)
    private let scrollView = NSScrollView()
    private var renderedPrefix: NSMutableAttributedString = NSMutableAttributedString(string: "")

    private func setUpViews() {
        wantsLayer = true

        let flowLayout = NSCollectionViewFlowLayout()

        // Items have a built-in padding of 4
        flowLayout.sectionInset = NSEdgeInsets(top: 36, left: 64 - 4, bottom: 36, right: 64 - 4)

        flowLayout.minimumLineSpacing = 24
        flowLayout.minimumInteritemSpacing = 12
        flowLayout.itemSize = NSSize(width: 260, height: 240)
        flowLayout.footerReferenceSize = NSSize(width: self.bounds.width - 64 - 64, height: 33)

        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColors = [NSColor.clear]
        collectionView.register(
            ComponentPreviewItemViewController.self,
            forItemWithIdentifier: ITEM_IDENTIFIER)
        collectionView.register(
            ReadmePreview.self,
            forSupplementaryViewOfKind: .sectionFooter,
            withIdentifier: README_ITEM_IDENTIFIER)
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

    private func update(withoutReloading: Bool = false, withoutPrefixChange: Bool = false) {
        if !withoutReloading {
            collectionView.reloadData()
        }
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
                self.onSelectItem?(componentFile.url.path)
            }
        }

        return item
    }

    private func onReadmeHeightChanged(_ height: CGFloat) {
        if let flowLayout = collectionView.collectionViewLayout as? NSCollectionViewFlowLayout {
            if readme == "" {
                // we need to keep at least 33px otherwise the webview stop being rendered
                // and we won't get any update anymore
                flowLayout.footerReferenceSize = NSSize(width: self.bounds.width - 64 - 64, height: 33)
            } else {
                flowLayout.footerReferenceSize = NSSize(
                    width: self.bounds.width - 64 - 64,
                    height: height)
            }
        }
    }

    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        if kind == .sectionFooter && indexPath.item == 0 {
            let item = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: README_ITEM_IDENTIFIER, for: indexPath) as! ReadmePreview

            item.onReadmeHeightChanged = onReadmeHeightChanged
            item.readme = readme

            return item
        }
        return NSView()
    }
}

// MARK: - ReadmePreview

class ReadmePreview: NSBox {
    public struct Parameters: Equatable {
        public var readme: String

        public init(readme: String) {
            self.readme = readme
        }

        public init() {
            self.init(readme: "")
        }

        public static func == (lhs: Parameters, rhs: Parameters) -> Bool {
            return lhs.readme == rhs.readme
        }
    }

    // MARK: Lifecycle

    public init(_ parameters: Parameters) {
        self.parameters = parameters

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public convenience init(readme: String) {
        self.init(Parameters(readme: readme))
    }

    public convenience init() {
        self.init(Parameters())
    }

    public override convenience init(frame: NSRect) {
        self.init(Parameters())
    }

    public required init?(coder aDecoder: NSCoder) {
        self.parameters = Parameters()

        super.init(coder: aDecoder)

        setUpViews()
        setUpConstraints()

        update()
    }

    // MARK: Public

    public var readme: String {
        get { return parameters.readme }
        set {
            if parameters.readme != newValue {
                parameters.readme = newValue
            }
        }
    }

    public var parameters: Parameters {
        didSet {
            if parameters != oldValue {
                update()
            }
        }
    }

    public var scrollViewHeight: CGFloat = 0
    public var onReadmeHeightChanged: ((CGFloat) -> Void)?

    // MARK: Private

    private var markdownEditorView = MarkdownEditor(editable: false)

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        markdownEditorView.delegateScroll(onHeightChanged: {height in
            self.onReadmeHeightChanged?(height + 64)
        })

        markdownEditorView.load()

        addSubview(markdownEditorView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        markdownEditorView.translatesAutoresizingMaskIntoConstraints = false

        let textViewTopAnchorConstraint = markdownEditorView.topAnchor.constraint(equalTo: topAnchor, constant: 32)
        let textViewBottomAnchorConstraint = markdownEditorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 32)
        let textViewLeadingAnchorConstraint = markdownEditorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
        let textViewTrailingAnchorConstraint = markdownEditorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)

        NSLayoutConstraint.activate([
            textViewTopAnchorConstraint,
            textViewBottomAnchorConstraint,
            textViewLeadingAnchorConstraint,
            textViewTrailingAnchorConstraint
            ])
    }

    private func update() {
        markdownEditorView.markdownString = readme
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

    public var readme: String = "" { didSet { update() } }
    public var componentNames: [String] = [] { didSet { update() } }
    public var onSelectComponent: ((String) -> Void)? { didSet { update() } }

    // MARK: Private

    private let collectionView = ComponentPreviewCollectionView(frame: .zero)

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        addSubview(collectionView)

        update()
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
        var components: [LonaModule.ComponentFile] = []

        componentNames.enumerated().forEach {offset, name in
            let component = LonaModule.current.componentFile(named: name)

            if let component = component {
                components.append(component)
            }
        }
        collectionView.items = components
        collectionView.readme = readme
        collectionView.onSelectItem = onSelectComponent
    }
}
