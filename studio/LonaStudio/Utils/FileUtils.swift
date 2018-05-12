//
//  FileUtils.swift
//  LonaStudio
//
//  Created by Devin Abbott on 5/12/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation

enum FileUtils {
    enum FileExistsType {
        case file, directory, none
    }

    static func fileExists(atPath filename: String) -> FileExistsType {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: filename, isDirectory: &isDir) {
            if isDir.boolValue {
                return .directory
            } else {
                return .file
            }
        }

        return .none
    }
}
