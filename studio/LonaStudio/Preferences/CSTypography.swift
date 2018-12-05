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

private func fontWeightName(fontWeight: NSFont.Weight) -> String {
    switch fontWeight {
    case NSFont.Weight.ultraLight: return "Ultra Light"
    case NSFont.Weight.thin: return "Thin"
    case NSFont.Weight.light: return "Light"
    case NSFont.Weight.regular: return "Regular"
    case NSFont.Weight.medium: return "Medium"
    case NSFont.Weight.semibold: return "Semibold"
    case NSFont.Weight.bold: return "Bold"
    case NSFont.Weight.heavy: return "Heavy"
    case NSFont.Weight.black: return "Black"
    default: return "Regular"
    }
}

public struct CSTextStyle: Equatable {
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

    var summary: String {
        let weight = fontWeightName(fontWeight: font.weight)
        if let lineHeight = font.lineHeight {
            return "\(weight) \(font.size)/\(lineHeight)"
        }
        return "\(weight) \(font.size)"
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

    var font: TextStyle {
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

        return TextStyle(
            family: lookup({ style in style.fontFamily }) ?? defaultFamilyName,
            weight: weight ?? .regular,
            size: fontSize ?? defaultFontSize,
            lineHeight: lineHeight,
            kerning: letterSpacing ?? 0,
            color: color ?? NSColor.black)
    }

    func toData() -> CSData {
        return CSData.Object([
            "id": id.toData(),
            "name": name.toData(),
            "fontName": fontName?.toData() ?? CSData.Null,
            "fontFamily": fontFamily?.toData() ?? CSData.Null,
            "fontWeight": fontWeight?.toData() ?? CSData.Null,
            "fontSize": fontSize?.toData() ?? CSData.Null,
            "lineHeight": lineHeight?.toData() ?? CSData.Null,
            "letterSpacing": letterSpacing?.toData() ?? CSData.Null,
//            "color": color?.toData() ?? CSData.Null,
            "extends": extends?.toData() ?? CSData.Null
            ])
    }

    func toValue() -> CSValue {
        let csType = type(of: self).csType
        return CSValue(type: csType, data: CSValue.expand(type: csType, data: toData()))
    }

    static var csType: CSType {
        return CSType.dictionary([
            "id": (CSType.string, CSAccess.write),
            "name": (CSType.string, CSAccess.write),
            "fontName": (CSType.string.makeOptional(), CSAccess.write),
            "fontFamily": (CSType.string.makeOptional(), CSAccess.write),
            "fontWeight": (CSType.number.makeOptional(), CSAccess.write),
            "fontSize": (CSType.number.makeOptional(), CSAccess.write),
            "lineHeight": (CSType.number.makeOptional(), CSAccess.write),
            "letterSpacing": (CSType.number.makeOptional(), CSAccess.write),
//            "color": (CSType.number.makeOptional(), CSAccess.write),
            "extends": (CSType.string.makeOptional(), CSAccess.write)
            ])
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

    static func parseDefaultName(_ data: CSData) -> String? {
        return data["defaultStyleName"]?.string
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

    static func save(list: CSData) {
        data.set(keyPath: ["styles"], to: list)
        data = data.removingKeysForNullValues()

        save()

        LonaPlugins.current.trigger(eventType: .onSaveTextStyles)
    }

    static func delete(at index: Int) {
        guard var list = data["styles"]?.array else { return }

        list.remove(at: index)

        save(list: CSData.Array(list))
    }

    static func move(from sourceIndex: Int, to targetIndex: Int) {
        guard var list = data["styles"]?.array else { return }

        let item = list[sourceIndex]

        list.remove(at: sourceIndex)

        if sourceIndex < targetIndex {
            list.insert(item, at: targetIndex - 1)
        } else {
            list.insert(item, at: targetIndex)
        }

        save(list: CSData.Array(list))
    }

    static func update(textStyle textStyleData: CSData, at index: Int) {
        guard let list = data["styles"] else { return }

        let updated = list.arrayValue.enumerated().map({ offset, element in
            return index == offset
                ? CSValue.compact(type: CSTextStyle.csType, data: textStyleData)
                : element
        })

        save(list: CSData.Array(updated))
    }
}
