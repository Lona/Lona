//
//  MarkdownDocument.swift
//  LonaStudio
//
//  Created by Devin Abbott on 6/29/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

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

    var content: [BlockEditor.Block] = [] {
       didSet {
           if let url = fileURL {
               LogicModule.invalidateCaches(url: url, newValue: program)
           }
       }
    }

    var program: LGCProgram {
        return MarkdownFile.makeMarkdownRoot(content).program()
    }

    override func makeWindowControllers() {
        DocumentController.shared.createOrFindWorkspaceWindowController(for: self)
    }

    override func showWindows() {
        DocumentController.shared.createOrFindWorkspaceWindowController(for: self)

        super.showWindows()
    }

    override func data(ofType typeName: String) throws -> Data {
        guard let data = MarkdownFile.makeMarkdownData(content) else {
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotWriteToFile, userInfo: nil)
        }
        return data
    }

    override func read(from data: Data, ofType typeName: String) throws {
        guard let content = MarkdownFile.makeBlocks(data) else {
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotOpenFile, userInfo: nil)
        }

        // Ensure that a document has at least one editable block when we load it
        self.content = (content.last == nil || content.last?.isEmpty == false)
            ? content + [BlockEditor.Block.makeDefaultEmptyBlock()]
            : content

        if let url = fileURL {
            LogicModule.invalidateCaches(url: url, newValue: program)
        }
    }

    override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
        super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)

        LogicModule.invalidateCaches(url: url, newValue: program)
    }

    func save(to url: URL, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        save(to: url, ofType: "Markdown", for: saveOperation, completionHandler: { error in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                completionHandler(.success(()))
            }
        })
    }
}

extension MarkdownDocument {

    func deleteChildPageFiles(_ deleted: [String]) throws {
        guard let fileURL = fileURL else { return }

        if deleted.isEmpty { return }

        let pageNoun = "page\(deleted.count > 1 ? "s" : "")"

        if Alert.runConfirmationAlert(
            confirmationText: "Delete \(pageNoun)",
            messageText: "This will delete the \(pageNoun) \(deleted.map { "'\($0)'" }.joined(separator: ", ")) and can't be undone. Continue?"
        ) {
            try deleted.forEach { pageName in
                let pageURL = fileURL.deletingLastPathComponent().appendingPathComponent(pageName)

                do {
                    try FileManager.default.removeItem(at: pageURL)
                } catch CocoaError.fileNoSuchFile {
                    // Continue if the file didn't exist
                } catch let error {
                    throw error
                }
            }
        }
    }

    // Convert Page.md to Page/README.md
    // - Make the Page directory
    // - Change the URL of the current document to Page/README.md and save it
    // - Delete the old Page.md
    func convertToDirectory(completionHandler: @escaping ((Result<URL, Error>) -> Void)) {
        guard let originalFileURL = fileURL else { return }

        if FileManager.default.isDirectory(path: originalFileURL.path) { return }

        let pageName = originalFileURL.deletingPathExtension().lastPathComponent
        let directoryURL = originalFileURL.deletingLastPathComponent().appendingPathComponent(pageName).deletingPathExtension()

        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: false, attributes: [:])
        } catch let error {
            Swift.print("Error creating directory \(directoryURL)", error)
            completionHandler(.failure(error))
            return
        }

        let readmeURL = directoryURL.appendingPathComponent("README.md")

        save(to: readmeURL, ofType: "Markdown", for: .saveAsOperation, completionHandler: { [unowned self] error in
            if let error = error {
                Swift.print("Error saving README file \(readmeURL)", error)
                completionHandler(.failure(error))
                return
            }

            do {
                try FileManager.default.removeItem(at: originalFileURL)
            } catch let error {
                completionHandler(.failure(error))
                return
            }

            Swift.print("Saved \(originalFileURL) as \(self.fileURL)")

            completionHandler(.success(readmeURL))
        })
    }
}
