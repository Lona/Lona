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
        stackView.subviews.forEach({ $0.removeFromSuperview() })

        let views = [
            PathSettingRow(title: "Workspace Path", value: CSWorkspacePreferences.workspaceURL.path, onChange: { value in
                CSWorkspacePreferences.workspaceURL = URL(fileURLWithPath: value.stringValue, isDirectory: true)

                // Close all documents, since preferences change things drastically
                NSDocumentController.shared.closeAllDocuments(withDelegate: nil, didCloseAllSelector: nil, contextInfo: nil)

                // Load preferences for this new workspace if they exist
                CSWorkspacePreferences.reload()
                CSColors.reload()
                CSTypography.reload()

                self.render()
            })
        ]

        views.forEach({ stackView.addArrangedSubview($0) })
    }

    var stackView: NSStackView!

    override func viewDidLoad() {
        super.viewDidLoad()

        CSUserPreferences.reload()
        CSWorkspacePreferences.reload()

        view = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 0))
        view.translatesAutoresizingMaskIntoConstraints = false

        let stackView = NSStackView()
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

        self.stackView = stackView

        render()
    }

    var toolbarItemLabel: String? {
        return LABEL
    }

    var toolbarItemImage: NSImage? {
        return #imageLiteral(resourceName: "icon-layer-list-text")
    }
}
