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

        self.hasUndoManager = true
    }

    override var autosavingFileType: String? {
        return nil
    }

    var viewController: WorkspaceViewController? {
        return windowControllers[0].contentViewController as? WorkspaceViewController
    }

    var content: LGCSyntaxNode = .topLevelDeclarations(
        .init(
            id: UUID(),
            declarations: .init([.makePlaceholder()])
        )
    ) {
        didSet {
            if let url = fileURL {
                invalidateCaches(url: url)
            }
        }
    }

    override func makeWindowControllers() {
        WorkspaceWindowController.create(andAttachTo: self)
    }

    public static func encode(_ content: LGCSyntaxNode) throws -> Data {
        let encoder = JSONEncoder()

        if #available(OSX 10.13, *) {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        } else {
            encoder.outputFormatting = [.prettyPrinted]
        }

        let jsonData = try encoder.encode(content)

        // Save in XML if possible, falling back to JSON if that fails
        if let xmlData = LogicFile.convert(jsonData, kind: .logic, to: .xml) {
            return xmlData
        } else {
            Swift.print("Failed to save .logic file as XML")
            return jsonData
        }
    }

    override func data(ofType typeName: String) throws -> Data {
        return try LogicDocument.encode(content)
    }

    override func read(from data: Data, ofType typeName: String) throws {
        content = try LogicDocument.read(from: data)

        if let url = fileURL {
            invalidateCaches(url: url)
        }
    }

    public static func read(from data: Data) throws -> LGCSyntaxNode {
        guard let jsonData = LogicFile.convert(data, kind: .logic, to: .json) else {
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotOpenFile, userInfo: nil)
        }

        let decoded = try JSONDecoder().decode(LGCSyntaxNode.self, from: jsonData)

        // Normalize the imported data
        // TODO: Figure out why multiple placeholders are loaded
        return decoded.replace(id: UUID(), with: .literal(.boolean(id: UUID(), value: true)))
    }

    override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
        super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)

        invalidateCaches(url: url)
    }

    public func invalidateCaches(url: URL) {
        LogicViewController.invalidateThumbnail(url: url)
        LogicModule.updateFile(url: url, value: content)
    }
}
