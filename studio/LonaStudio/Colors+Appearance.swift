//
//  Colors+Appearance.swift
//  LonaStudio
//
//  Created by Devin Abbott on 1/3/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

extension NSColor {
    public static func themed(
        light lightColor: NSColor,
        dark darkColor: NSColor
    ) -> NSColor {
        if #available(OSX 10.15, *) {
            // 10.15 lets us update a color dynamically based on current theme
            return self.init(name: nil, dynamicProvider: { appearance in
                switch appearance.bestMatch(from: [.aqua, .darkAqua]) {
                case .some(.darkAqua):
                    return darkColor
                default:
                    return lightColor
                }
            })
        } else if #available(OSX 10.14, *) {
            // In 10.14 we can set a color once based on app theme
            switch NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) {
            case .some(.darkAqua):
                return darkColor
            default:
                return lightColor
            }
        } else {
            return lightColor
        }
    }
}

extension Colors {
    public static let textColor = NSColor(named: "textColor")!

    public static let mutedTextColor = NSColor(named: "textColor")!.withAlphaComponent(0.7)

    public static let labelText = NSColor(named: "labelTextColor")!

    public static let windowBackground = NSColor(named: "windowBackgroundColor")!

    public static let headerBackground = NSColor(named: "headerBackgroundColor")!

    public static let controlBackground = NSColor(named: "controlBackgroundColor")!

    public static let divider = NSSplitView.defaultDividerColor

    public static let dividerSubtle: NSColor = .themed(
        light: NSColor(named: "dividerSubtleColor")!,
        dark: Colors.divider
    )

    public static let contentHeaderBackground: NSColor = .themed(
        light: .white,
        dark: .controlBackgroundColor
    )

    public static let contentBackground: NSColor = .themed(
        light: .white,
        dark: .controlBackgroundColor
    )

    public static let iconFill: NSColor = .themed(
        light: NSColor.black.withAlphaComponent(0.3),
        dark: NSColor.parse(css: "#D8D8D8")!
    )

    public static let iconFillAccent: NSColor = .themed(
        light: Colors.contentBackground.withAlphaComponent(0.7),
        dark: NSColor.parse(css: "#9B9B9B")!
    )
}
