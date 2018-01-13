//
//  NSColorExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 7/31/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

extension NSColor {
    var contrastingLabelColor: NSColor {
        guard let rgbColor = usingColorSpace(.genericRGB) else { return NSColor.black }
        let average = (rgbColor.redComponent + rgbColor.greenComponent + rgbColor.blueComponent) / 3//
        return (average >= 0.5) ? NSColor.black : NSColor.white
    }
    
    var hexString: String {
        guard let rgbColor = usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
            return "#FFFFFF"
        }
        let red = Int(round(rgbColor.redComponent * 0xFF))
        let green = Int(round(rgbColor.greenComponent * 0xFF))
        let blue = Int(round(rgbColor.blueComponent * 0xFF))
        let hexString = NSString(format: "#%02X%02X%02X", red, green, blue)
        return hexString as String
    }
    
    var rgbaString: String {
        guard let rgbColor = usingColorSpaceName(NSColorSpaceName.calibratedRGB) else {
            return "rgba(255,255,255,1)"
        }
        let red = Int(round(rgbColor.redComponent * 255))
        let green = Int(round(rgbColor.greenComponent * 255))
        let blue = Int(round(rgbColor.blueComponent * 255))
        let rgbaString = NSString(format: "rgba(%d,%d,%d,%f)", red, green, blue, alphaComponent)
        return rgbaString as String
    }
    
    var colorValue: CSValue {
        return CSValue(type: CSColorType, data: CSData.String(rgbaString))
    }
}
