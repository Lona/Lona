//
//  ConstraintFrame.swift
//  ComponentStudio
//
//  Created by devin_abbott on 11/13/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

enum CSConstraint {
    case width(CGFloat)
    case widthEqualTo(NSView)
    case height(CGFloat)
    case heightEqualTo(NSView)
    case topEqualTo(NSView)
    case bottomEqualTo(NSView)
    case leftEqualTo(NSView)
    case rightEqualTo(NSView)
    
    static func apply(_ constraints: [CSConstraint], to view: NSView) {
        for constraint in constraints {
            switch constraint {
            case .width(let value):
                view.widthAnchor.constraint(equalToConstant: value).isActive = true
            case .widthEqualTo(let other):
                view.widthAnchor.constraint(equalTo: other.widthAnchor).isActive = true
            case .height(let value):
                view.heightAnchor.constraint(equalToConstant: value).isActive = true
            case .heightEqualTo(let other):
                view.heightAnchor.constraint(equalTo: other.heightAnchor).isActive = true
            case .topEqualTo(let other):
                view.topAnchor.constraint(equalTo: other.topAnchor).isActive = true
            case .bottomEqualTo(let other):
                view.bottomAnchor.constraint(equalTo: other.bottomAnchor).isActive = true
            case .leftEqualTo(let other):
                view.leftAnchor.constraint(equalTo: other.leftAnchor).isActive = true
            case .rightEqualTo(let other):
                view.rightAnchor.constraint(equalTo: other.rightAnchor).isActive = true
            }
        }
    }
    
    static func fill(view: NSView) -> [CSConstraint] {
        return [
            CSConstraint.topEqualTo(view),
            CSConstraint.rightEqualTo(view),
            CSConstraint.bottomEqualTo(view),
            CSConstraint.leftEqualTo(view),
        ]
    }
    
    static func size(width: CGFloat, height: CGFloat) -> [CSConstraint] {
        return [
            CSConstraint.width(width),
            CSConstraint.height(height),
        ]
    }
}

