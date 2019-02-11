//
//  LonaNode.swift
//  LonaStudio
//
//  Created by devin_abbott on 5/4/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

typealias SendData = (_ data: Data) -> Void

enum LonaNode {

    // MARK: Public

    static func runSync(
        arguments: [String],
        inputData: Data? = nil,
        currentDirectoryPath: String? = nil) throws -> Data {

        var output: Data?
        var failureMessage: String?

        _ = run(
            arguments: arguments,
            inputData: inputData,
            currentDirectoryPath: currentDirectoryPath,
            sync: true,
            onSuccess: { data in
                output = data
            }, onFailure: { code, error in
                failureMessage = "Error \(code): \(error ?? "")"
            }
        )

        if let output = output {
            return output
        } else {
            throw failureMessage ?? "Node error"
        }
    }

    static func run(
        arguments: [String],
        inputData: Data? = nil,
        currentDirectoryPath: String? = nil,
        sync: Bool = false,
        onData: ((Data) -> Void)? = nil,
        onSuccess: ((Data) -> Void)? = nil,
        onFailure: ((Int, String?) -> Void)? = nil) {

        let stdin = launchAndReturnFileHandle(
            arguments: arguments,
            inputData: inputData,
            currentDirectoryPath: currentDirectoryPath,
            sync: sync,
            onData: onData,
            onSuccess: onSuccess,
            onFailure: onFailure
            )

        stdin?.closeFile()
    }

    static func launch(
        arguments: [String],
        inputData: Data? = nil,
        currentDirectoryPath: String? = nil,
        sync: Bool = false,
        onData: ((Data) -> Void)? = nil,
        onSuccess: ((Data) -> Void)? = nil,
        onFailure: ((Int, String?) -> Void)? = nil) -> SendData? {

        return launchAndReturnFileHandle(
            arguments: arguments,
            inputData: inputData,
            currentDirectoryPath: currentDirectoryPath,
            sync: sync,
            onData: onData,
            onSuccess: onSuccess,
            onFailure: onFailure
            )?.write
    }

    private static func launchAndReturnFileHandle(
        arguments: [String],
        inputData: Data? = nil,
        currentDirectoryPath: String? = nil,
        sync: Bool = false,
        onData: ((Data) -> Void)? = nil,
        onSuccess: ((Data) -> Void)? = nil,
        onFailure: ((Int, String?) -> Void)? = nil) -> FileHandle? {

        guard let nodePath = LonaNode.binaryPath else {
            onFailure?(-1, "Couldn't find node")
            return nil
        }

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

        var recvBuf = Data()

        stdout.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            LonaNode.recvHandler(data, &recvBuf, onData)
        }

        func run() {
            // Launch the task
            task.launch()

            if let inputData = inputData {
                stdin.fileHandleForWriting.write(inputData)
            }

            task.waitUntilExit()

            onSuccess?(recvBuf)
        }

        if sync {
            run()
        } else {
            DispatchQueue.global().async {
                run()
            }
        }

        return stdin.fileHandleForWriting
    }

    static var binaryPath: String? {
        return Bundle.main.path(forResource: "node", ofType: "")
    }

    // most of the following is taken from https://github.com/xi-editor/xi-mac/blob/master/Sources/XiEditor/RPCSending.swift#L175-L201
    private static func recvHandler(_ data: Data, _ recvBuf: inout Data, _ onData: ((Data) -> Void)? = nil) {
        if data.count == 0 {
            return
        }
        let scanStart = recvBuf.count
        recvBuf.append(data)
        let recvBufLen = recvBuf.count

        recvBuf.withUnsafeMutableBytes { (recvBufBytes: UnsafeMutablePointer<UInt8>) -> Void in
            var i = scanStart
            for j in scanStart..<recvBufLen {
                // TODO: using memchr would probably be faster
                if recvBufBytes[j] == UInt8(ascii: "\n") {
                    let bufferPointer = UnsafeBufferPointer(start: recvBufBytes.advanced(by: i), count: j + 1 - i)
                    let dataPacket = Data(bufferPointer)
                    onData?(dataPacket)
                    i = j + 1
                }
            }
        }
    }
}
