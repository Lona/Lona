//
//  CSGradients.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

struct CSGradient {
    let id: String?
    let name: String
    let colors: [CGColor]
    let locations: [NSNumber]
    
    var caGradientLayer: CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.locations = locations
        return gradientLayer
    }
}

class CSGradients: CSPreferencesFile {
    static var url: URL {
        return CSWorkspacePreferences.workspaceURL.appendingPathComponent("gradients.json")
    }
    
    static private var parsedGradients: [CSGradient] = parse(data)
    static var gradients: [CSGradient] { return parsedGradients }
    
    static var data: CSData = load() {
        didSet { parsedGradients = parse(data) }
    }
    
    private static func parse(_ data: CSData) -> [CSGradient] {
        guard let colorData = data["gradients"] else { return [] }
        
        return colorData.arrayValue.map({ gradient in
            let id = gradient["id"]?.string
            let name = gradient["name"]?.string ?? "No name"
            
            let pairs: [(CGColor, NSNumber)] = (gradient["colorStops"] ?? CSData.Null).arrayValue.map({ colorStop in
                let location = colorStop["position"]?.number ?? 0
                let colorString = colorStop["color"]?.string ?? "transparent"
                let color = CSColors.parse(css: colorString, withDefault: NSColor.clear)
                return (color.color.cgColor, NSNumber(value: location))
            })
            
            let locations = pairs.map({ $0.1 })
            let colors = pairs.map({ $0.0 })
            
            return CSGradient(id: id, name: name, colors: colors, locations: locations)
        })
    }
    
    static func gradient(withId id: String) -> CSGradient? {
        return gradients.first(where: { $0.id == id })
    }
}

