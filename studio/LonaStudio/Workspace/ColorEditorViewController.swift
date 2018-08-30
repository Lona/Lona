//
//  ColorEditorViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/30/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Colors
import Foundation

// MARK: - ColorEditorViewController

class ColorEditorViewController: NSViewController {

    // MARK: Lifecycle

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)

        setUpViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setUpViews()

        update()
    }

    // MARK: Public

    public var selectedColor: CSColor?
    public var colors: [CSColor] = [] { didSet { update() } }
    public var onInspectColor: ((CSColor?) -> Void)?

    // Change colors and specify the selection simultaneously
    public var onChangeColors: ((String, [CSColor], CSColor?) -> Void)?

    // MARK: Private

    private let colorBrowser = ColorBrowser()

    private lazy var addColorSheet = AddColorSheet()
    private lazy var addColorViewController: NSViewController = {
        return NSViewController(view: addColorSheet)
    }()

    private func setUpViews() {
        self.view = colorBrowser

        colorBrowser.onSelectColor = { color in
            self.onInspectColor?(color)
        }

        colorBrowser.onClickAddColor = {
            var color = CSColor(id: "", name: "", value: "black", comment: "")
            var pristineIdText: Bool = true

            self.addColorSheet.idText = color.id
            self.addColorSheet.nameText = color.name
            self.addColorSheet.valueText = color.value
            self.addColorSheet.colorValue = Color(cssString: color.value)
            self.addColorSheet.descriptionText = color.comment

            self.addColorSheet.onChangeNameText = { value in
                color.name = value
                self.addColorSheet.nameText = value

                if pristineIdText {
                    let invalidCharacters = CharacterSet.init(charactersIn: " \"\\/?<>:+*%|")
                    let lowerFirst = value.count > 0 ? value.prefix(1).lowercased() + value.dropFirst() : value
                    let idText = lowerFirst.components(separatedBy: invalidCharacters).joined(separator: "")
                    color.id = idText
                    self.addColorSheet.idText = idText
                }
            }

            self.addColorSheet.onChangeIdText = { value in
                color.id = value
                self.addColorSheet.idText = value

                pristineIdText = false
            }

            self.addColorSheet.onChangeValueText = { value in
                color.value = value
                self.addColorSheet.colorValue = Color.init(cssString: value)
                self.addColorSheet.valueText = value
            }

            self.addColorSheet.onChangeDescriptionText = { value in
                color.comment = value
                self.addColorSheet.descriptionText = value
            }

            self.addColorSheet.onChangeColorValue = { value in
                if !value.isApproximatelyEqual(to: color.value) {
                    color.value = value.rgbaString
                    self.addColorSheet.valueText = value.rgbaString
                }

                self.addColorSheet.colorValue = value
            }

            self.addColorSheet.onSubmit = {
                self.dismissViewController(self.addColorViewController)

                var updated = self.colors
                updated.append(color)

                self.onChangeColors?("Add Color", updated, color)
            }

            self.addColorSheet.onCancel = {
                self.dismissViewController(self.addColorViewController)
            }

            self.presentViewControllerAsSheet(self.addColorViewController)
        }

        colorBrowser.onDeleteColor = { color in
            guard let color = color else { return }

            let updated = self.colors.filter { element in
                return color.id != element.id
            }

            self.onChangeColors?("Delete Color", updated, nil)
        }

        colorBrowser.onMoveColor = { sourceIndex, targetIndex in
            var updated = self.colors

            let item = updated[sourceIndex]

            updated.remove(at: sourceIndex)

            if sourceIndex < targetIndex {
                updated.insert(item, at: targetIndex - 1)
            } else {
                updated.insert(item, at: targetIndex)
            }

            self.onChangeColors?("Move Color", updated, self.selectedColor)
        }
    }

    private func update() {
        colorBrowser.colors = colors
    }
}
