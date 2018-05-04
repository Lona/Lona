//
//  LonaWebView.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/3/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation
import WebKit

class LonaWebView: WKWebView {

    // MARK: Lifecycle

    init() {
        let userContentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController

        super.init(frame: .zero, configuration: config)

        userContentController.add(self, name: "notification")

        setUpViews()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var onMessage: ((CSData) -> Void)? { didSet { update() } }

    func loadLocalApp(main: URL, directory: URL) {
        loadFileURL(main, allowingReadAccessTo: directory)

        let request = URLRequest(url: main)
        load(request)
    }

    // MARK: Private

    private func setUpViews() {
        setValue(false, forKey: "drawsBackground")
        configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func update() {}
}

// MARK: WKScriptMessageHandler

extension LonaWebView: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let data = CSData.from(json: message.body)
        onMessage?(data)
    }
}
