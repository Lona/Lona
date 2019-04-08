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

    // MARK: Private

    let viewComponentIcon = DraggableIconButton()

    let button = NSSegmentedControl(labels: ["Add"], trackingMode: .momentary, target: nil, action: nil)

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        viewComponentIcon.image = #imageLiteral(resourceName: "icon-component-view")
        viewComponentIcon.getPasteboardItem = {
            let item = NSPasteboardItem()
            item.setString(CSLayer.LayerType.builtIn(.view).string, forType: .lonaLayerTemplateType)
            return item
        }

        button.isEnabled = true

        let menu = NSMenu(items: ComponentMenu.menuItems())
        button.setMenu(menu, forSegment: 0)

        if #available(OSX 10.13, *) {
            button.setShowsMenuIndicator(true, forSegment: 0)
        }

        addSubview(button)
        addSubview(viewComponentIcon)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        viewComponentIcon.translatesAutoresizingMaskIntoConstraints = false

        heightAnchor.constraint(equalToConstant: 37).isActive = true

        button.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true

        viewComponentIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        viewComponentIcon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1).isActive = true
        viewComponentIcon.widthAnchor.constraint(equalToConstant: 12).isActive = true
        viewComponentIcon.heightAnchor.constraint(equalToConstant: 12).isActive = true
    }

    private func update() {}

    private func updateMenuItems() {
        button.menu(forSegment: 0)?.items = ComponentMenu.menuItems()
    }

    deinit {
        subscriptions.forEach({ sub in sub() })
    }
}
