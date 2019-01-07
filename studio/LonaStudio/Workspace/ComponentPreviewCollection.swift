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

    public var prefix: String = "" { didSet { if oldValue != prefix { update(withoutReloading: true) } } }
    public var items: [LonaModule.ComponentFile] = [] { didSet { update(withoutPrefixChange: true) } }
    public var onSelectComponent: ((URL) -> Void)? { didSet { update(withoutReloading: true, withoutPrefixChange: true) } }

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
        flowLayout.headerReferenceSize = NSSize(width: self.bounds.width - 64 - 64, height: 400)

        collectionView.collectionViewLayout = flowLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColors = [NSColor.clear]
        collectionView.register(
            ComponentPreviewItemViewController.self,
            forItemWithIdentifier: ITEM_IDENTIFIER)
        collectionView.register(
            ReadmePreview.self,
            forSupplementaryViewOfKind: .sectionHeader,
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

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            return
        }
        self.onSelectComponent?(items[indexPath.item].url)
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
        }

        return item
    }

    private func onReadmeHeightChanged(_ height: CGFloat) {
        if let flowLayout = collectionView.collectionViewLayout as? NSCollectionViewFlowLayout {
            if prefix == "" {
                flowLayout.headerReferenceSize = NSSize(
                    width: 0,
                    height: 0)
            } else {
                flowLayout.headerReferenceSize = NSSize(
                    width: self.bounds.width - 64 - 64,
                    height: height)
            }
        }
    }

    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        if kind == .sectionHeader && indexPath.item == 0 {
            let item = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: README_ITEM_IDENTIFIER, for: indexPath) as! ReadmePreview

            item.onReadmeHeightChanged = onReadmeHeightChanged
            item.readme = prefix

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

    private var markdownEditorView = LonaWebView()
    private var markdownEditorLoaded = false { didSet { update() } }

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        markdownEditorView.delegateScroll(onHeightChanged: {height in
            self.onReadmeHeightChanged?(height)
        })

        let app = Bundle.main.resourceURL!.appendingPathComponent("Web")
        let url = app.appendingPathComponent("markdown-editor.html")
        markdownEditorView.loadLocalApp(main: url, directory: app)
        markdownEditorView.onMessage = { data in
            guard let messageType = data.get(key: "type").string else { return }

            switch messageType {
            case "ready":
                self.markdownEditorLoaded = true
            default:
                break
            }
        }

        addSubview(markdownEditorView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        markdownEditorView.translatesAutoresizingMaskIntoConstraints = false

        let textViewTopAnchorConstraint = markdownEditorView.topAnchor.constraint(equalTo: topAnchor, constant: 32)
        let textViewBottomAnchorConstraint = markdownEditorView.bottomAnchor.constraint(equalTo: bottomAnchor)
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
        let payload1 = CSData.Object([
            "type": "setEditable".toData(),
            "payload": false.toData()
            ])
        if let json = payload1.jsonString() {
            markdownEditorView.evaluateJavaScript("window.update(\(json))", completionHandler: nil)
        }
        let payload2 = CSData.Object([
            "type": "setDescription".toData(),
            "payload": readme.toData()
            ])
        if let json2 = payload2.jsonString() {
            markdownEditorView.evaluateJavaScript("window.update(\(json2))", completionHandler: nil)
        }
    }
}

// MARK: - ComponentPreviewItemViewController

class ComponentPreviewItemViewController: NSCollectionViewItem {
    override func loadView() {
        view = ComponentPreviewCard()
    }

    override var isSelected: Bool {
        get {
            return (view as? ComponentPreviewCard)?.selected ?? false
        }
        set {
            (view as? ComponentPreviewCard)?.selected = newValue
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

    public var prefix: String = "" { didSet { update() } }
    public var componentNames: [String] = [] { didSet { update() } }

    // MARK: Private

    private let collectionView = ComponentPreviewCollectionView(frame: .zero)

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        // TODO: This callback should propagate up to the root. Currently Lona doesn't
        // generate callbacks with params, so we'll handle it here for now.
        collectionView.onSelectComponent = { url in
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
        collectionView.prefix = prefix
    }
}
