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

    static func parse(_ data: CSData) -> [CSColor] {
        guard let colorData = data["colors"] else { return [] }

        return colorData.arrayValue.map({ color in CSColor.fromData(color) })
    }

    static func parse(css string: String, withDefault defaultColor: NSColor = NSColor.clear) -> CSColor {
        let match = CSColors.colors.first(where: { $0.id.uppercased() == string.uppercased() })

        return match ?? CSColor(id: "custom", name: "Custom color", color: NSColor.parse(css: string) ?? defaultColor, value: string, comment: "")
    }

    static func deleteColor(at index: Int) {
        guard var colorListData = data["colors"]?.array else { return }

        colorListData.remove(at: index)

        data.set(keyPath: ["colors"], to: CSData.Array(colorListData))

        save()

        LonaPlugins.current.trigger(eventType: .onSaveColors)
    }

    static func moveColor(from sourceIndex: Int, to targetIndex: Int) {
        guard var colorListData = data["colors"]?.array else { return }

        let item = colorListData[sourceIndex]

        colorListData.remove(at: sourceIndex)

        if sourceIndex < targetIndex {
            colorListData.insert(item, at: targetIndex - 1)
        } else {
            colorListData.insert(item, at: targetIndex)
        }

        data.set(keyPath: ["colors"], to: CSData.Array(colorListData))

        save()

        LonaPlugins.current.trigger(eventType: .onSaveColors)
    }

    static func update(color colorData: CSData, at index: Int) {
        guard let colorListData = data["colors"] else { return }

        let updated = colorListData.arrayValue.enumerated().map({ offset, element in
            return index == offset ? colorData : element
        })

        data.set(keyPath: ["colors"], to: CSData.Array(updated))

        save()

        LonaPlugins.current.trigger(eventType: .onSaveColors)
    }
}
