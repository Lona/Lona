//
//  CSTextStyle.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 05/01/2019.
//  Copyright © 2019 Devin Abbott. All rights reserved.
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

public struct CSTextStyle: Equatable, CSDataSerializable {
    var id: String
    var name: String
    var fontName: String?
    var fontFamily: String?
    var fontWeight: String?
    var fontSize: Double?
    var lineHeight: Double?
    var letterSpacing: Double?
    var textTransform: String?
    var color: String?
    var extends: String?
    var comment: String?

    init(id: String,
         name: String,
         fontName: String? = nil,
         fontFamily: String? = nil,
         fontWeight: String? = nil,
         fontSize: Double? = nil,
         lineHeight: Double? = nil,
         letterSpacing: Double? = nil,
         textTransform: String? = nil,
         color: String? = nil,
         extends: String? = nil,
         comment: String? = nil) {
        self.id = id
        self.name = name
        self.fontName = fontName
        self.fontFamily = fontFamily
        self.fontWeight = fontWeight
        self.fontSize = fontSize
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
        self.textTransform = textTransform
        self.color = color
        self.extends = extends
        self.comment = comment
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
        let color = getCSColor().color

        return TextStyle(
            family: lookup({ style in style.fontFamily }) ?? defaultFamilyName,
            weight: weight ?? .regular,
            size: fontSize ?? defaultFontSize,
            lineHeight: lineHeight,
            kerning: letterSpacing ?? 0,
            textTransform: lookup({ style in style.textTransform }) ?? "none",
            color: color)
    }

    func getCSColor() -> CSColor {
        return lookup { style in
            return CSColors.parse(css: style.color ?? "black", withDefault: NSColor.black)
            } ?? CSColor(id: "custom", name: "Custom color", value: NSColor.black.rgbaString, comment: "", metadata: CSData.Object([:]))
    }

    func toData() -> CSData {
        var data = CSData.Object([
            "id": id.toData(),
            "name": name.toData()
            ])

        if let fontName = fontName, fontName != "" {
            data["fontName"] = fontName.toData()
        }

        if let fontFamily = fontFamily, fontFamily != "" {
            data["fontFamily"] = fontFamily.toData()
        }

        if let fontWeight = fontWeight, fontWeight != "" {
            data["fontWeight"] = fontWeight.toData()
        }

        if let fontSize = fontSize, fontSize != -1 {
            data["fontSize"] = fontSize.toData()
        }

        if let lineHeight = lineHeight, lineHeight != -1 {
            data["lineHeight"] = lineHeight.toData()
        }

        if let letterSpacing = letterSpacing, letterSpacing != -1 {
            data["letterSpacing"] = letterSpacing.toData()
        }

        if let textTransform = textTransform, textTransform != "" {
            data["textTransform"] = textTransform.toData()
        }

        if let color = color, color != "" {
            data["color"] = color.toData()
        }

        if let extends = extends, extends != "" {
            data["extends"] = extends.toData()
        }

        if let comment = comment, comment != "" {
            data["comment"] = comment.toData()
        }

        return data
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
            "textTransform": (CSType.string.makeOptional(), CSAccess.write),
            "color": (CSType.string.makeOptional(), CSAccess.write),
            "extends": (CSType.string.makeOptional(), CSAccess.write),
            "comment": (CSType.string.makeOptional(), CSAccess.write)
            ])
    }

    static func fromData(_ data: CSData) -> CSTextStyle {
        return CSTextStyle(
            id: data["id"]?.string ?? "missingFontId",
            name: data["name"]?.string ?? "Missing style name",
            fontName: data["fontName"]?.string,
            fontFamily: data["fontFamily"]?.string,
            fontWeight: data["fontWeight"]?.string,
            fontSize: data["fontSize"]?.number,
            lineHeight: data["lineHeight"]?.number,
            letterSpacing: data["letterSpacing"]?.number,
            textTransform: data["textTransform"]?.string,
            color: data["color"]?.string,
            extends: data["extends"]?.string,
            comment: data["comment"]?.string)
    }
}

extension CSTextStyle: Identify, Searchable {}
