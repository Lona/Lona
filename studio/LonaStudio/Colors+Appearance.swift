//
//  Colors+Appearance.swift
//  LonaStudio
//
//  Created by Devin Abbott on 1/3/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

extension Colors {
    public static let textColor: NSColor = {
        if #available(OSX 10.13, *) {
            return NSColor(named: NSColor.Name("textColor"))!
        } else {
            return NSColor.black
        }
    }()

    public static let labelText: NSColor = {
        if #available(OSX 10.13, *) {
            return NSColor(named: NSColor.Name("labelTextColor"))!
        } else {
            return NSColor.parse(css: "#545454")!
        }
    }()

    public static let headerBackground: NSColor = {
        if #available(OSX 10.13, *) {
            return NSColor(named: NSColor.Name("headerBackgroundColor"))!
        } else {
            return NSColor.white
        }
    }()

    public static let contentHeaderBackground: NSColor = {
        if #available(OSX 10.14, *) {
            switch NSApp.effectiveAppearance.bestMatch(from: [.aqua, .darkAqua]) {
            case .some(.darkAqua):
                return NSColor.controlBackgroundColor
            default:
                return NSColor.white
            }
        } else {
            return NSColor.white
        }
    }()

    public static let dividerSubtle: NSColor = {
        if #available(OSX 10.13, *) {
            return NSColor(named: NSColor.Name("dividerSubtleColor"))!
        } else {
            return NSColor.white
        }
    }()
}
