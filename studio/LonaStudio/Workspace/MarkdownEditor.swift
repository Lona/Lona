//
//  MarkdownEditor.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 08/01/2019.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation
import WebKit

class MarkdownEditor: LonaWebView {

    // MARK: Lifecycle

    init(editable: Bool) {

        super.init()

        // pass down the editable state
        let source = "window.EDITABLE = \(editable ? "true" : "false");"
        let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        self.configuration.userContentController.addUserScript(script)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var onMarkdownStringChanged: ((String) -> Void)?
    var markdownString = "" { didSet { update() } }

    func load() {
        let app = Bundle.main.resourceURL!.appendingPathComponent("Web")
        let url = app.appendingPathComponent("markdown-editor.html")
        self.loadLocalApp(main: url, directory: app)
        self.onMessage = { data in
            guard let messageType = data.get(key: "type").string else { return }

            switch messageType {
            case "ready":
                self.markdownEditorLoaded = true
            case "description":
                guard let stringValue = data.get(key: "payload").string else { return }
                self.onMarkdownStringChanged?(stringValue)
            default:
                break
            }
        }
    }

    // MARK: Private

    private var markdownEditorLoaded = false { didSet { update() } }

    private func update() {
        let payload = CSData.Object([
            "type": "setDescription".toData(),
            "payload": markdownString.toData()
            ])
        if let json = payload.jsonString() {
            self.evaluateJavaScript("window.update(\(json))", completionHandler: nil)
        }
    }
}
