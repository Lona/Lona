//
//  MarkdownDocument.swift
//  LonaStudio
//
//  Created by Devin Abbott on 6/29/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Defaults
import Logic

class MarkdownDocument: BaseDocument {

    public static let INDEX_PAGE_NAME = "README.md"

    // MARK: Lifecycle

    override init() {
        super.init()

        self.hasUndoManager = false
    }

    init(title: String) {
        super.init()

        self.hasUndoManager = false

        _content = [
            .init(.text(.init(string: title), .h1), .none),
            .makeDefaultEmptyBlock()
        ]
    }

    // MARK: Autosaving

    override var hasUnautosavedChanges: Bool {
        return true
    }

    override class var autosavesInPlace: Bool {
        return true
    }

    override func autosave(withImplicitCancellability autosavingIsImplicitlyCancellable: Bool, completionHandler: @escaping (Error?) -> Void) {
        guard let fileURL = fileURL else {
            completionHandler(nil)
            return
        }

        save(to: fileURL, for: .autosaveInPlaceOperation).finalResult({ result in
            switch result {
            case .success:
                completionHandler(nil)
            case .failure(let error):
                completionHandler(error)
            }
        })
    }

    override func canAsynchronouslyWrite(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType) -> Bool {
        return true
    }

    // MARK: Content

    var _content: [BlockEditor.Block] = [] {
        didSet {
            if let url = fileURL {
                LogicModule.invalidateCaches(url: url, newValue: program)
            }
        }
    }

    var content: [BlockEditor.Block] { return _content }

    var program: LGCProgram {
        return MarkdownFile.makeMarkdownRoot(content).program()
    }

    public var isIndexPage: Bool {
        return fileURL?.lastPathComponent == MarkdownDocument.INDEX_PAGE_NAME
    }

    private var changeEmitter: Emitter<[BlockEditor.Block]> = .init()

    public func addChangeListener(_ listener: @escaping ([BlockEditor.Block]) -> Void) -> Int {
        return changeEmitter.addListener(listener)
    }

    public func removeChangeListener(forKey key: Int) {
        changeEmitter.removeListener(forKey: key)
    }

    // MARK: Views & Windows

    var viewController: WorkspaceViewController? {
        return windowControllers[0].contentViewController as? WorkspaceViewController
    }

    // MARK: Reading & Saving

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
        self._content = (content.last == nil || content.last?.isEmpty == false)
            ? content + [BlockEditor.Block.makeDefaultEmptyBlock()]
            : content
    }

    override func save(to url: URL, ofType typeName: String, for saveOperation: NSDocument.SaveOperationType, completionHandler: @escaping (Error?) -> Void) {
        let dataOnDisk = try? Data(contentsOf: url)

        super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: completionHandler)

        let newData = try? self.data(ofType: typeName)

        // only invalidate if what was on the disk is different from what we saved
        if dataOnDisk != newData {
          LogicModule.invalidateCaches(url: url, newValue: program)
        }
    }

    func save(to url: URL, for saveOperation: NSDocument.SaveOperationType) -> Promise<Void, NSError> {
        return Promise<Void, NSError>.result { completed in
            save(to: url, ofType: "Markdown", for: saveOperation, completionHandler: { error in
                if let error = error {
                    return completed(.failure(error as NSError))
                } else {
                    return completed(.success(()))
                }
            })
        }
    }
}

// MARK: - Page Editing

extension MarkdownDocument {

    enum MarkdownDocumentError: Error {
        case failedToDeleteFile
        case directoryNotEmpty
    }

    func pages(blocks: [BlockEditor.Block]) -> [String] {
        blocks.compactMap {
            switch $0.content {
            case .page(title: _, target: let target):
                return target
            default:
                return nil
            }
        }
    }

    static func replacePageLink(blocks: [BlockEditor.Block], oldTarget: String, newTarget: String) -> [BlockEditor.Block] {
        return blocks.map { block in
            switch block.content {
            case .page(title: let title, target: oldTarget):
                return .init(.page(title: title, target: newTarget), block.listDepth)
            default:
                return block
            }
        }
    }

    static func removePageLink(blocks: [BlockEditor.Block], target: String) -> [BlockEditor.Block] {
        return blocks.filter { block in
            switch block.content {
            case .page(_, target: target):
                return false
            default:
                return true
            }
        }
    }

    static func insertPageLink(blocks: [BlockEditor.Block], title: String, target: String) -> [BlockEditor.Block] {

        // Only allow one page link for any given target
        if pageLinks(blocks: blocks).contains(target) { return blocks }

        let pageLinkBlock: BlockEditor.Block = .init(.page(title: title, target: target), .default)

        var clone = blocks
        if clone.last?.isEmpty == true {
            clone[clone.count - 1] = pageLinkBlock
        } else {
            clone.append(pageLinkBlock)
        }

        clone.append(.makeDefaultEmptyBlock())

        return clone
    }

