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

    convenience init(editable: Bool, preview: Bool) {
        self.init(nibName: nil, bundle: nil)

        self.editable = editable
        self.preview = preview
    }

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    // MARK: Public

    public var editable: Bool = true

    public var preview: Bool = true

    public var content: String = "" { didSet { update() } }

    public var onChange: ((String) -> Void)?

    // MARK: Private

    override func loadView() {

        setUpViews()
        setUpConstraints()

        update()
    }

    private let containerView = NSBox()
    private var contentView: MarkdownEditor! = nil

    private func setUpViews() {
        containerView.borderType = .noBorder
        containerView.boxType = .custom
        containerView.contentViewMargins = .zero
        containerView.fillColor = Colors.contentBackground

        contentView = MarkdownEditor(editable: editable, preview: preview, fullscreen: true)
        contentView.load()
        contentView.onMarkdownStringChanged = { [unowned self] value in self.onChange?(value) }

        containerView.addSubview(contentView)

        view = contentView
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
