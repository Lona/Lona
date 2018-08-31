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

    // MARK: Public

//    var component: CSComponent? { didSet { update() } }
//
//    var onChange: (() -> Void)? {
//        get { return outlineView.onChange }
//        set { outlineView.onChange = newValue }
//    }
//
//    var onSelectLayer: ((CSLayer?) -> Void)? {
//        get { return outlineView.onSelectLayer }
//        set { outlineView.onSelectLayer = newValue }
//    }
//
//    func addLayer(layer newLayer: CSLayer) {
//        outlineView.addLayer(layer: newLayer)
//    }
//
//    func reloadWithoutModifyingSelection() {
//        outlineView.render(fullRender: false)
//    }

    // MARK: Private

    let button = NSSegmentedControl(labels: ["Add Component"], trackingMode: .momentary, target: nil, action: nil)

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        button.isEnabled = true

        let menu = NSMenu(items: ComponentMenu.menuItems())
        button.setMenu(menu, forSegment: 0)

        if #available(OSX 10.13, *) {
            button.setShowsMenuIndicator(true, forSegment: 0)
        }

        addSubview(button)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false

        topAnchor.constraint(equalTo: button.topAnchor, constant: -10).isActive = true
        bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: 10).isActive = true
        leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: -10).isActive = true
        trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 10).isActive = true
    }

    private func update() {
//        outlineView.component = component
    }
}
