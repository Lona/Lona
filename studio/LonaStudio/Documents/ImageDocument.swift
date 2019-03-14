//
//  JSONDocument.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 1/5/19.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

class ImageDocument: NSDocument {
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

    var content: NSImage?

    override func makeWindowControllers() {
        WorkspaceWindowController.create(andAttachTo: self)
    }

    override func data(ofType typeName: String) throws -> Data {
        guard let content = content else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        guard let data = content.tiffRepresentation else {
            throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        }
        return data
    }

    override func read(from url: URL, ofType typeName: String) throws {
        let data = try Data(contentsOf: url, options: NSData.ReadingOptions())
        if url.pathExtension == "svg" {
            let size = CGSize(width: 450, height: 450)
            content = SVG.render(contentsOf: url, size: size, resizingMode: .scaleAspectFit)
        } else {
            content = NSImage(data: data)
        }
    }
}
