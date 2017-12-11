//
//  CSShadow.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

struct CSShadow {
    let id: String
    let name: String
    let color: NSColor
    let x: CGFloat
    let y: CGFloat
    let blur: CGFloat
    
    var nsShadow: NSShadow {
        return NSShadow(color: color, offset: CGSize(width: x, height: y), blur: blur)
    }
    
    func attributeDictionary() -> [String: Any] {
        return [NSShadowAttributeName: nsShadow]
    }
}

class CSShadows: CSPreferencesFile {
    static var url: URL {
        return CSWorkspacePreferences.workspaceURL.appendingPathComponent("shadows.json")
    }
    
    static private var parsedShadows: [CSShadow] = parse(data)
    static private var defaultShadowName: String?
    static var shadows: [CSShadow] { return parsedShadows }
    
    static var data: CSData = load() {
        didSet { parsedShadows = parse(data) }
    }
    
    private static func parse(_ data: CSData) -> [CSShadow] {
        guard let colorData = data["shadows"] else { return [] }
        defaultShadowName = data["defaultShadowName"]?.string
        
        return colorData.arrayValue.map({ shadow in
            let id = shadow["id"]!.string!
            let name = shadow["name"]?.string ?? "No name"
            let colorString = shadow["color"]?.string ?? "black"
            let color = CSColors.parse(css: colorString, withDefault: NSColor.black)
            let x = shadow["x"]?.number ?? 0
            let y = shadow["y"]?.number ?? 0
            let blur = shadow["blur"]?.number ?? 0
            
            return CSShadow(id: id, name: name, color: color.color, x: CGFloat(x), y: CGFloat(y), blur: CGFloat(blur))
        })
    }
    
    static func shadow(with id: String) -> CSShadow {
        return shadows.first(where: { $0.id == id }) ?? defaultShadow
    }
    
    public static var defaultName: String {
        return defaultShadowName ?? unstyledDefaultName
    }
    
    public static var defaultShadow: CSShadow {
        if let defaultShadowName = defaultShadowName {
            let shadow = self.shadow(with: defaultShadowName)
            return shadow
        }
        return unstyledDefaultShadow
    }
    
    public static let unstyledDefaultName = "none"
    
    public static var unstyledDefaultShadow: CSShadow {
        return CSShadow(id: "none", name: "Default", color: NSColor.clear, x: 0, y: 0, blur: 0)
    }
}

