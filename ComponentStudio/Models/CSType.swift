//
//  CSType.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/5/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

indirect enum CSType: Equatable, CSDataSerializable, CSDataDeserializable {
    typealias SchemaRecord = (type: CSType, access: CSAccess)
    typealias Schema = [String: SchemaRecord]
    
    case any
    case optional(CSType)
    case named(String, CSType) // TODO should we have a CSNamedType?
    case generic(String, CSType)
    case undefined
    case null
    case bool
    case number
    case string
    case array(CSType)
    case dictionary(Schema)
    case enumeration([CSValue])
    
    init(_ data: CSData) {
        self = .undefined
        
        if let string = data.string {
            if let builtin = CSType.builtInTypes[string] {
                self = builtin
                return
            }
            
            if let type = CSType.userType(named: string) {
                self = type
                return
            }
            
            switch string {
            case "Null": self = .null
            case "Number": self = .number
            case "Boolean": self = .bool
            case "String": self = .string
            default: self = .undefined
            }
        } else if let object = data.object {
            if let type = object["type"] {
                if let named = object["named"] {
                    self = .named(named.stringValue, CSType(type))
                } else if type.stringValue == "Enumeration", let values = object["values"]?.array {
                    self = .enumeration(values.map({ CSValue($0) }))
                }
            }
        }
    }
    
    func typeAt(keyPath: [String]) -> CSType? {
        if keyPath.count == 0 { return self }
        guard case CSType.dictionary(let schema) = self else { return nil }
        guard let item = schema[keyPath[0]] else { return nil }
        return item.type.typeAt(keyPath: Array(keyPath[1..<keyPath.count]))
    }
    
    var genericId: String? {
        guard case CSType.generic(let id, _) = self else { return nil }
        return id
    }
    
    var isGeneric: Bool { return genericId != nil }
    
    func unwrappedNamedType() -> CSType {
        switch self {
        case .named(_, let type):
            return type
        default:
            return self
        }
    }
    
    func toString() -> String {
        switch self {
        case .bool: return "Boolean"
        case .number: return "Number"
        case .string: return "String"
        case .named(let name, _): return name
        default: return "Any"
        }
    }
    
    // TODO Params on
    // optional, generic, array, dictionary
    func toData() -> CSData {
        switch self {
        case .any: return .String("Any")
        case .optional(_): return .String("Optional")
        case .named(let name, let type):
            if let found = CSType.userType(named: name) { return .String(name) }
            
            return .Object([
                "named": .String(name),
                "type": type.toData(),
            ])
        case .generic(_, _): return .String("Generic")
        case .undefined: return .String("Undefined")
        case .null: return .String("Null")
        case .bool: return .String("Boolean")
        case .number: return .String("Number")
        case .string: return .String("String")
        case .array(_): return .String("Array")
        case .dictionary(_): return .String("Dictionary")
        case .enumeration(let values):
            if let match = CSType.builtInTypes.enumerated().first(where: { (arg) -> Bool in
                let (_, item) = arg
                return item.value == self
            }) {
                return .String(match.element.key)
            }
            
            return CSData.Object([
                "type": "Enumeration".toData(),
                "values": CSData.Array(values.map({ $0.toData() })),
            ])
        }
    }
    
    static func userType(named typeName: String) -> CSType? {
        for userType in CSUserTypes.types {
            if case CSType.named(let name, _) = userType, name == typeName {
                return userType
            }
        }
        
        return nil
    }
    
    static func from(string: String) -> CSType {
        if let builtin = builtInTypes[string] { return builtin }
        if let type = userType(named: string) { return type }
        
        switch string {
        case "Boolean": return .bool
        case "Number": return .number
        case "String": return .string
        default: return .any
        }
    }
    
    static func ==(lhs: CSType, rhs: CSType) -> Bool {
        switch (lhs, rhs) {
        case (.any, .any): return true
        case (.optional(let l), .optional(let r)): return l == r
        case (.named(let ln, let l), .named(let rn, let r)): return ln == rn && l == r
        case (.undefined, .undefined): return true
        case (.null, .null): return true
        case (.bool, .bool): return true
        case (.number, .number): return true
        case (.string, .string): return true
        case (.array(let l), .array(let r)): return l == r
        case (.dictionary(let l), .dictionary(let r)):
            // TODO does this work?
            return NSDictionary(dictionary: l).isEqual(to: r)
        case (.enumeration(let l), .enumeration(let r)):
            for pair in zip(l, r) {
                if pair.0 != pair.1 {
                    return false
                }
            }
            
            return true
        default:
            return false
        }
    }

    func merge(_ additional: CSType) -> CSType {
        guard case CSType.dictionary(let originalSchema) = self else { return self }
        guard case CSType.dictionary(let additionalSchema) = additional else { return self }
        
        var merged: Schema = [:]
        
        originalSchema.forEach({ (key, value) in
            merged[key] = value
        })
        
        additionalSchema.forEach({ (key, value) in
            merged[key] = value
        })
        
        return CSType.dictionary(merged)
    }
    
    func merge(key name: String, type: CSType, access: CSAccess) -> CSType {
        let record: CSType.SchemaRecord = (type: type, access: access)
        let additional = CSType.dictionary([name: record])
        return merge(additional)
    }
    
    static func parameterType() -> CSType {
        // TODO caching
        let values: [CSValue] = [
            CSValue(type: .string, data: .String("Boolean")),
            CSValue(type: .string, data: .String("Number")),
            CSValue(type: .string, data: .String("String")),
            CSValue(type: .string, data: .String("Color")),
            CSValue(type: .string, data: .String("TextStyle")),
            CSValue(type: .string, data: .String("URL")),
            ] + CSUserTypes.types.map({ CSValue(type: .string, data: $0.toString().toData()) })

        return CSType.enumeration(values)
    }
    
    static var builtInTypes: [String: CSType] = [
        "Color": CSColorType,
        "TextStyle": CSTextStyleType,
        "Comparator": CSComparatorType,
        "URL": CSURLType,
        ]
}

