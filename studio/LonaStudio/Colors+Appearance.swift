//
//  Colors+Appearance.swift
//  LonaStudio
//
//  Created by Devin Abbott on 1/3/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import ThemedColor

extension Colors {
    public static let textColor = NSColor(named: "textColor")!

    public static let mutedTextColor = NSColor(named: "textColor")!.withAlphaComponent(0.7)

    public static let labelText = NSColor(named: "labelTextColor")!

    public static let windowBackground = NSColor(named: "windowBackgroundColor")!

    public static let headerBackground = NSColor(named: "headerBackgroundColor")!

    public static let controlBackground = NSColor(named: "controlBackgroundColor")!

    public static let divider = NSSplitView.defaultDividerColor

    public static let dividerSubtle = NSColor.themed(
        light: NSColor(named: "dividerSubtleColor")!,
        dark: Colors.divider
    )

    public static let contentHeaderBackground = NSColor.themed(
        light: .white,
        dark: .controlBackgroundColor
    )

    public static let contentBackground = NSColor.themed(
        light: .white,
        dark: .controlBackgroundColor
    )

    public static let iconFill = NSColor.themed(
        light: NSColor.black.withAlphaComponent(0.3),
        dark: NSColor.parse(css: "#D8D8D8")!
    )

    public static let iconFillAccent = NSColor.themed(
        light: Colors.contentBackground.withAlphaComponent(0.7),
        dark: NSColor.parse(css: "#9B9B9B")!
    )

    // MARK: Vibrant

    public static let vibrantDivider = NSColor.themed(
        light: Colors.headerBackground.shadow(withLevel: 0.08)!,
        dark: NSColor.black
    )

    public static let vibrantWell = NSColor.themed(
        light: Colors.headerBackground.shadow(withLevel: 0.05)!,
        dark: NSColor.black.highlight(withLevel: 0.05)!
    )

    public static let vibrantRaised = NSColor.themed(
        light: Colors.headerBackground,
        dark: NSColor.black.highlight(withLevel: 0.08)!
    )
}
