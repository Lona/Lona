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
        onSuccess: (Any?) -> Void,
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
        }
    }
}
