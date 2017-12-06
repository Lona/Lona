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
    
    var onClickFont: ((CSTextStyle) -> Void)?

    // MARK: - Init
    init(selectedStyle: String) {
        super.init(frame: NSRect(x: 0, y: 0, width: 400, height: 600))
        
        setupLayout(selectedStyle)
        setupYoga()
        layoutWithYoga()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func embeddedViewController() -> NSViewController {
        let controller = NSViewController(view: self)
        return controller
    }
    
    // MARK: - Private
    private func setupYoga() {
        useYogaLayout = true
        ygNode?.flex = 1
        ygNode?.flexDirection = .column
        ygNode?.flexWrap = .wrap
    }
    
    private func setupLayout(_ selectedStyle: String) {
        var totalHeight: CGFloat = 0.0
        var maxWidth: CGFloat = 0.0
        
        let items = CSTypography.styles.map { (style) -> TextStyleItemView in
            let item = TextStyleItemView(textStyle: style)
            item.isSelected = style.id == selectedStyle
            item.onClick = { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.onClickFont?(style)
            }
            totalHeight += item.frame.height
            maxWidth = max(item.frame.width, maxWidth)
            return item
        }
        
        // Add subview
        items.forEach { addSubview($0) }
        
        // Override size depend on content
        frame.size = NSSize(width: maxWidth, height: totalHeight)
    }
    
    // MARK: - Override
    override var isFlipped: Bool { return true }
}
