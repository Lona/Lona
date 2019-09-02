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

    typealias ProcessResult = Result<Data, String>

    // MARK: Public

    static func runSync(
        arguments: [String],
        inputData: Data = Data(),
        currentDirectoryPath: String? = nil) -> Result<Data, String> {

        var result: Result<Data, String>?

        run(
            sync: true,
            arguments: arguments,
            inputData: inputData,
            currentDirectoryPath: currentDirectoryPath,
            onComplete: ({
                result = $0
            })
        )

        if let result = result {
            return result
        } else {
            return .failure("Unknown process error")
        }
    }

    static func run(
        sync: Bool,
        arguments: [String],
        inputData: Data = Data(),
        currentDirectoryPath: String? = nil,
        onComplete: ((ProcessResult) -> Void)? = nil) {

        let process = makeProcess(
            arguments: arguments,
            currentDirectoryPath: currentDirectoryPath
        )

        var buffer = Data()

        process.execute(
            sync: sync,
            onLaunch: ({ _ in
                process.pipeToStandardInput(data: inputData, closeAfterWriting: true)
                process.pipeFromStandardOutput(onData: { data in
                    buffer += data
                })
            }),
            onComplete: ({ _ in
                if process.terminationStatus == 0 {
                    onComplete?(.success(buffer))
                } else {
                    onComplete?(.failure("Node process terminated with code: \(process.terminationStatus)"))
                }
            })
        )
    }

    static func makeProcess(arguments: [String], currentDirectoryPath: String? = nil) -> Process {
        let process = Process()

        var env = ProcessInfo.processInfo.environment

        if let path = env["PATH"] {
            let nodeDirectory = URL(fileURLWithPath: binaryPath).deletingLastPathComponent()
            env["PATH"] = "\(nodeDirectory):\(path)"
        }

        if let currentDirectoryPath = currentDirectoryPath {
            process.currentDirectoryPath = currentDirectoryPath

            // Add node_modules to PATH
            if let path = env["PATH"] {
                let nodeModulesBinaries = URL(fileURLWithPath: currentDirectoryPath)
                    .appendingPathComponent("node_modules/.bin", isDirectory: true).path
                env["PATH"] = "\(nodeModulesBinaries):\(path)"
            }
        }

        process.environment = env

        process.launchPath = binaryPath
        process.arguments = arguments

        let stdin = Pipe()
        let stdout = Pipe()

        process.standardInput = stdin
        process.standardOutput = stdout

        return process
    }

    static var binaryPath: String {
        return Bundle.main.path(forResource: "node", ofType: "")!
    }

    static var compilerPath: String {
        let bundledCompilerPath = binaryPath + "/../Modules/lonac"
        return CSUserPreferences.compilerURL?.path ?? bundledCompilerPath
    }
}

public extension Process {

    // IO

    func pipeFromStandardOutput() -> Data {
        guard let outputPipe = standardOutput as? Pipe else { fatalError("Invalid stdout") }

        return outputPipe.fileHandleForReading.readDataToEndOfFile()
    }

    func pipeFromStandardOutput(onData: @escaping (Data) -> Void) {
        guard let outputPipe = standardOutput as? Pipe else { fatalError("Invalid stdout") }

        outputPipe.fileHandleForReading.readabilityHandler = { handle in onData(handle.availableData) }
    }

    func pipeToStandardInput(data inputData: Data, closeAfterWriting: Bool = false) {
        guard let inputPipe = standardInput as? Pipe else { fatalError("Invalid stdin") }

        inputPipe.fileHandleForWriting.write(inputData)

        if closeAfterWriting {
            inputPipe.fileHandleForWriting.closeFile()
        }
    }

    // Execute

    func execute(
        sync: Bool,
        onLaunch: ((Process) -> Void)? = nil,
        onComplete: ((Process) -> Void)? = nil) {

        let run: () -> Void = {
            self.launch()

            onLaunch?(self)

            self.waitUntilExit()

            onComplete?(self)
        }

        let dispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)

        if sync {
            dispatchQueue.sync(execute: run)
        } else {
            dispatchQueue.async(execute: run)
        }
    }
}
