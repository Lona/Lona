//
//  DimensionSizingRule.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/4/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation

enum DimensionSizingRule {
    case Fixed, Expand, Shrink

    func toString() -> String {
        switch self {
        case .Fixed:
            return "Fixed"
        case .Expand:
            return "Expand"
        case .Shrink:
            return "Shrink"
        }
    }

    static func fromString(rawValue: String?) -> DimensionSizingRule {
        if rawValue == nil {
            return DimensionSizingRule.Expand
        }

        switch rawValue! {
        case "Expand":
            return DimensionSizingRule.Expand
        case "Shrink":
            return DimensionSizingRule.Shrink
        default:
            return DimensionSizingRule.Fixed
        }
    }
}
