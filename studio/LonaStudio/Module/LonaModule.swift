//
//  LonaModule.swift
//  LonaStudio
//
//  Created by devin_abbott on 3/9/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

private let defaultReadmeContents = """
## Overview

This is a Lona workspace.

Here we define the components, tokens (colors, text styles, shadows, etc), and data types that make up our design system.

We then use the Lona compiler to convert this design system to platform-specific code.

> You can learn more about Lona [here](https://github.com/airbnb/Lona).
"""

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

    var types: [CSType] {
        if let types = LonaModule.cachedTypes[url] { return types }

        let files = componentFiles().sorted { a, b in a.name < b.name }

        let components = files.map { component(url: $0.url) }.compactMap { $0 }

        let types: [[CSType]] = components.map { component in
            let types: [CSType?] = component.parameters.map { param in
                switch param.type {
                case .named(let name, .variant(let contents)):
                    return .named((component.name ?? "") + "." + name, .variant(contents))
                default:
                    return nil
                }
            }

            return types.compactMap { $0 }
        }

        let flat = Array(types.joined())

        LonaModule.cachedTypes[url] = flat

        return flat
    }

    func type(named typeName: String) -> CSType? {
        for type in types {
            if case CSType.named(let name, _) = type, name == typeName {
                return type
            }
        }

        return nil
    }

    // MARK: - STATIC

    private static var cachedTypes: [URL: [CSType]] = [:]

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

    static func createWorkspace(at url: URL) throws {
        let workspaceName = url.lastPathComponent
        let workspaceParent = url.deletingLastPathComponent()

        let root = VirtualDirectory(name: workspaceName, children: [
            VirtualFile(name: "README.md", contents: defaultReadmeContents.data(using: .utf8)!),
            VirtualFile(name: "lona.json", data: CSData.Object([:])),
            VirtualFile(name: "colors.json", data: CSData.Object([
                "colors": CSData.Array([])
                ])),
            VirtualFile(name: "shadows.json", data: CSData.Object([
                "shadows": CSData.Array([])
                ])),
            VirtualFile(name: "textStyles.json", data: CSData.Object([
                "styles": CSData.Array([])
                ])),
            VirtualDirectory(name: "assets"),
            VirtualDirectory(name: "components")
            ])

        try VirtualFileSystem.write(node: root, relativeTo: workspaceParent)
    }
}
