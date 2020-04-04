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
        viewDidChangeEffectiveAppearance()

        update()
    }

    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public override func viewDidChangeEffectiveAppearance() {
        if isDarkMode {
            visualEffectView.state = .followsWindowActiveState
            visualEffectView.appearance = NSAppearance(appearanceNamed: .vibrantDark, bundle: nil)
        } else {
            visualEffectView.state = .inactive
            visualEffectView.appearance = NSAppearance(appearanceNamed: .vibrantLight, bundle: nil)
        }
    }

    // MARK: Private

    private var visualEffectView = NSVisualEffectView()

    private var contentView = BackgroundView()

    private func setUpViews() {
        super.addSubview(visualEffectView)
        visualEffectView.addSubview(contentView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        visualEffectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        contentView.topAnchor.constraint(equalTo: visualEffectView.topAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor).isActive = true
    }

    private func update() {}

    public override func addSubview(_ view: NSView) {
        contentView.addSubview(view)
    }
}

private class BackgroundView: NSView {

    override var allowsVibrancy: Bool {
        return isDarkMode
    }

    var backgroundColor: NSColor = .themed(
        light: Colors.headerBackground,
        dark: NSColor.black.highlight(withLevel: 0.08)!
    )

    override func draw(_ dirtyRect: NSRect) {
        backgroundColor.setFill()
        dirtyRect.fill()
    }
}
