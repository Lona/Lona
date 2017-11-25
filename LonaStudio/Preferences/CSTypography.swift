//
//  CSTypography.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

public typealias CSTextStyle = (name: String, id: String, font: AttributedFont)

class CSTypography: CSPreferencesFile {
    static var url: URL {
        return CSWorkspacePreferences.workspaceURL.appendingPathComponent("textStyles.json")
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
            let id = font["id"]?.string ?? "missingFontId"
            let name = font["name"]?.string ?? "Missing style name"
            let fontFamily = font["fontFamily"]?.string ?? NSFont.systemFont(ofSize: 17).familyName ?? "Helvetica"
            let fontSize = CGFloat(font["fontSize"]?.number ?? 12)
            let fontWeight = font["fontWeight"]?.number ?? 400
            let lineHeight = CGFloat(font["lineHeight"]?.number ?? Double(fontSize))
            let kerning = font["letterSpacing"]?.number ?? 0
            let color = CSColors.parse(css: font["color"]?.string ?? "black", withDefault: NSColor.black).color
            
            let font = AttributedFont(
                fontFamily: fontFamily,
                fontSize: fontSize,
                lineHeight: lineHeight,
                kerning: kerning,
                weight: convertFontWeight(fontWeight: fontWeight),
                color: color
            )
            
            return (name, id, font)
        })
    }
    
    static private func convertFontWeight(fontWeight: Double) -> AttributedFontWeight {
        if (fontWeight < 400) { return AttributedFontWeight.standard }
        if (fontWeight < 600) { return AttributedFontWeight.medium }
        return AttributedFontWeight.bold
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
    
    public static let unstyledDefaultFont: CSTextStyle = (
        "Default",
        unstyledDefaultName,
        AttributedFont(
            fontFamily: NSFont.systemFont(ofSize: 17).familyName ?? "Helvetica",
            fontSize: 17,
            lineHeight: 22,
            kerning: 0.2,
            weight: .standard
        )
    )
}

