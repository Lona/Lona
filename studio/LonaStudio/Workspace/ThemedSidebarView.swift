//
//  ThemedSidebarView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/3/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit

public class ThemedSidebarView: NSView {

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    // MARK: Private

    private var contentWrapperView: NSView {
        return isDarkMode ? visualEffectView : self
    }

    private lazy var visualEffectView: NSVisualEffectView = .init()

    private lazy var contentView = NSBox()

    private func setUpViews() {
        contentView.boxType = .custom
        contentView.borderType = .noBorder
        contentView.contentViewMargins = .zero

        if contentWrapperView != self {
            super.addSubview(contentWrapperView)
            contentWrapperView.addSubview(contentView)
        } else {
            super.addSubview(contentView)
        }

        contentView.fillColor = .themed(
            light: Colors.headerBackground,
            dark: NSColor.white.withAlphaComponent(0.1)
        )
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        if contentWrapperView != self {
            contentWrapperView.translatesAutoresizingMaskIntoConstraints = false

            contentWrapperView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            contentWrapperView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            contentWrapperView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            contentWrapperView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        }

        contentView.topAnchor.constraint(equalTo: contentWrapperView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: contentWrapperView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: contentWrapperView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: contentWrapperView.bottomAnchor).isActive = true
    }

    private func update() {}

    public override func addSubview(_ view: NSView) {
        contentView.addSubview(view)
    }
}
