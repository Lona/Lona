//
//  CSTypography.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

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

        return fontData.arrayValue.map({ textStyle in CSTextStyle.fromData(textStyle) })
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
}
