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
    static let heightRow: CGFloat = 44.0
    static let minHeight: CGFloat = 44.0
    static let maxHeight: CGFloat = 1000
}

class PickerListView<Element>: NSScrollView, NSTableViewDelegate, NSTableViewDataSource {
    
    // MARK: - Variable
    private let tableView = NSTableView(frame: NSRect.zero)
    private var options: PickerView<Element>.Options
    
    // MARK: - Init
    init(options: PickerView<Element>.Options) {
        self.options = options
        
        super.init(frame: NSRect.zero)
        
        setupCommon()
        fitSize()
        setupTableView()
        scrollToSelection()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCommon() {
        translatesAutoresizingMaskIntoConstraints = false
        drawsBackground = false
        hasVerticalScroller = true
    }
    
    private func setupTableView() {
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
    
    // MARK: - Public func
    func update(data: [Element], selected: String) {
        options.data = data
        options.selected = selected
        
        // Reload
        tableView.reloadData()
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
        return Constant.heightRow
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let item = options.data[tableView.selectedRow]
        options.didSelectItem(item)
    }
    
    func updateHover(_ index: Int) {
        guard let view = tableView.view(atColumn: 0, row: index, makeIfNecessary: false) as? ShadowStyleRow else { return }
        removeHover()
        view.updateHover(true)
    }
    
    // MARK: - Calculate size for rows
    fileprivate func fitSize() {
        var height = CGFloat(options.data.count) * Constant.heightRow
        
        // Make sure the size is in appropriate range
        height = max(min(height, Constant.maxHeight), Constant.minHeight)
        
        // Override Width/Height of entire NSPopover
        heightAnchor.constraint(equalToConstant: height + 8).isActive = true
    }
    
    private func removeHover() {
        tableView.enumerateAvailableRowViews { (row, index) in
            let textRow = row.view(atColumn: 0) as! ShadowStyleRow
            textRow.updateHover(false)
        }
    }
}

