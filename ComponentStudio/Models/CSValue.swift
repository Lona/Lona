//
//  CSValue.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/5/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

struct CSValue: Equatable, CSDataSerializable, CSDataDeserializable {
    var type: CSType
    var data: CSData
    
    init(_ data: CSData) {
        self.type = CSType(data.get(key: "type"))
        self.data = data.get(key: "data")
    }
    
    init(type: CSType, data: CSData) {
        self.type = type
        self.data = data
    }
    
    func cast(to type: CSType) -> CSValue {
        // TODO make sure we return a copy
        if self.type == type { return self }
        
        switch type {
        case .bool: return CSValue(type: type, data: .Bool(false))
        case .number: return CSValue(type: type, data: .Number(0))
        case .string: return CSValue(type: type, data: .String(""))
        case .named("Color", .string): return CSValue(type: type, data: .String("black"))
        default: return CSValue(type: type, data: .Null)
        }
    }
    
    func toData() -> CSData {
        return CSData.Object([
            "type": type.toData(),
            "data": data,
        ])
    }
    
    func unwrappedNamedType() -> CSValue {
        return CSValue(type: type.unwrappedNamedType(), data: data)
    }
    
    static func ==(lhs: CSValue, rhs: CSValue) -> Bool {
        return lhs.type == rhs.type && lhs.data == rhs.data
    }
    
    static func exampleValue(for type: CSType) -> CSValue {
        switch type {
        case .bool: return CSValue(type: type, data: .Bool(false))
        case .number: return CSValue(type: type, data: .Number(0))
        case .string: return CSValue(type: type, data: .String("Text"))
        case .named("Color", .string): return CSValue(type: type, data: .String("black"))
        default:
            return CSValue(type: CSAnyType, data: CSData.Null)
        }
    }
    
    func filteredData(typed typeFilter: CSType, accessed accessFilter: CSAccess) -> CSData {
        guard case CSType.dictionary(let schema) = self.type else { return CSData.Object([:]) }
        
        return self.data.objectValue.reduce(CSData.Object([:])) { (result, item) -> CSData in
            var result = result
            
//            Swift.print("filter", item.key)
            
            if let schemaItem = schema[item.key] /*, schemaItem.access == accessFilter */ {
                if item.value.object != nil {
                    let value = CSValue(type: schemaItem.type, data: item.value)
//                    Swift.print("Matching sub object", item.key)
                    let sub = value.filteredData(typed: typeFilter, accessed: accessFilter)
//                    if sub.objectValue.count > 0 {
                    result[item.key] = sub
//                    }
                        
                    return result
                }
                
                if typeFilter.isGeneric || typeFilter == schemaItem.type {
//                    Swift.print("Filter matched", item.key, item.value)
                    result[item.key] = item.value
                }
            }
            
            return result
        }
    }
}

let CSUndefinedValue = CSValue(type: .undefined, data: CSData.Null)
let CSEmptyDictionaryValue = CSValue(type: .dictionary(CSType.Schema()), data: CSData.Object([:]))
