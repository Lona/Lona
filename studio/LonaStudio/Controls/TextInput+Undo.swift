//
//  TextInput+Undo.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/29/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation

// Controlled components (probably) don't need their own undoManager,
// since changes are managed by the parent view
extension TextInput {
    open override var undoManager: UndoManager? {
        return nil
    }
}
