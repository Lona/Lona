//
//  CSColors.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

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
        let value = NSColor.parse(css: string) == nil ? defaultColor.rgbaString : string

        return match ?? CSColor(id: "custom", name: "Custom color", value: value, comment: "", metadata: CSData.Object([:]))
    }

    static func lookup(css string: String) -> CSColor? {
        return CSColors.colors.first { $0.value == string }
    }

    static var logicSyntax: LGCDeclaration {
        return .namespace(
            id: UUID(),
            name: .init(id: UUID(), name: "Colors"),
            declarations: .init(
                colors.map { color in
                    return .variable(
                        id: UUID(),
                        name: .init(id: UUID(), name: color.id),
                        annotation: .some(
                            .typeIdentifier(
                                id: UUID(),
                                identifier: .init(id: UUID(), string: "CSSColor"),
                                genericArguments: .empty
                            )
                        ),
                        initializer: .some(
                            .literalExpression(
                                id: UUID(),
                                literal: .color(id: UUID(), value: color.value)
                            )
                        )
                    )
                }
            )
        )
    }
}
