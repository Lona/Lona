//
//  WorkspaceWindowController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/24/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Defaults
import Foundation

private let viewControllerId = "MainWorkspace"
private let windowControllerId = "Document Window Controller"
private let storyboardName = "Main"

extension Defaults.Keys {
    static let workspaceWindowFrame = OptionalKey<NSRect>("Workspace window frame")
}

// MARK: WorkspaceWindowController

class WorkspaceWindowController: NSWindowController {
    var workspaceViewController: WorkspaceViewController {
        return contentViewController as! WorkspaceViewController
    }
}

// MARK: NSWindowDelegate

extension WorkspaceWindowController: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let frame = window?.frame {
            Defaults[.workspaceWindowFrame] = frame
        }

        (NSApp.delegate as? AppDelegate)?.showWelcomeWindow(self)
    }
}

// MARK: Static

extension WorkspaceWindowController {

    static var first: WorkspaceWindowController? {
        return NSApp.windows
            .map { $0.windowController }
            .compactMap { $0 }
            .map { $0 as? WorkspaceWindowController }
            .compactMap { $0 }
            .first
    }

    @discardableResult static func create() -> WorkspaceWindowController {
        let storyboard = NSStoryboard(name: storyboardName, bundle: nil)

        let workspaceViewController = storyboard.instantiateController(withIdentifier: viewControllerId) as! WorkspaceViewController

        let windowController = storyboard.instantiateController(withIdentifier: windowControllerId) as! WorkspaceWindowController

        let toolbar = NSToolbar(identifier: "toolbar")
        toolbar.allowsUserCustomization = false
        toolbar.showsBaselineSeparator = false

        if let window = windowController.window {
            window.backgroundColor = Colors.headerBackground
            window.tabbingMode = .preferred
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.toolbar = toolbar
            window.delegate = windowController
        }

        windowController.contentViewController = workspaceViewController

        return windowController
    }
}
