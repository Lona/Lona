//
//  URLExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/1/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

extension URL {
    func contentsAsBase64EncodedString() -> String? {
        guard let data = try? Data(contentsOf: self) else { return nil }
        return data.base64EncodedString()
    }

    func absoluteURLForWorkspaceURL() -> URL {
        if !(absoluteString.starts(with: "file://./") || absoluteString.starts(with: "file://../")) { return self }

        var resolved = absoluteString.replacingOccurrences(
            of: "file://./",
            with: "file://" + CSUserPreferences.workspaceURL.path + "/")

        resolved = resolved.replacingOccurrences(
            of: "file://../",
            with: "file://" + CSUserPreferences.workspaceURL.path + "/../")

        return URL(string: resolved) ?? self
    }

    func isLonaWorkspace() -> Bool {
        let configURL = self.appendingPathComponent("lona.json")
        return FileManager.default.fileExists(atPath: configURL.path)
    }

    func isLonaMarkdownDirectory() -> Bool {
        let readmeURL = self.appendingPathComponent(MarkdownDocument.INDEX_PAGE_NAME)
        return FileManager.default.fileExists(atPath: readmeURL.path)
    }

    func hasMarkdownExtension() -> Bool {
        return pathExtension == "md"
    }

    func isLonaPage() -> Bool {
        return isLonaMarkdownDirectory() || hasMarkdownExtension()
    }

    func deletingTrailingSlash() -> URL {
        if hasDirectoryPath {
            let lastComponent = lastPathComponent
            return self.deletingLastPathComponent().appendingPathComponent(lastComponent)
        } else {
            return self
        }
    }

    static func equal(_ a: URL, _ b: URL, ignoringTrailingSlash ignore: Bool = false) -> Bool {
        if ignore && a.hasDirectoryPath != b.hasDirectoryPath {
            let aString = a.absoluteString
            let bString = b.absoluteString

            return (aString + "/" == bString) || (aString == bString + "/")
        }

        return a == b
    }
}