    static func pageLinks(blocks: [BlockEditor.Block]) -> [String] {
        return blocks.compactMap { block in
            switch block.content {
            case .page(_, target: let target):
                return target
            default:
                return nil
            }
        }
    }

    // Set the document's content. Returns true if the changes can be undone.
    @discardableResult func setContent(_ value: [BlockEditor.Block], userInitiated: Bool) -> Bool {
        let oldPages = pages(blocks: content)
        let newPages = pages(blocks: value)

        let diff = oldPages.extendedDiff(newPages)
        let deleted: [String] = diff.compactMap {
            switch $0 {
            case .delete(at: let index):
                return oldPages[index]
            case .insert, .move:
                return nil
            }
        }

        // Delete child pages. Check the return to see if the user canceled the deletion
        switch deleteChildPageFiles(deleted, userInitiated: userInitiated) {
        case .success(false):
            return false
        default:
            break
        }

        let value = value.isEmpty ? [BlockEditor.Block.makeDefaultEmptyBlock()] : value

        self._content = value


        if deleted.isEmpty {
            self.changeEmitter.emit(self.content)

            return true
        } else {
            guard let fileURL = fileURL else { return true }

            // If we deleted child pages, we automatically save
            save(to: fileURL, for: .saveOperation).finalSuccess {
                if self.shouldConvertToFile() {
                    self.convertToFile().finalResult { _ in
                        self.changeEmitter.emit(self.content)
                    }
                } else {
                    self.changeEmitter.emit(self.content)
                }
            }

            return false
        }
    }

    func makeAndOpenChildPage(pageName: String, blockIndex index: Int, shouldReplaceBlock shouldReplace: Bool) {
        guard let fileURL = fileURL else { return }

        // Ensure that this is a directory before creating a child page
        if !isIndexPage {
            convertToDirectory().finalResult { result in
                switch result {
                case .success:
                    self.makeAndOpenChildPage(pageName: pageName, blockIndex: index, shouldReplaceBlock: shouldReplace)
                case .failure(let error):
                    Swift.print("Failed to convert readme to directory", error)
                }
            }
            return
        }

        var pageURL = fileURL.deletingLastPathComponent().appendingPathComponent(pageName)

        if pageURL.pathExtension != "md" {
            pageURL = pageURL.appendingPathExtension("md")
        }

        let title = pageURL.deletingPathExtension().lastPathComponent
        let newBlock = BlockEditor.Block(.page(title: title, target: pageURL.lastPathComponent), .none)

        var blocks = content
        if shouldReplace {
            blocks[index] = newBlock
        } else {
            blocks.insert(newBlock, at: index)
        }

        setContent(blocks, userInitiated: true)

        save(to: fileURL, for: .saveOperation).onSuccess { _ in
            return DocumentController.shared.makeAndOpenMarkdownDocument(withTitle: title, savedTo: pageURL)
        }
        .finalFailure { error in
            Swift.print("Failed to save", error)
            Alert.runInformationalAlert(messageText: "Failed to save \(fileURL.path).")
        }
    }

    // Returns false if canceled, true otherwise
    private func deleteChildPageFiles(_ deleted: [String], userInitiated: Bool) -> Result<Bool, MarkdownDocumentError> {
        guard let fileURL = fileURL else { return .success(true) }

        if deleted.isEmpty { return .success(true) }

        let pageNoun = "page\(deleted.count > 1 ? "s" : "")"

        if userInitiated {
            let ok = Alert.runConfirmationAlert(
                confirmationText: "Delete \(pageNoun)",
                messageText: "This will delete the \(pageNoun) \(deleted.map { "'\($0)'" }.joined(separator: ", ")) and can't be undone. Continue?"
            )

            if !ok {
                return .success(false)
            }
        }

        for pageName in deleted {
            let pageURL = fileURL.deletingLastPathComponent().appendingPathComponent(pageName)

            do {
                try FileManager.default.removeItem(at: pageURL)
            } catch CocoaError.fileNoSuchFile {
                // Continue if the file didn't exist
            } catch {
                Swift.print("Failed to delete markdown page \(pageName)")
                return .failure(.failedToDeleteFile)
            }
        }

        return .success(true)
    }

