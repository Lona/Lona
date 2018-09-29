//
//  Generated.swift
//  iOS
//
//  Created by Jason Zurita on 3/4/18.
//  Copyright © 2018 Lona. All rights reserved.
//

import AppKit

enum Generated: String {
    case localAsset = "Local Asset"
    case nestedComponent = "Nested Component"
    case nestedButtons = "Nested Buttons"
    case button = "Button"
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
    case boxModelConditionalSmall = "Box Model Conditional Small"
    case boxModelConditionalLarge = "Box Model Conditional Large"

    static func allValues() -> [Generated] {
        return [
            localAsset,
            nestedComponent,
            nestedButtons,
            button,
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
            boxModelConditionalSmall,
            boxModelConditionalLarge,
        ]
    }

    var view: NSBox {
        switch self {
        case .localAsset:
            return LocalAsset()
        case .nestedComponent:
            return NestedComponent()
        case .nestedButtons:
            return NestedButtons()
        case .button:
            var count = 0
            let button = Button(label: "Tapped \(count)", secondary: false)
            button.onTap = {
                count += 1
                button.label = "Tapped \(count)"
            }
            return button
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
        case .boxModelConditionalSmall:
            return BoxModelConditional(margin: 4, size: 60)
        case .boxModelConditionalLarge:
            return BoxModelConditional(margin: 20, size: 120)
        }
    }

    var constraints: [Constraint] {
        switch self {
        case .localAsset, .pressableRootView:
            return [
                equal(\.topAnchor),
                equal(\.leftAnchor),
                equal(\.widthAnchor),
            ]
        case .button,
             .nestedComponent,
             .nestedButtons,
             .fixedParentFillAndFitChildren,
             .fixedParentFitChild,
             .primaryAxis,
             .secondaryAxis,
             .borderWidthColor,
             .textAlignment,
             .fitContentParentSecondaryChildren,
             .boxModelConditionalSmall,
             .boxModelConditionalLarge:
            return [
                equal(\.topAnchor),
                equal(\.leftAnchor),
                equal(\.rightAnchor),
            ]
        default:
            return [
                equal(\.topAnchor),
                equal(\.bottomAnchor),
                equal(\.leftAnchor),
                equal(\.rightAnchor),
            ]
        }
    }
}
