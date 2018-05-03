//
//  DocumentationView.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/3/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit
import WebKit

class DocumentationView: NSBox {

    // MARK: Lifecycle

    public init(componentName: String) {
        self.componentName = componentName

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public convenience init() {
        self.init(componentName: "")
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var componentName: String { didSet { update() } }

    // MARK: Private

    private var titleView = NSTextField(labelWithString: "")
    private var markdownEditorView = LonaWebView()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        let app = Bundle.main.resourceURL!.appendingPathComponent("Web")
        let url = app.appendingPathComponent("test.html")
        markdownEditorView.loadLocalApp(main: url, directory: app)

        addSubview(titleView)
        addSubview(markdownEditorView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        markdownEditorView.translatesAutoresizingMaskIntoConstraints = false

        titleView.topAnchor.constraint(equalTo: topAnchor, constant: 48).isActive = true
        titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48).isActive = true

        markdownEditorView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 24).isActive = true
        markdownEditorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -48).isActive = true
        markdownEditorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 48).isActive = true
        markdownEditorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -48).isActive = true
    }

    private func update() {
        titleView.attributedStringValue = TextStyles.title.apply(to: componentName)
    }
}
