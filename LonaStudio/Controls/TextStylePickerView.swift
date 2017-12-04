//
//  ColorPickerView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/10/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class TextStyleItemView: NSView {
    
    private let minHeight: CGFloat = 44.0
    private let maxHeight: CGFloat = 200.0
    private var attributeText: NSAttributedString!
    
    var onClick: (() -> Void)?

    // MARK: - Init
    init(frame frameRect: NSRect, textStyle: CSTextStyle) {
        super.init(frame: frameRect)
        
        setupLayout(textStyle: textStyle)
        calculateFitSize()
        setupYoga()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            let textLayer = NSTextField(labelWithAttributedString: attributeText)
            addSubview(textLayer)
        } else {
            // Fallback on earlier versions
            let textLayer = NSTextField(frame: bounds)
            textLayer.attributedStringValue = attributeText
            addSubview(textLayer)
        }
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
            let item = TextStyleItemView(frame: NSRect(x: 0, y: 0, width: 200, height: 100), textStyle: style)
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
