//
//  CSValueField.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/5/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

class CSValueField: CSControl {
    enum Options {
        case isBordered
        case drawsBackground
        case usesLinkStyle

        // For instant feedback when typing
        case submitOnChange
    }

    var data: CSData {
        get { return value.data }
        set { value.data = newValue }
    }

    var onChangeData: (CSData) -> Void = { _ in }

    var value: CSValue = CSValue.init(type: CSAnyType, data: CSData.Null)

    var view: NSView = NSView()

    var subfields: [CSValueField] = []

    func styled(string: String, usesLinkStyle: Bool) -> NSAttributedString {
        if usesLinkStyle {
            return NSAttributedString(string: string, attributes: editableFontAttributes)
        } else {
            return NSAttributedString(string: string)
        }
    }

    init(value: CSValue, options: [Options: Bool] = [:]) {
        self.value = value

        setup(value: value, options: options)
    }

    func setup(value: CSValue, options: [Options: Bool]) {
        let isBordered = options[Options.isBordered] ?? false
        let drawsBackground = options[Options.drawsBackground] ?? false
        let submitOnChange = options[Options.submitOnChange] ?? false
        let usesLinkStyle = options[Options.usesLinkStyle] ?? true

        let defaultChangeHandler: (CSData) -> Void = { [weak self] data in
            guard let field = self else {
                Swift.print("Cannot call defaultChangeHandler() - self has been deallocated")
                return
            }

            field.value = CSValue(type: value.type, data: data)
            field.onChangeData(field.data)
        }

        func renderDropdown(tags: [String], initialTag: String) -> PopupField {
            let type = PopupField(
                frame: NSRect(x: 0, y: 0, width: 70, height: 26),
                values: tags,
                initialValue: initialTag)

            let attributedString = styled(string: initialTag, usesLinkStyle: usesLinkStyle)
            let size = attributedString.measure(width: 1000)

            type.frame.size = size
            type.frame.size.width += 24
            type.isBordered = isBordered

            for item in type.menu!.items {
                let desc = String(describing: item.title)
                let text = styled(string: desc, usesLinkStyle: usesLinkStyle)
                item.attributedTitle = text
            }

            return type
        }

        switch value.type {
        case .string:
            let field = TextField(frame: NSRect(x: 0, y: 0, width: 80, height: 16))

            field.isBordered = isBordered
            field.isBezeled = isBordered
            field.drawsBackground = drawsBackground
            field.usesSingleLineMode = true
            field.tag = EDITABLE_TEXT_FIELD_TAG

            let desc = String(describing: value.data.stringValue)
            let text = styled(string: desc, usesLinkStyle: usesLinkStyle)

            field.attributedStringValue = text

            field.frame.size = text.measure(width: 1000)
            field.frame.size.width = max(field.frame.size.width, 30)
            field.frame.size.width += 4

            let widthConstraint = field.widthAnchor.constraint(equalToConstant: field.frame.size.width)
            widthConstraint.priority = .defaultHigh
            widthConstraint.isActive = true

            if submitOnChange {
                field.onChangeData = defaultChangeHandler
            } else {
                field.onSubmitData = defaultChangeHandler
            }

            view = field
        case .number, .wholeNumber:
            let field = NumberField(frame: NSRect(x: 0, y: 0, width: 80, height: 16))

            field.isBordered = isBordered
            field.isBezeled = isBordered
            field.drawsBackground = drawsBackground
            field.usesSingleLineMode = true
            field.tag = EDITABLE_TEXT_FIELD_TAG

            let desc = String(describing: value.data.numberValue)
            let text = styled(string: desc, usesLinkStyle: usesLinkStyle)

            field.attributedStringValue = text

            field.frame.size = text.measure(width: 1000)
            field.frame.size.width = max(field.frame.size.width, 30)
            field.frame.size.width += 4

            let widthConstraint = field.widthAnchor.constraint(equalToConstant: field.frame.size.width)
            widthConstraint.priority = .defaultHigh
            widthConstraint.isActive = true

            if submitOnChange {
                field.onChangeData = defaultChangeHandler
            } else {
                field.onSubmitData = defaultChangeHandler
            }

            view = field
        case .bool:
            let field = CheckboxField(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
            view = field

            field.value = value.data.boolValue
            field.onChangeData = defaultChangeHandler
            field.imagePosition = .imageOnly
        case .named("LonaParameter", _):
            let inputType = CSType(value.data)
            let typeName = CSUnitValue.wrap(in: CSType.parameterType(), tagged: inputType.toString())
            let typeField = CSValueField(value: typeName, options: options)

            subfields.append(typeField)

            typeField.onChangeData = { data in
                let type = CSType.from(string: CSValue(type: CSType.parameterType(), data: data).tag())
                defaultChangeHandler(type.toData())
            }

            let stackView = NSStackView(views: [typeField.view], orientation: .horizontal)

            typeField.view.translatesAutoresizingMaskIntoConstraints = false
            stackView.translatesAutoresizingMaskIntoConstraints = false

            view = stackView

            switch inputType {
            case .array(let elementType):
                let elementValue = CSValue(type: CSType.namedParameterType(), data: elementType.toData())
                let elementField = CSValueField(value: elementValue, options: options)

                subfields.append(elementField)
                stackView.addArrangedSubview(elementField.view)

                elementField.onChangeData = { data in
                    let newElementType = CSType(data)

                    if elementType == newElementType { return }

                    defaultChangeHandler(CSType.array(newElementType).toData())
                }
            case .dictionary(let schema):
                let recordFieldType = CSType.dictionary([
                    "key": (CSType.string, .write),
                    "type": (CSType.namedParameterType(), .write),
                    "optional": (CSType.bool, .write)
                    ])
                let recordFieldsType = CSType.array(recordFieldType)
                let fieldsData: [CSData] = schema.enumerated().map({ arg in
                    let (key, value) = arg.element
                    return CSData.Object([
                        "key": key.toData(),
                        "type": (value.type.isOptional() ? value.type.unwrapOptional()! : value.type).toData(),
                        "optional": value.type.isOptional().toData()
                        ])
                })
                let fieldsValue = CSValue(type: recordFieldsType, data: CSData.Array(fieldsData))
                let fieldsField = CSValueField(value: fieldsValue, options: options)

                subfields.append(fieldsField)
                stackView.addArrangedSubview(fieldsField.view)

                fieldsField.onChangeData = { data in
                    let newSchema: CSType.Schema = data.arrayValue.key({ field in
                        let key = field.get(key: "key").stringValue
                        let type = CSType(field.get(key: "type"))
                        let optional = field.get(key: "optional").boolValue
                        return (key: key, value: (type: optional ? type.makeOptional() : type, access: .write))
                    })

                    // TODO: Don't call this if the new schema hasn't changed
                    defaultChangeHandler(CSType.dictionary(newSchema).toData())
                }
            default:
                break
            }

        case .named("Component", _):
            let field = ComponentEditorButton(value: value, onChangeData: defaultChangeHandler)

            view = field

            field.frame = NSRect(x: 0, y: -2, width: 120, height: 26)

        case .named("Color", .string):
            let field = ColorPickerButton(frame: NSRect(x: 0, y: -2, width: 120, height: 26))
            view = field

            field.value = value.data.stringValue
            field.onChangeData = defaultChangeHandler
        case .named("TextStyle", .string):
            let field = TextStylePickerButton(frame: NSRect(x: 0, y: -2, width: 120, height: 26))
            view = field

            field.value = value.data.stringValue
            field.onChangeData = defaultChangeHandler
        case .named("Shadow", .string):
            let field = ShadowStylePickerButton(frame: NSRect(x: 0, y: -2, width: 120, height: 26))
            view = field

            field.value = value.data.stringValue
            field.onChangeData = defaultChangeHandler
        case .named("URL", .string):
            let button = Button(frame: NSRect(x: 0, y: -2, width: 80, height: 26))
            button.setButtonType(.momentaryPushIn)
            button.imagePosition = .noImage
            button.alignment = .left
            button.bezelStyle = .rounded
            button.title = "Browse..."
            button.onPress = {
                let dialog = NSOpenPanel()

                dialog.title = "Choose a file or directory"
                dialog.showsResizeIndicator = true
                dialog.showsHiddenFiles = false
                dialog.canCreateDirectories = true
                dialog.canChooseDirectories = true
                dialog.canChooseFiles = true
                dialog.allowsMultipleSelection = false

                if dialog.runModal() == NSApplication.ModalResponse.OK {
                    defaultChangeHandler(CSData.String(dialog.url!.absoluteString))
                }
            }

            let stringField = CSValueField(value: value.unwrappedNamedType(), options: options)
            stringField.onChangeData = defaultChangeHandler

            subfields.append(stringField)

            let field = NSStackView(views: [
                stringField.view,
                button
                ], orientation: .horizontal)

//            field.heightAnchor.constraint(equalToConstant: 30).isActive = true

            field.translatesAutoresizingMaskIntoConstraints = false
            button.translatesAutoresizingMaskIntoConstraints = false
            stringField.view.translatesAutoresizingMaskIntoConstraints = false

            view = field
        case .variant(let cases):
            if cases.isEmpty {
                Swift.print("Empty variant for value", value)
                return
            }

            let tags = cases.map({ value in value.0 })
            let currentTag = tags.contains(value.tag()) ? value.tag() : tags[0]

            let tagField = renderDropdown(tags: tags, initialTag: currentTag)
            tagField.onChange = { tag in
                defaultChangeHandler(value.with(tag: tag).data)
            }

            var valueField: CSValueField? = nil

            // If we have a valid variant case
            if let unwrapped = value.unwrapVariant() {
                if unwrapped.type != .unit {
                    valueField = CSValueField(value: unwrapped, options: options)
                    valueField?.onChangeData = { newData in
                        defaultChangeHandler(value.with(data: newData).data)
                    }
                }
            // If we don't have a valid variant case, we the default value of the first possible case
            } else if let currentType = cases.first(where: { item in item.0 == currentTag })?.1 {
                valueField = CSValueField(value: CSValue.defaultValue(for: currentType), options: options)
                valueField?.onChangeData = { newData in
                    defaultChangeHandler(
                        CSValue(type: currentType, data: newData).wrap(in: value.type, tagged: currentTag).data)
                }
            } else {
                valueField = CSValueField(value: CSUndefinedValue, options: options)
            }

            if let valueField = valueField {
                subfields.append(valueField)
            }

            let stackedViews: [NSView] = [tagField, valueField?.view].compactMap { $0 }
            let field = NSStackView(views: stackedViews, orientation: .horizontal)

//            field.heightAnchor.constraint(equalToConstant: 30).isActive = true

            tagField.translatesAutoresizingMaskIntoConstraints = false
            valueField?.view.translatesAutoresizingMaskIntoConstraints = false
            field.translatesAutoresizingMaskIntoConstraints = false

            view = field

        // Generic fallthrough for user types
        case .named(_, let type):
            let innerValue = CSValue(type: type, data: value.data)

            setup(value: innerValue, options: options)

            if var view = view as? CSControl {
                view.onChangeData = { [unowned self] data in
                    self.value = CSValue(type: value.type, data: data)
                    self.onChangeData(self.data)
                }
            }
        case .dictionary:
            let field = DictionaryEditorButton(value: value, onChangeData: defaultChangeHandler)

            view = field

            field.frame = NSRect(x: 0, y: -2, width: 120, height: 26)
        case .array:
            let field = ArrayEditorButton(frame: NSRect(x: 0, y: -2, width: 120, height: 26))
            view = field

            field.value = value
            field.onChangeData = defaultChangeHandler
        case .null:
            let field = TextField(frame: NSRect(x: 0, y: 0, width: 80, height: 16))
            view = field

            field.isBordered = isBordered
            field.drawsBackground = drawsBackground
            field.isEditable = false
            field.usesSingleLineMode = true

            let text = NSAttributedString(string: "null", attributes: disabledFontAttributes)
            field.attributedStringValue = text

            field.frame.size = text.measure(width: 1000)
            field.frame.size.width += 4

            let widthConstraint = field.widthAnchor.constraint(equalToConstant: field.frame.size.width)
            widthConstraint.priority = .defaultHigh
            widthConstraint.isActive = true
        default:
            break
        }
    }
}
