//
//  CSColor.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/5/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

public struct CSColor: Equatable, CSDataSerializable {
    var id: String
    var name: String
    var value: String
    var comment: String?
    var metadata: CSData
    var color: NSColor {
        return NSColor.parse(css: value) ?? NSColor.black
    }

    var resolvedValue: String {
        return id
    }

    func toData() -> CSData {
        var data = CSData.Object([
            "id": id.toData(),
            "name": name.toData(),
            "value": value.toData()
            ])

        if let comment = comment, comment != "" {
            data["comment"] = comment.toData()
        }

        if !metadata.objectValue.isEmpty {
            data["metadata"] = metadata
        }

        return data
    }

    func toValue() -> CSValue {
        return CSValue(type: CSColor.csType, data: toData())
    }

    static var csType: CSType {
        return CSType.dictionary([
            "id": (CSType.string, CSAccess.write),
            "name": (CSType.string, CSAccess.write),
            "value": (CSType.string, CSAccess.write),
            "comment": (CSType.string.makeOptional(), CSAccess.write),
            "metadata": (CSType.any.makeOptional(), CSAccess.write)
            ])
    }

    static func fromData(_ data: CSData) -> CSColor {
        let id = data["id"]?.string ?? ""
        let name = data["name"]?.string ?? "No name"
        let value = data["value"]?.string ?? "#000000"
        let comment = data["comment"]?.string
        let metadata = data["metadata"] ?? CSData.Object([:])

        return CSColor(id: id, name: name, value: value, comment: comment, metadata: metadata)
    }
}

extension CSColor: Identify, Searchable {}
