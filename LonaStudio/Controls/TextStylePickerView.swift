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
    
    var onClick: () -> Void = {_ in}
    
    override var isFlipped: Bool { return true }
    
    override func mouseDown(with event: NSEvent) {
        onClick()
    }
    
    func setup(textStyle: CSTextStyle) {
        if #available(OSX 10.12, *) {
            let textLayer = NSTextField(labelWithAttributedString: textStyle.font.apply(to: textStyle.name))
            
//            textLayer.frame.origin.y = 90
//            textLayer.frame.size.width = 90
//            textLayer.alignment = .center
            
            addSubview(textLayer)
        } else {
            // Fallback on earlier versions
        }
    }
    
    init(frame frameRect: NSRect, textStyle: CSTextStyle) {
        super.init(frame: frameRect)
        setup(textStyle: textStyle)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TextStylePickerView: NSView {
    
    var onClickFont: (CSTextStyle) -> Void = {_ in}
    
    override var isFlipped: Bool { return true }
    
    let cellWidth = 130
    let cellHeight = 40
    let padding = 20
    
    func setup() {
        for textStyle in CSTypography.styles {
            let item = TextStyleItemView(frame: NSRect(x: 0, y: 0, width: 200, height: 40), textStyle: textStyle)
            
            item.useYogaLayout = true
            
            item.onClick = {
                Swift.print("Font", textStyle.name)
                self.onClickFont(textStyle)
            }
            
            addSubview(item)
        }
    }
    
    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 800, height: 600))
        
        setup()
        
        useYogaLayout = true
        ygNode?.flex = 1
        ygNode?.flexDirection = .column
        ygNode?.flexWrap = .wrap
        
        layoutWithYoga()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
