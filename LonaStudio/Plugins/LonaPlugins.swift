//
//  LonaPlugins.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/4/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation

class LonaPlugins {
    struct PluginFile {

        // MARK: Public

        let url: URL

        var name: String {
            return url.lastPathComponent
        }

        func run(onSuccess: (String) -> Void) {
            guard let config = config else { return }
            config.run(pluginDirectory: url, onSuccess: onSuccess)
        }

        // MARK: Private

        private var config: LonaPluginConfig? {
            let configUrl = url.appendingPathComponent("lonaplugin.json", isDirectory: false)
            guard let contents = try? Data(contentsOf: configUrl) else { return nil }
            return try? JSONDecoder().decode(LonaPluginConfig.self, from: contents)
        }
    }

    let url: URL

    init(url: URL) {
        self.url = url
    }

    func pluginFiles() -> [PluginFile] {
        return LonaPlugins.pluginFiles(in: url)
    }

    func pluginFile(named name: String) -> PluginFile? {
        return pluginFiles().first(where: { arg in arg.name == name })
    }

    // MARK: - STATIC

    static var current: LonaPlugins {
        return LonaPlugins(url: CSUserPreferences.workspaceURL.appendingPathComponent("plugins", isDirectory: true))
    }

    static func pluginFiles(in workspace: URL) -> [PluginFile] {
        var files: [PluginFile] = []

        let fileManager = FileManager.default
        let keys = [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey]
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsHiddenFiles]

        guard let enumerator = fileManager.enumerator(
            at: workspace,
            includingPropertiesForKeys: keys,
            options: options,
            errorHandler: {(_, _) -> Bool in true }) else { return files }

        while let file = enumerator.nextObject() as? URL {
            if file.lastPathComponent == "lonaplugin.json" {
                files.append(PluginFile(url: file.deletingLastPathComponent()))
            }
        }

        return files
    }
}
