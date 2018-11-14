//
//  CSRendering.swift
//  LonaStudio
//
//  Created by Devin Abbott on 11/14/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit

protocol CSRendering where Self: NSView {
    var csViewAncestors: [CSView] { get }
    var multipliedAlpha: CGFloat { get }
}

extension CSRendering {
    var csViewAncestors: [CSView] {
        var views: [CSView] = []
        var currentView: NSView? = self

        while currentView != nil {
            if let currentView = currentView as? CSView {
                views.append(currentView)
            }

            currentView = currentView?.superview
        }

        return views
    }

    var multipliedAlpha: CGFloat {
        return csViewAncestors.reduce(1) { acc, view in
            return acc * view.opacity
        }
    }
}
