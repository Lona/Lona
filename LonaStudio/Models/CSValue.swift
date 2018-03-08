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

        if !self.type.isOptional(), let unwrappedType = type.unwrapOptional() {
            let newValue = self.cast(to: unwrappedType)
            return newValue.wrap(in: type, tagged: newValue.data == CSData.Null ? "None" : "Some")
        } else if self.type.isOptional(), let unwrappedType = type.unwrapOptional() {
            let newValue = self.unwrapVariant()?.cast(to: unwrappedType) ?? CSValue.defaultValue(for: unwrappedType)
            return newValue.wrap(in: type, tagged: newValue.data == CSData.Null ? "None" : "Some")
        } else if self.type.isOptional() && !type.isOptional() {
            return self.unwrapVariant()?.cast(to: type) ?? CSValue.defaultValue(for: type)
        }

        switch type {
        case .bool: return CSValue(type: type, data: .Bool(false))
        case .number: return CSValue(type: type, data: .Number(0))
        case .string: return CSValue(type: type, data: .String(""))
        case .named("Color", .string): return CSValue(type: type, data: .String("black"))
        case .named:
            var value = cast(to: type.unwrappedNamedType())
            value.type = type
            return value
        case .array: return CSValue(type: type, data: .Array([]))
        default: return CSValue(type: type, data: .Null)
        }
    }

    func toData() -> CSData {
        return CSData.Object([
            "type": type.toData(),
            "data": data
        ])
    }

    func get(key: String) -> CSValue {
        guard case CSType.dictionary(let schema) = self.type else { return CSUndefinedValue }
        guard let record = schema.first(where: { key == $0.key }) else { return CSUndefinedValue }

        return CSValue(type: record.value.type, data: data.get(key: key))
    }

    func get(keyPath: [String]) -> CSValue {
        return keyPath.reduce(self, { (result, key) in result.get(key: key) })
    }

    func unwrappedNamedType() -> CSValue {
        return CSValue(type: type.unwrappedNamedType(), data: data)
    }

    static func == (lhs: CSValue, rhs: CSValue) -> Bool {
        return lhs.type == rhs.type && lhs.data == rhs.data
    }

    /// A placeholder value, optimizing for showing something on the screen (human-friendly), rather than
    /// optimizing for sensible code generation (computer-friendly)
    static func exampleValue(for type: CSType) -> CSValue {
        switch type {
        case .bool: return CSValue(type: type, data: .Bool(false))
        case .number: return CSValue(type: type, data: .Number(0))
        case .string: return CSValue(type: type, data: .String("Text"))
        case .named("Color", .string): return CSValue(type: type, data: .String("black"))
        case .array: return CSValue(type: type, data: .Array([]))
        case .dictionary(let schema):
            let fields: [String: CSData] = schema.key({ (arg) in
                return (key: arg.key, value: exampleValue(for: arg.value.type).data)
            })
            return CSValue(type: type, data: .Object(fields))
        default:
            return CSValue(type: CSAnyType, data: CSData.Null)
        }
    }

    static func defaultValue(for type: CSType) -> CSValue {
        switch type {
        case .bool: return CSValue(type: type, data: .Bool(false))
        case .number: return CSValue(type: type, data: .Number(0))
        case .string: return CSValue(type: type, data: .String(""))
        case .named("Color", .string): return CSValue(type: type, data: .String("transparent"))
        case .array: return CSValue(type: type, data: .Array([]))
        case .dictionary(let schema):
            let fields: [String: CSData] = schema.key({ (arg) in
                return (key: arg.key, value: defaultValue(for: arg.value.type).data)
            })
            return CSValue(type: type, data: .Object(fields))
        default:
            return CSUndefinedValue.cast(to: type)
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
                } else if
                    case CSType.variant(let cases) = typeFilter,
                    cases.contains(where: { arg in schemaItem.type == arg.1 }) {
                    result[item.key] = item.value
                } else if typeFilter.isGeneric || typeFilter == CSType.any || typeFilter == schemaItem.type {
                    result[item.key] = item.value
                }
            }

            return result
        }
    }
}

// MARK: - Variant Handling

extension CSValue {
    func tag() -> String {
        return self.data.get(key: "tag").stringValue
    }

    func wrap(in variant: CSType, tagged tag: String) -> CSValue {
        guard case CSType.variant(let cases) = variant else {
            Swift.print("Attempted to wrap", self, "in non-variant type", variant)
            return CSUndefinedValue
        }

        guard cases.contains(where: { item in item.0 == tag && item.1 == self.type }) else {
            Swift.print("Could not find tag", tag, "and type", self.type, "in variant type", variant)
            return CSUndefinedValue
        }

        return CSValue(type: variant, data: CSData.Object([
            "tag": tag.toData(),
            "data": data
            ]))
    }

    func unwrapVariant() -> CSValue? {
        guard case CSType.variant(let cases) = self.type else {
            Swift.print("Attempted to unwrap non-variant type of value", self)
            return nil
        }

        let tag = self.data.get(key: "tag").stringValue
        guard let match = cases.first(where: { item in item.0 == tag }) else {
            Swift.print("Could not find tag", tag, "in variant type of value", self)
            return nil
        }

        return CSValue(type: match.1, data: self.data.get(key: "data"))
    }

    func with(data newData: CSData) -> CSValue {
        return CSValue(type: (self.unwrapVariant() ?? CSUndefinedValue).type, data: newData)
            .wrap(in: self.type, tagged: self.tag())
    }

    func with(tag newTag: String) -> CSValue {
        guard case CSType.variant(let cases) = self.type else {
            Swift.print("Attempted to modify tag of non-variant type of value", self)
            return CSUndefinedValue
        }
        let newType = cases.first(where: { item in item.0 == newTag })?.1 ?? CSType.undefined
        let unwrappedValue = self.unwrapVariant() ?? CSValue.defaultValue(for: newType)
        return unwrappedValue.cast(to: newType).wrap(in: self.type, tagged: newTag)
    }
}

let CSUnitValue = CSValue(type: .unit, data: CSData.Null)
let CSUndefinedValue = CSValue(type: .undefined, data: CSData.Null)
let CSEmptyDictionaryValue = CSValue(type: .dictionary(CSType.Schema()), data: CSData.Object([:]))

typealias CSValueChangeHandler = (CSValue) -> Void
let CSValueDefaultChangeHandler: CSValueChangeHandler = {_ in}
