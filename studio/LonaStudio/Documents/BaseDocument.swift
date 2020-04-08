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

    override func makeWindowControllers() {
        // We manage window controllers in `showWindows`
    }

    override func showWindows() {
        DocumentController.shared.createOrFindWorkspaceWindowController(for: self)

        if let frame = Defaults[.workspaceWindowFrame] {
            WorkspaceWindowController.first?.window?.setFrame(frame, display: true)
        }

        super.showWindows()
    }
}
