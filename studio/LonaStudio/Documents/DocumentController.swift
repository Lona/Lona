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
    public var didOpenADocument = false

    override public static var shared: DocumentController {
        return NSDocumentController.shared as! DocumentController
    }

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

    override func makeDocument(for urlOrNil: URL?, withContentsOf contentsURL: URL, ofType typeName: String) throws -> NSDocument {
        try super.makeDocument(for: urlOrNil, withContentsOf: contentsURL, ofType: typeName)
    }

    override func makeDocument(withContentsOf url: URL, ofType typeName: String) throws -> NSDocument {
        if FileManager.default.isDirectory(path: url.path) {
            return try super.makeDocument(withContentsOf: url.appendingPathComponent("README.md"), ofType: "Markdown")
        }

        return try super.makeDocument(withContentsOf: url, ofType: typeName)
    }

    override func openDocument(
        withContentsOf url: URL,
        display displayDocument: Bool,
        completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void
    ) {
        if !ensureValidWorkspaceForOpeningFile(url: url) { return }

        super.openDocument(withContentsOf: url, display: displayDocument, completionHandler: completionHandler)
    }

    public func openDocument(withContentsOf url: URL, display displayDocument: Bool) {
        openDocument(withContentsOf: url, display: displayDocument, completionHandler: { _, _, _ in })
    }

    override public func reopenDocument(
        for urlOrNil: URL?,
        withContentsOf contentsURL: URL,
        display displayDocument: Bool,
        completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {

        if !ensureValidWorkspaceForOpeningFile(url: contentsURL) { return }

        super.reopenDocument(for: urlOrNil, withContentsOf: contentsURL, display: displayDocument, completionHandler: completionHandler)
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
