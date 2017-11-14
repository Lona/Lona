//
//  NSViewControllerExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 11/13/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

extension NSViewController {
    convenience init(view: NSView) {
        self.init()
        
        self.view = view
    }
}
