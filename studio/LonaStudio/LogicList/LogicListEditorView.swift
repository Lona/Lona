//
//  LogicListEditorView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/29/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

//
//  ParameterListEditorView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

class LogicListEditorView: NSView {

    var editorView: LogicListView

    func renderScrollView() -> NSView {
        let scrollView = NSScrollView(frame: frame)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.addSubview(editorView)
//        scrollView.documentView = editorView
        scrollView.hasVerticalRuler = true

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

        button.image = NSImage.init(named: NSImage.Name.addTemplate)!
        button.bezelStyle = .smallSquare
        button.setButtonType(.momentaryPushIn)
        button.isBordered = false

        return button
    }

    var component: CSComponent? {
        get { return editorView.component }
        set { editorView.component = newValue }
    }

    var list: [LogicNode] {
        get { return editorView.list }
        set { editorView.list = newValue }
    }

    var onChange: ([LogicNode]) -> Void = {_ in }

    override init(frame frameRect: NSRect) {
        editorView = LogicListView(frame: frameRect)

        super.init(frame: frameRect)

        // Create views

        let toolbar = renderToolbar()
        let scrollView = renderScrollView()
        let plusButton = renderPlusButton()

        toolbar.addSubview(plusButton)
        addSubview(toolbar)
        addSubview(scrollView)
        addBorderView(to: .top)

        // Constraints

        constrain(to: scrollView, [.left, .width])
        scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: toolbar.topAnchor).isActive = true

        constrain(to: toolbar, [.bottom, .left, .width])
        toolbar.constrain(.height, as: 24)

        // Event handlers

        plusButton.onPress = {
            let newItem = LogicNode()
            self.editorView.list.append(newItem)
//            self.editorView.reloadData()
//            self.editorView.select(item: newItem, ensureVisible: true)
        }

        editorView.onChange = { value in
            self.onChange(value)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
