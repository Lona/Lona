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

    private struct Theme: Codable {
        var text: String
        var divider: String
    }

    // MARK: Lifecycle

    init(editable: Bool, preview: Bool, fullscreen: Bool) {
        self.editable = editable
        self.preview = preview
        self.fullscreen = fullscreen

        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var onMarkdownStringChanged: ((String) -> Void)?
    var markdownString = "" { didSet { update() } }

    func load() {
        let app = Bundle.main.resourceURL!.appendingPathComponent("Web")
        let html = app.appendingPathComponent("markdown-editor.html")
        var urlComponents = URLComponents(url: html, resolvingAgainstBaseURL: true)!

        let theme = Theme(
            text: Colors.textColor.hexString,
            divider: NSSplitView.defaultDividerColor.rgbaString
        )

        urlComponents.queryItems = [
            URLQueryItem(name: "fullscreen", value: fullscreen.description),
            URLQueryItem(name: "editable", value: editable.description),
            URLQueryItem(name: "preview", value: preview.description),
            URLQueryItem(name: "theme", value: try? JSONEncoder().encode(theme).utf8String() ?? "")
        ]

        self.loadLocalApp(main: urlComponents.url!, directory: app)
        self.onMessage = { data in
            guard let messageType = data.get(key: "type").string else { return }

            switch messageType {
            case "ready":
                self.markdownEditorLoaded = true
                self.update()
            case "description":
                guard let stringValue = data.get(key: "payload").string else { return }
                self.onMarkdownStringChanged?(stringValue)
            default:
                break
            }
        }
    }

    // MARK: Private

    /// Show the markdown text editor
    private var editable: Bool

    /// Show a rendered preview of the markdown
    private var preview: Bool

    private var fullscreen: Bool

    private var markdownEditorLoaded = false { didSet { update() } }

    private func update() {
        if !markdownEditorLoaded { return }

        let payload = CSData.Object([
            "type": "setDescription".toData(),
            "payload": markdownString.toData()
            ])
        if let json = payload.jsonString() {
            self.evaluateJavaScript("window.update(\(json))", completionHandler: nil)
        }
    }
}
