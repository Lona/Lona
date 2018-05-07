//
//  LonaModule.swift
//  LonaStudio
//
//  Created by devin_abbott on 3/9/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation

class LonaModule {
    struct ComponentFile {
        let url: URL
        var name: String {
            return url.deletingPathExtension().lastPathComponent
        }
    }

    let url: URL

    init(url: URL) {
        self.url = url
    }

    func componentFiles() -> [ComponentFile] {
        return LonaModule.componentFiles(in: url)
    }

    func componentFile(named name: String) -> ComponentFile? {
        return componentFiles().first(where: { arg in arg.name == name })
    }

    func component(url: URL) -> CSComponent? {
        guard let componentFile = componentFiles().first(where: { arg in arg.url == url }) else { return nil }
        return CSComponent(url: componentFile.url)
    }

    func component(named name: String) -> CSComponent? {
        guard let componentFile = componentFiles().first(where: { arg in arg.name == name }) else { return nil }
        return CSComponent(url: componentFile.url)
    }

    // MARK: - STATIC

    static var current: LonaModule {
        return LonaModule(url: CSUserPreferences.workspaceURL)
    }

    static func componentFiles(in workspace: URL) -> [ComponentFile] {
        var files: [ComponentFile] = []

        let fileManager = FileManager.default
        let keys = [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey]
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsHiddenFiles]

        guard let enumerator = fileManager.enumerator(
            at: workspace,
            includingPropertiesForKeys: keys,
            options: options,
            errorHandler: {(_, _) -> Bool in true }) else { return files }

        while let file = enumerator.nextObject() as? URL {
            if file.pathExtension == "component" {
                files.append(ComponentFile(url: file))
            }
        }

        return files
    }
}
