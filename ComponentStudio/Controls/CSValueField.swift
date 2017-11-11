//
//  CSValueField.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/5/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

class CSValueField {
    enum Options {
        case isBordered
        case drawsBackground
        case usesLinkStyle
        case usesYogaLayout
        
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
    
    func styled(string: String, usesLinkStyle: Bool) -> NSAttributedString {
        if usesLinkStyle {
            return NSAttributedString(string: string, attributes: editableFontAttributes)
        } else {
            return NSAttributedString(string: string)
        }
    }
    
    init(value: CSValue, options: [Options: Bool] = [:]) {
        setup(value: value, options: options)
    }
        
    func setup(value: CSValue, options: [Options: Bool]) {
        let isBordered = options[Options.isBordered] ?? false
        let drawsBackground = options[Options.drawsBackground] ?? false
        let submitOnChange = options[Options.submitOnChange] ?? false
        let usesLinkStyle = options[Options.usesLinkStyle] ?? true
        let usesYogaLayout = options[Options.usesYogaLayout] ?? true
        
        let defaultChangeHandler: (CSData) -> Void = { data in
            self.value = CSValue(type: value.type, data: data)
            self.onChangeData(self.data)
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
            
            field.frame.size = measureText(string: text, width: 1000)
            field.frame.size.width = max(field.frame.size.width, 30)
            field.frame.size.width += 4
            
            field.useYogaLayout = true
            
            if submitOnChange {
                field.onChangeData = defaultChangeHandler
            } else {
                field.onSubmitData = defaultChangeHandler
            }
            
            view = field
        case .number:
            let field = NumberField(frame: NSRect(x: 0, y: 0, width: 80, height: 16))
            
            field.isBordered = isBordered
            field.isBezeled = isBordered
            field.drawsBackground = drawsBackground
            field.usesSingleLineMode = true
            field.tag = EDITABLE_TEXT_FIELD_TAG
            
            let desc = String(describing: value.data.numberValue)
            let text = styled(string: desc, usesLinkStyle: usesLinkStyle)
            
            field.attributedStringValue = text
            
            field.frame.size = measureText(string: text, width: 1000)
            field.frame.size.width = max(field.frame.size.width, 30)
            field.frame.size.width += 4
            
            field.useYogaLayout = true
            
            if submitOnChange {
                field.onChangeData = defaultChangeHandler
            } else {
                field.onSubmitData = defaultChangeHandler
            }
            
            view = field
        case .bool:
            let field = CheckboxField(frame: NSRect(x: 0, y: 0, width: 20, height: 20))
            view = field
            
            field.useYogaLayout = true
            field.value = value.data.boolValue
            field.onChangeData = defaultChangeHandler
            field.imagePosition = .imageOnly
        case .named("Component", _):
            let field = Button(title: "Set component", onPress: {
//                let layer = CSLayer(name: "Test", type: "View", parameters: ["width": 100], children: [])
                let layer = CSData.Object([
                    "type": "View".toData(),
                    "parameters": CSData.Object([
                        "width": 100.toData(),
                        "height": 100.toData(),
                        "backgroundColor": "babu".toData()
                    ])
                ])
                defaultChangeHandler(layer)
            })
            view = field
            
            field.frame.size = field.intrinsicContentSize
            field.useYogaLayout = true
            
        case .named("Color", .string):
            let field = ColorPickerButton(frame: NSRect(x: 0, y: -2, width: 120, height: 26))
            view = field
            
            field.useYogaLayout = true
            field.value = value.data.stringValue
            field.onChangeData = defaultChangeHandler
        case .named("TextStyle", .string):
            let field = TextStylePickerButton(frame: NSRect(x: 0, y: -2, width: 120, height: 26))
            view = field
            
            field.useYogaLayout = true
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
                
                if dialog.runModal() == NSModalResponseOK {
                    defaultChangeHandler(CSData.String(dialog.url!.absoluteString))
                }
            }
            
            let stringField = CSValueField(value: value.unwrappedNamedType(), options: options)
            stringField.onChangeData = defaultChangeHandler
            
            if usesYogaLayout {
                let field = NSView(frame: NSRect(x: 0, y: 0, width: 220, height: 26))
                
                field.useYogaLayout = true
                field.ygNode?.flexDirection = .row
                field.ygNode?.alignItems = .center
                
                button.useYogaLayout = true
                
                stringField.view.frame.size.width = 140
                stringField.view.useYogaLayout = true
                
                field.addSubview(stringField.view)
                field.addSubview(button)
                
                view = field
            } else {
                let field = NSStackView(views: [
                    stringField.view,
                    button,
                    ], orientation: .horizontal)
                
                field.heightAnchor.constraint(equalToConstant: 30).isActive = true
                
                field.translatesAutoresizingMaskIntoConstraints = false
                button.translatesAutoresizingMaskIntoConstraints = false
                stringField.view.translatesAutoresizingMaskIntoConstraints = false
                
                view = field
            }
            
        // Generic fallthrough for user types
        case .named(_, let type):
            let control = CSValueField(value: CSValue(type: type, data: value.data), options: options)
            
            control.onChangeData = defaultChangeHandler
            
            view = control.view
        case .enumeration(let options):
            let optionValues = options.map({ $0.data.stringValue })
            let type = PopupField(frame: NSRect(x: 0, y: 0, width: 70, height: 26), values: optionValues, initialValue: value.data.string)
            view = type
            
            let attributedString = styled(string: value.data.stringValue, usesLinkStyle: usesLinkStyle)
            let size = measureText(string: attributedString, width: 1000)
            
            type.frame.size = size
            type.frame.size.width += 24
            type.useYogaLayout = true
            type.ygNode?.marginLeft = -7
            type.ygNode?.marginBottom = -1
            type.isBordered = isBordered
            type.value = value.data.stringValue
            
            for item in type.menu!.items {
                let desc = String(describing: item.title)
                let text = styled(string: desc, usesLinkStyle: usesLinkStyle)
                item.attributedTitle = text
            }
            
            type.onChangeData = defaultChangeHandler
        case .dictionary(_):
            let field = DictionaryEditorButton(frame: NSRect(x: 0, y: -2, width: 120, height: 26))
            view = field
            
            field.useYogaLayout = true
            field.value = value
            field.onChangeData = defaultChangeHandler
        case .array(_):
            let field = ArrayEditorButton(frame: NSRect(x: 0, y: -2, width: 120, height: 26))
            view = field
            
            field.useYogaLayout = true
            field.value = value
            field.onChangeData = defaultChangeHandler
        case .null():
            let field = TextField(frame: NSRect(x: 0, y: 0, width: 80, height: 16))
            view = field
            
            field.isBordered = isBordered
            field.drawsBackground = drawsBackground
            field.isEditable = false
            field.usesSingleLineMode = true
            
            let text = NSAttributedString(string: "null", attributes: disabledFontAttributes)
            field.attributedStringValue = text
            
            field.frame.size = measureText(string: text, width: 1000)
            field.frame.size.width += 4
            field.useYogaLayout = true
            field.ygNode?.marginLeft = 2
        default:
            view.useYogaLayout = true
            
            break
        }
    }
}
