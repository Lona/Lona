//
//  CanvasTableView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 12/7/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

protocol Selectable {
    var isSelected: Bool { get set }
}

private extension NSTableColumn {
    convenience init(
        title: String,
        resizingMask: ResizingOptions = .autoresizingMask,
        width: CGFloat? = nil,
        minWidth: CGFloat? = nil,
        maxWidth: CGFloat? = nil) {
        self.init(identifier: NSUserInterfaceItemIdentifier(rawValue: title))
        self.title = title
        self.resizingMask = resizingMask

        if let width = width {
            self.width = width
        }

        if let minWidth = minWidth {
            self.minWidth = minWidth
        }

        if let maxWidth = maxWidth {
            self.maxWidth = maxWidth
        }
    }
}

public typealias Entity = String
public typealias TypeListItem = String

public class CanvasSurface: NSBox {

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

        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.drawsBackground = false
        scrollView.addSubview(outlineView)
        scrollView.documentView = outlineView

        outlineView.sizeToFit()

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

                outlineView.reloadData()
                outlineView.header.update()
            }
        }
    }

    public var onChange: ([Entity]) -> Void {
        get { return outlineView.onChange }
        set { outlineView.onChange = newValue }
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
        scrollView.magnification *= CanvasSurface.magnificationFactor
    }

    public func zoomOut() {
        scrollView.magnification /= CanvasSurface.magnificationFactor
    }
}

extension CanvasSurface {
    struct Parameters {
        var component: CSComponent
        var onSelectLayer: (CSLayer) -> Void
        var selectedLayerName: String?
    }
}

private class CanvasTableView: NSTableView, NSTableViewDataSource, NSTableViewDelegate {

    override func drawGrid(inClipRect clipRect: NSRect) { }

    func setup() {

        columnAutoresizingStyle = .noColumnAutoresizing
        backgroundColor = NSColor.white.withAlphaComponent(0.5)

        gridColor = NSColor.black.withAlphaComponent(0.08)
        gridStyleMask = [.solidHorizontalGridLineMask, .solidVerticalGridLineMask]
        intercellSpacing = NSSize(width: 1, height: 1)

        header.tableView = self
        header.onPressPlus = {
//            var copy = self.list
//            copy.append(Entity.genericType(GenericType.init(name: "", cases: [])))
//            self.onChange(copy)
        }
        header.update()

        focusRingType = .none
        rowSizeStyle = .medium
        headerView = header

        doubleAction = #selector(doubleClick(sender:))

        self.reloadData()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    fileprivate let header = CanvasTableHeaderView(frame: NSRect(x: 0, y: 0, width: 0, height: 42))

    override var frame: NSRect {
        didSet {
            header.frame.size.width = frame.width

        }
    }

    var canvases: [Canvas] = [] {
        didSet {
            tableColumns.forEach { column in
                removeTableColumn(column)
            }

            let columns: [NSTableColumn] = canvases.map { canvas in
                return NSTableColumn(title: canvas.name, width: CGFloat(canvas.width) + CanvasView.margin * 2)
            }

            columns.forEach { column in
                addTableColumn(column)

                column.headerCell = EmptyHeaderCell(textCell: column.title)
            }
        }
    }

    var selectedLayerName: String?

    var cases: [CSCaseEntry] = []

    var component: CSComponent?

    var onChange: ([Entity]) -> Void = {_ in }

    @objc fileprivate func doubleClick(sender: AnyObject) {
        if clickedColumn == -1 { return }

        if tableColumns[clickedColumn].title == "Name" {
            editColumn(clickedColumn, row: clickedRow, with: nil, select: true)
        }
    }

    override func viewWillDraw() {
        super.viewWillDraw()

        header.update()
    }

    // TODO: It seems like in some cases (animation?) updating the header in tile() is helpful.
    // When do/don't we want this?
//    override func tile() {
//        super.tile()
//        (headerView as? TypeListHeaderView)?.update()
//    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return cases.count
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let heights = canvases.enumerated().map { index, _ in
            return measureCellAt(row: row, column: index).height
        }

        return max(40, heights.max() ?? 0)
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard
            let column = tableColumn,
            let columnIndex = tableColumns.firstIndex(of: column),
            let component = self.component
        else { return NSView() }

        let canvasIndex = columnIndex
        let caseIndex = row

        guard caseIndex < cases.count && canvasIndex < canvases.count else { return NSView() }

        let canvas = canvases[canvasIndex]
        let `case` = cases[caseIndex]

        let rootLayer = component.rootLayer

        let config = ComponentConfiguration(
            component: component,
            arguments: `case`.value.objectValue,
            canvas: canvas
        )

        let parameters = CanvasView.Parameters(
            canvas: canvas,
            rootLayer: rootLayer,
            config: config,
            options: RenderOptions([
                .renderCanvasShadow(true),
//                .onSelectLayer(options.onSelectLayer),
                .selectedLayerName(selectedLayerName)
                ]))

        return getCachedCanvasViewAt(row: caseIndex, column: canvasIndex, parameters: parameters)
    }

    var canvasViewCache: [IndexPath: CanvasView] = [:]

    private func getCachedCanvasViewAt(row: Int, column: Int, parameters: CanvasView.Parameters) -> CanvasView {
        let indexPath = IndexPath(item: row, section: column)

        if let canvasView = canvasViewCache[indexPath] {
            canvasView.parameters = parameters
            return canvasView
        }

        let canvasView = CanvasView(parameters)

        canvasViewCache[indexPath] = canvasView

        return canvasView
    }

    private func measureCellAt(row: Int, column: Int) -> NSSize {

        guard let component = component else { return .zero }

        let canvasIndex = column
        let caseIndex = row

//        let canvasIndex = indexPath[options.layout == .caseXcanvasY ? 0 : 1]
//        let caseIndex = indexPath[options.layout == .caseXcanvasY ? 1 : 0]

        guard caseIndex < cases.count && canvasIndex < canvases.count else { return .zero }

        let canvas = canvases[canvasIndex]
        let `case` = cases[caseIndex]

        let rootLayer = component.rootLayer

        let config = ComponentConfiguration(
            component: component,
            arguments: `case`.value.objectValue,
            canvas: canvas)

        let configuredRootLayer = CanvasView.configureRoot(layer: rootLayer, with: config)
        guard let layout = layoutRoot(canvas: canvas, configuredRootLayer: configuredRootLayer, config: config) else { return NSSize.zero }

//        let size = NSSize(width: CGFloat(canvas.width) + CANVAS_INSET * 2, height: layout.height + CANVAS_INSET * 2)

        layout.rootNode.free(recursive: true)

        //        Swift.print("Size", size)

        let size = NSSize(
            width: CGFloat(canvas.width) + CanvasView.margin * 2,
            height: layout.height + CanvasView.margin * 2)

        return size
    }
}
