//
//  CanvasAreaView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 12/8/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

public class CanvasAreaView: NSBox {

    // MARK: Lifecycle

    init(_ parameters: Parameters? = nil) {
        self.parameters = parameters

        super.init(frame: .zero)

        sharedInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        sharedInit()
    }

    private func sharedInit() {
        setUpViews()
        setUpConstraints()
    }

    // MARK: Public

    public var onSelectCanvasHeaderItem: ((Int) -> Void)?

    public var onDeleteCanvasHeaderItem: ((Int) -> Void)?

    public var selectedHeaderItem: Int? {
        get { return outlineView.selectedHeaderItem }
        set { outlineView.selectedHeaderItem = newValue }
    }

    // MARK: Private

    private var scrollView = NSScrollView(frame: .zero)
    private var outlineView = CanvasTableView()

    func setUpViews() {
        boxType = .custom
        borderType = .lineBorder
        contentViewMargins = .zero
        borderWidth = 0

        outlineView.dataSource = outlineView
        outlineView.delegate = outlineView
        outlineView.onClickHeaderItem = { [unowned self] index in
            self.onSelectCanvasHeaderItem?(index)
        }
        outlineView.onDeleteHeaderItem = { [unowned self] index in
            self.onDeleteCanvasHeaderItem?(index)
        }

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.drawsBackground = false
        scrollView.addSubview(outlineView)
        scrollView.documentView = outlineView

        addSubview(scrollView)
    }

    func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
    }

    private var previousComponentSerialized: CSData?

    var parameters: Parameters? {
        didSet {
            let componentSerialized = parameters?.component.toData()

            if componentSerialized != previousComponentSerialized ||
                parameters?.selectedLayerName != oldValue?.selectedLayerName {

                previousComponentSerialized = componentSerialized

                outlineView.canvases = parameters?.component.computedCanvases() ?? []
                outlineView.cases = parameters?.component.computedCases(for: nil) ?? []
                outlineView.component = parameters?.component
                outlineView.selectedLayerName = parameters?.selectedLayerName

                outlineView.updateHeader()
                outlineView.reloadData()
            }
        }
    }

    // MARK: Panning & Zooming

    var dragOffset: NSPoint?
    var panningEnabled: Bool = false
    var currentlyPanning: Bool = false

    override public func mouseDown(with event: NSEvent) {
        dragOffset = event.locationInWindow
    }

    override public func mouseUp(with event: NSEvent) {
        dragOffset = nil
        currentlyPanning = false
    }

    override public func mouseDragged(with event: NSEvent) {
        if !currentlyPanning && !panningEnabled { return }

        guard let dragOffset = dragOffset else { return }

        currentlyPanning = true

        let delta = (event.locationInWindow - dragOffset) / scrollView.magnification
        let flippedY = NSPoint(x: delta.x, y: -delta.y)
        outlineView.scroll(scrollView.documentVisibleRect.origin - flippedY)

        self.dragOffset = event.locationInWindow
    }

    override public func hitTest(_ point: NSPoint) -> NSView? {
        if currentlyPanning || panningEnabled {
            return self
        }

        return super.hitTest(point)
    }

    private static let magnificationFactor: CGFloat = 1.25

    public func zoom(to zoomLevel: CGFloat) {
        scrollView.magnification = zoomLevel
    }

    public func zoomIn() {
        scrollView.magnification *= CanvasAreaView.magnificationFactor
    }

    public func zoomOut() {
        scrollView.magnification /= CanvasAreaView.magnificationFactor
    }
}

extension CanvasAreaView {
    struct Parameters {
        var component: CSComponent
        var onSelectLayer: (CSLayer) -> Void
        var selectedLayerName: String?
    }
}
