//
//  NSTextFieldExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/17/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

extension NSTextField {
    convenience init(labelWithStringCompat value: String) {
        if #available(OSX 10.12, *) {
            self.init(labelWithString: value)
        } else {
            self.init()
        }
    }
}

