//
//  CSFunction.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/10/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

struct CSFunction {
    struct Invocation: CSDataSerializable, CSDataDeserializable {
        var name: String = CSFunction.noneFunction.declaration
        var arguments: NamedArguments = [:]
        
        init() {}
        
        init(_ data: CSData) {
            self.name = String(data.get(key: "name"))
            self.arguments = data.get(key: "arguments").objectValue.reduce([:], { (result, item) -> NamedArguments in
                var result = result
                result[item.key] = CSFunction.Argument(item.value)
                return result
            })
        }
        
        func run(in scope: CSScope) -> ReturnValue {
            let function = CSFunction.getFunction(declaredAs: name)
            return function.invoke(arguments, scope)
        }
        
        var canBeInvoked: Bool {
            let function = CSFunction.getFunction(declaredAs: name)
        
            for parameter in function.parameters {
                if arguments[parameter.name] == nil {
                    return false
                }
            }
            
            return true
        }
        
        func toData() -> CSData {
            return CSData.Object([
                "name": name.toData(),
                "arguments": arguments.toData(),
            ])
        }
        
        // Returns nil if no concrete type was found
        func concreteTypeForArgument(named argumentName: String, in scope: CSScope) -> CSType? {
            let function = CSFunction.getFunction(declaredAs: self.name)
            
//            Swift.print("concrete type for", argumentName)
            
            guard let matchingParameter = function.parameters.first(where: { $0.name == argumentName }) else { return nil }
            
            if !matchingParameter.variableType.isGeneric { return matchingParameter.variableType }
            
            for parameter in function.parameters {
                // If we reach this parameter, there was no concrete type
                if parameter.name == argumentName { break }
                
                if parameter.variableType.genericId == matchingParameter.variableType.genericId, let argument = arguments[parameter.name] {
                    let resolved = argument.resolve(in: scope).type
//                    Swift.print("resolved generic type", resolved)
                    return resolved
                }
            }
            
            return nil
        }
    }
    
    enum ParameterType {
        case variable(type: CSType, access: CSAccess)
        case keyword(type: CSType) // Such as a comparator
        case declaration()
    }
    
    struct Parameter {
        var label: String?
        var name: String
        var type: ParameterType
        
        var variableType: CSType {
            switch self.type {
            case .variable(type: let type, access: _): return type
            case .keyword(type: let type): return type
            case .declaration: return CSType.undefined
            }
        }
        
        var access: CSAccess {
            switch self.type {
            case .variable(type: _, access: let access): return access
            case .keyword(type: _): return CSAccess.read
            case .declaration: return CSAccess.write
            }
        }
    }
    
    enum Argument: CSDataSerializable, CSDataDeserializable {
        init(_ data: CSData) {
            switch data.get(key: "type").stringValue {
            case "value":
                self = .value(CSValue(data.get(key: "value")))
            case "identifier":
                let identifierType = CSType(data.get(keyPath: ["value", "type"]))
                let identifierPath = data.get(keyPath: ["value", "path"]).arrayValue.map({ $0.stringValue })
                self = .identifier(identifierType, identifierPath)
            default:
                self = .value(CSUndefinedValue)
            }
        }
        
        func toData() -> CSData {
            switch self {
            case .value(let value):
                return CSData.Object([
                    "type": .String("value"),
                    "value": value.toData(),
                ])
            case .identifier(let type, let keyPath):
                return CSData.Object([
                    "type": .String("identifier"),
                    "value": CSData.Object([
                        "type": type.toData(),
                        "path": keyPath.toData(),
                    ])
                ])
            }
        }
        
        case value(CSValue)
        case identifier(CSType, [String])
        
        func resolve(in scope: CSScope) -> CSValue {
            switch self {
            case .value(let value): return value
            // TODO: Verify that the type matches what's in scope? Or we can just rely on the fact
            // that most uses of a variable won't work with the wrong type
            case .identifier(_, let keyPath):
                if keyPath.count == 0 { return CSUndefinedValue }
                return scope.getValueAt(keyPath: keyPath)
            }
        }
        
        var keyPath: [String]? {
            switch self {
            case .value(_): return nil
            case .identifier(_, let name): return name
            }
        }
        
        static var customValue: String { return "custom" }
        static var noneValue: String { return "none" }
        static var noneKeyPath: [String] { return [noneValue] }
        static var customKeyPath: [String] { return [customValue] }
        static var customValueKeyPath: [String] { return [customValue, "value"] }
        static var customTypeKeyPath: [String] { return [customValue, "type"] }
    }
    
