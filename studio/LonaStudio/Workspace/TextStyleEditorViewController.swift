//
//  TextStyleEditorViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/30/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Colors
import Foundation

// MARK: - TextStyleEditorViewController

class TextStyleEditorViewController: NSViewController {

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

    public var selectedTextStyle: CSTextStyle?
    public var textStyles: [CSTextStyle] = [] { didSet { update() } }
    public var onInspectTextStyle: ((CSTextStyle?) -> Void)?

    // Change text styles and specify the selection simultaneously
    public var onChangeTextStyles: ((String, [CSTextStyle], CSTextStyle?) -> Void)?

    // MARK: Private

    private let textStyleBrowser = TextStyleBrowser()
    private lazy var addTextStyleSheet = AddTextStyleSheet()
    private lazy var addTextStyleViewController: NSViewController = {
        return NSViewController(view: addTextStyleSheet)
    }()

    private func setUpViews() {
        self.view = textStyleBrowser

        textStyleBrowser.onSelectTextStyle = { textStyle in
            self.onInspectTextStyle?(textStyle)
        }

        textStyleBrowser.onClickAddTextStyle = {
            var textStyle = CSTextStyle(id: "", name: "", fontName: nil, fontFamily: nil, fontWeight: nil, fontSize: nil, lineHeight: nil, letterSpacing: nil, color: nil, comment: nil)
            var pristineIdText: Bool = true

            self.addTextStyleSheet.idText = textStyle.id
            self.addTextStyleSheet.nameText = textStyle.name
            self.addTextStyleSheet.descriptionText = textStyle.comment ?? ""
            self.addTextStyleSheet.fontNameText = textStyle.fontName ?? ""
            self.addTextStyleSheet.fontFamilyText = textStyle.fontFamily ?? ""
            self.addTextStyleSheet.fontWeightText = textStyle.fontWeight ?? ""
            self.addTextStyleSheet.colorValue = textStyle.color ?? ""
            self.addTextStyleSheet.fontSizeNumber = CGFloat(textStyle.fontSize ?? -1)
            self.addTextStyleSheet.lineHeightNumber = CGFloat(textStyle.lineHeight ?? -1)
            self.addTextStyleSheet.letterSpacingNumber = CGFloat(textStyle.letterSpacing ?? -1)

            self.addTextStyleSheet.onChangeNameText = { value in
                textStyle.name = value
                self.addTextStyleSheet.nameText = value

                if pristineIdText {
                    let invalidCharacters = CharacterSet.init(charactersIn: " \"\\/?<>:+*%|")
                    let lowerFirst = value.count > 0 ? value.prefix(1).lowercased() + value.dropFirst() : value
                    let idText = lowerFirst.components(separatedBy: invalidCharacters).joined(separator: "")
                    textStyle.id = idText
                    self.addTextStyleSheet.idText = idText
                }
            }

            self.addTextStyleSheet.onChangeIdText = { value in
                textStyle.id = value
                self.addTextStyleSheet.idText = value

                pristineIdText = false
            }

            self.addTextStyleSheet.onChangeDescriptionText = { value in
                textStyle.comment = value
                self.addTextStyleSheet.descriptionText = value
            }

            self.addTextStyleSheet.onChangeFontNameText = { value in
                textStyle.fontName = value
                self.addTextStyleSheet.fontNameText = value
            }

            self.addTextStyleSheet.onChangeFontFamilyText = { value in
                textStyle.fontFamily = value
                self.addTextStyleSheet.fontFamilyText = value
            }

            self.addTextStyleSheet.onChangeFontWeightText = { value in
                textStyle.fontWeight = value
                self.addTextStyleSheet.fontWeightText = value
            }

            self.addTextStyleSheet.onChangeColorValue = { value in
                textStyle.color = value
                self.addTextStyleSheet.colorValue = value
            }

            self.addTextStyleSheet.onChangeFontSizeNumber = { value in
                textStyle.fontSize = Double(value)
                self.addTextStyleSheet.fontSizeNumber = value
            }

            self.addTextStyleSheet.onChangeLineHeightNumber = { value in
                textStyle.lineHeight = Double(value)
                self.addTextStyleSheet.lineHeightNumber = value
            }

            self.addTextStyleSheet.onChangeLetterSpacingNumber = { value in
                textStyle.letterSpacing = Double(value)
                self.addTextStyleSheet.letterSpacingNumber = value
            }

            self.addTextStyleSheet.onSubmit = {
                self.dismiss(self.addTextStyleViewController)

                var updated = self.textStyles
                updated.append(textStyle)

                self.onChangeTextStyles?("Add Text Style", updated, textStyle)
            }

            self.addTextStyleSheet.onCancel = {
                self.dismiss(self.addTextStyleViewController)
            }

            self.presentAsSheet(self.addTextStyleViewController)
        }

        textStyleBrowser.onDeleteTextStyle = { textStyle in
            guard let textStyle = textStyle else { return }

            let updated = self.textStyles.filter { element in
                return textStyle.id != element.id
            }

            self.onChangeTextStyles?("Delete Text Style", updated, nil)
        }

        textStyleBrowser.onMoveTextStyle = { sourceIndex, targetIndex in
            var updated = self.textStyles

            let item = updated[sourceIndex]

            updated.remove(at: sourceIndex)

            if sourceIndex < targetIndex {
                updated.insert(item, at: targetIndex - 1)
            } else {
                updated.insert(item, at: targetIndex)
            }

            self.onChangeTextStyles?("Move Text Style", updated, self.selectedTextStyle)
        }
    }

    private func update() {
        textStyleBrowser.textStyles = textStyles
    }
}
