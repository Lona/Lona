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

    private static func runAsync(arguments: [String], currentDirectoryPath: String) -> Promise<String, NSError> {

        Swift.print("INFO: Running `\(Git.launchPath) \(arguments.joined(separator: " "))`")

        return Process.run(
            configuration: Process.Configuration(
                launchPath: Git.launchPath,
                arguments: arguments,
                currentDirectoryPath: currentDirectoryPath
            )
        ).onSuccess({ data in
            return .success(data.utf8String() ?? "")
        })
    }

    // MARK: Public

    public static var defaultOriginName = "origin"

    public static var defaultBranchName = "master"

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

        public func runAsync(arguments: [String]) -> Promise<String, NSError> {
            return Git.runAsync(arguments: arguments, currentDirectoryPath: currentDirectoryPath)
        }
    }
}

// MARK: Sync

extension Git.Client {
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

    public func getRootDirectoryPath() -> Result<String, NSError> {
        return run(arguments: ["rev-parse", "--show-toplevel"]).map({ output in
            output.trimmingCharacters(in: .whitespacesAndNewlines)
        })
    }

    public func getRemoteURL() -> Result<URL, NSError> {
        return run(arguments: ["remote", "get-url", Git.defaultOriginName]).map({ output in
            output.trimmingCharacters(in: .whitespacesAndNewlines)
        }).flatMap({ urlString in
            if let url = URL(string: urlString) {
                return .success(url)
            } else {
                return .failure(NSError("Invalid URL: \(urlString)"))
            }
        })
    }

    public func getHeadSHA() -> Result<String, NSError> {
        return run(arguments: ["rev-parse", "HEAD"]).map({ output in
            output.trimmingCharacters(in: .whitespacesAndNewlines)
        })
    }

    public func hasUncommittedChanges() -> Result<Bool, NSError> {
        return run(arguments: ["status", "--porcelain"]).map({ output in
            !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        })
    }

    public func clone(repository: URL, localDirectoryPath: String) -> Result<String, NSError> {
        return run(arguments: ["clone", repository.absoluteString, localDirectoryPath])
    }
}

// MARK: Async

extension Git.Client {
    public func getRemoteSHAAsync() -> Promise<String, NSError> {
        return runAsync(arguments: ["ls-remote", Git.defaultOriginName, Git.defaultBranchName, "--porcelain"]).onSuccess({ result in
            return .success(String(result.prefix(40)))
        })
    }

    public func isLocalBranchUpToDateWithRemote() -> Promise<Bool, NSError> {
        let headSHA = Git.client.getHeadSHA()

        return Git.client.getRemoteSHAAsync().onResult({ result in
            switch (headSHA, result) {
            case (.success(let headSHA), .success(let remoteSHA)):
                return .success(headSHA == remoteSHA)
            case (.failure(let error), _):
                return .failure(NSError("Git failure: couldn't find git SHA for HEAD.\n\(error)"))
            case (_, .failure(let error)):
                return .failure(NSError("Failed to connect to remote git repository. Are you connected to the internet?\n\(error)"))
            }
        })
    }
}

// MAKR: URL

extension Git {
    public enum URL {
        public enum Format {
            case ssh, https
        }

        private static var githubHTTPSPrefix = "https://github.com/"

        private static var githubSSHPrefix = "git@github.com:"

        public static func format(_ url: Foundation.URL, as format: Format) -> Foundation.URL? {
            let baseString: String

            switch format {
            case .ssh:
                baseString = url.absoluteString.replacingOccurrences(of: githubHTTPSPrefix, with: githubSSHPrefix)
            case .https:
                baseString = url.absoluteString.replacingOccurrences(of: githubSSHPrefix, with: githubHTTPSPrefix)
            }

            guard let baseURL = Foundation.URL(string: baseString) else { return nil }

            switch format {
            case .ssh:
                return baseURL.pathExtension == "git" ? baseURL : baseURL.appendingPathExtension("git")
            case .https:
                return baseURL.pathExtension == "git" ? baseURL.deletingPathExtension() : baseURL
            }
        }

        public static func isSameGitRepository(_ a: Foundation.URL, _ b: Foundation.URL) -> Bool {
            return a == Git.URL.format(b, as: .ssh) || a == Git.URL.format(b, as: .https)
        }
    }
}
