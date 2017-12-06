//
//  NSShadowExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 11/15/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

extension NSShadow {
    convenience init(color: NSColor, offset: NSSize, blur: CGFloat) {
        self.init()
        
        shadowColor = color
        shadowOffset = offset
        shadowBlurRadius = blur
    }
}
