//
//  CALayerExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/12/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

extension CALayer {

    func addBorder(to edge: NSRectEdge, color: CGColor, thickness: CGFloat) {

        let border = CALayer()

        switch edge {
        case NSRectEdge.minY: border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case NSRectEdge.maxY: border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case NSRectEdge.minX: border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case NSRectEdge.maxX: border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        }

        border.backgroundColor = color

        self.addSublayer(border)
    }
}
