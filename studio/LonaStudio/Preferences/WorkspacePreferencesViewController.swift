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

    func render() {
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })

        let workspaceIconRow = ValueSettingRow(
            title: "Workspace Icon",
            value: CSWorkspacePreferences.workspaceIconPathValue, onChange: { value in
                CSWorkspacePreferences.workspaceIconPathValue = CSValue(type: CSWorkspacePreferences.optionalURLType, data: value)
                CSWorkspacePreferences.save()

                LonaPlugins.current.trigger(eventType: .onReloadWorkspace)

                self.render()
        })

        let compilerPathRow = ValueSettingRow(
            title: "Custom Compiler Path",
            value: CSUserPreferences.compilerPathValue, onChange: { value in
                CSUserPreferences.compilerPathValue = CSValue(type: CSUserPreferences.optionalURLType, data: value)
                CSUserPreferences.save()

                self.render()
        })

        let colorsPathRow = ValueSettingRow(
            title: "Custom Colors Path",
            value: CSWorkspacePreferences.colorsFilePathValue, onChange: { value in
                CSWorkspacePreferences.colorsFilePathValue = CSValue(type: CSWorkspacePreferences.optionalURLType, data: value)
                CSWorkspacePreferences.save()

                CSColors.reload()

                self.render()
            })

        let textStylesPathRow = ValueSettingRow(
            title: "Custom Text Styles Path",
            value: CSWorkspacePreferences.textStylesFilePathValue, onChange: { value in
                CSWorkspacePreferences.textStylesFilePathValue = CSValue(type: CSWorkspacePreferences.optionalURLType, data: value)
                CSWorkspacePreferences.save()

                CSTypography.reload()

                self.render()
        })

        let canvasAreaBackgroundColorRow = ValueSettingRow(
            title: "Canvas Area Background Color",
            value: CSUserPreferences.canvasAreaBackgroundColorValue, onChange: { value in
                CSUserPreferences.canvasAreaBackgroundColorValue = CSValue(type: .string, data: value)
                CSUserPreferences.save()

                LonaPlugins.current.trigger(eventType: .onChangeTheme)

                self.render()
        })

        let views = [
            workspaceIconRow,
            compilerPathRow,
            colorsPathRow,
            textStylesPathRow,
            canvasAreaBackgroundColorRow
        ]

        views.forEach({ stackView.addArrangedSubview($0) })
    }

    var stackView = NSStackView()

    override func viewDidLoad() {
        super.viewDidLoad()

        CSUserPreferences.reload()
        CSWorkspacePreferences.reload()

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
