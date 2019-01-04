//
//  ColorSwatchRowView.swift
//  LonaStudio
//
//  Created by Nghia Tran on 12/24/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

final class ColorSwatchRowView: NSStackView, Hoverable, PickerRowViewType {

    var onClick: () -> Void = {}

    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }

    override func mouseDown(with event: NSEvent) {
        Swift.print("Click swatch")
        onClick()
    }

    let titleView: NSTextField
    let subtitleView: NSTextField

    init(color: CSColor, selected: Bool) {
        let title = NSTextField(labelWithString: color.name)
        title.font = NSFont.systemFont(ofSize: 12)
        title.textColor = Colors.textColor
        titleView = title

        let subtitle = NSTextField(labelWithString: color.value)
        subtitle.font = NSFont.systemFont(ofSize: 10)
        subtitle.textColor = Colors.textColor
        subtitleView = subtitle

        super.init(frame: NSRect.zero)

        wantsLayer = true

        //        backgroundFill = NSColor.red.cgColor

        spacing = 8
        orientation = .horizontal
        alignment = .centerY
        translatesAutoresizingMaskIntoConstraints = false
        edgeInsets = NSEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)

        let swatch = NSView(frame: NSRect.zero)
        swatch.translatesAutoresizingMaskIntoConstraints = false
        swatch.heightAnchor.constraint(equalToConstant: 32).isActive = true
        swatch.widthAnchor.constraint(equalToConstant: 32).isActive = true
        swatch.wantsLayer = true
        swatch.layer?.backgroundColor = color.color.cgColor
        swatch.layer?.cornerRadius = 2

        let description = NSStackView(views: [title, subtitle], orientation: .vertical)
        description.spacing = 2
        description.alignment = .left

        addArrangedSubview(swatch)
        addArrangedSubview(description)

        onHover(selected)
        startTrackingHover()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func onHover(_ hover: Bool) {
        if hover {
            titleView.textColor = NSColor.white
            subtitleView.textColor = NSColor.parse(css: "rgba(255,255,255,0.5)")!
            layer?.backgroundColor = NSColor.selectedMenuItemColor.cgColor
        } else {
            titleView.textColor = Colors.textColor
            subtitleView.textColor = Colors.textColor
            layer?.backgroundColor = NSColor.clear.cgColor
        }
    }

    // MARK: - Hover
    override func mouseEntered(with theEvent: NSEvent) {
        onHover(true)
    }

    override func mouseExited(with theEvent: NSEvent) {
        onHover(false)
    }
}
