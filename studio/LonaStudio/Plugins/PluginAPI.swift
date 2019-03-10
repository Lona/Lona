//
//  PluginAPI.swift
//  LonaStudio
//
//  Created by Mathieu Dutour on 06/02/2019.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

enum NotificationMethod: String {
    case alert
}

enum RequestMethod: String {
    case workspacePath
    case compilerPath
    case customParameters
    case devicePresetList
}

private enum PluginPersistenceScope: String {
    case workspace
    case global
    case none
}

class PluginAPI {
    static func handleNotification(_ jsonMethod: String, _ jsonParams: AnyObject?) {
        guard let method = NotificationMethod(rawValue: jsonMethod) else {
                print("unknown method")
                return
        }

        switch method {
        case .alert:
            guard let message = jsonParams?["msg"] as? String else {
                print("invalid params")
                return
            }
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = message
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                alert.addButton(withTitle: "Cancel")
                alert.runModal()
            }
        }
    }

    static func handleRequest(
        _ jsonMethod: String,
        _ jsonParams: AnyObject?,
        onSuccess: @escaping (Any?) -> Void,
        onFailure: (RPCError) -> Void) {
        guard let method = RequestMethod(rawValue: jsonMethod) else {
            onFailure(RPCError.MethodNotFound())
            return
        }

        switch method {
        case .workspacePath:
            let result = CSUserPreferences.workspaceURL.path

            onSuccess(result)
            return
        case .compilerPath:
            let result = CSUserPreferences.compilerURL?.path

            onSuccess(result)
            return
        case .devicePresetList:
            if let data = try? JSONEncoder().encode(Canvas.devicePresets),
                let json = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) {
                onSuccess(json)
            } else {
                onFailure(RPCError.InternalError())
            }
            return
        case .customParameters:
            guard let workspaceViewController = WorkspaceWindowController.first?.contentViewController else {
                onSuccess(nil)
                return
            }

            var title = "Parameters"
            var parameters: [CSParameter] = []
            var initialValues: [String: CSData] = [:]
            var persistenceKeyPath: [String]?

            if let jsonParams = jsonParams {
                let params = CSData.from(json: jsonParams)

                if let value = params.get(key: "title").string {
                    title = value
                }

                if let value = params.get(key: "params").array {
                    parameters = value.map { CSParameter($0) }
                    initialValues = CSParameter.defaultDataObject(for: parameters)
                }

                if let id = params.get(key: "id").string,
                    let persistenceScope = PluginPersistenceScope(rawValue:
                        params.get(key: "persistenceScope").string ?? "workspace") {

                    switch persistenceScope {
                    case .none:
                        break
                    case .workspace:
                        persistenceKeyPath = [LonaModule.current.url.path, id]
                    case .global:
                        persistenceKeyPath = [id]
                    }
                }

                if let persistenceKeyPath = persistenceKeyPath {
                    if let pluginParamsStore = UserDefaults.standard.csData(forKey: PluginAPI.pluginParamsStoreKey),
                        let stored = pluginParamsStore.get(keyPath: persistenceKeyPath).object {
                        initialValues = initialValues.merging(stored, uniquingKeysWith: { a, b in b })
                    }
                }
            }

            DispatchQueue.main.async {
                CustomParametersEditorView.presentSheet(
                    parentViewController: workspaceViewController,
                    titleText: title,
                    parameters: parameters,
                    initialValues: initialValues,
                    onCompletion: { data in
                        if let data = data {
                            if let persistenceKeyPath = persistenceKeyPath {
                                var pluginParamsStore = UserDefaults.standard.csData(forKey: PluginAPI.pluginParamsStoreKey) ?? CSData.Object([:])
                                pluginParamsStore.set(keyPath: persistenceKeyPath, to: CSData.Object(data))
                                UserDefaults.standard.set(pluginParamsStore, forKey: PluginAPI.pluginParamsStoreKey)
                            }

                            let json = CSData.Object(data).toAny()
                            onSuccess(json)
                        } else {
                            onSuccess(nil)
                        }
                    }
                )
            }
        }
    }

    private static let pluginParamsStoreKey = "pluginParamsStore"
}
