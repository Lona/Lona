//
//  FlippedScrollView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 2/26/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import AppKit

/// A drop-in replacement for `NSScrollView` that arranges its contents starting from the top instead of the bottom.
class FlippedScrollView: NSScrollView {

    private var flippedView = FlippedView()

    override var documentView: NSView? {
        get {
            return flippedView.subviews.first
        }
        set {
            if super.documentView != flippedView {
                super.documentView = flippedView
            }

            if newValue != super.documentView {
                newValue?.removeFromSuperview()

                if let newValue = newValue {
                    flippedView.translatesAutoresizingMaskIntoConstraints = false

                    flippedView.addSubview(newValue)

                    flippedView.topAnchor.constraint(equalTo: newValue.topAnchor).isActive = true
                    flippedView.leadingAnchor.constraint(equalTo: newValue.leadingAnchor).isActive = true
                    flippedView.trailingAnchor.constraint(equalTo: newValue.trailingAnchor).isActive = true
                    flippedView.bottomAnchor.constraint(equalTo: newValue.bottomAnchor).isActive = true
                }
            }
        }
    }
}
