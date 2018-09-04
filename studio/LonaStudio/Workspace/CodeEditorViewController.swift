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
                    onSuccess: { result in
                        guard let result = result else { return }
                        DispatchQueue.main.async {
                            self.contentView.textValue = result
                        }
                }, onFailure: { code, message in
                    Swift.print("Failed", code, message as Any)
                })
            }
        }
    }
}
