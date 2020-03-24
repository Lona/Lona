//
//  CanvasTableView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 12/7/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

class CanvasTableView: NSTableView, NSTableViewDataSource, NSTableViewDelegate {

    override func drawGrid(inClipRect clipRect: NSRect) { }

    var canvasAreaBackgroundColor: NSColor {
        return CSUserPreferences.canvasAreaBackgroundColor ??
            (isDarkMode
                ? (NSColor.controlBackgroundColor.blended(withFraction: 0.2, of: NSColor.black) ?? NSColor.controlBackgroundColor)
                : NSColor.white.withAlphaComponent(0.5))
    }

    var subscriptionHandle: LonaPlugins.SubscriptionHandle?

    func setup() {
        columnAutoresizingStyle = .noColumnAutoresizing
        backgroundColor = canvasAreaBackgroundColor

        self.subscriptionHandle = LonaPlugins.current.register(eventTypes: [.onChangeTheme], handler: { [unowned self] in
            self.backgroundColor = self.canvasAreaBackgroundColor
        })

        gridColor = isDarkMode ? NSColor.black.withAlphaComponent(0.4) : NSColor.black.withAlphaComponent(0.08)
        gridStyleMask = [.solidHorizontalGridLineMask, .solidVerticalGridLineMask]
        intercellSpacing = NSSize(width: 1, height: 1)

        header.tableView = self

        focusRingType = .none
        rowSizeStyle = .custom
        headerView = header

        header.onClickItem = handleClickHeaderItem
        header.onDeleteItem = handleDeleteHeaderItem
        header.onClickPlus = handleClickHeaderPlus
        header.onMoveItem = handleMoveHeaderItem

        // A hack to let us reuse the same cell view every render:
        //
        // Normally NSTableView doesn't give us control over which view gets reused.
        // Reusing the view in the same row/column is much more efficient in our case,
        // since this means nothing really needs to rerender. By telling the table view
        // that we're using static content, it won't attempt to reuse our views, so
        // we can do it manually.
        usesStaticContents = true

        doubleAction = #selector(doubleClick(sender:))

        self.reloadData()
    }

    deinit {
        subscriptionHandle?()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    fileprivate let header = CanvasTableHeaderView(frame: NSRect(x: 0, y: 0, width: 0, height: EditorViewController.navigationBarHeight))

    override var frame: NSRect {
        didSet {
            header.frame.size.width = frame.width
        }
    }

    // MARK: Public

    var canvases: [Canvas] = []

    var showsAccessibilityOverlay: Bool = false

    var selectedLayerName: String?

    var cases: [CSCaseEntry] = []

    var component: CSComponent?

    var onClickHeaderItem: ((Int) -> Void)?

    var onDeleteHeaderItem: ((Int) -> Void)?

    var onClickHeaderPlus: (() -> Void)?

    var onMoveHeaderItem: ((Int, Int) -> Void)?

    var selectedHeaderItem: Int? {
        get { return header.selectedItem }
        set { header.selectedItem = newValue }
    }

    public func headerRect(ofColumn column: Int) -> NSRect {
        var columnRect = rect(ofColumn: column)
        columnRect.size.height = header.frame.height
        columnRect.origin.y -= header.frame.height
        return columnRect
    }

    private func handleClickHeaderItem(_ index: Int) {
        onClickHeaderItem?(index)
    }

    private func handleDeleteHeaderItem(_ index: Int) {
        onDeleteHeaderItem?(index)
    }

    private func handleClickHeaderPlus() {
        onClickHeaderPlus?()
    }

    private func handleMoveHeaderItem(_ index: Int, _ newIndex: Int) {
        onMoveHeaderItem?(index, newIndex)
    }

    @objc fileprivate func doubleClick(sender: AnyObject) {
        if clickedColumn == -1 { return }

        if tableColumns[clickedColumn].title == "Name" {
            editColumn(clickedColumn, row: clickedRow, with: nil, select: true)
        }
    }

    let extraColumn = NSTableColumn(title: "Add Canvas", minWidth: 42)

    // Call this after changing canvases to update the labels
    func updateHeader() {
        let columns: [NSTableColumn] = canvases.map { canvas in
            return NSTableColumn(title: canvas.computedName, width: CGFloat(canvas.width) + CanvasView.margin * 2)
        } + [extraColumn]

        if columns.count == tableColumns.count && zip(columns, tableColumns).allSatisfy({ a, b in
            return a.title == b.title && a.width == b.width
        }) {
            return
        }

        tableColumns.forEach { column in
            removeTableColumn(column)
        }

        columns.forEach { column in
            addTableColumn(column)

            column.headerCell = EmptyHeaderCell(textCell: column.title)
        }

        header.update()
    }

    override func viewWillDraw() {
        sizeLastColumnToFit()

        super.viewWillDraw()

        header.update()
    }

    // TODO: It seems like in some cases (animation?) updating the header in tile() is helpful.
    // When do/don't we want this?
//    override func tile() {
//        super.tile()
//        (headerView as? TypeListHeaderView)?.update()
//    }

    // MARK: Data Source

    func numberOfRows(in tableView: NSTableView) -> Int {
        return cases.count
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let heights = canvases.enumerated().map { index, _ in
            return measureCellAt(row: row, column: index).height
        }

        return max(40, heights.max() ?? 0)
    }

    // MARK: Delegate

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
                .showsAccessibilityOverlay(showsAccessibilityOverlay),
                .renderCanvasShadow(true),
                .selectedLayerName(selectedLayerName)
                ]))

        return getCachedCanvasViewAt(row: caseIndex, column: canvasIndex, parameters: parameters)
    }

    // MARK: Private

    private var canvasViewCache: [IndexPath: CanvasView] = [:]

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

        guard caseIndex < cases.count && canvasIndex < canvases.count else { return .zero }

        let canvas = canvases[canvasIndex]
        let `case` = cases[caseIndex]

        let rootLayer = component.rootLayer

        let config = ComponentConfiguration(
            component: component,
            arguments: `case`.value.objectValue,
            canvas: canvas)

        let configuredRootLayer = CanvasView.configureRoot(layer: rootLayer, with: config)
        guard let layout = CanvasView.layoutRoot(canvas: canvas, configuredRootLayer: configuredRootLayer, config: config) else { return NSSize.zero }

        layout.rootNode.free(recursive: true)

        return NSSize(
            width: CGFloat(canvas.width) + CanvasView.margin * 2,
            height: layout.height + CanvasView.margin * 2)
    }
}
