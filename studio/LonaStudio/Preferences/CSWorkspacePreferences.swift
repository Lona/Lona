//
//  CSWorkspacePreferences.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

func defaultWorkspaceURL() -> URL {
    return preferencesDirectory().appendingPathComponent("LonaWorkspace", isDirectory: true)
}

class CSWorkspacePreferences: CSPreferencesFile {
    static let optionalURLType = CSURLType.makeOptional()

    enum Keys: String {
        case colorsPath
        case textStylesPath
        case workspaceIcon
        case workspaceName
    }

    static var url: URL {
        return CSUserPreferences.workspaceURL.appendingPathComponent("lona.json")
    }

    static var colorsFileURL: URL {
        return LonaModule.current.colorsFileUrls.first ??
            CSUserPreferences.workspaceURL.appendingPathComponent("colors.json")
    }

    static var textStylesFileURL: URL {
        return LonaModule.current.textStylesFileUrls.first ??
            CSUserPreferences.workspaceURL.appendingPathComponent("textStyles.json")
    }

    static var workspaceIconURL: URL {
        if let string = workspaceIconPathValue.data.get(key: "data").string,
            let url = URL(string: string)?.absoluteURLForWorkspaceURL() {
            return url
        }
        return Bundle.main.urlForImageResource("default-workspace-thumbnail")!
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

    static var workspaceIconPathValue: CSValue {
        get {
            if let path = CSWorkspacePreferences.data[Keys.workspaceIcon.rawValue] {
                return CSValue(type: optionalURLType, data: CSValue.expand(type: optionalURLType, data: path))
            } else {
                return CSUnitValue.wrap(in: optionalURLType, tagged: "None")
            }
        }
        set {
            CSWorkspacePreferences.data[Keys.workspaceIcon.rawValue] = newValue.tag() == "None"
                ? nil
                : CSValue.compact(type: optionalURLType, data: newValue.data)
        }
    }

    static var workspaceNameValue: CSValue {
        get {
            return CSValue(type: CSType.string, data: CSWorkspacePreferences.data[Keys.workspaceName.rawValue] ?? "".toData())
        }
        set {
            CSWorkspacePreferences.data[Keys.workspaceName.rawValue] = newValue.data.stringValue == ""
                ? nil
                : newValue.data
        }
    }

    static var workspaceName: String {
        let customName = workspaceNameValue.data.stringValue
        return customName.isEmpty ? LonaModule.current.url.lastPathComponent : customName
    }

    static var data: CSData = load()

    static func reloadAllConfigurationFiles(closeDocuments: Bool) {
        if closeDocuments {
            NSDocumentController.shared.closeAllDocuments(withDelegate: nil, didCloseAllSelector: nil, contextInfo: nil)
        }

        CSWorkspacePreferences.reload()
        CSUserTypes.reload()
        CSColors.reload()
        CSTypography.reload()
        CSGradients.reload()
        CSShadows.reload()
    }

    private enum CreateWorkspace: String {
        case ok = "OK"
    }

    /// Returns true if the url passed is a valid workspace
    ///
    /// A valid workspace is identified by a "lona.json" file in the root of the workspace.
    static func validateProposedWorkspace(url: URL) -> Bool {
        do {
            _ = try Data(contentsOf: url.appendingPathComponent("lona.json"))
            return true
        } catch {
            let alert = Alert(
                items: [CreateWorkspace.ok],
                messageText: "This doesn't appear to be a Lona workspace!",
                informativeText: "There's no 'lona.json' file in '\(url.path)'. A Lona workspace must have a 'lona.json' file in the top-level folder.")

            guard let response = alert.run() else { return false }

            switch response {
            case .ok:
                return false
            }
        }
    }
}
