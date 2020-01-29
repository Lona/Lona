//
//  DocumentController.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 09/01/2019.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

enum DocumentError: Error {
    case fileAlreadyExists(title: String, url: URL)
}

// MARK: - DocumentController

class DocumentController: NSDocumentController {

    override public static var shared: DocumentController {
        return NSDocumentController.shared as! DocumentController
    }

    override func noteNewRecentDocumentURL(_ url: URL) {
        if url.isLonaWorkspace() {
            super.noteNewRecentDocumentURL(url)
        }
    }

    // When attempting to open a directory, instead attempt to open its `README.md`.
    // If we fail to open a file, hide the current file within the workspace.
    override func openDocument(
        withContentsOf url: URL,
        display displayDocument: Bool,
        completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void
    ) {
        if !ensureValidWorkspaceForOpeningFile(url: url) { return }

        let realURL = FileManager.default.isDirectory(path: url.path)
            ? url.appendingPathComponent(MarkdownDocument.INDEX_PAGE_NAME)
            : url

        super.openDocument(withContentsOf: realURL, display: displayDocument, completionHandler: {
            document, documentWasAlreadyOpen, error in
            if let _ = error, displayDocument {
                self.removeAllDocumentsFromWorkspaceWindowControllers()
            }
            completionHandler(document, documentWasAlreadyOpen, error)
        })
    }

    // Should do exactly what `openDocument` does
    override public func reopenDocument(
        for urlOrNil: URL?,
        withContentsOf contentsURL: URL,
        display displayDocument: Bool,
        completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {

        if !ensureValidWorkspaceForOpeningFile(url: contentsURL) { return }

        let realURL = FileManager.default.isDirectory(path: contentsURL.path)
            ? contentsURL.appendingPathComponent(MarkdownDocument.INDEX_PAGE_NAME)
            : contentsURL

        super.reopenDocument(for: urlOrNil, withContentsOf: realURL, display: displayDocument, completionHandler: {
            document, documentWasAlreadyOpen, error in
            if let _ = error, displayDocument {
                self.removeAllDocumentsFromWorkspaceWindowControllers()
            }
            completionHandler(document, documentWasAlreadyOpen, error)
        })
    }
}

// MARK: - Document helpers

extension DocumentController {
    public func findOpenDocument(for url: URL) -> NSDocument? {
        if FileManager.default.isDirectory(path: url.path) {
            return findOpenDocument(for: url.appendingPathComponent(MarkdownDocument.INDEX_PAGE_NAME))
        }

        return documents.first(where: { document in document.fileURL == url })
    }

    public func close(document: NSDocument) {
        removeDocument(document)

        if let currentDocument = workspaceWindowControllers.first?.document as? NSDocument, document === currentDocument {
            removeAllDocumentsFromWorkspaceWindowControllers()
        }
    }

    public func delete(document: NSDocument) -> Promise<NSDocument, NSError> {
        close(document: document)

        if let fileURL = document.fileURL {
            let urlToRemove = fileURL.lastPathComponent == MarkdownDocument.INDEX_PAGE_NAME
                ? fileURL.deletingLastPathComponent()
                : fileURL

            Swift.print("Will remove", urlToRemove)

            return openDocument(withContentsOf: urlToRemove.deletingLastPathComponent(), display: false).onResult { (result) -> Promise<NSDocument, NSError> in
                switch result {
                case .success(let parentDocument):
                    let pageName = urlToRemove.lastPathComponent
                    if let parentDocument = parentDocument as? MarkdownDocument,
                        MarkdownDocument.pageLinks(blocks: parentDocument.content).contains(pageName) {

                        let updated = MarkdownDocument.removePageLink(blocks: parentDocument.content, target: pageName)
                        parentDocument.setContent(updated, userInitiated: false)
                        return .success(document)
                    }
                    return .failure(NSError.init())
                case .failure(let error):
                    return .failure(error)
                }
            }.onFailure { (error: NSError) in
                Swift.print("Falling back to deleting file manually", urlToRemove)

                do {
                    try FileManager.default.removeItem(at: urlToRemove)
                } catch {
                    Swift.print("INFO", error)
                }

                return .success(document)
            }
        } else {
            fatalError("Can't delete document missing fileURL")
        }
    }
}

// MARK: - File helpers

extension DocumentController {

