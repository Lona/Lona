//
//  DirectoryViewController.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 06/01/2019.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

// MARK: - DirectoryViewController

class DirectoryViewController: NSViewController {

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

    override var undoManager: UndoManager? { return nil }

    public var folderName: String? { didSet { update() } }
    public var componentNames: [String] = [] { didSet { update() } }
    public var logicFileNames: [String] = [] { didSet { update() } }
    public var readme: String? { didSet { update() } }
    public var onSelectComponent: ((String) -> Void)? { didSet { update() } }

    // MARK: Private

    private let contentView = ComponentBrowser()

    private func setUpViews() {
        self.view = contentView
    }

    private func setUpConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }

    private func update() {
        contentView.readme = readme ?? ""
        contentView.folderName = folderName ?? "Folder"
        contentView.logicFileNames = logicFileNames
        contentView.componentNames = componentNames
        contentView.onSelectComponent = onSelectComponent
    }
}
