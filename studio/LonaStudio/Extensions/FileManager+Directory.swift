//
//  FileManager+Directory.swift
//  LonaStudio
//
//  Created by Devin Abbott on 1/6/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import Foundation

extension FileManager {
    public func isDirectory(path: String) -> Bool {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            return isDir.boolValue
        } else {
            return false
        }
    }

    public func fileExists(atPath path: String) -> Bool {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            return true
        } else {
            return false
        }
    }
}
