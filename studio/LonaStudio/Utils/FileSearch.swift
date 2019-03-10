//
//  FileSearch.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/2/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

enum FileSearch {
    static func search(in root: URL, forFilesWithSuffix suffix: String, ignoring ignoreList: [String] = []) -> [URL] {
        var results: [URL] = []

        let fileManager = FileManager.default
        let keys = [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey]
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsHiddenFiles]

        guard let enumerator = fileManager.enumerator(
            at: root,
            includingPropertiesForKeys: keys,
            options: options,
            errorHandler: {(_, _) -> Bool in true }) else { return results }

        let dotSuffix = "." + suffix

        outer: while let file = enumerator.nextObject() as? URL {
            for ignore in ignoreList where file.path.contains(ignore) {
                enumerator.skipDescendants()
                continue outer
            }

            if file.lastPathComponent == suffix || file.path.hasSuffix(dotSuffix) {
                results.append(file)
            }
        }

        return results
    }
}
