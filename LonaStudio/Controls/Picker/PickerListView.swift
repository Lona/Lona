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
    static let minHeight: CGFloat = 100
    static let maxHeight: CGFloat = 800
}

final class PickerListView<Element: PickerItemType>: NSScrollView, NSTableViewDelegate, NSTableViewDataSource {
    
    // MARK: - Variable
    fileprivate let tableView = NSTableView(frame: NSRect.zero)
    fileprivate var options: PickerView<Element>.Options
    fileprivate var data: [Element] = []
    fileprivate var sizeRows: [String: NSSize] = [:]
    weak var picker: PickerView<Element>?
    
    // MARK: - Init
    init(options: PickerView<Element>.Options) {
        self.options = options
        self.data = options.data
        
        super.init(frame: NSRect.zero)
        
        setupCommon()
        cacheSize(data)
        fitSize()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    func update(data: [Element], selected: String) {
        self.data = data
        options.selected = selected
        
        tableView.reloadData()
    }
    
    func updateHover(_ index: Int) {
        guard let view = tableView.view(atColumn: 0, row: index, makeIfNecessary: false) as? PickerRowViewType else { return }
        removeHover()
        view.onHover(true)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return NSTableRowView(frame: NSRect(x: 0, y: 0, width: 200, height: 40))
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let item = data[row]
        let selected = item.ID == options.selected
        return options.viewForItem(tableView, item, selected) as? NSView
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let item = data[row]
        if let size = sizeRows[item.ID] {
            return size.height
        }
        return Constant.minHeightRow
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let item = data[tableView.selectedRow]
        options.didSelectItem(picker, item)
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
        
        let column = NSTableColumn(identifier: "style")
        column.title = "Style"
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
            let textRow = row.view(atColumn: 0) as! PickerRowViewType
            textRow.onHover(false)
        }
    }
}

// MARK: - Size
extension PickerListView {
    
    // MARK: - Calculate size for rows
    fileprivate func cacheSize(_ data: [Element]) {
        for item in data {
            let size = options.sizeForRow(item)
            sizeRows[item.ID] = size
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
