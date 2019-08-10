//
//  LogicLoader.swift
//  LonaStudio
//
//  Created by Devin Abbott on 7/11/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

public enum LogicLoader {
    // Files in the cache are updated directly by LogicDocument to avoid a round-trip to the filesystem
    // TODO: Improved file system watching, so that if a file changes on disk outside of Lona we still pick it up
    public static var cache: [String: LGCSyntaxNode] = [:]

    public static func load(name: String) -> LGCSyntaxNode? {
        if let cached = cache[name] { return cached }

        // Load from current module
        if let libraryUrl = LonaModule.current.logicFileUrls.first(where: { $0.lastPathComponent == "\(name).logic" }),
            let libraryScript = try? Data(contentsOf: libraryUrl),
            let decoded = try? LogicDocument.read(from: libraryScript) {

            Swift.print("Load local file", name)

            cache[name] = decoded
            return decoded
        }

        // Load from the Lona Studio bundle
        if let libraryUrl = Bundle.main.url(forResource: name, withExtension: "logic"),
            let libraryScript = try? Data(contentsOf: libraryUrl),
            let decoded = try? JSONDecoder().decode(LGCSyntaxNode.self, from: libraryScript) {

            cache[name] = decoded
            return decoded
        }

        // Fall back to the Logic bundle
        let fallback = Library.load(name: name)

        return fallback
    }
}
