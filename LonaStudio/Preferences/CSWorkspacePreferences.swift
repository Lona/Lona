//
//  CSWorkspacePreferences.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

func defaultWorkspaceURL() -> URL {
    return preferencesDirectory().appendingPathComponent("ComponentStudioWorkspace", isDirectory: true)
}

class CSWorkspacePreferences: CSPreferencesFile {
    static var url: URL {
        return workspaceURL.appendingPathComponent("csworkspace.json")
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
}
