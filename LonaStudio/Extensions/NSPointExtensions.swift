//
//  NSPointExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/2/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

extension NSPoint {

    // Vector & Vector

    static func + (left: NSPoint, right: NSPoint) -> NSPoint {
        return NSPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func - (left: NSPoint, right: NSPoint) -> NSPoint {
        return NSPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static func * (left: NSPoint, right: NSPoint) -> NSPoint {
        return NSPoint(x: left.x * right.x, y: left.y * right.y)
    }

    static func / (left: NSPoint, right: NSPoint) -> NSPoint {
        return NSPoint(x: left.x / right.x, y: left.y / right.y)
    }

    // Vector & Scalar

    static func + (left: NSPoint, right: CGFloat) -> NSPoint {
        return NSPoint(x: left.x + right, y: left.y + right)
    }

    static func - (left: NSPoint, right: CGFloat) -> NSPoint {
        return NSPoint(x: left.x - right, y: left.y - right)
    }

    static func * (left: NSPoint, right: CGFloat) -> NSPoint {
        return NSPoint(x: left.x * right, y: left.y * right)
    }

    static func / (left: NSPoint, right: CGFloat) -> NSPoint {
        return NSPoint(x: left.x / right, y: left.y / right)
    }
}