let CSAnyType = CSType.any
let CSGenericTypeA = CSType.generic("a'", CSType.any)
let CSColorType = CSType.named("Color", .string)
let CSTextStyleType = CSType.named("TextStyle", .string)
let CSURLType = CSType.named("URL", .string)

//let CSParameterType = CSType.enumeration([
//    CSValue(type: .string, data: .String("Boolean")),
//    CSValue(type: .string, data: .String("Number")),
//    CSValue(type: .string, data: .String("String")),
//    CSValue(type: .string, data: .String("Color")),
//    CSValue(type: .string, data: .String("TextStyle")),
//    CSValue(type: .string, data: .String("URL")),
//])

let CSComparatorType = CSType.enumeration([
    CSValue(type: .string, data: .String("equal to")),
    CSValue(type: .string, data: .String("not equal to")),
    CSValue(type: .string, data: .String("greater than")),
    CSValue(type: .string, data: .String("greater than or equal to")),
    CSValue(type: .string, data: .String("less than")),
    CSValue(type: .string, data: .String("less than or equal to")),
])

let CSLayerType = CSType.dictionary([
//    "name": (type: .string, access: .read),
    "visible": (type: .bool, access: .write),
    
    // Box Model
    "height": (type: .number, access: .write),
    "width": (type: .number, access: .write),
    "marginTop": (type: .number, access: .write),
    "marginRight": (type: .number, access: .write),
    "marginBottom": (type: .number, access: .write),
    "marginLeft": (type: .number, access: .write),
    "paddingTop": (type: .number, access: .write),
    "paddingRight": (type: .number, access: .write),
    "paddingBottom": (type: .number, access: .write),
    "paddingLeft": (type: .number, access: .write),
    
    // Color
    "backgroundColor": (type: CSColorType, access: .write),
    
    // Text
    "text": (type: .string, access: .write),
    "textStyle": (type: CSTextStyleType, access: .write),
    
    // Image
    "image": (type: CSURLType, access: .write),
])









