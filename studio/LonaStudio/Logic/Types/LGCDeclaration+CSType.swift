//
//  LGCDeclaration+CSType.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/9/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation
import Logic

extension LGCDeclaration {
    init(csType: CSType) {
        switch csType {
        case .named(let name, .variant(let cases)):
            self = .enumeration(
                id: UUID(),
                name: LGCPattern(id: UUID(), name: name),
                genericParameters: .empty,
                cases: LGCList(
                    cases.map {
                        LGCEnumerationCase.enumerationCase(
                            id: UUID(),
                            name: LGCPattern(id: UUID(), name: $0.0),
                            associatedValueTypes: .next(
                                LGCTypeAnnotation(csType: $0.1),
                                .empty
                            )
                        )
                    } + [LGCEnumerationCase.makePlaceholder()]
                )
            )
        default:
            fatalError("Not supported")
        }
    }

    var csType: CSType? {
        switch self {
        case .enumeration(let enumeration):
            return .named(
                enumeration.name.name,
                .variant(
                    enumeration.cases.map {
                        switch $0 {
                        case .enumerationCase(let enumerationCase):
                            return (enumerationCase.name.name, enumerationCase.associatedValueTypes.first?.csType() ?? .unit)
                        case .placeholder:
                            return nil
                        }
                        }.compactMap { $0 }
                )
            )
        default:
            fatalError("Not supported")
        }
    }
}
