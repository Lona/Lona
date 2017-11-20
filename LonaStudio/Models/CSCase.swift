//
//  CSCase.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/26/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import SwiftyJSON

final class CSCaseEntry: CSDataSerializable, CSDataDeserializable {
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
        // If the file is missing this key, show the cases anyway
        visible = data.get(key: "visible").bool ?? true
    }
    
    func toData() -> CSData {
        return CSData.Object([
            "name": name.toData(),
            "value": value,
            "visible": visible.toData(),
        ])
    }
}

final class CSCase: DataNodeCopying {
    
    enum CaseType {
        case entry(CSCaseEntry)
        case importedList(URL)
        
        var typeName: String {
            switch self {
            case .entry(_): return "entry"
            case .importedList(_): return "importedList"
            }
        }
    }
    
    var caseType: CaseType = CaseType.entry(CSCaseEntry(name: "name", value: CSData.Object([:]), visible: true))
    
    init() {}
    
    init(name: String, value: CSData = CSData.Object([:])) {
        caseType = .entry(CSCaseEntry(name: name, value: value, visible: true))
    }
    
    init(_ data: CSData) {
        let type = data["type"]?.string ?? "entry"
        
        switch type {
        case "entry":
            let name = data.get(key: "name").stringValue
            let value = data.get(key: "value")
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
    
    func toData() -> CSData {
        switch caseType {
        case .entry(let caseItem):
            return CSData.Object([
                "type": caseType.typeName.toData(),
                "name": caseItem.name.toData(),
                "value": caseItem.value,
                "visible": caseItem.visible.toData(),
            ])
        case .importedList(url: let url):
            return CSData.Object([
                "type": caseType.typeName.toData(),
                "url": url.absoluteString.toData(),
            ])
        }
    }
    
    func childCount() -> Int { return 0 }
    func child(at index: Int) -> Any { return 0 }
    
    static var defaultCase: CSCase {
        return CSCase(name: "Default")
    }
}

