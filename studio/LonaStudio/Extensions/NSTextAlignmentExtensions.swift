//
//  NSTextAlignmentExtensions.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/14/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

extension NSTextAlignment {
    init(_ string: String) {
        switch string {
        case "left":
            self = NSTextAlignment.left
        case "center":
            self = NSTextAlignment.center
        case "right":
            self = NSTextAlignment.right
        default:
            self = NSTextAlignment.left
        }
    }
}
