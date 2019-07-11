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
    private static var cache: [String: LGCSyntaxNode] = [:]

    public static func load(name: String) -> LGCSyntaxNode? {
        if let cached = cache[name] { return cached }

        // First load from the Lona Studio bundle
        guard let libraryUrl = Bundle.main.url(forResource: name, withExtension: "logic"),
            let libraryScript = try? Data(contentsOf: libraryUrl),
            let decoded = try? JSONDecoder().decode(LGCSyntaxNode.self, from: libraryScript)
        else {
            // Fall back to the Logic bundle
            return Library.load(name: name)
        }

        cache[name] = decoded

        return decoded
    }
}
