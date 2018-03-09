//
//  ComponentEditorButton.swift
//  ComponentStudio
//
//  Created by devin_abbott on 11/13/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

import Foundation
import AppKit

private func layerType(for value: CSValue) -> String {
    return value.data.get(key: "type").string ?? "None"
}

class ComponentEditorButton: Button, CSControl, NSPopoverDelegate {

    var data: CSData {
        get { return value.toData() }
        set { value = CSValue(newValue) }
    }

    var onChangeData: CSDataChangeHandler

    var value: CSValue

    var onChange: (CSValue) -> Void = {_ in}

    private var editor: DictionaryEditor?

    func layerValue(for input: CSValue, parameters: CSData? = nil) -> CSValue {
        // TODO: Need to test this after changing to enum-based layer types
        let layerType = CSLayer.LayerType(input.data.get(key: "type"))
        let template = CSLayer(name: "Component", type: layerType).layerValue()

        let updatedData = parameters != nil ? input.data.merge(CSData.Object(["parameters": parameters!])) : input.data
        let updatedValue = CSValue(type: template.type, data: updatedData)

        return updatedValue
    }

    func editorValue(for input: CSValue, parameters: CSData? = nil) -> CSValue {
        return layerValue(for: input, parameters: parameters).get(key: "parameters")
    }

    init(value: CSValue, onChangeData: @escaping CSDataChangeHandler) {
        self.value = value
        self.onChangeData = onChangeData

        super.init(title: layerType(for: value))

        self.onPress = {
            let editor = DictionaryEditor(
                value: self.layerValue(for: self.value).get(key: "parameters"),
                onChange: { parameters in
                    let newValue = self.layerValue(for: self.value, parameters: parameters.data)

                    self.value = newValue
                    self.editor?.setParameters(value: newValue.get(key: "parameters"))
                }
            )

            self.editor = editor

            // TODO: All built-in components currently share the same CSType... need to use different types
            func setValue(withViewType type: CSLayer.LayerType) {
                let template = CSLayer(name: "Component", type: type).layerValue()
                let value = CSValue(type: template.type, data: CSData.Object([
                    "type": type.toData(),
                    "parameters": CSData.Object([:])
                ]))

                self.value = value
                self.title = type.string
                self.editor?.setParameters(value: value.get(key: "parameters"))
            }

            let popupButton = NSPopUpButton()
            popupButton.title = "Test"
            popupButton.translatesAutoresizingMaskIntoConstraints = false
            popupButton.isBordered = false
            popupButton.menu = NSMenu(items: [
                NSMenuItem(title: "None", onClick: {

                }),
                NSMenuItem.separator(),
                NSMenuItem(title: "View", onClick: {
                    setValue(withViewType: .view)
                }),
                NSMenuItem(title: "Text", onClick: {
                    setValue(withViewType: .text)
                }),
                NSMenuItem(title: "Image", onClick: {
                    setValue(withViewType: .image)
                }),
                NSMenuItem.separator(),
                NSMenuItem(title: "Component...", onClick: {})
            ])
            popupButton.selectItem(withTitle: layerType(for: value))

            let stackView = NSStackView(views: [popupButton, editor], orientation: .vertical, stretched: true)
            stackView.distribution = .fill
            stackView.apply(layout: CSConstraint.size(width: 250, height: 400))

            let viewController = NSViewController(view: stackView)
            let popover = NSPopover(contentViewController: viewController, delegate: self)

            popover.show(relativeTo: NSRect.zero, of: self, preferredEdge: .maxY)
        }
    }

    func popoverWillClose(_ notification: Notification) {
        self.onChange(value)
        self.onChangeData(value.data)

        self.editor = nil
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
