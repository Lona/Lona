//
//  CSWorkspacePreferences.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

func defaultWorkspaceURL() -> URL {
    return preferencesDirectory().appendingPathComponent("LonaWorkspace", isDirectory: true)
}

class CSWorkspacePreferences: CSPreferencesFile {
    static let optionalURLType = CSURLType.makeOptional()

    enum Keys: String {
        case colorsPath
        case textStylesPath
    }

    static var url: URL {
        return CSUserPreferences.workspaceURL.appendingPathComponent("workspace.json")
    }

    static var colorsFileURL: URL {
        if let string = colorsFilePathValue.data.get(key: "data").string, let url = URL(string: string) {
            return url
        }
        return CSUserPreferences.workspaceURL.appendingPathComponent("colors.json")
    }

    static var textStylesFileURL: URL {
        if let string = textStylesFilePathValue.data.get(key: "data").string, let url = URL(string: string) {
            return url
        }
        return CSUserPreferences.workspaceURL.appendingPathComponent("textStyles.json")
    }

    static var colorsFilePathValue: CSValue {
        get {
            if let path = CSWorkspacePreferences.data[Keys.colorsPath.rawValue] {
                return CSValue(type: optionalURLType, data: CSValue.expand(type: optionalURLType, data: path))
            } else {
                return CSUnitValue.wrap(in: optionalURLType, tagged: "None")
            }
        }
        set {
            CSWorkspacePreferences.data[Keys.colorsPath.rawValue] = newValue == CSUnitValue
                ? nil
                : CSValue.compact(type: optionalURLType, data: newValue.data)
        }
    }

    static var textStylesFilePathValue: CSValue {
        get {
            if let path = CSWorkspacePreferences.data[Keys.textStylesPath.rawValue] {
                return CSValue(type: optionalURLType, data: CSValue.expand(type: optionalURLType, data: path))
            } else {
                return CSUnitValue.wrap(in: optionalURLType, tagged: "None")
            }
        }
        set {
            CSWorkspacePreferences.data[Keys.textStylesPath.rawValue] = newValue == CSUnitValue
                ? nil
                : CSValue.compact(type: optionalURLType, data: newValue.data)
        }
    }

    static var data: CSData = load()
}
