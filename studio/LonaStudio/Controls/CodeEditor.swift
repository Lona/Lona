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

    public var textValue: String = "" { didSet { update() } }
    public var titleText: String = "" { didSet { update() } }
    public var subtitleText: String = "" { didSet { update() } }
    public var fileIcon: NSImage = NSImage() { didSet { update() } }

    // MARK: Private

    private let textView = NSTextField(frame: .zero)
    private let editorHeaderView = EditorHeader()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        editorHeaderView.dividerColor = NSSplitView.defaultDividerColor

        textView.focusRingType = .none
        textView.isBezeled = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = TextStyles.monospacedMicro.nsFont

        addSubview(editorHeaderView)
        addSubview(textView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        editorHeaderView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false

        editorHeaderView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        editorHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        editorHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        editorHeaderView.heightAnchor.constraint(equalToConstant: 38).isActive = true

        textView.setContentHuggingPriority(.defaultLow, for: .vertical)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        textView.topAnchor.constraint(equalTo: editorHeaderView.bottomAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        textView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func update() {
        textView.stringValue = textValue

        editorHeaderView.titleText = titleText
        editorHeaderView.subtitleText = subtitleText
        editorHeaderView.fileIcon = fileIcon
    }
}
