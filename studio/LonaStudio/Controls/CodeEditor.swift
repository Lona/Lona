//
//  CodeEditor.swift
//  LonaStudio
//
//  Created by Devin Abbott on 9/4/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

// MARK: - CodeEditor

public class CodeEditor: NSBox {

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var generatedCode: String = "" { didSet { update() } }
    public var titleText: String = "" { didSet { update() } }
    public var subtitleText: String = "" { didSet { update() } }
    public var fileIcon: NSImage = NSImage() { didSet { update() } }
    public var commandPreview: String = "" { didSet { update() } }
    public var compilerTargetValues: [String] = [] { didSet { update() } }
    public var compilerTargetIndex: Int = 0 { didSet { update() } }
    public var onChangeCompilerTargetIndex: ((Int) -> Void)? { didSet { update() } }
    public var compilerFrameworkValues: [String] = [] { didSet { update() } }
    public var compilerFrameworkIndex: Int = 0 { didSet { update() } }
    public var onChangeCompilerFrameworkIndex: ((Int) -> Void)? { didSet { update() } }

    // MARK: Private

    private let editorHeaderView = EditorHeader()

    private let outputPreview = GeneratedOutputPreview()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        editorHeaderView.dividerColor = NSSplitView.defaultDividerColor

        addSubview(editorHeaderView)
        addSubview(outputPreview)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        editorHeaderView.translatesAutoresizingMaskIntoConstraints = false
        outputPreview.translatesAutoresizingMaskIntoConstraints = false

        editorHeaderView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        editorHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        editorHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        editorHeaderView.heightAnchor.constraint(equalToConstant: 38).isActive = true

        outputPreview.topAnchor.constraint(equalTo: editorHeaderView.bottomAnchor).isActive = true
        outputPreview.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        outputPreview.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        outputPreview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        outputPreview.commandPreviewView.isSelectable = true
        outputPreview.commandPreviewView.allowsEditingTextAttributes = true
        outputPreview.commandPreviewView.setContentHuggingPriority(.defaultLow, for: .vertical)
        outputPreview.commandPreviewView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        outputPreview.commandPreviewView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        outputPreview.commandPreviewView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        outputPreview.codePreviewView.isSelectable = true
        outputPreview.codePreviewView.allowsEditingTextAttributes = true
        outputPreview.codePreviewView.setContentHuggingPriority(.defaultLow, for: .vertical)
        outputPreview.codePreviewView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        outputPreview.codePreviewView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        outputPreview.codePreviewView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func update() {
        outputPreview.commandText = commandPreview
        outputPreview.generatedCode = generatedCode

        outputPreview.onChangeFrameworkIndex = onChangeCompilerFrameworkIndex
        outputPreview.onChangeCompilerTargetIndex = onChangeCompilerTargetIndex
        outputPreview.compilerTargetValues = compilerTargetValues
        outputPreview.frameworkValues = compilerFrameworkValues
        outputPreview.compilerTargetIndex = compilerTargetIndex
        outputPreview.frameworkIndex = compilerFrameworkIndex

        editorHeaderView.titleText = titleText
        editorHeaderView.subtitleText = subtitleText
        editorHeaderView.fileIcon = fileIcon
    }
}
