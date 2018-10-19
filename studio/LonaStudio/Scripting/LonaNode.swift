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
        arguments: [String],
        inputData: Data? = nil,
        currentDirectoryPath: String? = nil,
        onSuccess: ((Data) -> Void)? = nil,
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
            task.arguments = arguments

            if let currentDirectoryPath = currentDirectoryPath {
                task.currentDirectoryPath = currentDirectoryPath
            }

            let stdin = Pipe()
            let stdout = Pipe()

            task.standardInput = stdin
            task.standardOutput = stdout

            // Launch the task
            task.launch()

            if let inputData = inputData {
                stdin.fileHandleForWriting.write(inputData)
            }

            stdin.fileHandleForWriting.closeFile()

            task.waitUntilExit()

            let handle = stdout.fileHandleForReading
            let data = handle.readDataToEndOfFile()

            onSuccess?(data)
        }
    }

    static var binaryPath: String? {
        return Bundle.main.path(forResource: "node", ofType: "")
    }
}
