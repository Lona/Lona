//
//  CSPreferences.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

protocol CSPreferencesFile {
    static var data: CSData { get set }
    static var url: URL { get }
    static var path: String { get }

    static func save()
    static func load() -> CSData
    static func reload()
}

extension CSPreferencesFile {
    static var path: String { return url.path }

    static func save() {
        do {
            try data.toData()?.write(to: url)
        } catch {
            Swift.print("Failed to save preferences to \(url.path)")
        }
    }

    static func load() -> CSData {
        return CSData.from(fileAtPath: path) ?? CSData.Object([:])
    }

    static func reload() {
        data = load()
    }
}
