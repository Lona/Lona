//
//  CanvasCollectionView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/26/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

private let CANVAS_IDENTIFIER = "canvas"

struct CanvasCollectionOptions {
    var layout: RenderSurface.Layout
    var component: CSComponent
    var onSelectLayer: (CSLayer) -> Void
    var selectedLayerName: String?
}

class MatrixLayout: NSCollectionViewFlowLayout {

    // swiftlint:disable weak_delegate
    weak var delegate: NSCollectionViewDelegateFlowLayout?

    init(delegate: NSCollectionViewDelegateFlowLayout) {
        self.delegate = delegate
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    var _edgeInsets = NSEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
    override var sectionInset: NSEdgeInsets {
        get { return _edgeInsets }
        set { _edgeInsets = newValue }
    }
    var interItemSpacingY: CGFloat = 20
    var interItemSpacingX: CGFloat = 20
    var layoutInfo: [IndexPath: NSCollectionViewLayoutAttributes] = [:]

    override func prepare() {

        layoutInfo.removeAll(keepingCapacity: true)

        let sectionCount = self.collectionView?.numberOfSections
        var indexPath = IndexPath(item: 0, section: 0)

        for section in 0..<sectionCount! {
            let itemCount = self.collectionView?.numberOfItems(inSection: section)

            for item in 0..<itemCount! {
                indexPath = IndexPath(item: item, section: section)
                let itemAttributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
                itemAttributes.frame = frameForCellAtIndexPath(indexPath: indexPath)
                layoutInfo[indexPath] = itemAttributes
            }
        }
    }

    func frameForCellAtIndexPath(indexPath: IndexPath) -> CGRect {
        guard let delegate = delegate else {
            return .zero
        }
        let size = delegate.collectionView!(collectionView!, layout: self, sizeForItemAt: indexPath)

        var origin = CGPoint(x: sectionInset.left, y: sectionInset.top)

        if let prevX = layoutInfo[IndexPath(item: indexPath.item - 1, section: indexPath.section)] {
            origin.x += prevX.frame.origin.x + prevX.frame.width + interItemSpacingX
        }

        if let prevY = layoutInfo[IndexPath(item: indexPath.item, section: indexPath.section - 1)] {
            origin.y += prevY.frame.origin.y + prevY.frame.height + interItemSpacingY
        }

        return CGRect(origin: origin, size: size)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [NSCollectionViewLayoutAttributes] {
        var allAttributes: [NSCollectionViewLayoutAttributes] = []

        for (_, attributes) in self.layoutInfo {
            if rect.intersects(attributes.frame) {
                allAttributes.append(attributes)
            }
        }

        return allAttributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        return self.layoutInfo[indexPath]
    }

    override var collectionViewContentSize: NSSize {
        var width: CGFloat = 0
        var height: CGFloat = 0

        layoutInfo.forEach { (_, attributes) in
            width = max(width, attributes.frame.maxX)
            height = max(height, attributes.frame.maxY)
        }

        return CGSize(width: width + sectionInset.right, height: height + sectionInset.bottom)
    }
}

let CANVAS_INSET: CGFloat = 10

class CanvasCollectionView: NSView, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {

    var options: CanvasCollectionOptions?
    var computedCases: [CSCaseEntry] = []
    var computedCanvases: [Canvas] = []

    func update(options: CanvasCollectionOptions) {
        computedCases = options.component.computedCases(for: nil)
        computedCanvases = options.component.computedCanvases()
        self.options = options
        collectionView!.reloadData()
    }

    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        guard let options = options else { return 0 }
        let count = options.layout == .caseXcanvasY ? computedCanvases.count : computedCases.count
//        Swift.print("Sections", count)
        return count
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let options = options else { return 0 }
        let count = options.layout == .caseXcanvasY ? computedCases.count : computedCanvases.count
//        Swift.print("Items per section", count)
        return count
    }

    func measureCanvas(sizeForItemAt indexPath: IndexPath) -> NSSize {
        guard let options = options else { return NSSize.zero }

        let canvasIndex = indexPath[options.layout == .caseXcanvasY ? 0 : 1]
        let caseIndex = indexPath[options.layout == .caseXcanvasY ? 1 : 0]

        let component = options.component
        let canvas = computedCanvases[canvasIndex]
        let computedCases = options.component.computedCases(for: canvas)

        guard caseIndex < computedCases.count else { return NSSize.zero }

        let rootLayer = component.rootLayer

        let config = ComponentConfiguration(
            component: component,
            arguments: computedCases[caseIndex].value.objectValue,
            canvas: canvas
        )

        let configuredRootLayer = CanvasView.configureRoot(layer: rootLayer, with: config)
        guard let layout = layoutRoot(canvas: canvas, configuredRootLayer: configuredRootLayer, config: config) else { return NSSize.zero }

        let size = NSSize(width: CGFloat(canvas.width) + CANVAS_INSET * 2, height: layout.height + CANVAS_INSET * 2)

        layout.rootNode.free(recursive: true)

        return size
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {

//        Swift.print("measure item", indexPath)

        let size = measureCanvas(sizeForItemAt: indexPath)

//        Swift.print("measured with size", size, "at", indexPath)

        return size
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: CANVAS_IDENTIFIER), for: indexPath) as! CanvasItemViewController

        guard let options = options else { return item }

        item.view.subviews.forEach({ $0.removeFromSuperview() })

        let canvasIndex = indexPath[options.layout == .caseXcanvasY ? 0 : 1]
        let caseIndex = indexPath[options.layout == .caseXcanvasY ? 1 : 0]

        let component = options.component
        let canvas = computedCanvases[canvasIndex]
        let caseEntry = options.component.computedCases(for: canvas)[caseIndex]
        let rootLayer = component.rootLayer

        let config = ComponentConfiguration(
            component: component,
            arguments: caseEntry.value.objectValue,
            canvas: canvas
        )

        let canvasView = CanvasView(
            canvas: canvas,
            rootLayer: rootLayer,
            config: config,
            options: [
                .renderCanvasShadow(true),
                .onSelectLayer(options.onSelectLayer),
                .selectedLayerName(options.selectedLayerName)
            ])

        let canvasContainerView = NSView(frame: canvasView.bounds.insetBy(dx: -CANVAS_INSET, dy: -CANVAS_INSET).offsetBy(dx: CANVAS_INSET, dy: CANVAS_INSET))
        canvasContainerView.addSubview(canvasView)

        canvasView.frame = canvasView.frame.offsetBy(dx: CANVAS_INSET, dy: CANVAS_INSET)

        item.view.addSubview(canvasContainerView)

        return item
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, insetForSectionAt section: Int) -> NSEdgeInsets {
        return NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }

