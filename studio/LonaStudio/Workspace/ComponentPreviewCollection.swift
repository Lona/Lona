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
private let LOGIC_ITEM_IDENTIFIER = NSUserInterfaceItemIdentifier(rawValue: "logic")
private let COLLECTION_VIEW_MARGIN = CGSize(width: 64, height: 32)

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

private class DoubleClickableLogicPreviewCard: LogicPreviewCard {
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
    public var logicItems: [URL] = [] { didSet { update(withoutPrefixChange: true) } }
    public var onSelectItem: ((String) -> Void)? { didSet { update(withoutReloading: true, withoutPrefixChange: true) } }

    // MARK: - Private

    private let collectionView = NSCollectionView(frame: .zero)
    private let scrollView = NSScrollView()
    private var renderedPrefix: NSMutableAttributedString = NSMutableAttributedString(string: "")
    private var flowLayout = NSCollectionViewFlowLayout()

    private var isEmpty: Bool {
        return items.isEmpty && logicItems.isEmpty
    }

    private func setUpViews() {
        wantsLayer = true

        // Items have a built-in padding of 4
        flowLayout.sectionInset = NSEdgeInsets(
            top: COLLECTION_VIEW_MARGIN.height,
            left: COLLECTION_VIEW_MARGIN.width - 4,
            bottom: 0,
            right: COLLECTION_VIEW_MARGIN.width - 4)

        flowLayout.minimumLineSpacing = 24
        flowLayout.minimumInteritemSpacing = 12
        flowLayout.itemSize = NSSize(width: 260, height: 240)

        // Reference height must be greater than 0 to render a footer
        flowLayout.footerReferenceSize = NSSize(width: self.bounds.width, height: 1)

        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColors = [NSColor.clear]
        collectionView.register(
            ComponentPreviewItemViewController.self,
            forItemWithIdentifier: ITEM_IDENTIFIER)
        collectionView.register(
            LogicPreviewItemViewController.self,
            forItemWithIdentifier: LOGIC_ITEM_IDENTIFIER)
        collectionView.register(
            ReadmePreview.self,
            forSupplementaryViewOfKind: NSCollectionView.elementKindSectionFooter,
            withIdentifier: README_ITEM_IDENTIFIER)
        collectionView.isSelectable = true

        scrollView.verticalScrollElasticity = .allowed
        scrollView.horizontalScrollElasticity = .allowed
        scrollView.allowsMagnification = true
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
        flowLayout.sectionInset.bottom = (isEmpty || readme.isEmpty) ? 0 : COLLECTION_VIEW_MARGIN.height

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
        return items.count + logicItems.count
    }
}

// MARK: - NSCollectionViewDataSource

extension ComponentPreviewCollectionView: NSCollectionViewDataSource {
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        if indexPath.item < items.count {
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
        } else {
            let item = collectionView.makeItem(
                withIdentifier: LOGIC_ITEM_IDENTIFIER,
                for: indexPath) as! LogicPreviewItemViewController

            if let logicPreviewCard = item.view as? DoubleClickableLogicPreviewCard {
                let componentFile = logicItems[indexPath.item - items.count]
                let imageSize = NSSize(width: 252, height: 210)
                let image = LogicViewController.thumbnail(
                    for: componentFile,
                    within: imageSize,
                    canvasSize: .init(width: 800, height: 800),
                    viewportRect: .init(x: 0, y: 0, width: 400, height: 400 * imageSize.height / imageSize.width),
                    style: .standard
                )
                logicPreviewCard.titleText = componentFile.deletingPathExtension().lastPathComponent
                logicPreviewCard.image = image
                logicPreviewCard.onDoubleClick = {
                    self.onSelectItem?(componentFile.path)
                }
            }

            return item
        }
    }

    private func onReadmeHeightChanged(_ height: CGFloat) {
        if let flowLayout = collectionView.collectionViewLayout as? NSCollectionViewFlowLayout {
            // Height must be greater than the reference height (which is hardcoded as 1),
            // otherwise the webview stops being rendered and we won't get any more updates
            let safeHeight = max(readme.isEmpty ? 2 : height, 2)

            flowLayout.footerReferenceSize = NSSize(width: self.bounds.width, height: safeHeight)
        }
    }

    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        if kind == NSCollectionView.elementKindSectionFooter && indexPath.item == 0 {
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

    private var markdownEditorView = MarkdownEditor(editable: false, fullscreen: false)

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        markdownEditorView.delegateScroll(onHeightChanged: {height in
            self.onReadmeHeightChanged?(height + COLLECTION_VIEW_MARGIN.height)
        })

        markdownEditorView.load()

        addSubview(markdownEditorView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        markdownEditorView.translatesAutoresizingMaskIntoConstraints = false

        let textViewTopAnchorConstraint = markdownEditorView.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        let textViewBottomAnchorConstraint = markdownEditorView.bottomAnchor
            .constraint(equalTo: bottomAnchor, constant: COLLECTION_VIEW_MARGIN.height)
        let textViewLeadingAnchorConstraint = markdownEditorView.leadingAnchor
            .constraint(equalTo: leadingAnchor, constant: COLLECTION_VIEW_MARGIN.width)
        let textViewTrailingAnchorConstraint = markdownEditorView.trailingAnchor
            .constraint(equalTo: trailingAnchor, constant: -COLLECTION_VIEW_MARGIN.width)

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


// MARK: - LogicPreviewItemViewController

class LogicPreviewItemViewController: NSCollectionViewItem {
    override func loadView() {
        view = DoubleClickableLogicPreviewCard()
    }

    override var isSelected: Bool {
        get {
            return (view as? DoubleClickableLogicPreviewCard)?.selected ?? false
        }
        set {
            (view as? DoubleClickableLogicPreviewCard)?.selected = newValue
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
    public var logicFileNames: [String] = [] { didSet { update() } }
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

        collectionView.logicItems = logicFileNames.map { URL(fileURLWithPath: $0) }

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
