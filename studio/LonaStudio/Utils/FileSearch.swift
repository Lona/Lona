//
//  FileSearch.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/2/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

enum FileSearch {
    static let defaultIgnoreList = [".git", "node_modules"]

    static func search(
        filesIn root: URL,
        matching regularExpression: NSRegularExpression,
        ignoring ignoreList: [String] = defaultIgnoreList) -> [URL] {

        let matchPredicate: (URL) -> Bool = { file in
            let string = file.absoluteString
            let range = NSRange(location: 0, length: string.count)
            return regularExpression.firstMatch(in: string, range: range) != nil
        }

        return search(filesIn: root, matching: matchPredicate, ignoring: ignoreList)
    }

    static func search(
        filesIn root: URL,
        withSuffix suffix: String,
        ignoring ignoreList: [String] = defaultIgnoreList) -> [URL] {
        let dotSuffix = "." + suffix

        let matchPredicate: (URL) -> Bool = { file in
            file.lastPathComponent == suffix || file.path.hasSuffix(dotSuffix)
        }

        return search(filesIn: root, matching: matchPredicate, ignoring: ignoreList)
    }

    static func search(
        filesIn root: URL,
        matching matchPredicate: (URL) -> Bool,
        ignoring ignoreList: [String] = defaultIgnoreList) -> [URL] {

        let ignorePredicate: (URL) -> Bool = { file in
            for ignore in ignoreList where file.path.contains(ignore) {
                return true
            }

            return false
        }

        return search(filesIn: root, matching: matchPredicate, ignoring: ignorePredicate)
    }

    static func search(
        filesIn root: URL,
        matching matchPredicate: (URL) -> Bool,
        ignoring ignorePredicate: (URL) -> Bool) -> [URL] {
        var results: [URL] = []

        let fileManager = FileManager.default
        let keys = [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey]
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsHiddenFiles]

        guard let enumerator = fileManager.enumerator(
            at: root,
            includingPropertiesForKeys: keys,
            options: options,
            errorHandler: {(_, _) -> Bool in true }) else { return results }

        while let file = enumerator.nextObject() as? URL {
            if ignorePredicate(file) {
                enumerator.skipDescendants()
                continue
            }

            if matchPredicate(file) {
                results.append(file)
            }
        }

        return results
    }
}
