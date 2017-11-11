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
        case .named(_):
            var value = cast(to: type.unwrappedNamedType())
            value.type = type
            return value
        case .array(_): return CSValue(type: type, data: .Array([]))
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
        guard case CSType.dictionary(let schema) = self.type else {
            if typeFilter.isGeneric || self.type == typeFilter {
                return self.data
            } else {
                return CSData.Null
            }
        }
        
        return self.data.objectValue.reduce(CSData.Object([:])) { (result, item) -> CSData in
            var result = result
            
//            Swift.print("filter", item.key)
            
            if let schemaItem = schema[item.key] /*, schemaItem.access == accessFilter */ {
                if item.value.object != nil {
                    let value = CSValue(type: schemaItem.type, data: item.value)
                    let sub = value.filteredData(typed: typeFilter, accessed: accessFilter)

                    // TODO: Don't show sub if it's an object with no matching items
                    result[item.key] = sub
                } else if
                    case CSType.array(let innerTypeFilter) = typeFilter.unwrappedNamedType(),
                    case CSType.array(let innerSchemaType) = schemaItem.type.unwrappedNamedType(),
                    // TODO: In the append case, the type should no longer be generic here.
                    innerTypeFilter.isGeneric || innerTypeFilter == CSType.any || innerTypeFilter == innerSchemaType
                {
                    result[item.key] = item.value
                } else if typeFilter.isGeneric || typeFilter == CSType.any || typeFilter == schemaItem.type {
                    result[item.key] = item.value
                }
            }
            
            return result
        }
    }
}

let CSUndefinedValue = CSValue(type: .undefined, data: CSData.Null)
let CSEmptyDictionaryValue = CSValue(type: .dictionary(CSType.Schema()), data: CSData.Object([:]))
