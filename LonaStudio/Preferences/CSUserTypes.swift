//
//  CSUserTypes.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

class CSUserTypes: CSPreferencesFile {
    static var url: URL {
        return CSWorkspacePreferences.workspaceURL.appendingPathComponent("types.json")
    }

    static var loaded = false
    static var willReenter = false

    static private var parsedTypes: [CSType] = []

    // A bit of a hack to avoid crashing due to cyclic references. The CSType
    // constructor accesses this value, and we use that to parse() the data.
    // So, the first time this is called, call it again behind the scenes,
    // returning an empty array to avoid constructing any CSTypes.
    static var types: [CSType] {
        if willReenter { return [] }

        if !loaded {
            willReenter = true
            parsedTypes = parse(data)
            loaded = true
            willReenter = false
        }

        return parsedTypes
    }

    static var data: CSData = load() {
        didSet {
            parsedTypes = parse(data)
        }
    }

    private static func parse(_ data: CSData) -> [CSType] {
        guard let colorData = data["types"] else { return [] }

        return colorData.arrayValue.map({ CSType($0) })
    }
}
