//
//  NSPopoverExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 11/13/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

extension NSPopover {
    convenience init(
        contentViewController: NSViewController,
        delegate: NSPopoverDelegate,
        behavior: NSPopoverBehavior = NSPopoverBehavior.semitransient,
        animates: Bool = false
    ) {
        self.init()
        
        self.contentViewController = contentViewController
        self.delegate = delegate
        self.behavior = behavior
        self.animates = animates
    }
}
