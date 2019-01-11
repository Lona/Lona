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
        let states: [AccessibilityStates] = [.disabled, .selected].filter { self.contains($0) }

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

    var typeName: String {
        switch self {
        case .auto:
            return "auto"
        case .none:
            return "none"
        case .element:
            return "element"
        case .container:
            return "container"
        }
    }

    var element: AccessibilityElement? {
        if case .element(let element) = self {
            return element
        } else {
            return nil
        }
    }

    var label: String? { return element?.label }
    var hint: String? { return element?.hint }
    var role: AccessibilityRole? { return element?.role }
    var states: AccessibilityStates { return element?.states ?? .none }
    var elements: [String] {
        switch self {
        case .container(let elements):
            return elements
        default:
            return []
        }
    }

    func withType(_ typeName: String) -> AccessibilityType {
        switch typeName {
        case "auto":
            return .auto
        case "none":
            return .none
        case "element":
            if case .element = self {
                return self
            } else {
                return .element(AccessibilityElement(label: nil, hint: nil, role: nil, states: .none))
            }
        case "container":
            if case .container = self {
                return self
            } else {
                return .container([])
            }
        default:
            return .auto
        }
    }

    func withLabel(_ label: String?) -> AccessibilityType {
        if case .element(var element) = self {
            element.label = label
            return .element(element)
        } else {
            return self
        }
    }

    func withHint(_ hint: String?) -> AccessibilityType {
        if case .element(var element) = self {
            element.hint = hint
            return .element(element)
        } else {
            return self
        }
    }

    func withElements(_ elements: [String]) -> AccessibilityType {
        if case .container = self {
            return .container(elements)
        } else {
            return self
        }
    }
}

extension AccessibilityType: CSDataDeserializable {
    init(_ data: CSData) {
        let accessibilityType = data.get(key: "accessibilityType").string ?? "auto"

        switch accessibilityType {
        case "auto":
            self = AccessibilityType.auto
        case "none":
            self = AccessibilityType.none
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
            self = AccessibilityType.auto
        }
    }
}

extension AccessibilityType: CSDataSerializable {
    func toData() -> CSData {
        var data: CSData = CSData.Object([:])

        switch self {
        case .auto:
            // This is the default, no need to write to file
            break
        case .none:
            data["accessibilityType"] = "none".toData()
        case .element(let element):
            data["accessibilityType"] = "element".toData()
            data["accessibilityLabel"] = element.label?.toData()
            data["accessibilityHint"] = element.hint?.toData()
            data["accessibilityRole"] = element.role?.rawValue.toData()

            let stateStrings = element.states.strings
            if stateStrings.count > 0 {
                data["accessibilityStates"] = stateStrings.toData()
            }
        case .container(let elements):
            data["accessibilityType"] = "container".toData()
            data["accessibilityElements"] = elements.toData()
        }

        return data
    }
}
