//
//  UndoManager.swift
//  LonaStudio
//
//  Created by Nghia Tran on 2/7/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

struct Command {
    let name: String
    let execute: () -> Void
    let undo: () -> Void
}

extension UndoManager {

    static var shared: UndoManager {
        return NSDocumentController.shared.currentDocument!.undoManager!
    }

    func run(_ command: Command) {
        func undo() {
            command.undo()
            self.registerUndo(withTarget: self) { _ in execute() }
        }
        func execute() {
            command.execute()
            self.registerUndo(withTarget: self) { _ in undo() }
            self.setActionName(command.name)
        }
        execute()
    }

    func run(name: String, execute: @escaping () -> Void, undo: @escaping () -> Void) {
        run(Command(name: name, execute: execute, undo: undo))
    }
}
