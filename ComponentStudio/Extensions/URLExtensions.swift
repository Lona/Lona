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
}
