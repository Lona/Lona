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

    public init(componentName: String, descriptionText: String) {
        self.componentName = componentName
        self.descriptionText = descriptionText

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public convenience init() {
        self.init(componentName: "", descriptionText: "")
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var componentName: String { didSet { update() } }
    public var descriptionText: String { didSet { update() } }
    public var onChangeDescription: ((String) -> Void)?

    // MARK: Private

    private var titleView = NSTextField(labelWithString: "")
    private var markdownEditorView = LonaWebView()
    private var markdownEditorLoaded = false { didSet { update() } }

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        let app = Bundle.main.resourceURL!.appendingPathComponent("Web")
        let url = app.appendingPathComponent("markdown-editor.html")
        markdownEditorView.loadLocalApp(main: url, directory: app)
        markdownEditorView.onMessage = { data in
            guard let messageType = data.get(key: "type").string else { return }

            switch messageType {
            case "ready":
                self.markdownEditorLoaded = true
            case "description":
                guard let stringValue = data.get(key: "payload").string else { return }
                self.onChangeDescription?(stringValue)
            default:
                break
            }
        }

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

    private func updateDescription() {
        let payload = CSData.Object([
            "type": "setDescription".toData(),
            "payload": descriptionText.toData()
            ])
        if let json = payload.jsonString() {
            markdownEditorView.evaluateJavaScript("window.update(\(json))", completionHandler: nil)
        }
    }

    private func update() {
        titleView.attributedStringValue = TextStyles.title.apply(to: componentName)
        updateDescription()
    }
}