    enum ControlFlow {
        case stepOver, stepInto
    }
    
    typealias NamedArguments = [String: Argument]
    
    typealias ReturnValue = ControlFlow
    
    var name: String
    var description: String = ""
    var parameters: [Parameter]
    var hasBody: Bool
    
    // Named parameters are populated (pulled from scope) by the execution context
    var invoke: (NamedArguments, CSScope) -> ReturnValue = { _, scope in .stepOver }
    var updateScope: (NamedArguments, CSScope) -> Void = { _ in }

    static var registeredFunctionDeclarations: [String] {
        return Array(registeredFunctions.keys)
    }
    
    static var registeredFunctions: [String: CSFunction] = [
        CSFunction.noneFunction.declaration: CSFunction.noneFunction,
        CSAssignFunction.declaration: CSAssignFunction,
        CSIfFunction.declaration: CSIfFunction,
        CSIfExistsFunction.declaration: CSIfExistsFunction,
        CSDefineFunction.declaration: CSDefineFunction,
        CSAddFunction.declaration: CSAddFunction,
    ]
    
    static var noneFunction: CSFunction {
        return CSFunction(
            name: "none",
            description: "Do nothing",
            parameters: [],
            hasBody: false,
            invoke: { _, scope in .stepOver },
            updateScope: { _ in }
        )
    }
    
    static func register(function: CSFunction) {
        registeredFunctions[function.declaration] = function
    }

    static func getFunction(declaredAs declaration: String) -> CSFunction {
        return registeredFunctions[declaration] ?? notFound(name: declaration)
    }
    
    static func notFound(name: String) -> CSFunction {
        return CSFunction(
            name: "Function \(name) not found",
            description: "",
            parameters: [],
            hasBody: true,
            invoke: { _, scope in .stepOver },
            updateScope: { _ in }
        )
    }
    
    var declaration: String {
        let parameterList = parameters.map({ parameter in
            if let label = parameter.label {
                return "\(label) \(parameter.name)"
            } else {
                return parameter.name
            }
        }).joined(separator: ", ")
        return "\(name)(\(parameterList))".lowercased()
    }
}

let CSAssignFunction = CSFunction(
    name: "Assign",
    description: "Assign one value to another",
    parameters: [
        CSFunction.Parameter(label: nil, name: "lhs", type: .variable(type: CSGenericTypeA, access: .read)),
        CSFunction.Parameter(label: "to", name: "rhs", type: .variable(type: CSGenericTypeA, access: .write)),
    ],
    hasBody: false,
    invoke: { (arguments, scope) -> CSFunction.ReturnValue in
        let lhs = arguments["lhs"]!.resolve(in: scope)
        guard case CSFunction.Argument.identifier(_, let rhsKeyPath) = arguments["rhs"]! else { return .stepOver }
        scope.set(keyPath: rhsKeyPath, to: lhs)
        
        return .stepOver
    },
    updateScope: { _ in }
)

let CSIfFunction = CSFunction(
    name: "If",
    description: "Compare two values",
    parameters: [
        CSFunction.Parameter(label: nil, name: "lhs", type: .variable(type: CSGenericTypeA, access: .read)),
        CSFunction.Parameter(label: "is", name: "cmp", type: .keyword(type: CSComparatorType)),
        CSFunction.Parameter(label: nil, name: "rhs", type: .variable(type: CSGenericTypeA, access: .read)),
    ],
    hasBody: true,
    invoke: { arguments, scope in
        let lhs = arguments["lhs"]!.resolve(in: scope)
        let cmp = arguments["cmp"]!.resolve(in: scope)
        let rhs = arguments["rhs"]!.resolve(in: scope)
        
        switch cmp.type {
        case CSComparatorType:
            switch cmp.data.stringValue {
            case "equal to":
                return lhs.data == rhs.data ? .stepInto : .stepOver
            case "not equal to":
              return lhs.data != rhs.data ? .stepInto : .stepOver
            case "greater than":
                return lhs.data.numberValue > rhs.data.numberValue ? .stepInto : .stepOver
            case "greater than or equal to":
                return lhs.data.numberValue >= rhs.data.numberValue ? .stepInto : .stepOver
            case "less than":
                return lhs.data.numberValue < rhs.data.numberValue ? .stepInto : .stepOver
            case "less than or equal to":
                return lhs.data.numberValue <= rhs.data.numberValue ? .stepInto : .stepOver
            default:
                break
            }
        default:
            break
        }
        
        return .stepOver
    },
    updateScope: { _ in }
)

