//
//  CodeEditorViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 9/1/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

// MARK: - CodeEditorViewController

class CodeEditorViewController: NSViewController {

    // MARK: Lifecycle

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)

        setUpViews()
        setUpConstraints()

        update()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setUpViews()
        setUpConstraints()

        update()
    }

    // MARK: Public

    public var document: NSDocument? { didSet { update() } }

    // MARK: Private

    private var fileExtension = "js"

    private var generatedFilename: String {
        if let fileURL = document?.fileURL {
            return fileURL.deletingPathExtension().lastPathComponent + "." + fileExtension
        } else {
            return "Untitled"
        }
    }

    private let contentView = CodeEditor()

    private func setUpViews() {
        self.view = contentView
    }

    private func setUpConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func update() {
        if let document = document as? JSONDocument {
            contentView.titleText = generatedFilename
            contentView.subtitleText = " — Generated output"
            contentView.fileIcon = NSWorkspace.shared.icon(forFileType: fileExtension)

            if let content = document.content, case .colors = content {
                guard let compilerPath = CSUserPreferences.compilerURL?.path else { return }
                guard let data = try? document.data(ofType: "JSONDocument") else { return }

                LonaNode.run(
                    arguments: [compilerPath, "colors", fileExtension],
                    inputData: data,
                    currentDirectoryPath: CSUserPreferences.workspaceURL.path,
                    onSuccess: { output in
                        guard let result = output.utf8String() else { return }
                        DispatchQueue.main.async {
                            // There's a race condition here where the document may have changed
                            // by the time this completes, and the text will be set for the wrong document.
                            // Make sure we're looking at the same document before setting the text
                            guard document == self.document else { return }
                            self.contentView.textValue = result
                        }
                }, onFailure: { code, message in
                    Swift.print("Failed", code, message as Any)
                })

            } else if let content = document.content, case .textStyles = content {
                guard let compilerPath = CSUserPreferences.compilerURL?.path else { return }
                guard let data = try? document.data(ofType: "JSONDocument") else { return }

                LonaNode.run(
                    arguments: [compilerPath, "textStyles", fileExtension],
                    inputData: data,
                    currentDirectoryPath: CSUserPreferences.workspaceURL.path,
                    onSuccess: { output in
                        guard let result = output.utf8String() else { return }
                        DispatchQueue.main.async {
                            // There's a race condition here where the document may have changed
                            // by the time this completes, and the text will be set for the wrong document.
                            // Make sure we're looking at the same document before setting the text
                            guard document == self.document else { return }
                            self.contentView.textValue = result
                        }
                }, onFailure: { code, message in
                    Swift.print("Failed", code, message as Any)
                })
            } else {
                contentView.titleText = ""
                contentView.subtitleText = ""
                contentView.fileIcon = NSImage()
                contentView.textValue = ""
            }
        } else {
            contentView.titleText = ""
            contentView.subtitleText = "No output"
            contentView.fileIcon = NSImage()
            contentView.textValue = ""
        }
    }
}
