//
//  BaseDocument.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/7/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit
import Defaults

class BaseDocument: NSDocument {

    private static var didRestoreWindowFrame = false

    override func makeWindowControllers() {
        // We manage window controllers in `showWindows`
    }

    override func showWindows() {
        DocumentController.shared.createOrFindWorkspaceWindowController(for: self)

        if !BaseDocument.didRestoreWindowFrame, let frame = Defaults[.workspaceWindowFrame] {
            BaseDocument.didRestoreWindowFrame = true
            WorkspaceWindowController.first?.window?.setFrame(frame, display: true)
        }

        super.showWindows()
    }
}
