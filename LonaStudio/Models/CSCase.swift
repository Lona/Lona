//
//  CSCase.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/26/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

final class CSCaseEntry {
    var name: String
    var value: CSData
    var visible: Bool

    init(name: String, value: CSData, visible: Bool) {
        self.name = name
        self.value = value
        self.visible = visible
    }

    init(_ data: CSData) {
        name = data.get(key: "name").stringValue
        value = data.get(key: "value")
        visible = data.get(key: "visible").bool ?? true
    }

    func toData() -> CSData {
        return CSData.Object([
            "name": name.toData(),
            "value": value,
            "visible": visible.toData()
        ])
    }
}

final class CSCase: DataNodeCopying {

    enum CaseType {
        case entry(CSCaseEntry)
        case importedList(URL)

        var typeName: String {
            switch self {
            case .entry: return "entry"
            case .importedList: return "importedList"
            }
        }
    }

    var caseType: CaseType = CaseType.entry(CSCaseEntry(name: "name", value: CSData.Object([:]), visible: true))

    init() {}

    init(name: String, value: CSData = CSData.Object([:])) {
        caseType = .entry(CSCaseEntry(name: name, value: value, visible: true))
    }

    /// Use this when deserializing for use within other Lona code
    init(_ data: CSData) {
        let type = data["type"]?.string ?? "entry"

        switch type {
        case "entry":
            let name = data.get(key: "name").stringValue
            let value = data["params"] ?? data.get(key: "value")
            let visible = data.get(key: "visible").bool ?? true
            caseType = .entry(CSCaseEntry(name: name, value: value, visible: visible))
        case "importedList":
            if let url = URL(string: data.get(key: "url").stringValue) {
                caseType = .importedList(url)
            }
        default:
            break
        }
    }

    /// Use this when deserializing from disk. We must expand params into the interal format before use.
    convenience init(_ data: CSData, parametersType: CSType) {
        self.init(data)

        switch caseType {
        case .entry(let caseItem):
            caseItem.value = CSValue.expand(type: parametersType, data: caseItem.value)
        default:
            break
        }
    }

    func caseList() -> [CSCaseEntry] {
        switch caseType {
        case .entry(let caseItem):
            if caseItem.visible {
                return [caseItem]
            } else {
                return []
            }
        case .importedList(let url):
            let list = CSData.from(fileAtPath: url.path)?.array ?? []
            return list.map({ CSCaseEntry(name: $0["caseName"]?.string ?? "Artboard", value: $0, visible: true) })
        }
    }

    /// Use this when serializing for use within other Lona code
    func toData() -> CSData {
        switch caseType {
        case .entry(let caseItem):
            var data = CSData.Object([
                "name": caseItem.name.toData(),
                "params": caseItem.value
                ])

            if !caseItem.visible {
                data["visible"] = caseItem.visible.toData()
            }

            return data
        case .importedList(url: let url):
            return CSData.Object([
                "type": caseType.typeName.toData(),
                "url": url.absoluteString.toData()
            ])
        }
    }

    /// Use this when serializing in preparation for saving to disk. We store params in a compact
    /// format based on their types.
    func toData(parametersType: CSType) -> CSData {
        var data = self.toData()

        switch caseType {
        case .entry:
            data["params"] = CSValue.compact(type: parametersType, data: data.get(key: "params"))
        default:
            break
        }

        return data
    }

    func childCount() -> Int { return 0 }
    func child(at index: Int) -> Any { return 0 }

    static var defaultCase: CSCase {
        return CSCase(name: "Default")
    }
}
