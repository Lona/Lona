//
//  PickerView.swift
//  LonaStudio
//
//  Created by Nghia Tran on 12/24/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

final class PickerView<Element>: NSView {
    
    enum Option {
        case placeholderText(String)
        case selected(String)
        case data([Element])
        case viewForItem((NSTableView, Element) -> NSView)
        case didSelectItem((Element) -> Void)
        case heightOfRow((Int) -> CGFloat)
    }
    
    struct Options {
        var placeholderText: String!
        var selected: String!
        var data: [Element]!
        var viewForItem: ((NSTableView, Element) -> NSView)!
        var didSelectItem: ((Element) -> Void)!
        var heightOfRow: ((Int) -> CGFloat)?
        
        init(_ options: [Option]) {
            for option in options {
                switch option {
                case .placeholderText(let value):
                    placeholderText = value
                case .data(let value):
                    data = value
                case .didSelectItem(let f):
                    didSelectItem = f
                case .viewForItem(let f):
                    viewForItem = f
                case .heightOfRow(let f):
                    heightOfRow = f
                case .selected(let value):
                    selected = value
                }
            }
        }
    }
    
    // MARK: - Variable
    fileprivate let options: Options
    
    // MARK: - Init
    init(options: [Option]) {
        self.options = PickerView<Element>.Options(options)
        super.init(frame: NSRect.zero)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Override
    override var isFlipped: Bool { return true }
    
    // MARK: - Public
    func embeddedViewController() -> NSViewController {
        let controller = NSViewController(view: self)
        return controller
    }
}

// MARK: - Private
extension PickerView {
    
    fileprivate func setupLayout() {
        
    }
}
