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

    static func runSync(
        arguments: [String],
        inputData: Data = Data(),
        currentDirectoryPath: String? = nil) -> Result<Data, String> {

        var output: Data?
        var failureMessage: String?

        run(
            sync: true,
            arguments: arguments,
            inputData: inputData,
            currentDirectoryPath: currentDirectoryPath,
            onSuccess: ({ data in
                output = data
            }),
            onFailure: ({ code, error in
                failureMessage = "Error \(code): \(error ?? "")"
            })
        )

        if let output = output {
            return .success(output)
        } else {
            return .failure(failureMessage ?? "Unknown node error")
        }
    }

    static func run(
        sync: Bool,
        arguments: [String],
        inputData: Data = Data(),
        currentDirectoryPath: String? = nil,
        onSuccess: ((Data) -> Void)? = nil,
        onFailure: ((Int, String?) -> Void)? = nil) {

        let process = makeProcess(
            arguments: arguments,
            currentDirectoryPath: currentDirectoryPath,
            onFailure: onFailure
        )

        var buffer = Data()

        process.execute(
            sync: sync,
            onLaunch: ({ process in
                process.pipeToStandardInput(data: inputData, closeAfterWriting: true)
                process.pipeFromStandardOutput(onData: { data in
                    buffer += data
                })
            }),
            onComplete: ({ _ in
                onSuccess?(buffer)
            })
        )
    }

    static func makeProcess(
        arguments: [String],
        currentDirectoryPath: String? = nil,
        onFailure: ((Int, String?) -> Void)? = nil) -> Process {

        let process = Process()

        guard let nodePath = LonaNode.binaryPath else {
            onFailure?(-1, "Couldn't find node")
            return process
        }

        var env = ProcessInfo.processInfo.environment

        if let path = env["PATH"], let binaryPath = binaryPath {
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

        process.launchPath = nodePath
        process.arguments = arguments

        let stdin = Pipe()
        let stdout = Pipe()

        process.standardInput = stdin
        process.standardOutput = stdout

        return process
    }

    static var binaryPath: String? {
        return Bundle.main.path(forResource: "node", ofType: "")
    }
}

public extension Process {

    // Supports streaming chunks of data, separated by "\n"

    static func handleStreamingData(_ data: Data, onPacket: (Data) -> Void) {
        if data.count == 0 { return }

        let packets = data.split(separator: UInt8(ascii: "\n"))

        packets.forEach(onPacket)
    }

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
        dispatchQueue: DispatchQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated),
        onLaunch: ((Process) -> Void)? = nil,
        onComplete: ((Process) -> Void)? = nil) {

        let run: () -> Void = {
            self.launch()

            onLaunch?(self)

            self.waitUntilExit()

            onComplete?(self)
        }

        if sync {
            dispatchQueue.sync(execute: run)
        } else {
            dispatchQueue.async(execute: run)
        }
    }
}
