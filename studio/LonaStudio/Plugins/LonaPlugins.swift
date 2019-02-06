//
//  LonaPlugins.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/4/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

enum LonaPluginActivationEvent: String, Decodable {
    case onSaveComponent = "onSave:component"
    case onSaveColors = "onSave:colors"
    case onSaveTextStyles = "onSave:textStyles"
    case onReloadWorkspace = "onReload:workspace"
    case onChangeTheme = "onChange:theme"
}

struct LonaPluginConfig: Decodable {
    var main: String
    var activationEvents: [LonaPluginActivationEvent]?
}

class LonaPlugins {
    typealias SubscriptionHandle = () -> Void

    class Handler {
        var callback: () -> Void

        init(callback: @escaping () -> Void) {
            self.callback = callback
        }
    }

    struct PluginFile {

        // MARK: Public

        let url: URL

        var name: String {
            return url.lastPathComponent
        }

        func run(onSuccess: (String) -> Void) {
            guard let config = config else { return }

            let rpcService = RPCService()

            let stdinFileHandle = LonaNode.run(
                arguments: [url.appendingPathComponent(config.main).path],
                currentDirectoryPath: url.path,
                onData: rpcService.handleRaw,
                onSuccess: { output in
                    Swift.print("Output", String(data: output, encoding: String.Encoding.utf8) ?? "")

//                    DispatchQueue.main.async {
//                        let alert = NSAlert()
//                        alert.messageText = "Finished running \(self.name)"
//                        alert.informativeText = output ?? ""
//                        alert.runModal()
//                    }
            })

            rpcService.sendData = stdinFileHandle?.write
        }

        // MARK: Private

        var config: LonaPluginConfig? {
            let configUrl = url.appendingPathComponent("lonaplugin.json", isDirectory: false)
            guard let contents = try? Data(contentsOf: configUrl) else { return nil }
            return try? JSONDecoder().decode(LonaPluginConfig.self, from: contents)
        }
    }

    let urls: [URL]

    private static var handlers: [LonaPluginActivationEvent: [Handler]] = [:]

    init(urls: [URL]) {
        self.urls = urls
    }

    func pluginFiles() -> [PluginFile] {
        return urls.flatMap { LonaPlugins.pluginFiles(in: $0) }
    }

    func pluginFile(named name: String) -> PluginFile? {
        return pluginFiles().first(where: { arg in arg.name == name })
    }

    func pluginFilesActivatingOn(eventType: LonaPluginActivationEvent) -> [PluginFile] {
        return pluginFiles().filter({ file in
            file.config?.activationEvents?.contains(eventType) ?? false
        })
    }

    func register(eventType: LonaPluginActivationEvent, handler callback: @escaping () -> Void) -> SubscriptionHandle {
        let handler = Handler(callback: callback)

        var handlerList = LonaPlugins.handlers[eventType] ?? []
        handlerList.append(handler)
        LonaPlugins.handlers[eventType] = handlerList

        return {
            let handlerList = LonaPlugins.handlers[eventType] ?? []
            LonaPlugins.handlers[eventType] = handlerList.filter({ $0 !== handler })
        }
    }

    func register(eventTypes: [LonaPluginActivationEvent], handler callback: @escaping () -> Void) -> SubscriptionHandle {
        let subscriptions = eventTypes.map({ register(eventType: $0, handler: callback) })
        return {
            subscriptions.forEach({ sub in sub() })
        }
    }

    func trigger(eventType: LonaPluginActivationEvent) {
        LonaPlugins.current.pluginFilesActivatingOn(eventType: eventType).forEach({
            $0.run(onSuccess: {_ in })
        })

        LonaPlugins.handlers[eventType]?.forEach({ $0.callback() })
    }

    // MARK: - STATIC

    // this is the list of the plugins in:
    // - the `/plugins` folder of the current workspace
    // - the `~/Library/Application Support/${BUNDLE_IDENFIFIER}/plugins` folder
    static var current: LonaPlugins {
        do {
            let applicationSupportFolderURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as! String
            let commonPluginsfolder = applicationSupportFolderURL.appendingPathComponent("\(appName)/plugins", isDirectory: true)
            if !FileManager.default.fileExists(atPath: commonPluginsfolder.path) {
                try FileManager.default.createDirectory(at: commonPluginsfolder, withIntermediateDirectories: true, attributes: nil)
            }
            return LonaPlugins(urls: [
                commonPluginsfolder,
                CSUserPreferences.workspaceURL.appendingPathComponent("plugins", isDirectory: true)
            ])
        } catch {
            print(error)
            return LonaPlugins(urls: [
                CSUserPreferences.workspaceURL.appendingPathComponent("plugins", isDirectory: true)
            ])
        }
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
