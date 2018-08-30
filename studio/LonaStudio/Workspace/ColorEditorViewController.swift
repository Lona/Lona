//
//  ColorEditorViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/30/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
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

    private func setUpViews() {
        self.view = colorBrowser

        colorBrowser.onSelectColor = { color in
            self.onInspectColor?(color)
        }

        colorBrowser.onClickAddColor = {

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
