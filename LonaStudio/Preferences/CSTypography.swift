//
//  CSTypography.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

private func convertFontWeight(fontWeight: String) -> NSFont.Weight {
    switch fontWeight {
    case "100": return NSFont.Weight.ultraLight
    case "200": return NSFont.Weight.thin
    case "300": return NSFont.Weight.light
    case "400": return NSFont.Weight.regular
    case "500": return NSFont.Weight.medium
    case "600": return NSFont.Weight.semibold
    case "700": return NSFont.Weight.bold
    case "800": return NSFont.Weight.heavy
    case "900": return NSFont.Weight.black
    default: return NSFont.Weight.regular
    }
}

struct CSTextStyle {
    let id: String
    let name: String
    let fontName: String?
    let fontFamily: String?
    let fontWeight: String?
    let fontSize: Double?
    let lineHeight: Double?
    let letterSpacing: Double?
    let color: NSColor?
    let extends: String?

    init(id: String,
         name: String,
         fontName: String? = nil,
         fontFamily: String? = nil,
         fontWeight: String? = nil,
         fontSize: Double? = nil,
         lineHeight: Double? = nil,
         letterSpacing: Double? = nil,
         color: NSColor? = nil,
         extends: String? = nil) {
        self.id = id
        self.name = name
        self.fontName = fontName
        self.fontFamily = fontFamily
        self.fontWeight = fontWeight
        self.fontSize = fontSize
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
        self.color = color
        self.extends = extends
    }

    private func base() -> CSTextStyle? {
        guard let extends = self.extends else { return nil }
        return CSTypography.getFontBy(id: extends)
    }

    private func lookup<T>(_ property: (CSTextStyle) -> T?) -> T? {
        if let result = property(self) { return result }
        if let baseStyle = base() { return baseStyle.lookup(property) }
        return nil
    }

    private let defaultFamilyName = NSFont.systemFont(ofSize: 14).familyName ?? ""
    private let defaultFontSize = NSFont.systemFontSize

    var font: AttributedFont {
        let fontSize: CGFloat? = lookup { style in
            guard let value = style.fontSize else { return nil }
            return CGFloat(value)
        }
        let lineHeight: CGFloat? = lookup { style in
            guard let value = style.lineHeight else { return nil }
            return CGFloat(value)
        }
        let letterSpacing: Double? = lookup { style in
            guard let value = style.letterSpacing else { return nil }
            return value
        }
        let weight: NSFont.Weight? = lookup { style in
            guard let value = style.fontWeight else { return nil }
            return convertFontWeight(fontWeight: value)
        }
        let color: NSColor? = lookup { style in
            guard let value = style.color else { return nil }
            return value
        }

        return AttributedFont(
            family: lookup({ style in style.fontFamily }) ?? defaultFamilyName,
            weight: weight ?? .regular,
            size: fontSize ?? defaultFontSize,
            lineHeight: lineHeight,
            kerning: letterSpacing ?? 0,
            color: color ?? NSColor.black)
    }
}

extension CSTextStyle: Identify, Searchable {}

class CSTypography: CSPreferencesFile {
    static var url: URL {
        return CSWorkspacePreferences.textStylesFileURL
    }

    static private var parsedStyles: [CSTextStyle] = parse(data)
    static private var defaultStyleName: String?
    static var styles: [CSTextStyle] { return parsedStyles }

    static var data: CSData = load() {
        didSet { parsedStyles = parse(data) }
    }

    static func parse(_ data: CSData) -> [CSTextStyle] {
        guard let fontData = data["styles"] else { return [] }
        defaultStyleName = data["defaultStyleName"]?.string

        return fontData.arrayValue.map({ font in
            return CSTextStyle(
                id: font["id"]?.string ?? "missingFontId",
                name: font["name"]?.string ?? "Missing style name",
                fontName: font["fontName"]?.string,
                fontFamily: font["fontFamily"]?.string,
                fontWeight: font["fontWeight"]?.string,
                fontSize: font["fontSize"]?.number,
                lineHeight: font["lineHeight"]?.number,
                letterSpacing: font["letterSpacing"]?.number,
                color: font["color"] != nil ? CSColors.parse(css: font["color"]?.string ?? "black", withDefault: NSColor.black).color : nil,
                extends: font["extends"]?.string)
        })
    }

    private static func getOptionalFontBy(id: String) -> CSTextStyle? {
        // If the name is "default", use the configured default style
        if let styleName = defaultStyleName, id == unstyledDefaultName && styleName != unstyledDefaultName {
            return getOptionalFontBy(id: styleName)
        }

        if let match = styles.first(where: { $0.id == id }) {
            return match
        } else {
            return nil
        }
    }

    public static func getFontBy(id: String) -> CSTextStyle {
        return getOptionalFontBy(id: id) ?? defaultFont
    }

    public static var defaultName: String {
        return defaultStyleName ?? unstyledDefaultName
    }

    public static let unstyledDefaultName = "default"

    public static var defaultFont: CSTextStyle {
        if let styleName = defaultStyleName, let style = getOptionalFontBy(id: styleName) {
            return style
        }

        return unstyledDefaultFont
    }

    public static let unstyledDefaultFont = CSTextStyle(id: unstyledDefaultName, name: "Default")
}
