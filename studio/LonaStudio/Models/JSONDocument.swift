//
//  JSONDocument.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/25/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

class JSONDocument: NSDocument {
    enum Content {
        case colors([CSColor])
    }

    override init() {
        super.init()

        self.hasUndoManager = true
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override var autosavingFileType: String? {
        return nil
    }

    var viewController: WorkspaceViewController? {
        return windowControllers[0].contentViewController as? WorkspaceViewController
    }

    var content: Content?

    override func makeWindowControllers() {
        WorkspaceWindowController.create(andAttachTo: self)
    }

    override func data(ofType typeName: String) throws -> Data {
//        if let file = component, let json = file.toData(), let data = json.toData() {
//            return data
//        }

        throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
    }

    override func read(from url: URL, ofType typeName: String) throws {
        let name = url.deletingPathExtension().lastPathComponent

        do {
            let data = try Data(contentsOf: url, options: NSData.ReadingOptions())

            guard let csData = CSData.from(data: data) else {
                throw NSError(
                    domain: NSURLErrorDomain,
                    code: NSURLErrorCannotOpenFile,
                    userInfo: [NSLocalizedDescriptionKey: "Failed to parse \(url)."])
            }

            switch name {
            case "colors":
                content = Content.colors(CSColors.parse(csData))
            default:
                content = nil
            }
        } catch {
            Swift.print(error)
        }
    }

//    override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
//
//        super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)
//
//        LonaPlugins.current.trigger(eventType: .onSaveComponent)
//    }
}
