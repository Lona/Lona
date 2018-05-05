//
//  LonaNodePlugin.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/4/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

struct LonaPluginConfig: Decodable {

    // MARK: Public

    var main: String

    func run(pluginDirectory: URL, onSuccess: (String) -> Void) {
        guard let nodePath = LonaPluginConfig.nodePath else { return }

        DispatchQueue.global().async {
            let task = Process()

            // Set the task parameters
            task.launchPath = nodePath
            task.arguments = [pluginDirectory.appendingPathComponent(self.main).path]
            task.currentDirectoryPath = CSUserPreferences.workspaceURL.path

            let stdin = Pipe()
            let stdout = Pipe()

            task.standardInput = stdin
            task.standardOutput = stdout

            // Launch the task
            task.launch()

//            stdin.fileHandleForWriting.write(data)
            stdin.fileHandleForWriting.closeFile()

            task.waitUntilExit()

            let handle = stdout.fileHandleForReading
            let data = handle.readDataToEndOfFile()
            let out = NSString(data: data, encoding: String.Encoding.utf8.rawValue)

            Swift.print("result", out ?? "stdout empty")
        }
    }

    static var nodePath: String? {
        return Bundle.main.path(forResource: "node", ofType: "")
    }
}
