//
//  LogicDocument.swift
//  LonaStudio
//
//  Created by Devin Abbott on 6/5/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

class LogicDocument: NSDocument {
    override init() {
        super.init()

        self.hasUndoManager = false
    }

    override var autosavingFileType: String? {
        return nil
    }

    var viewController: WorkspaceViewController? {
        return windowControllers[0].contentViewController as? WorkspaceViewController
    }

    var content: LGCSyntaxNode = LogicEditor.defaultRootNode

    override func makeWindowControllers() {
        WorkspaceWindowController.create(andAttachTo: self)
    }

    override func data(ofType typeName: String) throws -> Data {
        let encoder = JSONEncoder()

        if #available(OSX 10.13, *) {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        } else {
            encoder.outputFormatting = [.prettyPrinted]
        }

        return try encoder.encode(content)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        content = try JSONDecoder().decode(LGCSyntaxNode.self, from: data)
    }
}
