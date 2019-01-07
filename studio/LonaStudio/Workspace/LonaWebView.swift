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

public typealias WebViewHeightChangedClosure = (_ height: CGFloat) -> Void

class LonaWebView: WKWebView {

    // MARK: Lifecycle

    init() {
        let userContentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = userContentController

        super.init(frame: .zero, configuration: config)

        userContentController.add(self, name: "notification")

        // pass down the theme
        let source = "window.THEME = {dark: \(isDarkMode ? "true" : "false"), text: '\(Colors.textColor.hexString)', background: '\(Colors.contentBackground.hexString)'}"
        let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        userContentController.addUserScript(script)

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

    func delegateScroll(onHeightChanged eventHandler: @escaping WebViewHeightChangedClosure) {
        shouldBubbleScroll = true
        onHeightChanged = eventHandler

        // we need to hook into the webview to get its content's height and update the parent view

        let source = "document.addEventListener('readystatechange', resizeHandler); function resizeHandler() {window.webkit.messageHandlers.sizeNotification.postMessage({height: document.body.scrollHeight, type: '__resizeEvent'});}"
        let source2 = "window.addEventListener('resize', resizeHandler)"

        // UserScript object
        let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        let script2 = WKUserScript(source: source2, injectionTime: .atDocumentEnd, forMainFrameOnly: true)

        // Content Controller object
        let controller = configuration.userContentController

        // Add script to controller
        controller.addUserScript(script)
        controller.addUserScript(script2)

        // Add message handler reference
        controller.add(self, name: "sizeNotification")
    }

    // MARK: Private

    private var onHeightChanged: WebViewHeightChangedClosure?
    private var previousHeight: Double = -1
    private var shouldBubbleScroll: Bool = false

    override open func scrollWheel(with event: NSEvent) {
        if shouldBubbleScroll {
            self.nextResponder?.scrollWheel(with: event)
        } else {
            super.scrollWheel(with: event)
        }
    }

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

        guard let messageType = data.get(key: "type").string else {
            onMessage?(data)
            return
        }

        if messageType == "__resizeEvent", let height = data.get(key: "height").number {
            if previousHeight != height {
                previousHeight = height
                self.onHeightChanged?(CGFloat(height))
            }
        } else {
            onMessage?(data)
        }
    }
}
