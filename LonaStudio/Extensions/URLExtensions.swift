//
//  URLExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/1/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

extension URL {
    func contentsAsBase64EncodedString() -> String? {
        guard let data = try? Data(contentsOf: self) else { return nil }
        return data.base64EncodedString()
    }

    func absoluteURLForWorkspaceURL() -> URL {
        if !absoluteString.starts(with: "file://./") { return self }

        let resolved = absoluteString.replacingOccurrences(
            of: "file://./",
            with: "file://" + CSWorkspacePreferences.workspaceURL.path + "/")

        return URL(string: resolved) ?? self
    }
}
