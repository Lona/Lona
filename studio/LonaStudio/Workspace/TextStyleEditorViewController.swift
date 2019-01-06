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

    private func setUpViews() {
        self.view = textStyleBrowser

        textStyleBrowser.onSelectTextStyle = { textStyle in
            self.onInspectTextStyle?(textStyle)
        }

        textStyleBrowser.onClickAddTextStyle = {}

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
