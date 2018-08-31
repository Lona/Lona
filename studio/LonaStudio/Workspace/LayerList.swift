//
//  LayerList.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/30/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

public class LayerList: NSBox {

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

    var component: CSComponent? { didSet { update() } }

    var onChange: (() -> Void)? {
        get { return outlineView.onChange }
        set { outlineView.onChange = newValue }
    }

    var onSelectLayer: ((CSLayer?) -> Void)? {
        get { return outlineView.onSelectLayer }
        set { outlineView.onSelectLayer = newValue }
    }

    func addLayer(layer newLayer: CSLayer) {
        outlineView.addLayer(layer: newLayer)
    }

    func reloadWithoutModifyingSelection() {
        outlineView.render(fullRender: false)
    }

    // MARK: Private

    private var outlineView = LayerListOutlineView()
    private var scrollView = NSScrollView(frame: .zero)
    private var headerView = LayerListHeader()
    private var dividerView = NSBox()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        dividerView.boxType = .custom
        dividerView.borderType = .noBorder
        dividerView.contentViewMargins = .zero
        dividerView.fillColor = NSSplitView.defaultDividerColor

        addSubview(dividerView)
        addSubview(headerView)

//        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.addSubview(outlineView)
        scrollView.documentView = outlineView

        outlineView.sizeToFit()

        addSubview(scrollView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        headerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        headerView.bottomAnchor.constraint(equalTo: dividerView.topAnchor).isActive = true

        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        dividerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        dividerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        dividerView.bottomAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true

        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func update() {
        outlineView.component = component
    }
}
