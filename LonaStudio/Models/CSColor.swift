//
//  CSColor.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/5/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

struct CSColor {
    let id: String
    let name: String
    let color: NSColor
    let value: String
    
    var resolvedValue: String {
        return id
    }
}

extension CSColor: Identify, Searchable {}

