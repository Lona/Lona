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

    enum CompilerTarget: String, CaseIterable {
        case js, swift

        var frameworkValues: [String] {
            switch self {
            case .js:
                return JSFramework.allCases.map { $0.rawValue }
            case .swift:
                return SwiftFramework.allCases.map { $0.rawValue }
            }
        }
    }

    enum JSFramework: String, CaseIterable {
        case reactdom, reactnative, reactsketchapp
    }

    enum SwiftFramework: String, CaseIterable {
        case uikit, appkit
    }

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

    private var fileExtension: String {
        return CodeEditorViewController.compilerTarget
    }

    private var currentFramework: String {
        let target = CompilerTarget.init(rawValue: CodeEditorViewController.compilerTarget) ?? CompilerTarget.js
        return CodeEditorViewController.compilerFramework(for: target)
    }

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
        guard let command = compilerCommand() else {
            contentView.commandPreview = ""
            return
        }

        contentView.commandPreview = "lonac " + command.joined(separator: " ")

        if let document = document as? JSONDocument {
            contentView.titleText = generatedFilename
            contentView.subtitleText = " — Generated code preview"
            contentView.fileIcon = NSWorkspace.shared.icon(forFileType: fileExtension)

            if let content = document.content, case .colors = content {
                guard let compilerPath = CSUserPreferences.compilerURL?.path else { return }
                guard let data = try? document.data(ofType: "JSONDocument") else { return }

                LonaNode.run(
                    arguments: [compilerPath] + command,
                    inputData: data,
                    currentDirectoryPath: CSUserPreferences.workspaceURL.path,
                    onSuccess: { output in
                        guard let result = output.utf8String() else { return }
                        DispatchQueue.main.async {
                            // There's a race condition here where the document may have changed
                            // by the time this completes, and the text will be set for the wrong document.
                            // Make sure we're looking at the same document before setting the text
                            guard document == self.document else { return }
                            self.contentView.generatedCode = result
                        }
                }, onFailure: { code, message in
                    Swift.print("Failed", code, message as Any)
                })

            } else if let content = document.content, case .textStyles = content {
                guard let compilerPath = CSUserPreferences.compilerURL?.path else { return }
                guard let data = try? document.data(ofType: "JSONDocument") else { return }

                LonaNode.run(
                    arguments: [compilerPath] + command,
                    inputData: data,
                    currentDirectoryPath: CSUserPreferences.workspaceURL.path,
                    onSuccess: { output in
                        guard let result = output.utf8String() else { return }
                        DispatchQueue.main.async {
                            // There's a race condition here where the document may have changed
                            // by the time this completes, and the text will be set for the wrong document.
                            // Make sure we're looking at the same document before setting the text
                            guard document == self.document else { return }
                            self.contentView.generatedCode = result
                        }
                }, onFailure: { code, message in
                    Swift.print("Failed", code, message as Any)
                })
            } else {
                contentView.titleText = ""
                contentView.subtitleText = ""
                contentView.fileIcon = NSImage()
                contentView.generatedCode = ""
            }
        } else if let document = document as? LogicDocument {
            contentView.titleText = generatedFilename
            contentView.subtitleText = " — Generated code preview"
            contentView.fileIcon = NSWorkspace.shared.icon(forFileType: fileExtension)

            guard let compilerPath = CSUserPreferences.compilerURL?.path else { return }
            guard let data = try? document.data(ofType: "Logic") else { return }

            LonaNode.run(
                arguments: [compilerPath] + command,
                inputData: data,
                currentDirectoryPath: CSUserPreferences.workspaceURL.path,
                onSuccess: { output in
                    guard let result = output.utf8String() else { return }
                    DispatchQueue.main.async {
                        // There's a race condition here where the document may have changed
                        // by the time this completes, and the text will be set for the wrong document.
                        // Make sure we're looking at the same document before setting the text
                        guard document == self.document else { return }
                        self.contentView.generatedCode = result
                    }
            }, onFailure: { code, message in
                Swift.print("Failed", code, message as Any)
            })
        } else {
            contentView.titleText = ""
            contentView.subtitleText = "No output"
            contentView.fileIcon = NSImage()
            contentView.generatedCode = ""
        }

        let target = CompilerTarget.init(rawValue: CodeEditorViewController.compilerTarget) ?? CompilerTarget.js

        contentView.compilerTargetIndex = CompilerTarget.allCases.firstIndex(of: target) ?? 0
        contentView.compilerTargetValues = CompilerTarget.allCases.map { $0.rawValue }
        contentView.onChangeCompilerTargetIndex = { [unowned self] index in
            self.contentView.compilerTargetIndex = index
            CodeEditorViewController.compilerTarget = CompilerTarget.allCases[index].rawValue
            self.update()
        }

        contentView.compilerFrameworkIndex = target.frameworkValues.firstIndex(of: CodeEditorViewController.compilerFramework(for: target)) ?? 0
        contentView.compilerFrameworkValues = target.frameworkValues
        contentView.onChangeCompilerFrameworkIndex = { [unowned self] index in
            self.contentView.compilerFrameworkIndex = index
            CodeEditorViewController.setCompilerFramework(for: target, value: target.frameworkValues[index])
            self.update()
        }
    }

    private func compilerCommand() -> [String]? {
        if let document = document as? JSONDocument {
            if let content = document.content, case .colors = content {
                return ["colors", "--target", fileExtension, "--framework", currentFramework]
            } else if let content = document.content, case .textStyles = content {
                return ["textStyles", "--target", fileExtension, "--framework", currentFramework]
            }
        } else if let _ = document as? LogicDocument {
            return ["logic", "--target", fileExtension, "--framework", currentFramework]
        }

        return nil
    }

    private static var outputPreviewCompilerTargetKey = "Output preview compiler target"

    static var compilerTarget: String {
        get {
            return UserDefaults.standard.string(forKey: outputPreviewCompilerTargetKey) ?? CompilerTarget.js.rawValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: outputPreviewCompilerTargetKey)
        }
    }

    static func compilerFramework(for target: CompilerTarget) -> String {
        let outputPreviewCompilerFrameworkKey = "\(compilerTarget): Output preview compiler framework"
        return UserDefaults.standard.string(forKey: outputPreviewCompilerFrameworkKey) ?? target.frameworkValues[0]
    }

    static func setCompilerFramework(for target: CompilerTarget, value: String) {
        let outputPreviewCompilerFrameworkKey = "\(compilerTarget): Output preview compiler framework"
        UserDefaults.standard.set(value, forKey: outputPreviewCompilerFrameworkKey)
    }
}
