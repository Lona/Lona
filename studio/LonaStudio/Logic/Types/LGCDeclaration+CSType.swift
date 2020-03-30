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
                            ),
                            comment: nil
                        )
                    } + [LGCEnumerationCase.makePlaceholder()]
                ),
                comment: nil
            )
        default:
            fatalError("Not supported")
        }
    }

    var csType: CSType? {
        switch self {
        case .enumeration(_, let name, _, let cases, _):
            return .named(
                name.name,
                .variant(
                    cases.map {
                        switch $0 {
                        case .enumerationCase(_, let caseName, let associatedValueTypes, _):
                            return (caseName.name, associatedValueTypes.first?.csType() ?? .unit)
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
