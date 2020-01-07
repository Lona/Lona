//
//  DocumentController.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 09/01/2019.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

class DocumentController: NSDocumentController {
    public var didOpenADocument = false

    override func noteNewRecentDocumentURL(_ url: URL) {
        if FileUtils.fileExists(atPath: url.path) == FileUtils.FileExistsType.directory {
            do {
                _ = try Data(contentsOf: url.appendingPathComponent("lona.json"))
                super.noteNewRecentDocumentURL(url)
            } catch {
                return
            }
        }
    }

    override func makeDocument(withContentsOf url: URL, ofType typeName: String) throws -> NSDocument {
        if FileManager.default.isDirectory(path: url.path) {
            return try super.makeDocument(withContentsOf: url.appendingPathComponent("README.md"), ofType: "Markdown")
        }

        return try super.makeDocument(withContentsOf: url, ofType: typeName)
    }

    override public func reopenDocument(
        for urlOrNil: URL?,
        withContentsOf contentsURL: URL,
        display displayDocument: Bool,
        completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {

        if FileUtils.fileExists(atPath: contentsURL.path) == .directory {
            guard let newDocument = try? NSDocumentController.shared.makeDocument(withContentsOf: contentsURL, ofType: "DirectoryDocument") else {
                completionHandler(nil, false, NSError(domain: NSCocoaErrorDomain, code: 256, userInfo: [
                    NSLocalizedDescriptionKey: "\(contentsURL) could not be handled because LonaStudio cannot open files of this type.",
                    NSLocalizedFailureReasonErrorKey: "LonaStudio cannot open files of this type."]))
                return
            }

            addDocument(newDocument)

            didOpenADocument = true
            completionHandler(newDocument, false, nil)
        } else {
            super.reopenDocument(for: urlOrNil, withContentsOf: contentsURL, display: displayDocument, completionHandler: { document, alreadyOpened, error in
                if error == nil {
                    self.didOpenADocument = true
                }
                completionHandler(document, alreadyOpened, error)
            })
        }
    }
}
