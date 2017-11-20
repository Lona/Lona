//
//  CSParameter.swift
//  ComponentStudio
//
//  Created by devin_abbott on 6/26/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import SwiftyJSON

final class CSParameter: JSONDeserializable, JSONSerializable, DataNode {
    var name: String = "parameter"
    var type: CSType = CSType.string
    var defaultValue: CSValue = CSUndefinedValue
    
    var hasDefaultValue: Bool {
        return defaultValue != CSUndefinedValue
    }
    
    var initialValue: CSValue {
        return CSValue.exampleValue(for: type)
    }
    
    init() {}
    
    init(_ json: JSON) {
        name = json["name"].stringValue
        type = CSType.from(string: json["type"].stringValue)
        
        if json["defaultValue"].dictionary != nil {
            defaultValue = CSValue(CSData.from(json: json["defaultValue"]))
        }
    }
    
    init(name: String, type: CSType) {
        self.name = name
        self.type = type
    }
    
    func toJSON() -> Any? {
        var data: [String: Any?] = [
            "name": name,
            "type": type.toString(),
        ]
        
        if defaultValue != CSUndefinedValue {
            data["defaultValue"] = defaultValue.toData().toAny()
        }
        
        return data
    }
    
    func childCount() -> Int { return 0 }
    func child(at index: Int) -> Any { return 0 }
}
