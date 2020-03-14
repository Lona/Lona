//
//  Process+Execute.swift
//  LonaStudio
//
//  Created by Devin Abbott on 2/19/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import Foundation

extension Process {

    public struct Configuration {
        public var launchPath: String
        public var arguments: [String] = []
        public var currentDirectoryPath: String?
    }

    public static func runSync(configuration: Configuration, inputData: Data = Data()) -> Result<Data, NSError> {
        var result: Result<Data, NSError>?

        _run(sync: true, configuration: configuration, inputData: inputData).finalResult { processResult in
            result = processResult
        }

        return result!
    }

    public static func run(configuration: Configuration, inputData: Data = Data()) -> Promise<Data, NSError> {
        return _run(sync: false, configuration: configuration, inputData: inputData)
    }

    private static func _run(sync: Bool, configuration: Configuration, inputData: Data) -> Promise<Data, NSError> {
        return .result { complete in
            let process = makeProcess(configuration: configuration)

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
                        complete(.success(buffer))
                    } else {
                        complete(.failure(NSError("Node process terminated with code: \(process.terminationStatus)")))
                    }
                })
            )
        }
    }

    static func makeProcess(configuration: Configuration) -> Process {
        let process = Process()

        process.launchPath = configuration.launchPath
        process.arguments = configuration.arguments

        if let currentDirectoryPath = configuration.currentDirectoryPath {
            process.currentDirectoryPath = currentDirectoryPath
        }

        let stdin = Pipe()
        let stdout = Pipe()

        process.standardInput = stdin
        process.standardOutput = stdout

        return process
    }

    // Execute

    public func execute(
        sync: Bool,
        onLaunch: ((Process) -> Void)? = nil,
        onComplete: ((Process) -> Void)? = nil
    ) {

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

    // IO

    public func pipeFromStandardOutput() -> Data {
        guard let outputPipe = standardOutput as? Pipe else { fatalError("Invalid stdout") }

        return outputPipe.fileHandleForReading.readDataToEndOfFile()
    }

    public func pipeFromStandardOutput(onData: @escaping (Data) -> Void) {
        guard let outputPipe = standardOutput as? Pipe else { fatalError("Invalid stdout") }

        outputPipe.fileHandleForReading.readabilityHandler = { handle in onData(handle.availableData) }
    }

    public func pipeToStandardInput(data inputData: Data, closeAfterWriting: Bool = false) {
        guard let inputPipe = standardInput as? Pipe else { fatalError("Invalid stdin") }

        inputPipe.fileHandleForWriting.write(inputData)

        if closeAfterWriting {
            inputPipe.fileHandleForWriting.closeFile()
        }
    }
}
