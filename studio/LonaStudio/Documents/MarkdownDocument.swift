//
//  MarkdownDocument.swift
//  LonaStudio
//
//  Created by Devin Abbott on 6/29/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

class MarkdownDocument: NSDocument {
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

    var content: String = ""

    override func makeWindowControllers() {
        WorkspaceWindowController.create(andAttachTo: self)
    }

    override func data(ofType typeName: String) throws -> Data {
        guard let data = content.data(using: .utf8) else {
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotWriteToFile, userInfo: nil)
        }
        return data
    }

    override func read(from data: Data, ofType typeName: String) throws {
        guard let content = data.utf8String() else {
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotOpenFile, userInfo: nil)
        }
        self.content = content
    }
}
