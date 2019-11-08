//
//  WorkspaceWindow.swift
//  LonaStudio
//
//  Created by Devin Abbott on 10/18/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

public class WorkspaceWindow: NSWindow {

    public override var isMovableByWindowBackground: Bool {
        get { return true }
        set {}
    }

    public override var acceptsFirstResponder: Bool {
        return true
    }

    public override var canBecomeKey: Bool {
        return true
    }

    public override var canBecomeMain: Bool {
        return true
    }
}
