//
//  CSColor.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/5/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

public struct CSColor {
    let id: String
    let name: String
    let color: NSColor
    let value: String
    let comment: String

    var resolvedValue: String {
        return id
    }

    func toData() -> CSData {
        return CSData.Object([
            "id": id.toData(),
            "name": name.toData(),
            "value": value.toData(),
            "comment": comment.toData()
            ])
    }

    func toValue() -> CSValue {
        return CSValue(type: CSColor.csType, data: toData())
    }

    static var csType: CSType {
        return CSType.dictionary([
            "id": (CSType.string, CSAccess.write),
            "name": (CSType.string, CSAccess.write),
            "value": (CSType.string, CSAccess.write),
            "comment": (CSType.string, CSAccess.write)
            ])
    }

    static func fromData(_ data: CSData) -> CSColor {
        let id = data["id"]?.string ?? ""
        let name = data["name"]?.string ?? "No name"
        let value = data["value"]?.string ?? "#000000"
        let comment = data["comment"]?.string ?? ""
        let nsColor = NSColor.parse(css: value) ?? NSColor.black

        return CSColor(id: id, name: name, color: nsColor, value: value, comment: comment)
    }
}

extension CSColor: Identify, Searchable {}
