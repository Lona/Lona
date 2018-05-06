//
//  CSScope.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/6/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

enum CSAccess: String {
    case read, write, inline
}

typealias CSVariable = (value: CSValue, access: CSAccess)

let CSUndefinedVariable: CSVariable = (value: CSUndefinedValue, access: .write)

protocol CSAbstractScope {
    func has(variable name: String) -> Bool

    func get(variable name: String) -> CSVariable

    @discardableResult func set(variable name: String, to variable: CSVariable) -> Bool
}

class CSRootScope: CSAbstractScope {
    func has(variable name: String) -> Bool { return false }

    func get(variable name: String) -> CSVariable {
        return (CSUndefinedValue, .read)
    }

    @discardableResult func set(variable name: String, to variable: CSVariable) -> Bool {
        return false
    }
}

class CSScope: CSRootScope {
    var variables: [String: CSVariable] = [:]
    var parent: CSAbstractScope

    init(parent: CSAbstractScope = CSRootScope()) {
        self.parent = parent
    }

    func has(value name: String) -> Bool {
        return has(variable: name)
    }

    override func has(variable name: String) -> Bool {
        let variable = get(variable: name)
        return variable.value != CSUndefinedValue
    }

    func get(value name: String) -> CSValue {
        return get(variable: name).value
    }

    override func get(variable name: String) -> CSVariable {
        if let variable = variables[name] { return variable }
        return parent.get(variable: name)
    }

    func getValueAt(keyPath path: [String]) -> CSValue {
        let value = get(value: path[0])
        let objectPath = Array(path[1..<path.count])
        let type = value.type.typeAt(keyPath: objectPath) ?? CSType.any
        let data = value.data.get(keyPath: objectPath)
        return CSValue(type: type, data: data)
    }

    func set(keyPath: [String], to value: CSValue) {
        var scopeValue = get(value: keyPath[0])
        scopeValue.data.set(keyPath: Array(keyPath[1..<keyPath.count]), to: value.data)
        set(value: keyPath[0], to: scopeValue)
    }

    @discardableResult func set(value name: String, to value: CSValue) -> Bool {
        return set(variable: name, to: (value, .write))
    }

    @discardableResult override func set(variable name: String, to variable: CSVariable) -> Bool {
        if let declared = variables[name] {
            switch declared.access {
            case .inline,
                 .read,
                 .write:
                variables[name] = variable
                return true
            }
        }

        if parent.has(variable: name) {
            return parent.set(variable: name, to: variable)
        } else {
            Swift.print("Attempted to set undeclared variable", name)
            return false
        }
    }

    @discardableResult func declare(value name: String, as value: CSValue = CSUndefinedValue) -> Bool {
        return declare(variable: name, as: (value, .write))
    }

    @discardableResult func declare(variable name: String, as variable: CSVariable = CSUndefinedVariable) -> Bool {
        if variables[name] != nil {
            Swift.print("Variable", name, "already declared")
            return false
        }

        variables[name] = variable
        return true
    }

    func undeclare(variable name: String) {
        variables.removeValue(forKey: name)
    }

    func scopes() -> [CSScope] {
        var scopes: [CSScope] = [self]

        var parent = self.parent

        while let parentScope = parent as? CSScope {
            scopes.append(parentScope)
            parent = parentScope.parent
        }

        return scopes.reversed()
    }

    func flattened() -> [String: CSVariable] {
        var base: [String: CSVariable] = [:]

        for scope in scopes() {
            base.merge(scope.variables, uniquingKeysWith: { _, new in new })
        }

        return base
    }

//    func allValues(withAccess accessFilter: CSAccess) -> [(String, CSVariable)] {
////        if accessFilter == .write { return variables.values }
////
////        return variables.values.filter({ (value, access) -> Bool in
////            return access == accessFilter
////        })
//        return variables.keys.map({ ($0, variables[$0]!) })
//    }

//    func dictionary(access: CSAccess) -> CSData {
//        return variables.enumerated().reduce(CSData.Object([:])) { (result, item) -> CSData in
//            if access == .write && item.element.value.access == .read { return result }
//
//            var result = result
//            result[item.element.key] = item.element.value.value.data
//            return result
//        }
//    }

    func data(typed typeFilter: CSType, accessed accessFilter: CSAccess) -> CSData {
        return flattened().enumerated().reduce(CSData.Object([:])) { (result, item) -> CSData in
            if accessFilter == .write && item.element.value.access == .read { return result }

//            Swift.print("Scope data", item.element.key, item.element.value.value.type)

            var result = result
            result[item.element.key] = item.element.value.value.filteredData(typed: typeFilter, accessed: accessFilter)
            return result
        }
    }

    func print() {
        let scopes = self.scopes()

        for (index, scope) in scopes.enumerated() {
            Swift.print("Scope", index, ":")
            for (key, element) in scope.variables {
                Swift.print("  ", key, element.value.data.debugDescription)
            }
            Swift.print("")
        }
    }
}
