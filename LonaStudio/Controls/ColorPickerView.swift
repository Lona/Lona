//
//  ColorPickerView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/10/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

class ColorCircleView: NSView {
    
    func setup(color: NSColor) {
        wantsLayer = true
        layer = CALayer()
        layer?.cornerRadius = frame.width / 2
        layer?.backgroundColor = color.cgColor
    }
    
    init(size: Double, color: NSColor) {
        super.init(frame: NSRect(x: 0, y: 0, width: size, height: size))
        setup(color: color)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ClickThroughLabel: NSTextField {
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
    
    override func resetCursorRects() {
        addCursorRect(bounds, cursor: .arrow())
    }
}

class ColorSwatchView: NSStackView {
    
    var onClick: () -> Void = {_ in}
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
    
    override func mouseDown(with event: NSEvent) {
        Swift.print("Click swatch")
        onClick()
    }

    func update(selected: Bool) {
        if selected {
            titleView.textColor = NSColor.white
            subtitleView.textColor = NSColor.parse(css: "rgba(255,255,255,0.5)")!
            layer?.backgroundColor = NSColor.selectedMenuItemColor.cgColor
        } else {
            titleView.textColor = NSColor.black
            subtitleView.textColor = NSColor.parse(css: "rgba(0,0,0,0.5)")!
            layer?.backgroundColor = NSColor.clear.cgColor
        }
    }
    
    let titleView: NSTextField
    let subtitleView: NSTextField

    init(color: CSColor, selected: Bool) {
        let title = NSTextField(labelWithStringCompat: color.name)
        title.font = NSFont.systemFont(ofSize: 12)
        titleView = title

        let subtitle = NSTextField(labelWithStringCompat: color.value)
        subtitle.font = NSFont.systemFont(ofSize: 10)
        subtitleView = subtitle
        
        super.init(frame: NSRect.zero)
        
        wantsLayer = true
        
//        backgroundFill = NSColor.red.cgColor
        
        spacing = 8
        orientation = .horizontal
        alignment = .centerY
        translatesAutoresizingMaskIntoConstraints = false
        edgeInsets = EdgeInsets(top: 0, left: 4, bottom: 0, right: 4)

        let swatch = NSView(frame: NSRect.zero)
        swatch.translatesAutoresizingMaskIntoConstraints = false
        swatch.heightAnchor.constraint(equalToConstant: 32).isActive = true
        swatch.widthAnchor.constraint(equalToConstant: 32).isActive = true
        swatch.wantsLayer = true
        swatch.layer?.backgroundColor = color.color.cgColor
        swatch.layer?.cornerRadius = 2

        let description = NSStackView(views: [title, subtitle], orientation: .vertical)
        description.spacing = 2
        description.alignment = .left

        addArrangedSubview(swatch)
        addArrangedSubview(description)

        update(selected: selected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ColorList: NSScrollView, NSTableViewDelegate, NSTableViewDataSource {
    
    var onSelectColor: (CSColor) -> Void
    
    var colors: [CSColor]
    
    var selectedIndex: Int = 0
    
    func update(colors: [CSColor]?, selectedIndex index: Int?) {
        if let colors = colors {
            self.colors = colors
        }
        
        if let index = index {
            self.selectedIndex = index
        }
        
        tableView.reloadData()
        tableView.scrollRowToVisible(self.selectedIndex)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return colors.count
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return NSTableRowView(frame: NSRect(x: 0, y: 0, width: 200, height: 40))
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let swatch = ColorSwatchView(color: colors[row], selected: row == selectedIndex)
        return swatch
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 37
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        tableView.enumerateAvailableRowViews { (rowView, index) in
            let colorRow = rowView.view(atColumn: 0) as? ColorSwatchView
            colorRow?.update(selected: index == row)
        }
        
        return true
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        tableView.enumerateAvailableRowViews { (rowView, row) in
            let colorRow = rowView.view(atColumn: 0) as? ColorSwatchView
            colorRow?.update(selected: rowView.isSelected)
        }
        
        onSelectColor(colors[tableView.selectedRow])
    }
    
    let tableView: NSTableView
    
    init(frame frameRect: NSRect, colors: [CSColor], onSelectColor: @escaping (CSColor) -> Void) {
    
        self.colors = colors
        self.onSelectColor = onSelectColor
        
        let table = NSTableView(frame: frameRect)
        table.backgroundColor = NSColor.clear
        table.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        
        let column = NSTableColumn(identifier: "color")
        column.title = "color"
        column.resizingMask = .autoresizingMask
        column.maxWidth = 1000
        
        table.addTableColumn(column)
        
        table.intercellSpacing = NSSize.zero
        table.headerView = nil 
        self.tableView = table
        
        super.init(frame: frameRect)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 400).isActive = true
        
        table.translatesAutoresizingMaskIntoConstraints = false
        table.dataSource = self
        table.delegate = self
        table.reloadData()
        
        drawsBackground = false
        hasVerticalScroller = true
        documentView = table

        table.sizeToFit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ColorPickerView: NSView {
    
    var onClickColor: (CSColor) -> Void = {_ in}
    
    var selectedIndex: Int = 0
    
    var colors: [CSColor] = []

    init() {
        super.init(frame: NSRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        colors = CSColors.colors
        
        let colorList = ColorList(
            frame: NSRect.zero,
            colors: colors,
            onSelectColor: { color in self.onClickColor(color) }
        )
        
        let searchField = CSSearchField(options: [
            CSSearchField.Option.placeholderText("Search colors..."),
            CSSearchField.Option.onChange({ filter in
                if filter.characters.count == 0 {
                    self.colors = CSColors.colors
                } else {
                    self.colors = CSColors.colors.filter({ csColor in
                        return csColor.name.lowercased().contains(filter.lowercased())
                    })
                }
                
                self.selectedIndex = 0
                
                colorList.update(colors: self.colors, selectedIndex: self.selectedIndex)
            }),
            CSSearchField.Option.onKeyPress({ keyCode in
                func update(index: Int) {
                    self.selectedIndex = max(0, min(index, self.colors.count - 1))
                    colorList.update(colors: nil, selectedIndex: self.selectedIndex)
                }
                
                switch keyCode {
                case .down:
                    update(index: self.selectedIndex + 1)
                case .up:
                    update(index: self.selectedIndex - 1)
                case .enter:
                    if self.colors.count > self.selectedIndex {
                        self.onClickColor(self.colors[self.selectedIndex])
                    }
                }
            })
        ])
        
        let stackView = NSStackView(views: [searchField, colorList], orientation: .vertical, stretched: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.edgeInsets = EdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        addSubview(stackView)

        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

