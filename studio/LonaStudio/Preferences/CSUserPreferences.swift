//
//  CSPreferences.swift
//  ComponentStudio
//
//  Created by devin_abbott on 7/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import AppKit

func preferencesDirectory() -> URL {
    let home: URL

    home = FileManager.default.homeDirectoryForCurrentUser

    return home
}

class CSUserPreferences: CSPreferencesFile {

    enum Keys: String {
        case compilerPath
        case canvasAreaBackgroundColor
    }

    static var url: URL {
        return preferencesDirectory().appendingPathComponent(".lonastudio")
    }

    static var data: CSData = load()

    static var workspaceURL: URL {
        get {
            guard let path = CSUserPreferences.data["workspacePath"] else { return defaultWorkspaceURL() }
            guard case CSData.String(let string) = path else { return defaultWorkspaceURL() }
            return URL(fileURLWithPath: string)
        }
        set {
            CSUserPreferences.data["workspacePath"] = CSData.String(newValue.path)
            CSUserPreferences.save()
        }
    }

    static let optionalURLType = CSURLType.makeOptional()

    static var compilerURL: URL? {
        if let string = compilerPathValue.data.get(key: "data").string,
            let url = URL(string: string)?.absoluteURLForWorkspaceURL() {
            return url
        }
        return nil
    }

    static var compilerPathValue: CSValue {
        get {
            if let path = CSUserPreferences.data[Keys.compilerPath.rawValue] {
                return CSValue(type: optionalURLType, data: CSValue.expand(type: optionalURLType, data: path))
            } else {
                return CSUnitValue.wrap(in: optionalURLType, tagged: "None")
            }
        }
        set {
            CSUserPreferences.data[Keys.compilerPath.rawValue] = newValue == CSUnitValue
                ? nil
                : CSValue.compact(type: optionalURLType, data: newValue.data)
        }
    }

    static var canvasAreaBackgroundColorValue: CSValue {
        get {
            if let path = CSUserPreferences.data[Keys.canvasAreaBackgroundColor.rawValue] {
                return CSValue(type: CSType.string, data: path)
            } else {
                return CSValue(type: CSType.string, data: CSData.String(""))
            }
        }
        set {
            CSUserPreferences.data[Keys.canvasAreaBackgroundColor.rawValue] = newValue.data.stringValue == ""
                ? nil
                : newValue.data
        }
    }

    static var canvasAreaBackgroundColor: NSColor? {
        return NSColor.parse(css: canvasAreaBackgroundColorValue.data.stringValue)
    }
}
