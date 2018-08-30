//
//  Color+Conversions.swift
//  LonaStudio
//
//  Created by Devin Abbott on 8/30/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Colors
import Foundation

extension Color {
    var rgbaString: String {
        let r = Int(rgb.red * 255)
        let g = Int(rgb.green * 255)
        let b = Int(rgb.blue * 255)
        let a = round(alpha * 100) / 100
        return "rgba(\(r),\(g),\(b),\(a))"
    }

    init(cssString: String) {
        let cssColor = parseCSSColor(cssString) ?? CSSColor(0, 0, 0, 0)
        var colorValue = Color(redInt: cssColor.r, greenInt: cssColor.g, blueInt: cssColor.b)
        colorValue.alpha = Float(cssColor.a)
        self = colorValue
    }

    func isApproximatelyEqual(to cssString: String) -> Bool {
        return rgbaString == Color(cssString: cssString).rgbaString
    }

    func isApproximatelyEqual(to color: Color) -> Bool {
        return rgbaString == color.rgbaString
    }
}
