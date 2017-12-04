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
    
    private let minHeight: CGFloat = 44.0
    private let maxHeight: CGFloat = 200.0
    private var attributeText: NSAttributedString!
    private lazy var contractAttributeText: NSAttributedString = { [unowned self] in
        var highlight = NSMutableAttributedString(attributedString: self.attributeText)
        highlight.addAttributes([NSForegroundColorAttributeName: NSColor.white], range: NSRange(location: 0, length: self.attributeText.length))
        return highlight
    }()
    private var textLayer: NSTextField!
    
    var onClick: (() -> Void)?

    // MARK: - Init
    init(frame frameRect: NSRect, textStyle: CSTextStyle) {
        super.init(frame: frameRect)
        
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
    }
    
    private func setupLayout(textStyle: CSTextStyle) {
        attributeText = textStyle.font.apply(to: textStyle.name)
        if #available(OSX 10.12, *) {
            textLayer = NSTextField(labelWithAttributedString: attributeText)
        } else {
            // Fallback on earlier versions
            textLayer = NSTextField(frame: bounds)
            textLayer.attributedStringValue = attributeText
        }
        addSubview(textLayer)
    }
    
    private func fitHeight(with attributeString: NSAttributedString, fixedWidth: CGFloat) -> CGFloat {
        let fixedSize = NSSize(width: fixedWidth, height: maxHeight)
        return attributeString.boundingRect(with: fixedSize,
                                                options: .usesFontLeading).height
    }
    
    private func calculateFitSize() {
        var height = fitHeight(with: attributeText, fixedWidth: bounds.width)
        height = min(height, maxHeight)
        height = max(height, minHeight)
        frame.size.height = height
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
    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        
        setupLayout()
        setupYoga()
        layoutWithYoga()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    private func setupYoga() {
        useYogaLayout = true
        ygNode?.flex = 1
        ygNode?.flexDirection = .column
        ygNode?.flexWrap = .wrap
    }
    
    private func setupLayout() {
        var totalHeight: CGFloat = 0.0
        let items = CSTypography.styles.map { (style) -> TextStyleItemView in
            let item = TextStyleItemView(textStyle: style)
            item.onClick = { [weak self] in
                guard let strongSelf = self else { return }
                Swift.print("Font", style.name)
                strongSelf.onClickFont?(style)
            }
            totalHeight += item.frame.height
            return item
        }
        items.forEach { item in
            self.addSubview(item)
        }
        
        // Overide height
        frame.size.height = totalHeight
    }
    
    // MARK: - Override
    override var isFlipped: Bool { return true }
}
