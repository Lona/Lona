//
//  CSData.swift
//  ComponentStudio
//
//  Created by devin_abbott on 7/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import SwiftyJSON

enum CSData: Equatable {
    case Null
    case Bool(Bool)
    case Number(Double)
    case String(String)
    case Array([CSData])
    case Object([String: CSData])
    
    static func ==(lhs: CSData, rhs: CSData) -> Bool {
        switch (lhs, rhs) {
        case (.Null, .Null): return true
        case (.Bool(let l), .Bool(let r)): return l == r
        case (.Number(let l), .Number(let r)): return l == r
        case (.String(let l), .String(let r)): return l == r
        case (.Array(let l), .Array(let r)):
            if l.count != r.count { return false }
            for pair in zip(l, r) {
                if pair.0 != pair.1 {
                    return false
                }
            }
            return true
        case (.Object(let l), .Object(let r)):
            if l.count != r.count { return false }
            for (key, value) in l {
                if r[key] != value {
                    return false
                }
            }
            return true
        default: return false
        }
    }
    
    var isNull: Bool {
        get {
            return self == CSData.Null
        }
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
        if keyPath.count == 0 { return value }
        
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
    
    func toAny() -> Any {
        switch self {
        case .Null:
            return NSNull()
        case .Bool(let value):
            return value
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
    
    func toJSONString() -> String? {
        return toJSON().rawString()
    }
    
    func toJSON() -> JSON {
        return JSON(toAny() as Any)
    }
    
    func toData() -> Data? {
        return toJSONString()?.data(using: .utf8)
    }
    
    static func from(data: Data) -> CSData? {
        guard let jsonString = Swift.String(data: data, encoding: .utf8) else { return nil }
        
        return from(jsonString: jsonString)
    }
    
    static func from(jsonString: String) -> CSData {
        let json = JSON(parseJSON: jsonString)
        
        return CSData.from(json: json)
    }
    
    static func from(json: JSON) -> CSData {
        if json.null != nil {
            return CSData.Null
        } else if let value = json.bool {
            return CSData.Bool(value)
        } else if let value = json.number {
            return CSData.Number(Double(value))
        } else if let value = json.string {
            return CSData.String(value)
        } else if let value = json.array {
            return CSData.Array(
                value.map({ CSData.from(json: $0) })
            )
        } else if let value = json.dictionary {
            return CSData.Object(
                value.map({ CSData.from(json: $0) })
            )
        }
        
        return CSData.Null
    }
    
    static func from(fileAtPath path: String) -> CSData? {
        let contents = FileManager.default.contents(atPath: path)
        
        if let contents = contents {
            guard let string = Swift.String(data: contents, encoding: .utf8) else { return nil }
            let json = JSON(parseJSON: string)
            return CSData.from(json: json)
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

extension Sequence where Iterator.Element: CSDataSerializable {
    func toData() -> CSData {
        let list = map({ $0.toData() })
        return .Array(list)
    }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: CSDataSerializable {
    func toData() -> CSData {
        var items: [String: CSData] = [:]
        
        for (_, item) in self.enumerated() {
            items["\(item.key)"] = item.value.toData()
        }
        
        return CSData.Object(items)
    }
}


