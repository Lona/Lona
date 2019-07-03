//
//  EditorViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 9/1/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

// MARK: - EditorViewController

class EditorViewController: NSViewController {

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

    public var contentView: NSView? {
        didSet {
            if let contentView = contentView {
                if contentView.superview != contentContainerView {
                    oldValue?.removeFromSuperview()

                    contentView.removeFromSuperview()

                    contentContainerView.addSubview(contentView)

                    contentView.translatesAutoresizingMaskIntoConstraints = false
                    contentView.topAnchor.constraint(equalTo: editorHeaderView.bottomAnchor).isActive = true
                    contentView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor).isActive = true
                    contentView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor).isActive = true
                    contentView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor).isActive = true
                }
            } else {
                oldValue?.removeFromSuperview()
            }

            update()
        }
    }

    // MARK: Private

    private let contentContainerView = NSView(frame: .zero)
    private let editorHeaderView = EditorHeader()

    private func setUpViews() {
        self.view = contentContainerView

        editorHeaderView.dividerColor = NSSplitView.defaultDividerColor
    }

    private func setUpConstraints() {
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        editorHeaderView.translatesAutoresizingMaskIntoConstraints = false

        contentContainerView.addSubview(editorHeaderView)

        editorHeaderView.topAnchor.constraint(equalTo: contentContainerView.topAnchor).isActive = true
        editorHeaderView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor).isActive = true
        editorHeaderView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor).isActive = true
        editorHeaderView.heightAnchor.constraint(equalToConstant: 38).isActive = true
    }

    private func update() {
        if let document = document {
            editorHeaderView.titleText = document.fileURL?.lastPathComponent ?? "Untitled"
            editorHeaderView.subtitleText = document.isDocumentEdited == true ? " — Edited" : ""
            if let fileURL = document.fileURL {
                editorHeaderView.fileIcon = NSWorkspace.shared.icon(forFile: fileURL.path)
            } else {
                editorHeaderView.fileIcon = NSImage()
            }
        } else {
            editorHeaderView.titleText = "No document"
//            editorHeaderView.subtitleText = ""
            editorHeaderView.fileIcon = NSImage()
        }
    }
}
