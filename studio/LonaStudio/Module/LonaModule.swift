//
//  LonaModule.swift
//  LonaStudio
//
//  Created by devin_abbott on 3/9/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

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

    var colorsFileUrls: [URL] {
        return FileSearch.search(filesIn: url, withSuffix: "colors.json")
    }

    var textStylesFileUrls: [URL] {
        return FileSearch.search(filesIn: url, withSuffix: "textStyles.json")
    }

    var shadowsFileUrls: [URL] {
        return FileSearch.search(filesIn: url, withSuffix: "shadows.json")
    }

    var gradientsFileUrls: [URL] {
        return FileSearch.search(filesIn: url, withSuffix: "gradients.json")
    }

    var logicFileUrls: [URL] {
        return FileSearch.search(filesIn: url, matching: LonaModule.logicRE)
    }

    var logicFileContents: LGCProgram {
        let programs: [LGCProgram] = logicFileUrls.compactMap {
            guard let data = try? Data(contentsOf: $0) else { return nil }
            guard let syntaxNode = try? LogicDocument.read(from: data) else { return nil }
            guard let program = LGCProgram.make(from: syntaxNode) else { return nil }
            return program
        }

        return .join(programs: programs)
    }

    var assetsFileUrls: [URL] {
        return FileSearch.search(filesIn: url, matching: LonaModule.assetRE)
    }

    var vectorFileUrls: [URL] {
        return FileSearch.search(filesIn: url, matching: LonaModule.vectorRE)
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
            let types: [CSType?] = component.types.map { csType in
                switch csType {
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

    private static let assetRE = try! NSRegularExpression(pattern: #"\.(png|jpg)$"#)

    private static let vectorRE = try! NSRegularExpression(pattern: #"\.svg$"#)

    private static let logicRE = try! NSRegularExpression(pattern: #"\.logic$"#)

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

    static func createWorkspace(at url: URL, using template: WorkspaceTemplate) throws {
        let workspaceName = url.lastPathComponent
        let workspaceParent = url.deletingLastPathComponent()

        let root = template.make(workspaceName: workspaceName)

        try VirtualFileSystem.write(node: root, relativeTo: workspaceParent)
    }

    static func findNearestWorkspace(containing url: URL) -> URL? {
        let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false) ?? false

        var url = isDirectory ? url : url.deletingLastPathComponent()

        while url.path != "/" {
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("lona.json").path) {
                return url
            }

            url = url.deletingLastPathComponent()
        }

        return nil
    }

    static func build(onComplete: ((LonaNode.ProcessResult) -> Void)?) -> Bool {
        guard let compilerPath = CSUserPreferences.compilerURL?.path else { return false }

        let workspacePath = CSUserPreferences.workspaceURL.path

        let dialog = NSSavePanel()

        dialog.title = "Generated workspace directory"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canCreateDirectories = true

        if dialog.runModal() != NSApplication.ModalResponse.OK { return false }
        guard let generatedOutputUrl = dialog.url else { return false }

        let arguments = [
            compilerPath,
            "workspace",
            "--workspace", workspacePath,
            "--target", "swift",
            "--framework", "uikit",
            "--output", generatedOutputUrl.path
        ]

        LonaNode.run(
            sync: false,
            arguments: arguments,
            currentDirectoryPath: workspacePath,
            onComplete: ({ result in
                DispatchQueue.main.sync { onComplete?(result) }
            })
        )

        return true
    }
}
