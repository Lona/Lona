//
//  DocumentController.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 09/01/2019.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

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

    public func openDocument(withContentsOf url: URL, display displayDocument: Bool) {
        openDocument(withContentsOf: url, display: displayDocument, completionHandler: { _, _, _ in })
    }

    override func openDocument(
        withContentsOf url: URL,
        display displayDocument: Bool,
        completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void
    ) {
        if !ensureValidWorkspaceForOpeningFile(url: url) { return }

        let realURL = FileManager.default.isDirectory(path: url.path) ? url.appendingPathComponent("README.md") : url

        super.openDocument(withContentsOf: realURL, display: displayDocument, completionHandler: completionHandler)
    }

    // For simplicity of document handling, always show Welcome window for now
    override public func reopenDocument(
        for urlOrNil: URL?,
        withContentsOf contentsURL: URL,
        display displayDocument: Bool,
        completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
        return
    }
}

// MARK: - File helpers

extension DocumentController {
    public func makeAndOpenMarkdownDocument(
        withTitle title: String,
        savedTo url: URL
    ) -> Promise<MarkdownDocument, NSError> {
        let document: MarkdownDocument

        do {
            document = try makeUntitledDocument(ofType: "Markdown") as! MarkdownDocument
        } catch let error {
            return .failure(error as NSError)
        }

        document.content = [
            .init(.text(.init(string: title), .h1), .none),
            .makeDefaultEmptyBlock()
        ]

        return document.save(to: url, for: .saveOperation).onSuccess({
            return .result { complete in
                self.openDocument(withContentsOf: url, display: true, completionHandler: { document, alreadyOpen, error in
                    if let error = error {
                        complete(.failure(error as NSError))
                    } else {
                        complete(.success(document as! MarkdownDocument))
                    }
                })
            }
        })
    }
}

// MARK: - Window Controllers

extension DocumentController {
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

        // We call update here, since sometimes updating the document doesn't call the
        // didSet handler. Calling update is sometimes redundant though.
        workspaceViewController.update()
    }

    public var workspaceWindowControllers: [WorkspaceWindowController] {
        let allWindowControllers = Array(documents.compactMap { document in
            document.windowControllers.compactMap({ $0 as? WorkspaceWindowController })
        }.joined())
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