    var collectionView: NSCollectionView?
    var scrollView: NSScrollView?

    // This allows the NSCollectionView to scroll horizontally in addition to vertically.
    // It's horribly unperformant, and the scrollbar calculations are pretty quirky, but
    // it's better than nothing. Hopefully we can figure out a better fix. If not, revisit
    // the scrollbar calculations.
    class CollectionScrollView: NSScrollView {
        override func tile() {
            super.tile()

            if  let collectionView = documentView as? NSCollectionView,
                let size = collectionView.collectionViewLayout?.collectionViewContentSize {
                // The collection view should still fill the available space if it's smaller
                let maxSize = NSSize(width: max(size.width, frame.width), height: max(size.height, frame.height))

                collectionView.setFrameSize(maxSize)

                if  let horizontalScroller = self.horizontalScroller,
                    NSScroller.preferredScrollerStyle == NSScroller.Style.legacy {
                    horizontalScroller.isHidden = size.width < frame.width

                    var verticalScrollerSize: CGFloat = 0
                    if let verticalScroller = self.verticalScroller {
                        verticalScrollerSize = verticalScroller.isHidden ? 0 : verticalScroller.frame.width
                    }

                    horizontalScroller.setFrameSize(NSSize(width: frame.width - verticalScrollerSize, height: frame.height))
                    horizontalScroller.setFrameOrigin(NSPoint(x: 0, y: 0))

                    horizontalScroller.knobProportion = frame.width / size.width
                    horizontalScroller.floatValue = Float(documentVisibleRect.origin.x / (size.width - frame.width))
                }
            }
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true

        let visualEffectView = NSVisualEffectView(frame: NSRect.zero)
        visualEffectView.material = .light
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active

        let collectionView = NSCollectionView(frame: NSRect.zero)
        collectionView.collectionViewLayout = MatrixLayout(delegate: self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColors = [NSColor.white.withAlphaComponent(0.5)]
        self.collectionView = collectionView

        let scrollView = CollectionScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.verticalScrollElasticity = .allowed
        scrollView.horizontalScrollElasticity = .allowed
        scrollView.allowsMagnification = true
        scrollView.backgroundColor = NSColor.red
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.documentView = collectionView

        self.scrollView = scrollView

        addSubviewStretched(subview: visualEffectView)
        visualEffectView.addSubviewStretched(subview: scrollView)

        collectionView.register(CanvasItemViewController.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: CANVAS_IDENTIFIER))
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var dragOffset: NSPoint?
    var panningEnabled: Bool = false
    var currentlyPanning: Bool = false

    override func mouseDown(with event: NSEvent) {
        dragOffset = event.locationInWindow
    }

    override func mouseUp(with event: NSEvent) {
        dragOffset = nil
        currentlyPanning = false
    }

    override func mouseDragged(with event: NSEvent) {
        if !currentlyPanning && !panningEnabled { return }

        guard let dragOffset = dragOffset else { return }

        currentlyPanning = true

        let delta = (event.locationInWindow - dragOffset) / scrollView!.magnification
        let flippedY = NSPoint(x: delta.x, y: -delta.y)
        collectionView!.scroll(scrollView!.documentVisibleRect.origin - flippedY)

        self.dragOffset = event.locationInWindow
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        if currentlyPanning || panningEnabled {
            return self
        }

        return super.hitTest(point)
    }

    private static let magnificationFactor: CGFloat = 1.25

    func zoom(to zoomLevel: CGFloat) {
        scrollView!.magnification = zoomLevel
    }

    func zoomIn() {
        scrollView!.magnification *= CanvasCollectionView.magnificationFactor
    }

    func zoomOut() {
        scrollView!.magnification /= CanvasCollectionView.magnificationFactor
    }
}

class CanvasItemViewController: NSCollectionViewItem {
    override func loadView() {
        view = NSView()
    }
}