    // Make sure the parent document contains a link to this document
    func ensureParentLink(customTitle: String? = nil) -> Promise<MarkdownDocument, NSError> {
        guard let fileURL = fileURL else { return .failure(NSError.init()) }

        let defaultTitle = isIndexPage
            ? fileURL.deletingLastPathComponent().lastPathComponent
            : fileURL.deletingPathExtension().lastPathComponent

        let title = customTitle ?? defaultTitle

        let target = isIndexPage ? title : title + ".md"

        let parentURL = isIndexPage
            ? fileURL.deletingLastPathComponent().deletingLastPathComponent()
            : fileURL.deletingLastPathComponent()

        // If the parent folder represents a page, make sure we have a link to the new markdown document
        return DocumentController.shared.openDocument(withContentsOf: parentURL, display: false).onSuccess { [unowned self] parentDocument in
            guard let parentDocument = parentDocument as? MarkdownDocument else { return .failure(NSError.init()) }

            Swift.print("Inserting link in \(parentURL) to \(target)")

            let updated = MarkdownDocument.insertPageLink(blocks: parentDocument.content, title: title, target: target)
            parentDocument.setContent(updated, userInitiated: false)
            _ = parentDocument.save(to: parentDocument.fileURL!, for: .saveOperation)

            return .success(self)
        }
    }

    // Remove the parent document's link to this document
    func removeParentLink(customTitle: String? = nil) -> Promise<MarkdownDocument, NSError> {
        guard let fileURL = fileURL else { return .failure(NSError.init()) }

        let defaultTitle = isIndexPage
            ? fileURL.deletingLastPathComponent().lastPathComponent
            : fileURL.deletingPathExtension().lastPathComponent

        let title = customTitle ?? defaultTitle

        let target = isIndexPage ? title : title + ".md"

        let parentURL = isIndexPage
            ? fileURL.deletingLastPathComponent().deletingLastPathComponent()
            : fileURL.deletingLastPathComponent()

        // If the parent folder represents a page, make sure we have a link to the new markdown document
        return DocumentController.shared.openDocument(withContentsOf: parentURL, display: false).onSuccess { [unowned self] parentDocument in
            guard let parentDocument = parentDocument as? MarkdownDocument else { return .failure(NSError.init()) }

            Swift.print("Removing link in \(parentURL) to \(target)")

            let updated = MarkdownDocument.removePageLink(blocks: parentDocument.content, target: target)
            parentDocument.setContent(updated, userInitiated: false)
            _ = parentDocument.save(to: parentDocument.fileURL!, for: .saveOperation)

            return .success(self)
        }
    }

