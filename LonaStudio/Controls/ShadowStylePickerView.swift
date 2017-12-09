//
//  ShadowStylePickerView.swift
//  LonaStudio
//
//  Created by Nghia Tran on 12/9/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

class ShadowStylePickerView: NSView {
    
    // MARK: - Variable
    var onClickFont: ((CSShadow) -> Void) = { _ in }
    private var selectedID: String
    private var currentHover = -1
    private var shadowStyles: [CSShadow] = []
    
    // MARK: - Init
    init(selectedID: String) {
        self.selectedID = selectedID
        
        super.init(frame: NSRect.zero )
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 300).isActive = true
        shadowStyles = CSShadows.shadows
        
        let shadowList = ShadowStyleList(shadowStyles: shadowStyles, selection: selectedID) {[unowned self] shadowStyle in
            self.onClickFont(shadowStyle)
        }
        
        let searchField = CSSearchField(options: [
            CSSearchField.Option.placeholderText("Search colors..."),
            CSSearchField.Option.onChange({ [unowned self] filter in
                if filter.count == 0 {
                    self.shadowStyles = CSShadows.shadows
                } else {
                    self.shadowStyles = CSShadows.shadows.filter {
                        $0.name.lowercased().contains(filter.lowercased())
                    }
                }
                shadowList.update(shadowStyles: self.shadowStyles, selectedID: self.selectedID)
            }),
            CSSearchField.Option.onKeyPress({ [unowned self] keyCode in
                
                func updateHover(index: Int) {
                    self.currentHover = max(0, min(index, self.shadowStyles.count - 1))
                    shadowList.updateHover(self.currentHover)
                }
                
                switch keyCode {
                case .down:
                    let index = self.currentHover + 1
                    updateHover(index: index)
                case .up:
                    let index = self.currentHover - 1
                    updateHover(index: index)
                case .enter:
                    guard self.currentHover < self.shadowStyles.count else { return }
                    self.onClickFont(self.shadowStyles[self.currentHover])
                    break
                }
            })
            ])
        
        let searchViewStackView = NSStackView(views: [searchField], orientation: .horizontal, stretched: true)
        searchViewStackView.edgeInsets = EdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        let stackView = NSStackView(views: [searchViewStackView, shadowList], orientation: .vertical, stretched: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.edgeInsets = EdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func embeddedViewController() -> NSViewController {
        let controller = NSViewController(view: self)
        return controller
    }
    
    // MARK: - Override
    override var isFlipped: Bool { return true }
}

class ShadowStyleList: NSScrollView, NSTableViewDelegate, NSTableViewDataSource {
    
    // MARK: - Variable
    private struct Constant {
        static let heightRow: CGFloat = 44.0
        static let minHeight: CGFloat = 44.0
        static let maxHeight: CGFloat = 1000
    }
    
    let tableView = NSTableView(frame: NSRect.zero)
    var onSelectColor: (CSShadow) -> Void
    var shadowStyles: [CSShadow]
    var selectedID: String
    
    // MARK: - Init
    init(shadowStyles: [CSShadow], selection: String, onSelectColor: @escaping (CSShadow) -> Void) {
        self.shadowStyles = shadowStyles
        self.onSelectColor = onSelectColor
        self.selectedID = selection
        
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
    func update(shadowStyles: [CSShadow], selectedID: String) {
        self.shadowStyles = shadowStyles
        self.selectedID = selectedID
        
        // Reload and scroll
        tableView.reloadData()
        scrollToSelection()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return shadowStyles.count
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return NSTableRowView(frame: NSRect(x: 0, y: 0, width: 200, height: 40))
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let shadowStyle = shadowStyles[row]
        let swatch = ShadowStyleRow(shadow: shadowStyles[row], selected: shadowStyle.id == selectedID)
        return swatch
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return Constant.heightRow
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        onSelectColor(shadowStyles[tableView.selectedRow])
    }
    
    func updateHover(_ index: Int) {
        guard let view = tableView.view(atColumn: 0, row: index, makeIfNecessary: false) as? ShadowStyleRow else { return }
        removeHover()
        view.updateHover(true)
    }
    
    // MARK: - Calculate size for rows
    fileprivate func fitSize() {
        var height = CGFloat(shadowStyles.count) * Constant.heightRow
        
        // Make sure the size is in appropriate range
        height = max(min(height, Constant.maxHeight), Constant.minHeight)
        
        // Override Width/Height of entire NSPopover
        heightAnchor.constraint(equalToConstant: height + 8).isActive = true
    }
    
    // MARK: - Scroll
    private func scrollToSelection() {
        guard let index = shadowStyles.index(where: { $0.id == selectedID }) else {
            return
        }
        tableView.scrollRowToVisible(index)
    }
    
    private func removeHover() {
        tableView.enumerateAvailableRowViews { (row, index) in
            let textRow = row.view(atColumn: 0) as! ShadowStyleRow
            textRow.updateHover(false)
        }
    }
}

class ShadowStyleRow: NSStackView, Hoverable {
    
    // MARK: - Variable
    private let titleView: NSTextField
    private let subtitleView: NSTextField
    private lazy var colorView: NSView = {
        let view = NSView(frame: NSRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        view.widthAnchor.constraint(equalToConstant: 32).isActive = true
        view.wantsLayer = true
        view.layer?.cornerRadius = 2
        return view
    }()
    var onClick: () -> Void = {_ in}
    
    // MARK: - Init
    init(shadow: CSShadow, selected: Bool) {
        titleView = NSTextField(labelWithString: shadow.name)
        subtitleView = NSTextField(labelWithString: "x: \(shadow.x) y: \(shadow.y) blur: \(shadow.blur)")
        
        super.init(frame: NSRect.zero)
        
        initCommon()
        colorView.backgroundFill = shadow.color.cgColor
        let container = NSStackView(views: [titleView, subtitleView], orientation: .vertical)
        container.alignment = .leading
        addArrangedSubview(colorView)
        addArrangedSubview(container)
        startTrackingHover()
    }
    
    private func initCommon() {
        spacing = 8
        orientation = .horizontal
        distribution = .fill
        alignment = .centerY
        edgeInsets = EdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
    
    override func mouseDown(with event: NSEvent) {
        onClick()
    }
    
    func updateHover(_ hover: Bool) {
        if hover {
            startHover { [weak self] in
                guard let strongSelf = `self` else { return }
                strongSelf.titleView.textColor = NSColor.white
                strongSelf.subtitleView.textColor = NSColor.white
                strongSelf.backgroundFill = NSColor.parse(css: "#0169D9")!.cgColor
            }
        } else {
            stopHover { [weak self] in
                guard let strongSelf = `self` else { return }
                strongSelf.titleView.textColor = NSColor.black
                strongSelf.subtitleView.textColor = NSColor.black
                strongSelf.backgroundFill = NSColor.clear.cgColor
            }
        }
    }
    
    // MARK: - Hover
    override func mouseEntered(with theEvent: NSEvent) {
        updateHover(true)
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        updateHover(false)
    }
}
