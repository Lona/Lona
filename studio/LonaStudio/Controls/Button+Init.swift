//
//  Button.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

extension Button {

    // For backwards compatability with earlier code. Remove eventually
    override convenience init(frame: NSRect) {
        self.init(titleText: "")

        self.frame = frame
        translatesAutoresizingMaskIntoConstraints = true
    }

    // Currently the button's `onPress` is conflicting with Lona's built-in `onPress`.
    // This workaround lets us use the name `onClick` within Lona studio instead.
    //
    // TODO: An `onPress` on a custom component should not be handled specially?
    // We shouldn't generate hover/press handling code for custom components?
    public var onClick: (() -> Void)? {
        get { return onPress }
        set { onPress = newValue }
    }
}
