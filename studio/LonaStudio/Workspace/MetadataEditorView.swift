//
//  MetadataEditorView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 10/20/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

class MetadataEditorView: NSStackView, CSControl {

    var data: CSData
    var onChangeData: CSControl.Handler

    func render() {
        let createChangeHandler: (String) -> ((CSData) -> Void) = { key in
            return { value in
                self.data[key] = value
                self.onChangeData(self.data)
            }
        }

        let fieldOptions: [CSValueField.Options: Bool] = [
            CSValueField.Options.isBordered: true,
            CSValueField.Options.drawsBackground: true,
            CSValueField.Options.submitOnChange: false,
            CSValueField.Options.usesLinkStyle: false,
            CSValueField.Options.usesYogaLayout: false
            ]

        // Description

        let descriptionKey = CSComponent.Metadata.description.rawValue
        let descriptionValue = CSValue(type: CSType.string, data: data[descriptionKey] ?? "".toData())
        let descriptionField = CSValueField(value: descriptionValue, options: fieldOptions)
        descriptionField.onChangeData = createChangeHandler(descriptionKey)

        let descriptionRow = NSStackView(views: [
            NSTextField(labelWithStringCompat: "Description"),
            descriptionField.view
            ], orientation: .horizontal, stretched: true)

        addArrangedSubview(descriptionRow)

        // Tags

        let tagsKey = CSComponent.Metadata.tags.rawValue
        let tagsValue = CSValue(type: CSType.array(CSType.string), data: data[tagsKey] ?? CSData.Array([]))
        let tagsField = CSValueField(value: tagsValue)
        tagsField.onChangeData = createChangeHandler(tagsKey)

        let tagsRow = NSStackView(views: [
            NSTextField(labelWithStringCompat: "Tags"),
            tagsField.view
            ], orientation: .horizontal, stretched: true)

        addArrangedSubview(tagsRow)
    }

    init(data: CSData, onChangeData: @escaping CSControl.Handler) {
        self.data = data
        self.onChangeData = onChangeData

        super.init(frame: NSRect.zero)

        self.translatesAutoresizingMaskIntoConstraints = false
        self.orientation = .vertical
        self.spacing = 12

        self.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        self.backgroundFill = CGColor.white

        render()
    }

    func update(data: CSData) {
        self.data = data

        for subview in arrangedSubviews { subview.removeFromSuperview() }

        render()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
