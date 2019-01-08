//
//  Accessibility.swift
//  LonaStudio
//
//  Created by Devin Abbott on 1/8/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import Foundation

enum AccessibilityRole: String {
    case none, button, link, search, image, keyboardkey, adjustable, imagebutton, header, summary
}

struct AccessibilityStates: OptionSet {
    let rawValue: Int

    static let disabled = AccessibilityStates(rawValue: 1 << 0)
    static let selected = AccessibilityStates(rawValue: 1 << 1)

    static let none: AccessibilityStates = []
}

extension AccessibilityStates {
    init(_ states: [String]) {
        self = states.reduce(AccessibilityStates.none, { options, state in
            switch state {
            case "disabled":
                return options.intersection(AccessibilityStates.disabled)
            case "selected":
                return options.intersection(AccessibilityStates.selected)
            default:
                Swift.print("WARNING: Unknown accessibility state decoded: `\(state)`")
                return options
            }
        })
    }

    var strings: [String] {
        let states: [AccessibilityStates] = [.disabled, .selected]
        return states.map { state in
            switch state {
            case .disabled:
                return "disabled"
            case .selected:
                return "selected"
            default:
                Swift.print("WARNING: Unknown accessibility state encoded: `\(state)`")
                return ""
            }
        }
    }
}

struct AccessibilityElement {
    var label: String?
    var hint: String?
    var role: AccessibilityRole?
    var states: AccessibilityStates = .none
}

enum AccessibilityType {
    case auto
    case none
    case element(AccessibilityElement)
    case container([String])
}

extension AccessibilityType: CSDataDeserializable {
    init(_ data: CSData) {
        let accessibilityType = data.get(key: "accessibilityType").stringValue

        switch accessibilityType {
        case "none":
            self = AccessibilityType.none
        case "auto":
            self = AccessibilityType.auto
        case "element":
            let label = data.get(key: "accessibilityLabel").string
            let hint = data.get(key: "accessibilityHint").string
            let role = AccessibilityRole(rawValue: data.get(key: "accessibilityRole").stringValue)
            let states = AccessibilityStates(data.get(key: "accessibilityStates").arrayValue.compactMap { $0.string })
            let element = AccessibilityElement.init(label: label, hint: hint, role: role, states: states)
            self = AccessibilityType.element(element)
        case "container":
            let elements = data.get(key: "accessibilityElements").arrayValue.compactMap { $0.string }
            self = AccessibilityType.container(elements)
        default:
            self = AccessibilityType.none
        }
    }
}

extension AccessibilityType: CSDataSerializable {
    func toData() -> CSData {
        var data: CSData = CSData.Object([:])

        switch self {
        case .none:
            data["accessibilityType"] = "none".toData()
        case .auto:
            data["accessibilityType"] = "auto".toData()
        case .element(let element):
            data["accessibilityType"] = "element".toData()
            data["accessibilityLabel"] = element.label?.toData()
            data["accessibilityHint"] = element.hint?.toData()
            data["accessibilityRole"] = element.role?.rawValue.toData()
            data["accessibilityStates"] = element.states.strings.toData()
        case .container(let elements):
            data["accessibilityType"] = "container".toData()
            data["accessibilityElements"] = elements.toData()
        }

        return data
    }
}
