//
//  PickerListView.swift
//  LonaStudio
//
//  Created by Nghia Tran on 12/24/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

// MARK: - Variable
private struct Constant {
    static let minWidth: CGFloat = 100
    static let maxWidth: CGFloat = 1000
    static let minHeightRow: CGFloat = 32.0
    static let maxHeightRow: CGFloat = 200.0
    static let minHeight: CGFloat = 100
    static let maxHeight: CGFloat = 1000
}

final class PickerListView<Element: Hashable>: NSScrollView, NSTableViewDelegate, NSTableViewDataSource {
    
    // MARK: - Variable
    fileprivate let tableView = NSTableView(frame: NSRect.zero)
    fileprivate var options: PickerView<Element>.Options
    fileprivate var sizeRows: [Int: NSSize] = [:]
    
    // MARK: - Init
    init(options: PickerView<Element>.Options) {
        self.options = options
        
        super.init(frame: NSRect.zero)
        
        setupCommon()
        cacheSize(options.data)
        fitSize()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func update(data: [Element], selected: String) {
        options.data = data
        options.selected = selected
        
        tableView.reloadData()
    }
    
    func updateHover(_ index: Int) {
        guard let view = tableView.view(atColumn: 0, row: index, makeIfNecessary: false) as? ShadowStyleRow else { return }
        removeHover()
        view.updateHover(true)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return options.data.count
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return NSTableRowView(frame: NSRect(x: 0, y: 0, width: 200, height: 40))
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = options.data[row]
        return options.viewForItem(tableView, item)
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let item = options.data[row]
        if let size = sizeRows[item.hashValue] {
            return size.height
        }
        return Constant.minHeightRow
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let item = options.data[tableView.selectedRow]
        options.didSelectItem(item)
    }
}

// MARK: - Private
extension PickerListView {
    
    fileprivate func setupCommon() {
        translatesAutoresizingMaskIntoConstraints = false
        drawsBackground = false
        hasVerticalScroller = true
    }
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = NSColor.clear
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        
        let column = NSTableColumn(identifier: "shadowStyle")
        column.title = "Shadow Style"
        column.resizingMask = .autoresizingMask
        column.maxWidth = 1000
        
        tableView.addTableColumn(column)
        tableView.intercellSpacing = NSSize.zero
        tableView.headerView = nil
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        documentView = tableView
        tableView.sizeToFit()
    }
    
    fileprivate func removeHover() {
        tableView.enumerateAvailableRowViews { (row, index) in
            let textRow = row.view(atColumn: 0) as! ShadowStyleRow
            textRow.updateHover(false)
        }
    }
}

// MARK: - Size
extension PickerListView {
    
    // MARK: - Calculate size for rows
    fileprivate func cacheSize(_ data: [Element]) {
        for item in data {
            let size = options.sizeForRow(item)
            sizeRows[item.hashValue] = size
        }
    }
    
    fileprivate func fitSize() {
        var height: CGFloat = 0.0
        var width = Constant.minWidth
        sizeRows.forEach { (_, size) in
            height += size.height
            if size.width > width {
                width = size.width
            }
        }
        
        // Make sure the size is in appropriate range
        height = max(min(height, Constant.maxHeight), Constant.minHeight)
        width = max(min(width, Constant.maxWidth), Constant.minWidth)
        
        // Override Width/Height of entire NSPopover
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width + 44).isActive = true
    }
}
