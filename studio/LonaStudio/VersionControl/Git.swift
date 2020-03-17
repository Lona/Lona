//
//  Git.swift
//  LonaStudio
//
//  Created by Devin Abbott on 2/19/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit

public enum GitError: Error {
    case generic(ProcessError)
    case permissionDenied
    case invalidRemoteURL(String)

    public var localizedDescription: String {
        switch self {
        case .generic(let error):
            return error.localizedDescription
        case .permissionDenied:
            return """
Permission denied by GitHub.

In order to publish with Lona, you'll need to be able to `push` to GitHub via the command line `git` command.
"""
        case .invalidRemoteURL(let url):
            return "Invalid remote URL: \(url)"
        }
    }
}

public enum Git {

    // MARK: Private

    private static var launchPath: String = "/usr/bin/git"

    private static func run(arguments: [String], currentDirectoryPath: String) -> Result<String, ProcessError> {
        Swift.print("INFO: Running `\(Git.launchPath) \(arguments.joined(separator: " "))`")

        let result = Process.runSync(
            Process.Configuration(
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

    private static func runAsync(arguments: [String], currentDirectoryPath: String) -> Promise<String, ProcessError> {

        Swift.print("INFO: Running `\(Git.launchPath) \(arguments.joined(separator: " "))`")

        return Process.run(
            Process.Configuration(
                launchPath: Git.launchPath,
                arguments: arguments,
                currentDirectoryPath: currentDirectoryPath
            )
        ).onSuccess({ data in
            return .success(data.utf8String() ?? "")
        }).onFailure({ error in
            return .failure(error)
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

        public func run(arguments: [String]) -> Result<String, ProcessError> {
            return Git.run(arguments: arguments, currentDirectoryPath: currentDirectoryPath)
        }

        public func runAsync(arguments: [String]) -> Promise<String, ProcessError> {
            return Git.runAsync(arguments: arguments, currentDirectoryPath: currentDirectoryPath)
        }
    }
}

// MARK: Sync

extension Git.Client {
    public func initRepo() -> Result<String, ProcessError> {
        return run(arguments: ["init"])
    }

    public func addAllFiles() -> Result<String, ProcessError> {
        return run(arguments: ["add", "."])
    }

    public func commit(message: String) -> Result<String, ProcessError> {
        return run(arguments: ["commit", "-m", message])
    }

    public func addRemote(name: String, url: URL) -> Result<String, ProcessError> {
        return run(arguments: ["remote", "add", name, url.absoluteString])
    }

    public func push(repository: String, refspec: String) -> Result<String, GitError> {
        return run(arguments: ["push", repository, refspec]).mapError({ error in
            if error.code == 128,
                let errorString = error.errorOutput.utf8String(),
                (errorString.contains("git@github.com: Permission denied (publickey)") || errorString.contains("Host key verification failed")) {
                return .permissionDenied
            } else {
                return .generic(error)
            }
        })
    }

    public func getRootDirectoryPath() -> Result<String, ProcessError> {
        return run(arguments: ["rev-parse", "--show-toplevel"]).map({ output in
            output.trimmingCharacters(in: .whitespacesAndNewlines)
        })
    }

    public func getRemoteURL() -> Result<URL, GitError> {
        return run(arguments: ["remote", "get-url", Git.defaultOriginName]).map({ output in
            output.trimmingCharacters(in: .whitespacesAndNewlines)
        })
            .mapError({ error in .generic(error) })
            .flatMap({ urlString in
                if let url = URL(string: urlString) {
                    return .success(url)
                } else {
                    return .failure(.invalidRemoteURL(urlString))
                }
            })
    }

    public func getHeadSHA() -> Result<String, ProcessError> {
        return run(arguments: ["rev-parse", "HEAD"]).map({ output in
            output.trimmingCharacters(in: .whitespacesAndNewlines)
        })
    }

    public func hasUncommittedChanges() -> Result<Bool, ProcessError> {
        return run(arguments: ["status", "--porcelain"]).map({ output in
            !output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        })
    }

    public func clone(repository: URL, localDirectoryPath: String) -> Result<String, ProcessError> {
        return run(arguments: ["clone", repository.absoluteString, localDirectoryPath])
    }
}

// MARK: Async

extension Git.Client {
    public func getRemoteSHAAsync() -> Promise<String, ProcessError> {
        return runAsync(arguments: ["ls-remote", Git.defaultOriginName, Git.defaultBranchName, "--porcelain"]).onSuccess({ result in
            return .success(String(result.prefix(40)))
        })
    }

    public func isLocalBranchUpToDateWithRemote() -> Promise<Bool, GitError> {
        let headSHA = Git.client.getHeadSHA()

        return Git.client.getRemoteSHAAsync().onResult({ result in
            switch (headSHA, result) {
            case (.success(let headSHA), .success(let remoteSHA)):
                let isEmptyRepo = remoteSHA.isEmpty
                return .success(headSHA == remoteSHA || isEmptyRepo)
            case (.failure(let error), _):
                Swift.print("Git failure: couldn't find git SHA for HEAD.")
                return .failure(.generic(error))
            case (_, .failure(let error)):
                if SSH.canConnectToGithub() {
                    return .failure(.generic(error))
                } else {
                    return .failure(.permissionDenied)
                }
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
