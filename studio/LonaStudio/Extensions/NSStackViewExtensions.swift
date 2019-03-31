// https://gist.github.com/martinhoeller/7a1d41e3744f4191d3b3f38868be5190

//
//  NSStackView+Animations.swift
//
//  Created by Martin Höller on 18.06.16.
//  Copyright © 2016 blue banana software. All rights reserved.
//
//  Based on http://prod.lists.apple.com/archives/cocoa-dev/2015/Jan/msg00314.html

import Cocoa

extension NSStackView {

    func hideViews(views: [NSView], animated: Bool) {
        views.forEach { view in
            view.isHidden = true
            view.wantsLayer = true
            view.layer!.opacity = 0.0
        }

        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
                self.window?.layoutIfNeeded()
            }, completionHandler: nil)
        }
    }

    func showViews(views: [NSView], animated: Bool) {
        views.forEach { view in
            // unhide the view so the stack view knows how to layout…
            view.isHidden = false

            if animated {
                view.wantsLayer = true
                // …but set opacity to 0 so the view is not visible during the animation
                view.layer!.opacity = 0.0
            }
        }

        if animated {
            views.forEach { view in view.layoutSubtreeIfNeeded() }

            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.allowsImplicitAnimation = true
//                views.forEach { view in
//                    view.layer!.opacity = 1.0
//                }
                self.window?.layoutIfNeeded()
            }, completionHandler: {
                views.forEach { view in
                    view.layer!.opacity = 1.0
                }
            })
        }
    }

    convenience init(views: [NSView], orientation: NSUserInterfaceLayoutOrientation, stretched: Bool = false) {
        self.init()

        self.orientation = orientation

        for view in views { addArrangedSubview(view, stretched: stretched) }
    }

    func addArrangedSubview(_ view: NSView, stretched: Bool) {
        addArrangedSubview(view)

        if stretched {
            switch orientation {
            case .horizontal:
                view.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
            case .vertical:
                view.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            @unknown default:
                print("unknown orientation")
            }
        }
    }
}