let CSIfExistsFunction = CSFunction(
    name: "If",
    description: "Check if a value exists",
    parameters: [
        CSFunction.Parameter(label: nil, name: "value", type: .variable(type: CSGenericTypeA, access: .read)),
        ],
    hasBody: true,
    invoke: { arguments, scope in
        let value: CSValue = arguments["value"]!.resolve(in: scope)
        
        if value.data.isNull {
            return .stepOver
        }
        
        return .stepInto
    },
    updateScope: { _ in }
)

let CSDefineFunction = CSFunction(
    name: "Let",
    description: "Declare a variable",
    parameters: [
        CSFunction.Parameter(label: nil, name: "variable", type: .declaration()),
        CSFunction.Parameter(label: "equal", name: "value", type: .variable(type: CSGenericTypeA, access: .read)),
        ],
    hasBody: false,
    invoke: { arguments, scope in
        let variable: CSValue = arguments["variable"]!.resolve(in: scope)
        let value: CSValue = arguments["value"]!.resolve(in: scope)
        
//        Swift.print("Let", variable, "equal", value)
        
        let s: CSScope = scope
        if let name = variable.data.string {
            s.declare(variable: name, as: (value: value, access: CSAccess.write))
        }
        
//        Swift.print("Scope", variable.data.stringValue, s.get(value: variable.data.stringValue))
        
        return .stepOver
    },
    updateScope: { arguments, scope in
        let variable: CSValue = arguments["variable"]!.resolve(in: scope)
        let value: CSValue = arguments["value"]!.resolve(in: scope)
        
        if let name = variable.data.string {
            scope.declare(variable: name, as: (value: value, access: CSAccess.write))
        }
    }
)

let CSAddFunction = CSFunction(
    name: "Add",
    description: "Add two values",
    parameters: [
        CSFunction.Parameter(label: nil, name: "lhs", type: .variable(type: CSGenericTypeA, access: .read)),
        CSFunction.Parameter(label: "to", name: "rhs", type: .variable(type: CSGenericTypeA, access: .read)),
        CSFunction.Parameter(label: "and assign to", name: "value", type: .variable(type: CSGenericTypeA, access: .write)),
        ],
    hasBody: false,
    invoke: { arguments, scope in
        let lhs: CSValue = arguments["lhs"]!.resolve(in: scope)
        let rhs: CSValue = arguments["rhs"]!.resolve(in: scope)
        
        guard case CSFunction.Argument.identifier(_, let valueKeyPath) = arguments["value"]! else { return .stepOver }
        
        switch lhs.type {
        case CSType.number:
            scope.set(keyPath: valueKeyPath, to: CSValue(type: CSType.number, data: CSData.Number(lhs.data.numberValue + rhs.data.numberValue)))
        case CSType.string:
            scope.set(keyPath: valueKeyPath, to: CSValue(type: CSType.string, data: CSData.String(lhs.data.stringValue + rhs.data.stringValue)))
        default:
            break
        }

        return .stepOver
    },
    updateScope: { _ in }
)

//let CSAppendFunctionInvocation: (CSFunction.NamedArguments, CSScope) -> CSFunction.ReturnValue = { arguments, scope in
//    let componentValue = arguments["component"]!.resolve(in: scope)
//    let baseValue = arguments["base"]!.resolve(in: scope)
//    guard case CSFunction.Argument.identifier(_, let baseKeyPath) = arguments["base"]! else { return (scope, .stepOver) }
//
//    let result = CSValue(type: CSURLType, data: CSData.String(baseValue.data.stringValue + componentValue.data.stringValue))
//    scope.set(keyPath: baseKeyPath, to: result)
//
//    return (scope, .stepOver)
//}

//let CSAppendFunction = CSFunction(
//    name: "Append",
//    parameters: [
//        CSFunction.Parameter(
//            label: "the component",
//            name: "component",
//            type: CSFunction.ParameterType.variable(type: CSType.string, access: .read)
//        ),
//        CSFunction.Parameter(
//            label: "to",
//            name: "base",
//            type: CSFunction.ParameterType.variable(type: CSURLType, access: .write)
//        ),
//    ],
//    hasBody: false,
//    invoke: CSAppendFunctionInvocation
//)

