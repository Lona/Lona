//
//  ColorPickerView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/10/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

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
    
    var color: NSColor
    var onClick: () -> Void = {_ in}
    
    override func mouseDown(with event: NSEvent) {
        onClick()
    }
    
    init(name: String, color: NSColor) {
        self.color = color
        super.init(frame: NSRect.zero)
        
        backgroundFill = color.cgColor
        orientation = .horizontal
        alignment = .centerX
        distribution = .equalCentering
        translatesAutoresizingMaskIntoConstraints = false
        
        heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        if #available(OSX 10.12, *) {
            let textLayer = ClickThroughLabel(wrappingLabelWithString: name)
            textLayer.translatesAutoresizingMaskIntoConstraints = false
            textLayer.alignment = .center
            
            textLayer.textColor = color.contrastingLabelColor
            textLayer.isEditable = false
            textLayer.isBezeled = false
            textLayer.drawsBackground = true
            textLayer.backgroundColor = color
            
            addArrangedSubview(textLayer)
        } else {
            // Fallback on earlier versions
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ColorPickerView: NSView {
    
    var onClickColor: (CSColor) -> Void = {_ in}
    
    func colorRows() -> [NSView] {
        return CSColors.colors.map({ csColor in
            let colorSwatchView = ColorSwatchView(name: csColor.name, color: csColor.color)
            colorSwatchView.onClick = {
                self.onClickColor(csColor)
            }
            return colorSwatchView
        })
    }
    
    init() {
        super.init(frame: NSRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        let stackView = NSStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.orientation = .vertical
        stackView.spacing = 2
        stackView.edgeInsets = EdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        addSubview(stackView)
        
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        
        let rows = colorRows()
        
        rows.forEach({
            stackView.addArrangedSubview($0)
            $0.leftAnchor.constraint(equalTo: stackView.leftAnchor, constant: 20).isActive = true
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

