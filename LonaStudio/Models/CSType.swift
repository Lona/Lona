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
    case named(String, CSType) // TODO should we have a CSNamedType?
    case generic(String, CSType)
    case undefined
    case unit
    case null
    case bool
    case number
    case string
    case array(CSType)
    case dictionary(Schema)
    case enumeration([CSValue])
    case function([(String, CSType)], CSType)
    case variant([(String, CSType)])

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
            case "Unit": self = .unit
            case "Undefined": self = .undefined
            default: self = .undefined
            }
        } else if let object = data.object {
            if let name = object["name"]?.string {
                switch name {
                case "Named":
                    if let alias = object["alias"]?.string, let of = object["of"] {
                        self = .named(alias, CSType(of))
                    }
                case "Array":
                    if let innerType = object["of"] {
                        self = .array(CSType(innerType))
                    }
                case "Record":
                    if let fields = object["fields"]?.object {
                        let schema: Schema = Schema(
                            fields.map({ (arg) in
                                let key = arg.key
                                let valueType = CSType(arg.value)
                                return (key, (valueType, CSAccess.write))
                            })
                        )
                        self = .dictionary(schema)
                    } else if let fields = object["fields"]?.array {
                        let schema: Schema = Schema(
                            fields.map({ (arg) in
                                let key = arg.get(key: "key").stringValue
                                let valueType = CSType(arg.get(key: "type"))
                                return (key, (valueType, CSAccess.write))
                            })
                        )
                        self = .dictionary(schema)
                    }
                case "Enumeration":
                    if let values = object["of"]?.array {
                        self = .enumeration(values.map({ CSValue($0) }))
                    }
                case "Function":
                    var parameters: [(String, CSType)] = []
                    var returnType: CSType = .undefined
                    if let values = object["parameters"]?.array {
                        parameters = values.map({ (arg) in
                            return (arg.get(key: "label").stringValue, CSType(arg.get(key: "type")))
                        })
                    }
                    if let value = object["returnType"] {
                        returnType = CSType(value)
                    }
                    self = .function(parameters, returnType)
                case "Variant":
                    var parameters: [(String, CSType)] = []
                    if let values = object["cases"]?.array {
                        parameters = values.map({ (arg) in
                            return (arg.get(key: "tag").stringValue, CSType(arg.get(key: "type")))
                        })
                    }
                    self = .variant(parameters)
                default:
                    break
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

    var isVariant: Bool {
        guard case CSType.variant(_) = self else { return false }
        return true
    }

    func unwrappedNamedType() -> CSType {
        switch self {
        case .named(_, let type):
            return type.unwrappedNamedType()
        default:
            return self
        }
    }

    func toString() -> String {
        if let unwrapped = self.unwrapOptional() {
            return unwrapped.toString()
        }

        switch self {
        case .bool: return "Boolean"
        case .number: return "Number"
        case .string: return "String"
        case .dictionary: return "Record"
        case .function: return "Function"
        case .named(let name, _): return name
        default: return "Any"
        }
    }

    // TODO Params on
    // optional, generic, array, dictionary
    func toData() -> CSData {
        for (name, type) in CSType.builtInTypes where self == type {
            return name.toData()
        }

        switch self {
        case .any: return .String("Any")
        case .named(let name, let type):
            if CSType.userType(named: name) != nil { return .String(name) }

            return .Object([
                "name": "Named".toData(),
                "alias": .String(name),
                "of": type.toData()
            ])
        case .generic: return .String("Generic")
        case .undefined: return .String("Undefined")
        case .null: return .String("Null")
        case .bool: return .String("Boolean")
        case .number: return .String("Number")
        case .string: return .String("String")
        case .array(let innerType):
            return .Object([
                "name": "Array".toData(),
                "of": innerType.toData()
            ])
        case .dictionary(let schema):
          var data: CSData = .Object([
            "name": "Record".toData()
            ])

          let hasAccessRules = schema.values.contains(where: { arg in arg.access != CSAccess.write })

          if hasAccessRules {
            data["fields"] = CSData.Array(schema.map({ (arg) -> CSData in
              let (key, value) = arg
              return CSData.Object([
                "key": key.toData(),
                "type": value.type.toData(),
                "access": value.access.rawValue.toData()
                ])
            }))
          } else {
            data["fields"] = CSData.Object(
                schema.key({ arg in
                    return (key: arg.key, value: arg.value.type.toData())
                }))
          }

          return data
        case .enumeration(let values):
            if let match = CSType.builtInTypes.enumerated().first(where: { (arg) -> Bool in
                let (_, item) = arg
                return item.value == self
            }) {
                return .String(match.element.key)
            }

            return CSData.Object([
                "name": "Enumeration".toData(),
                "of": CSData.Array(values.map({ $0.toData() }))
            ])
        case .function(let parameters, let returnType):
            var data: CSData = .Object([
                "name": "Function".toData()
                ])

            if parameters.count > 0 {
                data["parameters"] = CSData.Array(parameters.map({ (arg) -> CSData in
                    return CSData.Object([
                        "label": arg.0.toData(),
                        "type": arg.1.toData()
                        ])
                }))
            }

            if returnType != .undefined {
                data["returnType"] = returnType.toData()
            }

            return data
        case .variant(let cases):
            var data: CSData = .Object([
                "name": "Variant".toData()
                ])

            if cases.count > 0 {
                data["cases"] = CSData.Array(cases.map({ (arg) -> CSData in
                    let (tag, innerType) = arg

                    return CSData.Object([
                        "tag": tag.toData(),
                        "type": innerType.toData()
                        ])
                }))
            }

            return data
        case .unit:
            return "Unit".toData()
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
        case "Function": return CSHandlerType
        default: return .any
        }
    }

    static func == (lhs: CSType, rhs: CSType) -> Bool {
        switch (lhs, rhs) {
        case (.any, .any): return true
        case (.named(let ln, let l), .named(let rn, let r)): return ln == rn && l == r
        case (.unit, .unit): return true
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
            for pair in zip(l, r) where pair.0 != pair.1 {
                return false
            }

            return true
        case (.function(let lParams, let lReturnType), .function(let rParams, let rReturnType)):
            for pair in zip(lParams, rParams) where pair.0 != pair.1 {
                return false
            }

            return lReturnType == rReturnType
        case (.variant(let l), .variant(let r)):
            for pair in zip(l, r) where pair.0 != pair.1 {
                return false
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
            CSValue(type: .string, data: .String("Record")),
            CSValue(type: .string, data: .String("Color")),
            CSValue(type: .string, data: .String("TextStyle")),
            CSValue(type: .string, data: .String("URL")),
            CSValue(type: .string, data: .String("Function"))
//            CSValue(type: .string, data: .String("Component")),
            ] + CSUserTypes.types.map({ CSValue(type: .string, data: $0.toString().toData()) })

        return CSType.enumeration(values)
    }

    static var builtInTypes: [String: CSType] = {
        var data: [String: CSType] = [
            "Boolean": CSType.bool,
            "Number": CSType.number,
            "String": CSType.string,
            "Record": CSEmptyRecordType,
            "Color": CSColorType,
            "TextStyle": CSTextStyleType,
            "Comparator": CSComparatorType,
            "URL": CSURLType,
            "Component": CSComponentType
            ]

        data.forEach({ pair in
            let (k, v) = pair
            data[k + "?"] = v.makeOptional()
        })

        return data
    }()
}

// MARK: - Optional Handling

extension CSType {
    static func createOptional(_ inner: CSType) -> CSType {
        return CSType.variant([
            ("Some", inner),
            ("None", .unit)
            ])
    }

    func makeOptional() -> CSType {
        return CSType.createOptional(self)
    }

    func unwrapOptional() -> CSType? {
        guard case CSType.variant(let cases) = self else { return nil }
        guard cases.count == 2 else { return nil }

        let (firstName, firstType) = cases[0]
        let (secondName, secondType) = cases[1]

        guard firstName == "Some" && secondName == "None" &&
            secondType == .unit else { return nil }

        return firstType
    }

    func isOptional() -> Bool {
        return unwrapOptional() != nil
    }
}

let CSAnyType = CSType.any
let CSGenericTypeA = CSType.generic("a'", CSType.any)
let CSGenericArrayOfTypeA = CSType.array(CSGenericTypeA)
let CSColorType = CSType.named("Color", .string)
let CSTextStyleType = CSType.named("TextStyle", .string)
let CSURLType = CSType.named("URL", .string)
let CSComponentType = CSType.named("Component", .any)
let CSHandlerType = CSType.function([], .undefined)
let CSEmptyRecordType = CSType.dictionary([:])

let CSComparatorType = CSType.enumeration([
    CSValue(type: .string, data: .String("equal to")),
    CSValue(type: .string, data: .String("not equal to")),
    CSValue(type: .string, data: .String("greater than")),
    CSValue(type: .string, data: .String("greater than or equal to")),
    CSValue(type: .string, data: .String("less than")),
    CSValue(type: .string, data: .String("less than or equal to"))
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

    // States
    "pressed": (type: .bool, access: .read),
    "hovered": (type: .bool, access: .read),

    // Interactivity
    "onPress": (type: CSHandlerType, access: .write),

    // Children
    "children": (type: .array(.any), access: .write)
])
