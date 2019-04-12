//
//  WorkspacePreferencesViewController.swift
//  ComponentStudio
//
//  Created by devin_abbott on 7/27/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit
import MASPreferences

let LABEL = "Workspace"

class WorkspacePreferencesViewController: NSViewController, MASPreferencesViewController {

    var viewIdentifier: String {
        return identifier!.rawValue
    }

    override var identifier: NSUserInterfaceItemIdentifier? {
        get {
            return NSUserInterfaceItemIdentifier(rawValue: LABEL)
        }
        set {
            super.identifier = newValue
        }
    }

    // Ensure that callbacks don't fire when removing from superview
    private var loaded = false

    func render() {
        loaded = false

        CSUserPreferences.reload()
        CSWorkspacePreferences.reload()

        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })

        let workspaceNameRow = ValueSettingRow(
            title: "Workspace Name",
            value: CSWorkspacePreferences.workspaceNameValue, onChange: { [unowned self] value in
                if !self.loaded { return }

                CSWorkspacePreferences.workspaceNameValue = CSValue(type: CSType.string, data: value)
                CSWorkspacePreferences.save()

                LonaEvents.triggerReloadWorkspace()

                self.render()
        })

        let workspaceIconRow = ValueSettingRow(
            title: "Workspace Icon",
            value: CSWorkspacePreferences.workspaceIconPathValue, onChange: { [unowned self] value in
                if !self.loaded { return }

                CSWorkspacePreferences.workspaceIconPathValue = CSValue(type: CSWorkspacePreferences.optionalURLType, data: value)
                CSWorkspacePreferences.save()

                LonaEvents.triggerReloadWorkspace()

                self.render()
        })

        let compilerPathRow = ValueSettingRow(
            title: "Custom Compiler Path",
            value: CSUserPreferences.compilerPathValue, onChange: { [unowned self] value in
                if !self.loaded { return }

                CSUserPreferences.compilerPathValue = CSValue(type: CSUserPreferences.optionalURLType, data: value)
                CSUserPreferences.save()

                self.render()
        })

        let colorsPathRow = ValueSettingRow(
            title: "Custom Colors Path",
            value: CSWorkspacePreferences.colorsFilePathValue, onChange: { [unowned self] value in
                if !self.loaded { return }

                CSWorkspacePreferences.colorsFilePathValue = CSValue(type: CSWorkspacePreferences.optionalURLType, data: value)
                CSWorkspacePreferences.save()

                CSColors.reload()

                self.render()
            })

        let textStylesPathRow = ValueSettingRow(
            title: "Custom Text Styles Path",
            value: CSWorkspacePreferences.textStylesFilePathValue, onChange: { [unowned self] value in
                if !self.loaded { return }

                CSWorkspacePreferences.textStylesFilePathValue = CSValue(type: CSWorkspacePreferences.optionalURLType, data: value)
                CSWorkspacePreferences.save()

                CSTypography.reload()

                self.render()
        })

        let canvasAreaBackgroundColorRow = ValueSettingRow(
            title: "Canvas Area Background Color",
            value: CSUserPreferences.canvasAreaBackgroundColorValue, onChange: { [unowned self] value in
                if !self.loaded { return }

                CSUserPreferences.canvasAreaBackgroundColorValue = CSValue(type: .string, data: value)
                CSUserPreferences.save()

                LonaEvents.triggerChangeTheme(CSUserPreferences.canvasAreaBackgroundColorValue)

                self.render()
        })

        let views = [
            workspaceNameRow,
            workspaceIconRow,
            compilerPathRow,
            colorsPathRow,
            textStylesPathRow,
            canvasAreaBackgroundColorRow
        ]

        views.forEach({ stackView.addArrangedSubview($0) })

        loaded = true
    }

    var stackView = NSStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false

        stackView.orientation = .vertical
        stackView.alignment = .left
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

        view.addSubview(stackView)

        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
        stackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true

        render()
    }

    var toolbarItemLabel: String? {
        return LABEL
    }

    var toolbarItemImage: NSImage? {
        return #imageLiteral(resourceName: "icon-layer-list-text")
    }
}
