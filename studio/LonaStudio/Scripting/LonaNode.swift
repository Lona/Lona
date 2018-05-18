//
//  LonaNode.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/4/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

enum LonaNode {

    // MARK: Public

    static func run(
        scriptPath: String,
        inputData: CSData? = nil,
        currentDirectoryPath: String? = nil,
        onSuccess: ((String?) -> Void)? = nil,
        onFailure: ((Int, String?) -> Void)? = nil) {
        guard let nodePath = LonaNode.binaryPath else { return }

        DispatchQueue.global().async {
            let task = Process()

            var env = ProcessInfo.processInfo.environment
            if let path = env["PATH"], let binaryPath = binaryPath {
                let nodeDirectory = URL(fileURLWithPath: binaryPath).deletingLastPathComponent()
                env["PATH"] = "\(nodeDirectory):" + path
            }
            task.environment = env

            // Set the task parameters
            task.launchPath = nodePath
            task.arguments = [scriptPath]

            if let currentDirectoryPath = currentDirectoryPath {
                task.currentDirectoryPath = currentDirectoryPath
            }

            let stdin = Pipe()
            let stdout = Pipe()

            task.standardInput = stdin
            task.standardOutput = stdout

            // Launch the task
            task.launch()

            if let inputData = inputData, let data = inputData.toData() {
                stdin.fileHandleForWriting.write(data)
            }

            stdin.fileHandleForWriting.closeFile()

            task.waitUntilExit()

            let handle = stdout.fileHandleForReading
            let data = handle.readDataToEndOfFile()
            let out = NSString(data: data, encoding: String.Encoding.utf8.rawValue)

            onSuccess?(out as String?)
        }
    }

    static var binaryPath: String? {
        return Bundle.main.path(forResource: "node", ofType: "")
    }
}
