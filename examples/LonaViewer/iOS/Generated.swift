//
//  Generated.swift
//  iOS
//
//  Created by Jason Zurita on 3/4/18.
//  Copyright © 2018 Lona. All rights reserved.
//

import UIKit

enum Generated: String {
    case collectionTest = "Collection Test"
    case accessibilityTest = "Accessibility Test"
    case localAsset = "Local Asset"
    case vectorAsset = "Vector Asset"
    case vectorLogicActive = "Vector Logic - Active"
    case vectorLogicInactive = "Vector Logic - Inactive"
    case imageCropping = "Image Cropping"
    case repeatedVector = "Repeated Vector"
    case nestedComponent = "Nested Component"
    case nestedButtons = "Nested Buttons"
    case button = "Button"
    case pressableRootView = "Pressable Root View"
    case fitContentParentSecondaryChildren = "Fit Content Parent Secondary Children"
    case fixedParentFillAndFitChildren = "Fixed Parent Fill and Fit Children"
    case fixedParentFitChild = "Fixed Parent Fit Child"
    case primaryAxis = "Primary Axis"
    case primaryAxisFillSiblings = "Primary Fill Siblings"
    case primaryAxisFillNestedSiblings = "Primary Fill Nested Siblings"
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
    case shadowsTest = "Shadow Test"
    case opacityTest = "Opacity Test"
    case visibilityTest = "Visibility Test"
    case optionals = "Optionals"
    case inlineVariantTest = "Inline Variant Test"

    static func allValues() -> [Generated] {
        return [
            accessibilityTest,
            collectionTest,
            localAsset,
            vectorAsset,
            vectorLogicActive,
            vectorLogicInactive,
            repeatedVector,
            imageCropping,
            nestedComponent,
            nestedButtons,
            button,
            pressableRootView,
            fitContentParentSecondaryChildren,
            fixedParentFillAndFitChildren,
            fixedParentFitChild,
            primaryAxis,
            primaryAxisFillSiblings,
            primaryAxisFillNestedSiblings,
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
            shadowsTest,
            opacityTest,
            optionals,
            visibilityTest,
            inlineVariantTest
        ]
    }
    
    var view: UIView {
        switch self {
        case .accessibilityTest:
            var checked = false
            let view = AccessibilityTest(customTextAccessibilityLabel: "Custom label", checkboxValue: checked)
            view.onToggleCheckbox = {
                checked = !checked
                view.checkboxValue = checked
            }
            return view
        case .collectionTest:
            let collectionView = LonaCollectionView(
                items: [
                    NestedButtons.Model(),
                    LonaCollectionView.Model(
                      items: [
                        LocalAsset.Model(),
                        LocalAsset.Model(),
                        LocalAsset.Model(),
                        LocalAsset.Model(),
                        LocalAsset.Model(),
                        LocalAsset.Model(),
                        LocalAsset.Model(),
                        LocalAsset.Model(),
                      ],
                      scrollDirection: .horizontal,
                      fixedSize: 100),
                    NestedButtons.Model(),
                    PressableRootView.Model(
                        onPressOuter: { Swift.print("Pressed outer") },
                        onPressInner: { Swift.print("Pressed inner") }
                    ),
                    PrimaryAxisFillNestedSiblings.Model(),
                ])
            collectionView.onSelectItem = { item in
                Swift.print("Selected item", item)
            }
            return collectionView
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
            return BorderWidthColor(alternativeStyle: true)
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
        case .shadowsTest:
            return ShadowsTest()
        case .opacityTest:
            return OpacityTest(selected: true)
        case .visibilityTest:
            return VisibilityTest(enabled: true)
        case .optionals:
            return Optionals(boolParam: true, stringParam: "Hello World")
        case .vectorAsset:
            return VectorAsset()
        case .vectorLogicActive:
            return VectorLogic(active: true)
        case .vectorLogicInactive:
            return VectorLogic(active: false)
        case .repeatedVector:
            return RepeatedVector(active: true)
        case .imageCropping:
            return ImageCropping()
        case .primaryAxisFillSiblings:
            return PrimaryAxisFillSiblings()
        case .primaryAxisFillNestedSiblings:
            return PrimaryAxisFillNestedSiblings()
        case .inlineVariantTest:
            return InlineVariantTest(type: .error)
        }
    }

    var constraints: [Constraint] {
        switch self {
        case .localAsset:
            return [
                equal(\.topAnchor, \.safeAreaLayoutGuide.topAnchor),
                equal(\.leftAnchor),
            ]
        case .accessibilityTest,
             .button,
             .pressableRootView,
             .nestedComponent,
             .nestedButtons,
             .fixedParentFillAndFitChildren,
             .fixedParentFitChild,
             .primaryAxis,
             .primaryAxisFillSiblings,
             .primaryAxisFillNestedSiblings,
             .secondaryAxis,
             .borderWidthColor,
             .textAlignment,
             .fitContentParentSecondaryChildren,
             .boxModelConditionalSmall,
             .boxModelConditionalLarge,
             .shadowsTest,
             .opacityTest,
             .visibilityTest,
             .optionals,
             .vectorAsset,
             .vectorLogicActive,
             .vectorLogicInactive,
             .repeatedVector,
             .textStylesTest,
             .imageCropping,
             .inlineVariantTest:
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