    // Convert Page.md to Page/README.md
    // - Make the Page directory
    // - Delete the old Page.md
    // - Fix parent URL to point to Page/README.md
    func convertToDirectory() -> Promise<URL, NSError> {
        guard let originalFileURL = fileURL else { return .failure(.init()) }

        if FileManager.default.isDirectory(path: originalFileURL.path) { return .failure(.init()) }

        let pageName = originalFileURL.deletingPathExtension().lastPathComponent
        let directoryURL = originalFileURL.deletingLastPathComponent().appendingPathComponent(pageName).deletingPathExtension()
        let readmeURL = directoryURL.appendingPathComponent(MarkdownDocument.INDEX_PAGE_NAME)

        Swift.print("Converting \(pageName) to directory:", originalFileURL.path, "->", readmeURL.path)

        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: false, attributes: [:])
        } catch let error {
            Swift.print("Error creating directory \(directoryURL)", error)
            return .failure(error as NSError)
        }

        let saved: Promise<URL, NSError> = save(to: readmeURL, for: .saveAsOperation).onSuccess {
            do {
                try FileManager.default.removeItem(at: originalFileURL)
            } catch let error {
                return .failure(error as NSError)
            }

            return .success(directoryURL)
        }

        // Fix the parent URL. If it fails, still consider the whole operation a success
        saved.finalSuccess { _ in
            let parentReadmeURL = directoryURL.deletingLastPathComponent().appendingPathComponent(MarkdownDocument.INDEX_PAGE_NAME)

            DocumentController.shared.openDocument(withContentsOf: parentReadmeURL, display: false).finalSuccess { parentDocument in
                if let parentDocument = parentDocument as? MarkdownDocument {
                    let updated = MarkdownDocument.self.replacePageLink(
                        blocks: parentDocument.content,
                        oldTarget: originalFileURL.lastPathComponent,
                        newTarget: directoryURL.lastPathComponent
                    )
                    parentDocument.setContent(updated, userInitiated: false)
                    _ = parentDocument.save(to: parentDocument.fileURL!, for: .saveOperation)
                }
            }
        }

        return saved
    }

    // If a markdown document is a README.md alone in its directory, then we should represent it
    // as a named .md file in the parent directory instead.
    func shouldConvertToFile() -> Bool {
        guard let originalFileURL = fileURL else { return false }

        if originalFileURL.lastPathComponent != MarkdownDocument.INDEX_PAGE_NAME { return false }

        let files: [String]

        do {
            files = try FileManager.default.contentsOfDirectory(atPath: originalFileURL.deletingLastPathComponent().path)
        } catch {
            Swift.print("Failed to read directory \(originalFileURL.path)", error)
            return false
        }

        let remainingFiles = files.filter { $0 != MarkdownDocument.INDEX_PAGE_NAME && $0 != ".DS_Store" }

//        Swift.print(originalFileURL.deletingLastPathComponent().path, "remaining files", remainingFiles)

        return remainingFiles.isEmpty
    }

    // Convert Page/README.md to Page.md
    // - Double check that it's safe to delete the directory
    // - Make the Page.md file
    // - Delete the old Page directory
    // - Fix parent URL to point to Page.md
    func convertToFile() -> Promise<URL, NSError> {
        guard let originalFileURL = fileURL else { return .failure(.init()) }

        if !shouldConvertToFile() { return .failure(MarkdownDocumentError.directoryNotEmpty as NSError) }

        let pageName = originalFileURL.deletingLastPathComponent().lastPathComponent
        let directoryURL = originalFileURL.deletingLastPathComponent()
        let pageURL = directoryURL.deletingLastPathComponent().appendingPathComponent(pageName + ".md")

        Swift.print("Converting \(pageName) to file:", originalFileURL.path, "->", pageURL.path)

        let saved: Promise<URL, NSError> = save(to: pageURL, for: .saveAsOperation).onSuccess {
            do {
                try FileManager.default.removeItem(at: directoryURL)
            } catch let error {
                return .failure(error as NSError)
            }

            return .success(pageURL)
        }

        // Fix the parent URL. If it fails, still consider the whole operation a success
        saved.finalSuccess { _ in
            let parentReadmeURL = directoryURL.deletingLastPathComponent().appendingPathComponent(MarkdownDocument.INDEX_PAGE_NAME)

            DocumentController.shared.openDocument(withContentsOf: parentReadmeURL, display: false).finalSuccess { parentDocument in
                if let parentDocument = parentDocument as? MarkdownDocument {
                    let updated = MarkdownDocument.replacePageLink(
                        blocks: parentDocument.content,
                        oldTarget: directoryURL.lastPathComponent,
                        newTarget: pageURL.lastPathComponent
                    )
                    parentDocument.setContent(updated, userInitiated: false)
                    _ = parentDocument.save(to: parentDocument.fileURL!, for: .saveOperation)
                }
            }
        }

        return .success(pageURL)
    }

    func movePage(to nextURL: URL, display shouldDisplay: Bool) -> Promise<MarkdownDocument, NSError> {
        guard let prevURL = fileURL else { return .failure(NSError()) }

        let prevParentURL = prevURL.deletingLastPathComponent()
        let nextParentURL = nextURL.deletingLastPathComponent()

        let prevTitle = isIndexPage
            ? prevURL.deletingLastPathComponent().lastPathComponent
            : prevURL.deletingPathExtension().lastPathComponent

        let prevParentIsLonaPage = prevParentURL.isLonaPage()

        let fileToMove = isIndexPage ? prevURL.deletingLastPathComponent() : prevURL

        do {
            Swift.print("Move item", prevURL, nextURL)
            try FileManager.default.copyItem(atPath: fileToMove.path, toPath: nextURL.path)
        } catch {
            return .failure(error as NSError)
        }

        return DocumentController.shared.openDocument(withContentsOf: nextURL, display: shouldDisplay)
            .onSuccess({ (document: NSDocument) in .success(document as! MarkdownDocument) })
            // Link this page with its new parent
            .onSuccess({ (document: MarkdownDocument) -> Promise<MarkdownDocument, NSError> in
                if nextParentURL.isLonaPage() {
                    Swift.print("movePage: Insert link in \(nextParentURL) to \(prevURL)")
                    return document.ensureParentLink()
                } else {
                    return .success(document)
                }
            })
            // Unlink this page from its old parent
            // This has a side effect of deleting the old file
            .onSuccess({ (document: MarkdownDocument) -> Promise<MarkdownDocument, NSError> in
                if prevParentIsLonaPage {
                    Swift.print("movePage: Remove link in \(prevParentURL) to \(prevTitle)")
                    return document.removeParentLink(customTitle: prevTitle)
                } else {
                    return .success(document)
                }
            })
            .onSuccess({ document in
                DocumentController.shared.close(document: self)
                return .success(document)
            })
    }
}
