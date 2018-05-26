//
//  CSColors.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

class CSColors: CSPreferencesFile {
    static var url: URL {
        return CSWorkspacePreferences.colorsFileURL
    }

    static private var parsedColors: [CSColor] = parse(data)
    static var colors: [CSColor] { return parsedColors }

    static var data: CSData = load() {
        didSet { parsedColors = parse(data) }
    }

    private static func parse(_ data: CSData) -> [CSColor] {
        guard let colorData = data["colors"] else { return [] }

        return colorData.arrayValue.map({ color in CSColor.fromData(color) })
    }

    static func parse(css string: String, withDefault defaultColor: NSColor = NSColor.clear) -> CSColor {
        let match = CSColors.colors.first(where: { $0.id.uppercased() == string.uppercased() })

        return match ?? CSColor(id: "custom", name: "Custom color", color: NSColor.parse(css: string) ?? defaultColor, value: string)
    }

    static func updateAndSave(color c: CSData, at index: Int) {
        guard let colorData = data["colors"] else { return }

        let updated = colorData.arrayValue.enumerated().map({ offset, element in
            return index == offset ? c : element
        })

        data.set(keyPath: ["colors"], to: CSData.Array(updated))

        save()

        LonaPlugins.current.trigger(eventType: .onSaveColors)
    }
}
