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
            visualEffectView.material = .appearanceBased
        } else {
            visualEffectView.state = .inactive
            if #available(OSX 10.14, *) {
                visualEffectView.material = .contentBackground
            }
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

public class BackgroundView: NSView {

    public var backgroundColor = Colors.vibrantRaised {
        didSet {
            needsDisplay = true
        }
    }

    public override func draw(_ dirtyRect: NSRect) {
        backgroundColor.setFill()
        dirtyRect.fill()
    }

    public override var allowsVibrancy: Bool {
        return isDarkMode
    }
}
