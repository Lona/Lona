//
//  CanvasListView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class CanvasListView: NSView {
    
    var onChangeLayout: ((RenderSurface.Layout) -> ())?
    
    var editorView: CanvasListEditor
    
    func renderScrollView() -> NSView {
        let scrollView = NSScrollView(frame: frame)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(editorView)
        scrollView.documentView = editorView
        scrollView.hasVerticalRuler = true
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        
        return scrollView
    }
    
    func renderToolbar() -> NSView {
        let toolbar = NSView()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.backgroundFill = CGColor.white
        toolbar.addBorderView(to: .top)
        
        return toolbar
    }
    
    func renderPlusButton() -> Button {
        let button = Button(frame: NSRect(x: 0, y: 0, width: 24, height: 23))
        button.image = NSImage.init(named: NSImageNameAddTemplate)!
        button.bezelStyle = .smallSquare
        button.setButtonType(.momentaryPushIn)
        button.isBordered = false
        
        return button
    }
    
    var canvasList: [Canvas] {
        get { return editorView.canvasList }
        set { editorView.canvasList = newValue }
    }
    
    var onChange: ([Canvas]) -> Void = {_ in }
    
    private let popupField: PopupField
    
    var canvasLayout: RenderSurface.Layout {
        get { return popupField.value == "yx" ? .caseXcanvasY : .canvasXcaseY }
        set { popupField.value = newValue == .caseXcanvasY ? "yx" : "xy" }
    }
    
    override init(frame frameRect: NSRect) {
        editorView = CanvasListEditor(frame: frameRect)
        
        popupField = PopupField(
            frame: NSRect.zero,
            values: ["xy", "yx"],
            valueToTitle: ["xy": "Canvases along X axis", "yx": "Canvases along Y axis"]
        )
        popupField.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: frameRect)
        
        // Create views
        
        let toolbar = renderToolbar()
        let scrollView = renderScrollView()
        let plusButton = renderPlusButton()
        
        toolbar.addSubview(plusButton)
        toolbar.addSubview(popupField)
        addSubview(toolbar)
        
        addSubview(scrollView)
        
        // Constraints
        
        constrain(to: scrollView, [.left, .width])
        scrollView.constrain(by: self, [.top])
        
        constrain(to: toolbar, [.bottom, .left, .width])
        toolbar.constrain(.height, as: 24)
        
        popupField.rightAnchor.constraint(equalTo: toolbar.rightAnchor, constant: -2).isActive = true
        popupField.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor, constant: 1).isActive = true
        
        addConstraint(NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: toolbar, attribute: .top, multiplier: 1, constant: 0))
        
        // Event handlers
        
        plusButton.onPress = {
            let newItem = Canvas()
            self.editorView.canvasList.append(newItem)
            self.editorView.select(item: newItem, ensureVisible: true)
        }
        
        popupField.onChange = { value in
            self.onChangeLayout?(value == "xy" ? RenderSurface.Layout.canvasXcaseY : RenderSurface.Layout.caseXcanvasY)
        }
        popupField.controlSize = .small
        popupField.font = NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .small))
        
        editorView.onChange = { value in
            self.onChange(value)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
