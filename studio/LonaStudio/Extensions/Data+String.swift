//
//  Data+String.swift
//  LonaStudio
//
//  Created by Devin Abbott on 10/19/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation

extension Data {
    func utf8String() -> String? {
        guard let string = NSString(data: self, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return string as String
    }
}