    // Make a new page
    // - Initialize a new document with default content
    // - Save the document
    // - Create a link to the document in the parent page
    public func makeAndOpenMarkdownDocument(
        withTitle title: String,
        savedTo url: URL
    ) -> Promise<MarkdownDocument, NSError> {
        if FileManager.default.fileExists(atPath: url.path) {
            Alert.runInformationalAlert(
                messageText: "Couldn't create page \(title)",
                informativeText: "A file already exists at \(url.path).")
            return .failure(DocumentError.fileAlreadyExists(title: title, url: url) as NSError)
        }

        let document = MarkdownDocument(title: title)

        return document.save(to: url, for: .saveOperation)
            .onSuccess({ document.ensureParentLink(customTitle: title) })
            .onSuccess({ _ in self.openDocument(withContentsOf: url, display: true) })
            .onSuccess({ (document: NSDocument) in .success(document as! MarkdownDocument) })
    }
}

// MARK: - Window Controllers

extension DocumentController {
    private func removeAllDocumentsFromWorkspaceWindowControllers() {
        workspaceWindowControllers.forEach { workspaceWindowController in
            if let document = workspaceWindowController.document as? NSDocument {
                document.removeWindowController(workspaceWindowController)
            }

            let workspaceViewController = workspaceWindowController.workspaceViewController

            workspaceViewController.inspectedContent = nil
            workspaceViewController.document = nil
            workspaceViewController.update()
        }
    }

    public func createOrFindWorkspaceWindowController(for document: NSDocument) {
        let workspaceWindowController = workspaceWindowControllers.first ?? WorkspaceWindowController.create()
        let workspaceViewController = workspaceWindowController.workspaceViewController

        // If this document already has a controller, we don't need to do anything
        if let currentDocument = workspaceWindowController.document, currentDocument === document {
            workspaceViewController.update()
            return
        }

        document.windowControllers.forEach { document.removeWindowController($0) }
        document.addWindowController(workspaceWindowController)

        workspaceViewController.inspectedContent = nil
        workspaceViewController.document = document
        workspaceViewController.update()
    }

    public var workspaceWindowControllers: [WorkspaceWindowController] {
        let allWindowControllers = NSApp.windows.compactMap { $0.windowController as? WorkspaceWindowController }
        let uniqueWindowControllers = Array(Set(allWindowControllers))
        return uniqueWindowControllers
    }
}

// MARK: - Workspaces

extension DocumentController {
    public func createWorkspace(url: URL, workspaceTemplate: WorkspaceTemplate) -> Bool {
        let workspaceName = url.lastPathComponent
        let workspaceParent = url.deletingLastPathComponent()
        let root = workspaceTemplate.make(workspaceName: workspaceName)

        do {
            try VirtualFileSystem.write(node: root, relativeTo: workspaceParent)
        } catch {
            Alert.runInformationalAlert(messageText: "Failed to create workspace \(url.lastPathComponent) in \(url.deletingLastPathComponent().lastPathComponent)")
            return false
        }

        return true
    }

    public func ensureValidWorkspaceForOpeningFile(url: URL) -> Bool {

        // Only allow opening files within Lona workspaces
        guard let workspaceURL = LonaModule.findNearestWorkspace(containing: url) else {
            Alert.runInformationalAlert(
                messageText: "Could not find workspace",
                informativeText: [
                    "The file '\(url.path)' is not a descendant of a Lona workspace directory.",
                    "A workspace directory contains a 'lona.json' file."
                ].joined(separator: " ")
            )

            return false
        }

        // If opening a file in a different workspaces, attempt to switch workspaces
        if LonaModule.current.url != workspaceURL {
            if hasEditedDocuments {
                if Alert.runConfirmationAlert(
                confirmationText: "Save all and switch",
                messageText: "Unsaved files",
                informativeText: url.isLonaWorkspace()
                    ? "You have unsaved files in your current workspace. Save all and switch workspaces?"
                    : "The file '\(url.path)' is in a different workspace and can only be opened if we first switch workspaces. Do you want to save all files and switch?"
                ) {
                    saveAllDocuments(nil)
                } else {
                    return false
                }
            }

            if !setWorkspace(url: workspaceURL) { return false }
        }

        return true
    }

    private func setWorkspace(url: URL) -> Bool {
        if url.isLonaWorkspace() {
            noteNewRecentDocumentURL(url)

            CSUserPreferences.workspaceURL = url

            CSWorkspacePreferences.reloadAllConfigurationFiles(closeDocuments: true)

            AppDelegate.reloadPreferencesWindow()

            return true
        } else {
            Alert(
                items: ["OK"],
                messageText: "This doesn't appear to be a Lona workspace!",
                informativeText: [
                    "There's no 'lona.json' file in '\(url.path)'.",
                    "A Lona workspace must have a 'lona.json' file in the top-level folder."
                ].joined(separator: " ")
            ).run()

            return false
        }
    }
}
