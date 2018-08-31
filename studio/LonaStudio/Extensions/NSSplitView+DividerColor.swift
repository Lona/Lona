//
//  NSSplitView+DividerColor.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/30/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

extension NSSplitView {

    // To determine this, instantiate a split view and return its divider color.
    // Is there a better way?
    static var defaultDividerColor: NSColor = {
        let view = NSSplitView()
        view.dividerStyle = .thin
        return view.dividerColor
    }()
}
