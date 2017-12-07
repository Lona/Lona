//
//  ColorPickerView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/10/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class TextStyleItemView: NSView, Hoverable {
    
    private let minHeight: CGFloat = 32.0
    private let maxHeight: CGFloat = 200.0
    private var attributeText: NSAttributedString!
    private lazy var contractAttributeText: NSAttributedString = {
        var highlight = NSMutableAttributedString(attributedString: self.attributeText)
        highlight.addAttributes([NSForegroundColorAttributeName: NSColor.white],
                                range: NSRange(location: 0, length: self.attributeText.length))
        return highlight
    }()
    private var textLayer: NSTextField!
    private var tickImageView: NSImageView!
    
    var onClick: (() -> Void)?
    var isSelected: Bool = false {
        didSet {
            if isSelected {
                addSubview(tickImageView, positioned: NSWindowOrderingMode.below, relativeTo: nil)
            } else {
                tickImageView.removeFromSuperview()
            }
        }
    }

    // MARK: - Init
    init(frame frameRect: NSRect, textStyle: CSTextStyle) {
        super.init(frame: frameRect)
        
        setupTicketImageView()
        setupLayout(textStyle: textStyle)
        calculateFitSize()
        setupYoga()
        startTrackingHover()
    }
    
    convenience init(textStyle: CSTextStyle) {
        self.init(frame: NSRect.zero, textStyle: textStyle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeTrackingHover()
    }
    
    // MARK: - Private
    private func setupYoga() {
        useYogaLayout = true
        ygNode?.alginSelf = .stretch
        ygNode?.minWidthPercent = 100
        ygNode?.justifyContent = .flexStart
        ygNode?.flexDirection = .row
        ygNode?.alignItems = .center
        ygNode?.paddingLeft = 8
    }
    
    private func setupTicketImageView() {
        tickImageView = NSImageView(frame: NSRect(x: 0, y: 0, width: 16, height: 16))
        tickImageView.image = NSImage(named: "icon-layer-list-tick")!
        tickImageView.useYogaLayout = true
        tickImageView.isHidden = false
        tickImageView.ygNode?.marginRight = 8
    }
    
    private func setupLayout(textStyle: CSTextStyle) {
        attributeText = textStyle.font.apply(to: textStyle.name)
        textLayer = NSTextField(labelWithAttributedString: attributeText)
        textLayer.useYogaLayout = true
        addSubview(textLayer)
    }
    
    private func fitSize(with attributeString: NSAttributedString, fixedWidth: CGFloat) -> NSSize {
        let fixedSize = NSSize(width: fixedWidth, height: maxHeight)
        return attributeString.boundingRect(with: fixedSize,
                                                options: .usesFontLeading).size
    }
    
    private func calculateFitSize() {
        let size = fitSize(with: attributeText, fixedWidth: bounds.width)
        Swift.print(size)
        var height = size.height
        height = min(height, maxHeight)
        height = max(height, minHeight)
        frame.size = NSSize(width: size.width + 48, height: height)
    }
    
    // MARK: - Override
    override var isFlipped: Bool { return true }
    
    override func mouseDown(with event: NSEvent) {
        onClick?()
    }
    
    override func mouseEntered(with theEvent: NSEvent) {
        startHover { [weak self] in
            guard let strongSelf = `self` else { return }
            strongSelf.textLayer.attributedStringValue = strongSelf.contractAttributeText
            strongSelf.backgroundFill = NSColor.parse(css: "#0169D9")!.cgColor
        }
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        stopHover { [weak self] in
            guard let strongSelf = `self` else { return }
            strongSelf.textLayer.attributedStringValue = strongSelf.attributeText
            strongSelf.backgroundFill = NSColor.clear.cgColor
        }
    }
}

class TextStylePickerView: NSView {
    
    // MARK: - Variable
    var onClickFont: ((CSTextStyle) -> Void) = { _ in }
    private var selectedIndex = 0
    private var textStyles: [CSTextStyle] = []
    
