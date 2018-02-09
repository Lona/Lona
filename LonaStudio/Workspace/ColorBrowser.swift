//
//  ColorBrowser.swift
//  LonaStudio
//
//  Created by devin_abbott on 2/9/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

private let titleStyle = AttributedFont(
    fontFamily: NSFont.systemFont(ofSize: NSFont.systemFontSize).familyName!,
    fontSize: 32,
    lineHeight: 38,
    kerning: 0,
    weight: AttributedFontWeight.bold)

private let colorNameStyle = AttributedFont(
    fontFamily: NSFont.systemFont(ofSize: NSFont.systemFontSize).familyName!,
    fontSize: 13,
    lineHeight: 13 * 1.62,
    kerning: 0,
    weight: AttributedFontWeight.medium)

private class ColorGridCell: NSBox {

    // MARK: Lifecycle

    init(color: NSColor, value: String, name: String) {
        self.color = color
        self.value = value
        self.name = name

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var color: NSColor { didSet { update() } }
    var value: String { didSet { update() } }
    var name: String { didSet { update() } }

    // MARK: Private

    private var backgroundView = NSBox()
    private var colorView = NSBox()
    private var titleView = NSTextField(labelWithString: "")
    private var valueView = NSTextField(labelWithString: "")
    private var valueTextStyle = AttributedFont(
        fontFamily: NSFont.systemFont(ofSize: NSFont.systemFontSize).familyName!,
        fontSize: 13,
        lineHeight: 13 * 1.62,
        kerning: 0,
        weight: AttributedFontWeight.bold)

    func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero
        backgroundView.boxType = .custom
        backgroundView.borderType = .noBorder
        backgroundView.contentViewMargins = .zero
        colorView.boxType = .custom
        colorView.borderType = .noBorder
        colorView.contentViewMargins = .zero

        backgroundView.cornerRadius = 4
        backgroundView.fillColor = NSColor.white
        backgroundView.wantsLayer = true
        backgroundView.shadow = NSShadow(
            color: NSColor.parse(css: "rgba(0,0,0,0.5)")!,
            offset: NSSize(width: 0, height: -1),
            blur: 1)
        colorView.cornerRadius = 4

        addSubview(backgroundView)
        addSubview(titleView)
        backgroundView.addSubview(colorView)
        backgroundView.addSubview(valueView)
    }

    func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        valueView.translatesAutoresizingMaskIntoConstraints = false
        colorView.translatesAutoresizingMaskIntoConstraints = false

        widthAnchor.constraint(equalToConstant: 128).isActive = true
        heightAnchor.constraint(equalToConstant: 180).isActive = true

        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        backgroundView.heightAnchor.constraint(equalToConstant: 128).isActive = true

        colorView.topAnchor.constraint(equalTo: backgroundView.topAnchor).isActive = true
        colorView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor).isActive = true
        colorView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor).isActive = true
        colorView.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor).isActive = true

        titleView.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 4).isActive = true
        titleView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true

        valueView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        valueView.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 100).isActive = true
    }

    func update() {
        colorView.fillColor = color
        valueTextStyle = AttributedFont(
            fontFamily: NSFont.systemFont(ofSize: NSFont.systemFontSize).familyName!,
            fontSize: 12,
            lineHeight: 12,
            kerning: 0,
            weight: AttributedFontWeight.medium,
            color: color.contrastingLabelColor)
        titleView.attributedStringValue = colorNameStyle.apply(to: name)
        valueView.attributedStringValue = valueTextStyle.apply(to: value)
    }
}

private class ColorGrid: NSBox {

    // MARK: Lifecycle

    init(colors: [CSColor]) {
        self.colors = colors

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var colors: [CSColor] { didSet { update() } }

    // MARK: Private

    private var heightConstraint: NSLayoutConstraint?

    func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        colors.forEach({ color in
            addSubview(ColorGridCell(color: color.color, value: color.value, name: color.name))
        })
    }

    func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        heightConstraint = heightAnchor.constraint(equalToConstant: 400)
        heightConstraint?.isActive = true
    }

    private var height: CGFloat {
        let rows = (colors.count / 5) + (colors.count % 5 > 0 ? 1 : 0)
        return CGFloat(rows) * 180 + 8
    }

    func update() {
        heightConstraint?.constant = height
    }

    override func layout() {
        subviews[0].subviews.enumerated().forEach({ (arg) in
            let (index, view) = arg
            view.frame.origin.x = 24 + CGFloat(index % 5) * (128 + 24)
            view.frame.origin.y = height - 180 - (4 + CGFloat(index / 5) * 180)
        })
    }

}

class ColorBrowser: NSBox {

    // MARK: Lifecycle

    init(colors: [CSColor]) {
        self.colorGridView = ColorGrid(colors: colors)

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private

    private class FlippedView: NSView {
        override var isFlipped: Bool { return true }
    }

    private var titleView = NSTextField(labelWithAttributedString: titleStyle.apply(to: "Colors"))
    private var scrollView = NSScrollView()
    private var scrollViewContent = FlippedView()
    private var colorGridView: ColorGrid

    func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        scrollView.hasVerticalScroller = true
        scrollView.drawsBackground = false

        addSubview(titleView)
        addSubview(scrollView)
        scrollView.documentView = scrollViewContent
        scrollViewContent.addSubview(colorGridView)
    }

    func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollViewContent.translatesAutoresizingMaskIntoConstraints = false

        widthAnchor.constraint(equalToConstant: 784).isActive = true
        titleView.topAnchor.constraint(equalTo: topAnchor, constant: 48).isActive = true
        titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24).isActive = true

        scrollView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 48).isActive = true
        scrollView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -48).isActive = true

        scrollViewContent.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        colorGridView.topAnchor.constraint(equalTo: scrollViewContent.topAnchor).isActive = true
        colorGridView.leadingAnchor.constraint(equalTo: scrollViewContent.leadingAnchor).isActive = true
        colorGridView.trailingAnchor.constraint(equalTo: scrollViewContent.trailingAnchor).isActive = true
        colorGridView.bottomAnchor.constraint(equalTo: scrollViewContent.bottomAnchor).isActive = true
    }

    func update() {

    }

}
