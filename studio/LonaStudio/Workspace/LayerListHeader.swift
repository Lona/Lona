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
    private var subscriptions: [() -> Void] = []

    // MARK: Lifecycle

    init() {
        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()

        subscriptions.append(LonaPlugins.current.register(eventType: .onChangeFileSystemComponents) { [unowned self] in
            self.updateMenuItems()
        })
    }

    public required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var onClickLayerTemplateType: ((CSLayer.LayerType) -> Void)?

    // MARK: Private

    private let viewComponentIcon = DraggableIconButton()
    private let textComponentIcon = DraggableIconButton()
    private let imageComponentIcon = DraggableIconButton()
    private let vectorComponentIcon = DraggableIconButton()

    private let button = NSSegmentedControl(images: [#imageLiteral(resourceName: "icon-component-plus")], trackingMode: .momentary, target: nil, action: nil)

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        func getPasteboardItem(forLayerType type: CSLayer.LayerType) -> NSPasteboardItem {
            let item = NSPasteboardItem()
            item.setString(type.string, forType: .lonaLayerTemplateType)
            return item
        }

        viewComponentIcon.getPasteboardItem = { getPasteboardItem(forLayerType: .builtIn(.view)) }
        textComponentIcon.getPasteboardItem = { getPasteboardItem(forLayerType: .builtIn(.text)) }
        imageComponentIcon.getPasteboardItem = { getPasteboardItem(forLayerType: .builtIn(.image)) }
        vectorComponentIcon.getPasteboardItem = { getPasteboardItem(forLayerType: .builtIn(.vectorGraphic)) }

        viewComponentIcon.onClick = { [unowned self] in self.onClickLayerTemplateType?(.builtIn(.view)) }
        textComponentIcon.onClick = { [unowned self] in self.onClickLayerTemplateType?(.builtIn(.text)) }
        imageComponentIcon.onClick = { [unowned self] in self.onClickLayerTemplateType?(.builtIn(.image)) }
        vectorComponentIcon.onClick = { [unowned self] in self.onClickLayerTemplateType?(.builtIn(.vectorGraphic)) }

        viewComponentIcon.toolTip = "View"
        textComponentIcon.toolTip = "Text"
        imageComponentIcon.toolTip = "Image"
        vectorComponentIcon.toolTip = "Vector Graphic"

        addSubview(viewComponentIcon)
        addSubview(textComponentIcon)
        addSubview(imageComponentIcon)
        addSubview(vectorComponentIcon)

        button.isEnabled = true
        button.cell?.isBordered = false

        let menu = NSMenu(items: ComponentMenu.menuItems())
        button.setMenu(menu, forSegment: 0)
        button.setShowsMenuIndicator(true, forSegment: 0)

        addSubview(button)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        viewComponentIcon.translatesAutoresizingMaskIntoConstraints = false
        textComponentIcon.translatesAutoresizingMaskIntoConstraints = false
        imageComponentIcon.translatesAutoresizingMaskIntoConstraints = false
        vectorComponentIcon.translatesAutoresizingMaskIntoConstraints = false

        viewComponentIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 13).isActive = true
        viewComponentIcon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1).isActive = true
        viewComponentIcon.widthAnchor.constraint(equalToConstant: 12).isActive = true
        viewComponentIcon.heightAnchor.constraint(equalToConstant: 12).isActive = true

        textComponentIcon.leadingAnchor.constraint(equalTo: viewComponentIcon.trailingAnchor, constant: 19).isActive = true
        textComponentIcon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1).isActive = true
        textComponentIcon.widthAnchor.constraint(equalToConstant: 11).isActive = true
        textComponentIcon.heightAnchor.constraint(equalToConstant: 12).isActive = true

        imageComponentIcon.leadingAnchor.constraint(equalTo: textComponentIcon.trailingAnchor, constant: 20).isActive = true
        imageComponentIcon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1).isActive = true
        imageComponentIcon.widthAnchor.constraint(equalToConstant: 12).isActive = true
        imageComponentIcon.heightAnchor.constraint(equalToConstant: 12).isActive = true

        vectorComponentIcon.leadingAnchor.constraint(equalTo: imageComponentIcon.trailingAnchor, constant: 20).isActive = true
        vectorComponentIcon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1).isActive = true
        vectorComponentIcon.widthAnchor.constraint(equalToConstant: 12).isActive = true
        vectorComponentIcon.heightAnchor.constraint(equalToConstant: 12).isActive = true

        button.leadingAnchor.constraint(greaterThanOrEqualTo: vectorComponentIcon.trailingAnchor, constant: 10).isActive = true

        button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true
    }

    private func update() {
        let iconColor = isDarkMode ? #colorLiteral(red: 0.9450980392, green: 0.9450980392, blue: 0.9450980392, alpha: 1) : #colorLiteral(red: 0.3803921569, green: 0.3803921569, blue: 0.3803921569, alpha: 1)

        viewComponentIcon.image = #imageLiteral(resourceName: "icon-component-view").tinted(color: iconColor)
        textComponentIcon.image = #imageLiteral(resourceName: "icon-component-text").tinted(color: iconColor)
        imageComponentIcon.image = #imageLiteral(resourceName: "icon-component-image").tinted(color: iconColor)
        vectorComponentIcon.image = #imageLiteral(resourceName: "icon-component-vector").tinted(color: iconColor)
        button.setImage(#imageLiteral(resourceName: "icon-component-plus").tinted(color: iconColor), forSegment: 0)
    }

    private func updateMenuItems() {
        button.menu(forSegment: 0)?.items = ComponentMenu.menuItems()
    }

    deinit {
        subscriptions.forEach({ sub in sub() })
    }

    public override func viewDidChangeEffectiveAppearance() {
        update()
    }
}
