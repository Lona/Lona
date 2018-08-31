//
//  LayerListHeader.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/30/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

public class LayerListHeader: NSBox {

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

    // MARK: Private

    let titleView = NSTextField(labelWithString: "Layers")
    let button = NSSegmentedControl(labels: ["Add"], trackingMode: .momentary, target: nil, action: nil)

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        titleView.attributedStringValue = TextStyles.sectionTitle.apply(to: "Layers")

        button.isEnabled = true

        let menu = NSMenu(items: ComponentMenu.menuItems())
        button.setMenu(menu, forSegment: 0)

        if #available(OSX 10.13, *) {
            button.setShowsMenuIndicator(true, forSegment: 0)
        }

        addSubview(button)
        addSubview(titleView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false

        titleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true

        button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        button.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
    }

    private func update() {}
}
