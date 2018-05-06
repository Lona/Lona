//
//  InspectorContentView.swift
//  LonaStudio
//
//  Created by Nghia Tran on 2/19/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Cocoa

final class InspectorContentView: NSScrollView {

    // MARK: - Variable

    private let inspectorView: NSView

    // MARK: - Init

    init(inspectorView: NSView) {
        self.inspectorView = inspectorView
        super.init(frame: NSRect.zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {

        // Flip the content within the scrollview so it starts at the top
        let flippedView = FlippedView()
        flippedView.translatesAutoresizingMaskIntoConstraints = false
        flippedView.addSubview(inspectorView)

        translatesAutoresizingMaskIntoConstraints = false
        documentView = flippedView
        hasVerticalRuler = true
        drawsBackground = false
        automaticallyAdjustsContentInsets = false
        contentInsets = NSEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        inspectorView.widthAnchor.constraint(equalTo: flippedView.widthAnchor).isActive = true
        inspectorView.heightAnchor.constraint(equalTo: flippedView.heightAnchor).isActive = true

        flippedView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        flippedView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
    }
}
