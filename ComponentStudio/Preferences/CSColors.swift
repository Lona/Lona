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
        return CSWorkspacePreferences.workspaceURL.appendingPathComponent("cscolors.json")
    }
    
    static private var parsedColors: [CSColor] = parse(data)
    static var colors: [CSColor] { return parsedColors }
    
    static var data: CSData = load() {
        didSet { parsedColors = parse(data) }
    }
    
    private static func parse(_ data: CSData) -> [CSColor] {
        guard let colorData = data["colors"] else { return [] }
        
        return colorData.arrayValue.map({ color in
            let id = color["id"]?.string
            let name = color["name"]?.string ?? "No name"
            let value = color["value"]?.string ?? "#000000"
            let nsColor = NSColor.parse(css: value) ?? NSColor.black
            
            return CSColor(id: id, name: name, color: nsColor, value: value)
        })
    }
    
    static func parse(css string: String, withDefault defaultColor: NSColor = NSColor.clear) -> CSColor {
        let match = CSColors.colors.first(where: { $0.id?.uppercased() == string.uppercased() })
        
        return match ?? CSColor(id: nil, name: "Custom color", color: NSColor.parse(css: string) ?? defaultColor, value: string)
    }
}

