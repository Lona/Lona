//
//  WorkspaceWindowController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/24/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

private let viewControllerId = NSStoryboard.SceneIdentifier(rawValue: "MainWorkspace")
private let windowControllerId = NSStoryboard.SceneIdentifier(rawValue: "Document Window Controller")
private let storyboardName = NSStoryboard.Name(rawValue: "Main")

class WorkspaceWindowController: NSWindowController {
    @discardableResult static func create(andAttachTo document: NSDocument? = nil) -> WorkspaceWindowController {
        let storyboard = NSStoryboard(name: storyboardName, bundle: nil)

        let workspaceViewController = storyboard.instantiateController(withIdentifier: viewControllerId) as! WorkspaceViewController

        let windowController = storyboard.instantiateController(withIdentifier: windowControllerId) as! WorkspaceWindowController

        let toolbar = WorkspaceToolbar()

        workspaceViewController.onChangeActivePanes = { activePanes in
            toolbar.activePanes = activePanes
        }

        toolbar.onChangeActivePanes = { activePanes in
            workspaceViewController.activePanes = activePanes
        }

        windowController.window?.tabbingMode = .preferred
        windowController.window?.titleVisibility = .hidden
        windowController.window?.toolbar = toolbar
        windowController.contentViewController = workspaceViewController

        // Connect the document to both the window and view controller
        if let document = document {
            document.addWindowController(windowController)
            workspaceViewController.document = document
        }

        return windowController
    }
}
