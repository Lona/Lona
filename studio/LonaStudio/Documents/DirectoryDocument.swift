//
//  DirectoryDocument.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 06/01/2019.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

class DirectoryDocument: NSDocument {
    struct DirectoryContent {
        var componentNames: [String]
        var readme: String?
        var folderName: String
    }

    override init() {
        super.init()

        self.hasUndoManager = false
    }

    override class var autosavesInPlace: Bool {
        return false
    }

    override var autosavingFileType: String? {
        return nil
    }

    var viewController: WorkspaceViewController? {
        return windowControllers[0].contentViewController as? WorkspaceViewController
    }

    var content: DirectoryContent?

    override func makeWindowControllers() {
        WorkspaceWindowController.create(andAttachTo: self)
    }

    override func read(from url: URL, ofType typeName: String) throws {
        let files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

        var componentNames: [String] = []
        var readme: String? = nil

        try files.enumerated().forEach {offset, url in
            if url.pathExtension == "component" {
                componentNames.append(url.deletingPathExtension().lastPathComponent)
            } else if url.lastPathComponent == "README.md" {
                readme = try String(contentsOf: url)
            }
        }

        content = DirectoryContent(componentNames: componentNames, readme: readme, folderName: url.lastPathComponent)
    }
}
