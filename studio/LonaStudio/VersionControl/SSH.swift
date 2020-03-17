//
//  SSH.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/16/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import Foundation

public enum SSHError: Error {
    case keyscan(ProcessError)
    case fingerprint(ProcessError)
    case process(ProcessError)
    case invalidFingerprint
    case writingToKnownHosts
    case createKey(ProcessError)
    case failedToReadDirectory
    case failedToReadFile
    case localKeyMissing
}

public enum SSH {
    public static func keyscan(host: String) -> Result<Data, ProcessError> {
        return Process.runSync(
            .init(
                launchPath: "/usr/bin/ssh-keyscan",
                arguments: ["-t", "rsa", host]
            )
        )
    }

    public static func fingerprint(key: Data) -> Result<Data, ProcessError> {
        return Process.runSync(
            .init(
                launchPath: "/usr/bin/ssh-keygen",
                arguments: ["-lf", "-"]
            ),
            inputData: key
        )
    }

    public static func addToKnownHosts(key: Data) -> Result<Void, SSHError> {
        let knownHostsFileURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".ssh")
            .appendingPathComponent("known_hosts")

        if FileManager.default.fileExists(atPath: knownHostsFileURL.path) {
            // If the host is already in the file, we can stop
            if let fileString = try? Data(contentsOf: knownHostsFileURL).utf8String(),
                let keyString = key.utf8String(),
                fileString.contains(keyString.trimmingCharacters(in: .whitespacesAndNewlines)) {
                return .success(())
            }

            // Append the host to the file
            if let fileHandle = FileHandle(forWritingAtPath: knownHostsFileURL.path) {
                defer { fileHandle.closeFile() }
                fileHandle.seekToEndOfFile()
                fileHandle.write(key)
                return .success(())
            } else {
                return .failure(.writingToKnownHosts)
            }
        } else {
            // Create a new known_hosts file
            if FileManager.default.createFile(
                atPath: knownHostsFileURL.path,
                contents: key,
                attributes: [.posixPermissions: 0o644]) {
                return .success(())
            } else {
                return .failure(.writingToKnownHosts)
            }
        }
    }

    public static func validateGithubKeyAndAddToHosts() -> Result<Void, SSHError> {
        return keyscan(host: "github.com")
            .mapError({ SSHError.keyscan($0) })
            .flatMap({ key in
                switch fingerprint(key: key).mapError({ SSHError.fingerprint($0) }) {
                case .success(let value):
                    if value.utf8String() == githubRSAFingerprint {
                        return addToKnownHosts(key: key)
                    }
                    return .failure(.invalidFingerprint)
                case .failure(let error):
                    return .failure(error)
                }
            })
    }

    public static func createLocalKey() -> Result<String, SSHError> {
        let keyPath = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".ssh").appendingPathComponent("id_rsa").path

        let result = Process.runSync(
            Process.Configuration(
                launchPath: "/usr/bin/ssh-keygen",
                arguments: ["-t", "rsa", "-N", "", "-f", keyPath],
                currentDirectoryPath: FileManager.default.homeDirectoryForCurrentUser.path
            )
        )

        switch result {
        case .success:
            Swift.print("Created local SSH key")
            switch localKey() {
            case .success(nil):
                return .failure(.localKeyMissing)
            case .success(.some(let key)):
                return .success(key)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            Swift.print("Failed to create local SSH key")
            return .failure(.createKey(error))
        }
    }

    public static func localKey() -> Result<String?, SSHError> {
        let files: [String]

        let sshDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".ssh")

        do {
            try files = FileManager.default.contentsOfDirectory(atPath: sshDirectory.path)
        } catch {
            return .failure(.failedToReadDirectory)
        }

        guard let publicKeyFile = files.filter({ $0.hasSuffix(".pub") }).first else {
            return .success(nil)
        }

        guard let publicKey = FileManager.default.contents(atPath: sshDirectory.appendingPathComponent(publicKeyFile).path)?.utf8String() else {
            return .failure(.failedToReadFile)
        }

        return .success(publicKey.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    public static func canConnectToGithub() -> Bool {
        // We make an _unsafe_ request to GitHub, but this is OK, since we don't actually do anything beyond
        // check that we can access it. We don't want to add to the hosts file here, because we should only
        // do that from a user-initiated SSH flow.
        let result = Process.runSync(
            Process.Configuration(
                launchPath: "/usr/bin/ssh",
                arguments: ["-T", "-o", "StrictHostKeyChecking=no", "-o", "UserKnownHostsFile=/dev/null", "git@github.com"],
                currentDirectoryPath: FileManager.default.homeDirectoryForCurrentUser.path
            )
        )

        switch result {
        // This is success. GitHub said "Hi" on stderr.
        case .failure(let error) where error.code == 1:
            return true
        case .failure:
            return false
        // As far as I can tell, this command always returns an exit code > 0, so `success` never happens
        case .success:
            return false
        }
    }

    public static var githubRSAFingerprint = "2048 SHA256:nThbg6kXUpJWGl7E1IGOCspRomTxdCARLviKw6E5SY8 github.com (RSA)\n"
}
