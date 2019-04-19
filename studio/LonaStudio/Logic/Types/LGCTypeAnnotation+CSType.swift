//
//  Logic+CSType.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/6/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

extension LGCTypeAnnotation {
    init(csType: CSType) {
        switch csType {
        case .undefined, .null:
            self = .typeIdentifier(
                id: UUID(),
                identifier: LGCIdentifier(id: UUID(), string: "Unit"),
                genericArguments: .empty
            )
        // TODO: Should .any go elsewhere?
        case .any, .unit, .bool, .number, .string, .wholeNumber:
            self = .typeIdentifier(
                id: UUID(),
                identifier: LGCIdentifier(id: UUID(), string: csType.toString()),
                genericArguments: .empty
            )
        case .array(let subType):
            self = .typeIdentifier(
                id: UUID(),
                identifier: LGCIdentifier(id: UUID(), string: csType.toString()),
                genericArguments: .next(LGCTypeAnnotation(csType: subType), .empty)
            )
        case .named(let name, _):
            self = .typeIdentifier(
                id: UUID(),
                identifier: LGCIdentifier(id: UUID(), string: name),
                genericArguments: .empty
            )
        case .function(let paramTypes, let returnType):
            self = .functionType(
                id: UUID(),
                returnType: LGCTypeAnnotation(csType: returnType),
                argumentTypes: LGCList(paramTypes.map { LGCTypeAnnotation(csType: $1) } + [.makePlaceholder()])
            )
        case .generic(_, _):
            fatalError("Not supported")
        case .dictionary(_):
            fatalError("Not supported")
        case .variant(let cases):
            if cases.count == 2 && cases[0].0 == "Some" {
                self = .typeIdentifier(
                    id: UUID(),
                    identifier: LGCIdentifier(id: UUID(), string: "Optional"),
                    genericArguments: .next(LGCTypeAnnotation(csType: cases[0].1), .empty)
                )
            } else {
                fatalError("Not supported")
            }
        }
    }

    func csType(environmentTypes: [CSType] = []) -> CSType? {
        switch self {
        case .placeholder:
            return nil
        case .typeIdentifier(let value):
            if let firstArgument = value.genericArguments.first, let firstType = firstArgument.csType() {
                switch value.identifier.string {
                case "Array":
                    return CSType.array(firstType)
                case "Optional":
                    return firstType.makeOptional()
                default:
                    return nil
                }
            } else {
                for csType in environmentTypes {
                    switch csType {
                    case .named(let name, _) where name == value.identifier.string:
                        return csType
                    default:
                        break
                    }
                }

                return CSType.from(string: value.identifier.string)
            }
        case .functionType(let value):
            if let returnType = value.returnType.csType() {
                let argumentTypes = value.argumentTypes.map { $0.csType() }.compactMap { $0 }.map { ("_", $0) }

                // For backwards compatibility, functions
                if argumentTypes.count == 0, let firstArgument = argumentTypes.first, firstArgument.1 == .unit {
                    return CSType.function([], returnType)
                }

                return CSType.function(argumentTypes, returnType)
            }

            return nil
        }
    }
}
