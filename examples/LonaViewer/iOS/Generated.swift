//
//  Generated.swift
//  iOS
//
//  Created by Jason Zurita on 3/4/18.
//  Copyright © 2018 Lona. All rights reserved.
//

import UIKit

enum Generated: String {
    case localAsset = "Local Asset"
    case pressableRootView = "Pressable Root View"
    case fitContentParentSecondaryChildren = "Fit Content Parent Secondary Children"
    case fixedParentFillAndFitChildren = "Fixed Parent Fill and Fit Children"
    case fixedParentFitChild = "Fixed Parent Fit Child"
    case primaryAxis = "Primary Axis"
    case secondaryAxis = "Secondary Axis"
    case assign = "Assign"
    case ifEnabled = "If - Enabled"
    case ifDisabled = "If - Disabled"
    case borderWidthColor = "Border Width and Color"
    case textStyleConditionalTrue = "Text Style Conditional - True"
    case textStyleConditionalFalse = "Text Style Conditional - False"
    case textStylesTest = "Text Styles Test"
    case textAlignment = "Text Alignment"

    static func allValues() -> [Generated] {
        return [
            localAsset,
            pressableRootView,
            fitContentParentSecondaryChildren,
            fixedParentFillAndFitChildren,
            fixedParentFitChild,
            primaryAxis,
            secondaryAxis,
            assign,
            ifEnabled,
            ifDisabled,
            borderWidthColor,
            textStyleConditionalTrue,
            textStyleConditionalFalse,
            textStylesTest,
            textAlignment,
        ]
    }
    
    var view: UIView {
        switch self {
        case .localAsset:
            return LocalAsset()
        case .pressableRootView:
            return PressableRootView()
        case .fitContentParentSecondaryChildren:
            return FitContentParentSecondaryChildren()
        case .fixedParentFillAndFitChildren:
            return FixedParentFillAndFitChildren()
        case .fixedParentFitChild:
            return FixedParentFitChild()
        case .primaryAxis:
            return PrimaryAxis()
        case .secondaryAxis:
            return SecondaryAxis()
        case .assign:
            return Assign(text: "Hello Lona")
        case .ifEnabled:
            return If(enabled: true)
        case .ifDisabled:
            return If(enabled: false)
        case .borderWidthColor:
            return BorderWidthColor()
        case .textStyleConditionalTrue:
            return TextStyleConditional(large: true)
        case .textStyleConditionalFalse:
            return TextStyleConditional(large: false)
        case .textStylesTest:
            return TextStylesTest()
        case .textAlignment:
            return TextAlignment()
        }
    }

    var constraints: [Constraint] {
        switch self {
        case .localAsset, .pressableRootView:
            return [
                equal(\.topAnchor, \.safeAreaLayoutGuide.topAnchor),
                equal(\.leftAnchor),
            ]
        case .fixedParentFillAndFitChildren,
             .fixedParentFitChild,
             .primaryAxis,
             .secondaryAxis,
             .borderWidthColor,
             .textAlignment:
            return [
                equal(\.topAnchor, \.safeAreaLayoutGuide.topAnchor),
                equal(\.leftAnchor),
                equal(\.rightAnchor),
            ]
        default:
            return [
                equal(\.topAnchor, \.safeAreaLayoutGuide.topAnchor),
                equal(\.bottomAnchor),
                equal(\.leftAnchor),
                equal(\.rightAnchor),
            ]
        }
    }
}
