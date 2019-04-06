//
//  ParameterListEditorView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa
import Logic

private let startsWithNumberRegex = try? NSRegularExpression(pattern: #"^\d"#)

class ParameterListEditorView: NSView {

    var editorView: ParameterListView
    var logicEditor = LogicEditor.makeParameterEditorView()

    func renderScrollView() -> NSView {
        //        let scrollView = NSScrollView(frame: frame)
        //        scrollView.translatesAutoresizingMaskIntoConstraints = false
        //        scrollView.documentView = editorView
        //        scrollView.hasVerticalRuler = true
        //
        //        return scrollView

        return logicEditor
    }

    func renderToolbar() -> NSView {
        let toolbar = NSView()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.backgroundFill = NSColor.controlBackgroundColor.cgColor
        toolbar.addBorderView(to: .top, color: NSSplitView.defaultDividerColor.cgColor)

        return toolbar
    }

    func renderPlusButton() -> Button {
        let button = Button(frame: NSRect(x: 0, y: 0, width: 24, height: 23))
        button.image = NSImage.init(named: NSImage.addTemplateName)!
        button.bezelStyle = .smallSquare
        button.setButtonType(.momentaryPushIn)
        button.isBordered = false

        return button
    }

    var parameterList: [CSParameter] {
        get {
            return editorView.list
        }
        set {
            editorView.list = newValue

            let rootNode = LGCSyntaxNode.topLevelParameters(
                LGCTopLevelParameters(
                    id: UUID(),
                    parameters: LGCList(
                        parameterList.map { param in
                            return LGCFunctionParameter.parameter(
                                id: UUID(),
                                externalName: nil,
                                localName: LGCPattern(id: UUID(), name: param.name),
                                annotation: .makePlaceholder(),
                                defaultValue: .none(id: UUID())
                            )
                        } + [LGCFunctionParameter.makePlaceholder()]
                    )
                )
            )

            logicEditor.rootNode = rootNode
        }
    }

    var onChange: ([CSParameter]) -> Void = {_ in }

    override init(frame frameRect: NSRect) {
        editorView = ParameterListView(frame: frameRect)

        super.init(frame: frameRect)

        // Create views

        let toolbar = renderToolbar()
        let scrollView = renderScrollView()
        let plusButton = renderPlusButton()

        toolbar.addSubview(plusButton)
        addSubview(toolbar)
        addSubview(scrollView)
        addBorderView(to: .top, color: NSSplitView.defaultDividerColor.cgColor)

        // Constraints

        constrain(to: scrollView, [.left, .width])
        scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: toolbar.topAnchor).isActive = true

        constrain(to: toolbar, [.bottom, .left, .width])
        toolbar.constrain(.height, as: 24)

        // Event handlers

        plusButton.onPress = {
            let newItem = CSParameter()
            self.editorView.list.append(newItem)
            self.editorView.select(item: newItem, ensureVisible: true)
        }

        editorView.onChange = { value in
            self.onChange(value)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
