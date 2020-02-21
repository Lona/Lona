//
//  Git.swift
//  LonaStudio
//
//  Created by Devin Abbott on 2/19/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit

public enum Git {

    // MARK: Private

    private static var launchPath: String = "/usr/bin/git"

    private static func run(arguments: [String], currentDirectoryPath: String) -> Result<String, NSError> {

        Swift.print("INFO: Running `\(Git.launchPath) \(arguments.joined(separator: " "))`")

        let result = Process.runSync(
            configuration: Process.Configuration(
                launchPath: Git.launchPath,
                arguments: arguments,
                currentDirectoryPath: currentDirectoryPath
            )
        )

        switch result {
        case .success(let success):
            return .success(success.utf8String() ?? "")
        case .failure(let error):
            return .failure(error)
        }
    }

    // MARK: Public

    public static var client: Client {
        return Client(currentDirectoryPath: CSUserPreferences.workspaceURL.path)
    }

    public struct Client {
        public var currentDirectoryPath: String

        public init(currentDirectoryPath: String) {
            self.currentDirectoryPath = currentDirectoryPath
        }

        public func run(arguments: [String]) -> Result<String, NSError> {
            return Git.run(arguments: arguments, currentDirectoryPath: currentDirectoryPath)
        }

        public func initRepo() -> Result<String, NSError> {
            return run(arguments: ["init"])
        }

        public func addAllFiles() -> Result<String, NSError> {
            return run(arguments: ["add", "."])
        }

        public func commit(message: String) -> Result<String, NSError> {
            return run(arguments: ["commit", "-m", message])
        }

        public func addRemote(name: String, url: URL) -> Result<String, NSError> {
            return run(arguments: ["remote", "add", name, url.absoluteString])
        }

        public func push(repository: String, refspec: String) -> Result<String, NSError> {
            return run(arguments: ["push", repository, refspec])
        }

        public func getRootDirectory() -> Result<String, NSError> {
            return run(arguments: ["rev-parse", "--show-toplevel"]).map({ path in
                path.trimmingCharacters(in: .whitespacesAndNewlines)
            })
        }
    }
}
