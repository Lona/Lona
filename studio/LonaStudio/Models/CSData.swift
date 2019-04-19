//
//  CSData.swift
//  ComponentStudio
//
//  Created by devin_abbott on 7/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

// https://stackoverflow.com/questions/30215680/is-there-a-correct-way-to-determine-that-an-nsnumber-is-derived-from-a-bool-usin/30223989#30223989
private func isBool(number: NSNumber) -> Bool {
    let boolID = CFBooleanGetTypeID() // the type ID of CFBoolean
    let numID = CFGetTypeID(number) // the type ID of num
    return numID == boolID
}

enum CSData: Equatable, CustomDebugStringConvertible {
    case Null
    case Bool(Bool)
    case Number(Double)
    case String(String)
    case Array([CSData])
    case Object([String: CSData])

    var debugDescription: String {
        switch self {
        case .Null: return "null"
        case .Bool(let value): return "\(value)"
        case .Number(let value): return "\(value)"
        case .String(let value): return "\"\(value)\""
        case .Array(let value):
            return "[" + value.map({ $0.debugDescription }).joined(separator: ", ") + "]"
        case .Object(let value):
            return "{" + value.map({ "\($0.key): \($0.value)" }).joined(separator: ", ") + "}"
        }
    }

    static func == (lhs: CSData, rhs: CSData) -> Bool {
        switch (lhs, rhs) {
        case (.Null, .Null): return true
        case (.Bool(let l), .Bool(let r)): return l == r
        case (.Number(let l), .Number(let r)): return l == r
        case (.String(let l), .String(let r)): return l == r
        case (.Array(let l), .Array(let r)):
            if l.count != r.count { return false }
            for pair in zip(l, r) where pair.0 != pair.1 {
                return false
            }
            return true
        case (.Object(let l), .Object(let r)):
            if l.count != r.count { return false }
            for (key, value) in l where r[key] != value {
                return false
            }
            return true
        default: return false
        }
    }

    var isNull: Bool {
        return self == CSData.Null
    }

    var bool: Bool? {
        get {
            guard case CSData.Bool(let value) = self else { return nil }
            return value
        }
        set {
            if let value = newValue {
                self = CSData.Bool(value)
            }
        }
    }
    var boolValue: Bool { return bool ?? false }

    var number: Double? {
        get {
            guard case CSData.Number(let value) = self else { return nil }
            return value
        }
        set {
            if let value = newValue {
                self = CSData.Number(value)
            }
        }
    }
    var numberValue: Double { return number ?? 0 }

    var string: String? {
        get {
            guard case CSData.String(let value) = self else { return nil }
            return value
        }
        set {
            if let value = newValue {
                self = CSData.String(value)
            }
        }
    }
    var stringValue: String { return string ?? "" }

    var array: [CSData]? {
        get {
            guard case CSData.Array(let value) = self else { return nil }
            return value
        }
        set {
            if let value = newValue {
                self = CSData.Array(value)
            }
        }
    }
    var arrayValue: [CSData] { return array ?? [] }

    var object: [String: CSData]? {
        get {
            guard case CSData.Object(let value) = self else { return nil }
            return value
        }
        set {
            if let value = newValue {
                self = CSData.Object(value)
            }
        }
    }
    var objectValue: [String: CSData] { return object ?? [:] }

    subscript(index: Int) -> CSData? {
        get {
            switch self {
            case .Array(let value):
                return value[index]
            default:
                return nil
            }
        }
        set {
            switch self {
            case .Array(var value):
                if let v = newValue {
                    value[index] = v
                } else {
                    // This isn't quite right, but it's probably better than making a sparse array
                    value[index] = .Null
                }
                self = CSData.Array(value)
            default:
                break
            }
        }
    }

    subscript(index: String) -> CSData? {
        get {
            switch self {
            case .Object(let value):
                return value[index]
            default:
                return nil
            }
        }
        set {
            switch self {
            case .Object(var value):
                if let v = newValue {
                    value[index] = v
                } else {
                    value.removeValue(forKey: index)
                }
                self = CSData.Object(value)
            default:
                break
            }
        }
    }

    func get(key: String) -> CSData {
        return self[key] ?? .Null
    }

    func get(keyPath: [String]) -> CSData {
        return keyPath.reduce(self, { (result, key) in result.get(key: key) })
    }

    @discardableResult mutating func set(keyPath: [String], to value: CSData) -> CSData {
        if keyPath.count == 0 {
            self = value
            return self
        }

        let key = keyPath[0]
        var object = self[key] ?? CSData.Object([:])

        self = merge(.Object([
            key: object.set(keyPath: Swift.Array(keyPath[1..<keyPath.count]), to: value)
        ]))

        return self
    }

    func merge(_ object: CSData) -> CSData {
        var merged = CSData.Object([:])

        if let original = self.object {
            original.forEach({ (key, value) in
                merged[key] = value
            })
        }

        if let extra = object.object {
            extra.forEach({ (key, value) in
                merged[key] = value
            })
        }

        return merged
    }

    func removingKeysForNullValues(deep: Bool = true) -> CSData {
        var updated = CSData.Object([:])

        guard let object = self.object else { return self }

        object.forEach({ (key, value) in
            switch value {
            case .Null:
                break
            case let .Array(list):
                updated[key] = deep
                    ? CSData.Array(list.map({ $0.removingKeysForNullValues(deep: deep) }))
                    : value
            case .Object:
                updated[key] = deep
                    ? value.removingKeysForNullValues(deep: deep)
                    : value
            default:
                updated[key] = value
            }
        })

        return updated
    }

