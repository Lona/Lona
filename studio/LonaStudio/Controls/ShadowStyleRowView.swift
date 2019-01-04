//
//  ShadowStyleRowView.swift
//  LonaStudio
//
//  Created by Nghia Tran on 12/24/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

final class ShadowStyleRowView: NSStackView, Hoverable, PickerRowViewType {

    // MARK: - Variable
    private let titleView: NSTextField
    private let subtitleView: NSTextField
    private lazy var colorView: NSView = {
        let view = NSView(frame: NSRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        view.widthAnchor.constraint(equalToConstant: 32).isActive = true
        view.wantsLayer = true
        view.layer?.cornerRadius = 2
        return view
    }()
    var onClick: () -> Void = {}

    // MARK: - Init
    init(shadow: CSShadow, selected: Bool) {
        titleView = NSTextField(labelWithString: shadow.name)
        subtitleView = NSTextField(labelWithString: "x: \(shadow.x) y: \(shadow.y) blur: \(shadow.blur)")

        super.init(frame: NSRect.zero)

        initCommon()
        colorView.backgroundFill = shadow.color.cgColor
        let container = NSStackView(views: [titleView, subtitleView], orientation: .vertical)
        container.alignment = .leading
        addArrangedSubview(colorView)
        addArrangedSubview(container)
        startTrackingHover()
        onHover(selected)
    }

    deinit {
        removeTrackingHover()
    }

    private func initCommon() {
        spacing = 8
        orientation = .horizontal
        distribution = .fill
        alignment = .centerY
        edgeInsets = NSEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }

    override func mouseDown(with event: NSEvent) {
        onClick()
    }

    func onHover(_ hover: Bool) {
        if hover {
            startHover { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.titleView.textColor = NSColor.white
                strongSelf.subtitleView.textColor = NSColor.white
                strongSelf.backgroundFill = NSColor.parse(css: "#0169D9")!.cgColor
            }
        } else {
            stopHover { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.titleView.textColor = Colors.textColor
                strongSelf.subtitleView.textColor = Colors.textColor
                strongSelf.backgroundFill = NSColor.clear.cgColor
            }
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
