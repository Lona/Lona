//
//  PickerView.swift
//  LonaStudio
//
//  Created by Nghia Tran on 12/24/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

final class PickerView<Element: PickerItemType>: NSView {
    
    enum Option {
        case placeholderText(String)
        case selected(String)
        case data([Element])
        case viewForItem((NSTableView, Element) -> NSView)
        case didSelectItem((Element) -> Void)
        case sizeForRow((Element) -> NSSize)
    }
    
    struct Options {
        var placeholderText: String!
        var selected: String!
        var data: [Element]!
        var viewForItem: ((NSTableView, Element) -> NSView)!
        var didSelectItem: ((Element) -> Void)!
        var sizeForRow: ((Element) -> NSSize) = { _ in return NSSize(width: 44.0, height: 300)}
        
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
                case .sizeForRow(let f):
                    sizeForRow = f
                case .selected(let value):
                    selected = value
                }
            }
        }
    }
    
    // MARK: - Variable
    fileprivate let options: Options
    fileprivate var currentHover = -1
    
    // MARK: - Init
    init(options: [Option]) {
        self.options = PickerView<Element>.Options(options)
        super.init(frame: NSRect.zero)
        
        initCommon()
        setupLayout()
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
    
    fileprivate func initCommon() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    fileprivate func setupLayout() {
        
        // Components
        let list = PickerListView(options: options)
        let searchStackView = setupSearchView(list)
        
        // Stack View
        let stackView = NSStackView(views: [searchStackView, list], orientation: .vertical, stretched: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 8
        stackView.edgeInsets = EdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        // Constraint
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
    }
    
    private func setupSearchView(_ list: PickerListView<Element>) -> NSStackView {
        let searchField = CSSearchField(options: [
            CSSearchField.Option.placeholderText(options.placeholderText),
            CSSearchField.Option.onChange({ [unowned self] filter in
                
                var data: [Element] = []
                if filter.count == 0 {
                    data = self.options.data
                } else {
                    data = self.options.data.filter { $0.name.lowercased().contains(filter.lowercased()) }
                }
                
                list.update(data: data, selected: self.options.selected)
            }),
            CSSearchField.Option.onKeyPress({ [unowned self] keyCode in
                
                func updateHover(index: Int) {
                    self.currentHover = max(0, min(index, self.options.data.count - 1))
                    list.updateHover(self.currentHover)
                }
                
                switch keyCode {
                case .down:
                    let index = self.currentHover + 1
                    updateHover(index: index)
                case .up:
                    let index = self.currentHover - 1
                    updateHover(index: index)
                case .enter:
                    guard self.currentHover < self.options.data.count else { return }
                    let item = self.options.data[self.currentHover]
                    self.options.didSelectItem(item)
                    break
                }
            })
            ])
        
        let stackView = NSStackView(views: [searchField], orientation: .horizontal, stretched: true)
        stackView.edgeInsets = EdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        return stackView
    }
}
