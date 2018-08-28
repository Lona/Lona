//
//  InspectorContentView.swift
//  LonaStudio
//
//  Created by Nghia Tran on 2/19/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Cocoa

final class InspectorView: NSBox {

    enum Content {
        case layer(CSLayer)
        case color(CSColor)
    }

    // MARK: Lifecycle

    init() {
        super.init(frame: NSRect.zero)

        setUpViews()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var content: Content? { didSet { update() } }

    var onChangeContent: ((Content, LayerInspectorView.ChangeType) -> Void)?

    // MARK: Private

    private let scrollView = NSScrollView(frame: .zero)

    // Flip the content within the scrollview so it starts at the top
    private let flippedView = FlippedView()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.contentInsets = NSEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        scrollView.addSubview(flippedView)
        scrollView.documentView = flippedView

        addSubview(scrollView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        flippedView.translatesAutoresizingMaskIntoConstraints = false

        // The layout gets completely messed up without this
        flippedView.wantsLayer = true

        topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true

        flippedView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        flippedView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20).isActive = true
        flippedView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -20).isActive = true

//        flippedView.leftAnchor.constraint(equalTo: scrollView.contentView.leftAnchor, constant: 20).isActive = true
//        flippedView.rightAnchor.constraint(equalTo: scrollView.contentView.rightAnchor, constant: -20).isActive = true
    }

    private var inspectorView = NSView()

    func update() {
        inspectorView.removeFromSuperview()

        guard let content = content else { return }

        switch content {
        case .layer(let content):
            if case CSLayer.LayerType.custom = content.type, let componentLayer = content as? CSComponentLayer {
                let componentInspectorView = CustomComponentInspectorView(componentLayer: componentLayer)
                componentInspectorView.onChangeData = {[unowned self] (data, parameter) in
                    componentLayer.parameters[parameter.name] = data

                    self.onChangeContent?(.layer(componentLayer), LayerInspectorView.ChangeType.full)
                    componentInspectorView.reload()
                }
                inspectorView = componentInspectorView
            } else {
                let layerInspector = LayerInspectorView(layer: content)
                layerInspector.onChangeInspector = {[unowned self] changeType in
                    self.onChangeContent?(.layer(content), changeType)
                }
                inspectorView = layerInspector
            }

            flippedView.addSubview(inspectorView)

            inspectorView.widthAnchor.constraint(equalTo: flippedView.widthAnchor).isActive = true
            inspectorView.heightAnchor.constraint(equalTo: flippedView.heightAnchor).isActive = true

        case .color(let color):
            let editor = DictionaryEditor(
                value: color.toValue(),
                onChange: { updated in
//                    CSColors.update(color: updated.data, at: index)
                    Swift.print("Updated", updated)
                }
            )

            editor.heightAnchor.constraint(equalToConstant: 400).isActive = true

            inspectorView = editor

            flippedView.addSubview(inspectorView)

            inspectorView.widthAnchor.constraint(equalTo: flippedView.widthAnchor).isActive = true
            inspectorView.heightAnchor.constraint(equalTo: flippedView.heightAnchor).isActive = true
            inspectorView.topAnchor.constraint(equalTo: flippedView.topAnchor).isActive = true
            inspectorView.bottomAnchor.constraint(equalTo: flippedView.bottomAnchor).isActive = true
        }
    }
}
