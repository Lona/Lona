//
//  MarkdownViewController.swift
//  LonaStudio
//
//  Created by Devin Abbott on 6/29/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

// MARK: - MarkdownViewController

class MarkdownViewController: NSViewController {

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

    public var content: String = "" { didSet { update() } }

    public var onChange: ((String) -> Void)?

    // MARK: Private

    private let containerView = NSBox()
    private let contentView = MarkdownEditor(editable: true, fullscreen: true)

    private func setUpViews() {
        containerView.borderType = .noBorder
        containerView.boxType = .custom
        containerView.contentViewMargins = .zero

        containerView.fillColor = Colors.contentBackground

        contentView.load()
        contentView.onMarkdownStringChanged = { [unowned self] value in self.onChange?(value) }

        containerView.addSubview(contentView)

        self.view = containerView
    }

    private func setUpConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }

    private func update() {
        contentView.markdownString = content
    }
}