    func toAny() -> Any {
        switch self {
        case .Null:
            return NSNull()
        case .Bool(let value):
            return NSNumber(booleanLiteral: value) // swiftlint:disable:this compiler_protocol_init
        case .Number(let value):
            return value
        case .String(let value):
            return value
        case .Array(let value):
            return value.map({ $0.toAny() })
        case .Object(let value):
            return value.map({ $0.toAny() })
        }
    }

    func toData() -> Data? {
        switch self {
        case .Null:
            return "null".data(using: .utf8)
        case .String(let value):
            return ("\"\(value.replacingOccurrences(of: "\"", with: "\\\""))\"").data(using: .utf8)
        case .Number(let value):
            return "\(value)".data(using: .utf8)
        case .Bool(let value):
            return "\(value)".data(using: .utf8)
        case .Array, .Object:
            break
        }

        let options: JSONSerialization.WritingOptions

        if #available(OSX 10.13, *) {
            options = [
                JSONSerialization.WritingOptions.prettyPrinted,
                JSONSerialization.WritingOptions.sortedKeys
            ]
        } else {
            options = [
                JSONSerialization.WritingOptions.prettyPrinted
            ]
        }

        return try? JSONSerialization.data(withJSONObject: toAny(), options: options)
    }

    func jsonString() -> String? {
        guard let data = toData() else { return nil }
        return Swift.String(data: data, encoding: .utf8)
    }

    static func from(data: Data) -> CSData? {
        guard let json = try? JSONSerialization.jsonObject(
            with: data, options: [JSONSerialization.ReadingOptions.allowFragments]) else { return nil }
        return from(json: json)
    }

    static func from(json: Any) -> CSData {
        if json as? NSNull != nil {
            return CSData.Null
        } else if let value = json as? NSNumber {
            return isBool(number: value) ? CSData.Bool(value.boolValue) : CSData.Number(Double(truncating: value))
        } else if let value = json as? NSString {
            return CSData.String(value as String)
        } else if let value = json as? NSArray {
            return CSData.Array(
                value.map({ CSData.from(json: $0) })
            )
        } else if let value = json as? NSDictionary {
            let object: [String: CSData] = value.map({ $0 }).key { (key: ($0.key as! NSString) as String, value: CSData.from(json: $0.value)) }

            return CSData.Object(object)
        }

        return CSData.Null
    }

    static func from(fileAtPath path: String) -> CSData? {
        if FileUtils.fileExists(atPath: path) != .file {
            return nil
        }
        if let contents = try? Data(contentsOf: URL(fileURLWithPath: path)) {
            return CSData.from(data: contents)
        } else {
            Swift.print("Failed to read .json file at \(path)")
            return nil
        }
    }
}

protocol CSDataSerializable {
    func toData() -> CSData
}

protocol CSDataDeserializable {
    init(_ data: CSData)
}

extension Bool: CSDataSerializable {
    func toData() -> CSData {
        return .Bool(self)
    }
}

extension Double: CSDataSerializable {
    func toData() -> CSData {
        return .Number(self)
    }
}

extension Double: CSDataDeserializable {
    init(_ data: CSData) {
        self = data.numberValue
    }
}

extension CGFloat: CSDataSerializable {
    func toData() -> CSData {
        return .Number(Double(self))
    }
}

extension Int: CSDataSerializable {
    func toData() -> CSData {
        return .Number(Double(self))
    }
}

extension UInt: CSDataSerializable {
    func toData() -> CSData {
        return .Number(Double(self))
    }
}

extension String: CSDataSerializable {
    func toData() -> CSData {
        return .String(self)
    }
}

extension String: CSDataDeserializable {
    init(_ data: CSData) {
        self = data.stringValue
    }
}

extension Optional: CSDataSerializable where Wrapped: CSDataSerializable {
    func toData() -> CSData {
        switch self {
        case .none:
            return .Null
        case .some(let wrapped):
            return wrapped.toData()
        }
    }
}

extension Optional: CSDataDeserializable where Wrapped: CSDataDeserializable {
    init(_ data: CSData) {
        self = data.isNull ? nil : Wrapped(data)
    }
}

extension Sequence where Iterator.Element: CSDataSerializable {
    func toData() -> CSData {
        let list = map({ $0.toData() })
        return .Array(list)
    }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: CSDataSerializable {
    func toData() -> CSData {
        var items: [String: CSData] = [:]

        for item in self.enumerated() {
            items["\(item.element.key)"] = item.element.value.toData()
        }

        return CSData.Object(items)
    }
}

extension UserDefaults {
    func csData(forKey defaultName: String) -> CSData? {
        guard let data = self.data(forKey: defaultName) else { return nil }
        return CSData.from(data: data)
    }

    func set(_ value: CSData?, forKey defaultName: String) {
        if let data = value?.toData() {
            self.set(data, forKey: defaultName)
        } else {
            self.removeObject(forKey: defaultName)
        }
    }
}

typealias CSDataChangeHandler = (CSData) -> Void
let CSDataDefaultChangeHandler: CSDataChangeHandler = {_ in}
