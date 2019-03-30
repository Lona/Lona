//
//  CSSearchField.swift
//  ComponentStudio
//
//  Created by devin_abbott on 10/27/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

class CSSearchField: NSSearchField, NSSearchFieldDelegate {

    enum Option {
        case onChange((String) -> Void)
        case onKeyPress((KeyCode) -> Void)
        case placeholderText(String)
    }

    private struct Options {
        var onChange: (String) -> Void = {_ in}
        var onKeyPress: (KeyCode) -> Void = {_ in}
        var placeholderText: String = ""

        mutating func merge(options: [Option]) {
            options.forEach({ option in
                switch option {
                case .onChange(let value): onChange = value
                case .onKeyPress(let value): onKeyPress = value
                case .placeholderText(let value): placeholderText = value
                }
            })
        }

        init(_ options: [Option]) {
            merge(options: options)
        }
    }

    enum KeyCode {
        case up, down, enter
    }

    var onChange: (String) -> Void

    var onKeyPress: (KeyCode) -> Void

    func controlTextDidChange(_ obj: Notification) {
        onChange(stringValue)
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(moveUp(_:)) {
            onKeyPress(KeyCode.up)
            return true
        } else if commandSelector == #selector(moveDown(_:)) {
            onKeyPress(KeyCode.down)
            return true
        } else if commandSelector == #selector(insertNewline(_:)) {
            onKeyPress(KeyCode.enter)
            return true
        }

        return false
    }

    init(options optionsList: [Option]) {
        let options = Options(optionsList)

        self.onChange = options.onChange
        self.onKeyPress = options.onKeyPress

        super.init(frame: NSRect.zero)
        delegate = self
        translatesAutoresizingMaskIntoConstraints = false

        isBordered = true
        drawsBackground = true

        wantsLayer = true
        layer = CALayer()

        backgroundColor = NSColor.white
        layer?.backgroundColor = NSColor.white.cgColor // double-bumped!
        layer?.borderColor = NSColor.parse(css: "rgba(0,0,0,0.2)")!.cgColor
        layer?.borderWidth = 1
        layer?.cornerRadius = 10
        textColor = NSColor.black
        focusRingType = .none

        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: NSColor.parse(css: "rgba(0,0,0,0.5)")!
        ]
        let placeholderAttributedString = NSMutableAttributedString(string: options.placeholderText, attributes: placeholderAttributes)

        self.placeholderAttributedString =  placeholderAttributedString
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