    // MARK: - Init
    init() {
        super.init(frame: NSRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 400).isActive = true
        
        textStyles = CSTypography.styles
        
        let textList = TextStyleList(textStyles: textStyles, onSelectColor: onClickFont)
        
        let searchField = CSSearchField(options: [
            CSSearchField.Option.placeholderText("Search colors..."),
            CSSearchField.Option.onChange({ [unowned self] filter in
                if filter.count == 0 {
                    self.textStyles = CSTypography.styles
                } else {
                    self.textStyles = CSTypography.styles.filter {
                        $0.name.lowercased().contains(filter.lowercased())
                    }
                }
                self.selectedIndex = 0
                textList.update(textStyles: self.textStyles, selectedIndex: self.selectedIndex)
            }),
            CSSearchField.Option.onKeyPress({ [unowned self] keyCode in
                func update(index: Int) {
                    self.selectedIndex = max(0, min(index, self.textStyles.count - 1))
                    textList.update(textStyles: nil, selectedIndex: self.selectedIndex)
                }
                switch keyCode {
                case .down:
                    update(index: self.selectedIndex + 1)
                case .up:
                    update(index: self.selectedIndex - 1)
                case .enter:
                    if self.textStyles.count > self.selectedIndex {
                        self.onClickFont(self.textStyles[self.selectedIndex])
                    }
                }
            })
            ])
        
        let stackView = NSStackView(views: [searchField, textList], orientation: .vertical, stretched: true)
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
    
    func embeddedViewController() -> NSViewController {
        let controller = NSViewController(view: self)
        return controller
    }
    
    // MARK: - Override
    override var isFlipped: Bool { return true }
}

class TextStyleList: NSScrollView, NSTableViewDelegate, NSTableViewDataSource {
    
    // MARK: - Variable
    private let tableView = NSTableView(frame: NSRect.zero)
    var onSelectColor: (CSTextStyle) -> Void
    var textStyles: [CSTextStyle]
    var selectedIndex: Int = 0
    
    // MARK: - Init
    init(textStyles: [CSTextStyle], onSelectColor: @escaping (CSTextStyle) -> Void) {
        self.textStyles = textStyles
        self.onSelectColor = onSelectColor
        
        super.init(frame: NSRect.zero)
        
        setupCommon()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCommon() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 400).isActive = true
        drawsBackground = false
        hasVerticalScroller = true
    }
    
    private func setupTableView() {
        tableView.backgroundColor = NSColor.clear
        tableView.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        
        let column = NSTableColumn(identifier: "textStyle")
        column.title = "Text Style"
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
    func update(textStyles: [CSTextStyle]?, selectedIndex index: Int?) {
        if let textStyles = textStyles {
            self.textStyles = textStyles
        }
        
        if let index = index {
            self.selectedIndex = index
        }
        
        tableView.reloadData()
        tableView.scrollRowToVisible(self.selectedIndex)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return textStyles.count
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return NSTableRowView(frame: NSRect(x: 0, y: 0, width: 200, height: 40))
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let swatch = TextStyleRow(textStyle: textStyles[row], selected: row == selectedIndex)
        return swatch
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 37
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        tableView.enumerateAvailableRowViews { (rowView, index) in
            let colorRow = rowView.view(atColumn: 0) as? TextStyleRow
            colorRow?.update(selected: index == row)
        }
        
        return true
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        tableView.enumerateAvailableRowViews { (rowView, row) in
            let colorRow = rowView.view(atColumn: 0) as? TextStyleRow
            colorRow?.update(selected: rowView.isSelected)
        }
        
        onSelectColor(textStyles[tableView.selectedRow])
    }
}

class TextStyleRow: NSStackView {
    
    // MARK: - Variable
    private let tickView = NSImageView(image: NSImage(named: "icon-layer-list-tick")!)
    private let titleView: NSTextField
    var onClick: () -> Void = {_ in}
    
    // MARK: - Init
    init(textStyle: CSTextStyle, selected: Bool) {
        let attributeText = textStyle.font.apply(to: textStyle.name)
        titleView = NSTextField(labelWithAttributedString: attributeText)
        
        super.init(frame: NSRect.zero)
        
        spacing = 8
        orientation = .horizontal
        alignment = .left
        translatesAutoresizingMaskIntoConstraints = false
        edgeInsets = EdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        
        addArrangedSubview(tickView)
        addArrangedSubview(titleView)
        update(selected: selected)
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
    
    func update(selected: Bool) {
        if selected {
            addArrangedSubview(tickView)
        } else {
            removeArrangedSubview(tickView)
        }
    }
    
    
}
