//
//  MultipleSelectionButton.swift
//  LonaStudio
//
//  Created by Devin Abbott on 1/10/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

class MultipleSelectionButton: NSButton, NSPopoverDelegate {

    var options: [String] = []

    private var internalSelectedIndices: [Int] = []

    var selectedIndices: [Int] = [] {
        didSet {
            if let editor = editor {
                editor.list = listValue(from: selectedIndices)
                editor.reloadData()
            }
            internalSelectedIndices = selectedIndices
            setButtonTitle(value: "[\(selectedIndices.count) Values]")
        }
    }

    var onChangeSelectedIndices: ([Int]) -> Void = {_ in}

    func setup() {
        action = #selector(handleClick)
        target = self

        setButtonType(.momentaryPushIn)
        imagePosition = .imageLeft
        alignment = .left
        bezelStyle = .rounded

        setButtonTitle(value: "[0 Values]")
    }

    func setButtonTitle(value: String) {
        title = value
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    class ArrayItem: DataNode {
        var value: Int

        init(value: Int) {
            self.value = value
        }

        func childCount() -> Int { return 0 }
        func child(at index: Int) -> Any { return 0 }
    }

    func listValue(from array: [Int]) -> [ArrayItem] {
        return array.map({ item in ArrayItem(value: item) })
    }

    func arrayValue(from list: [ArrayItem]) -> [Int] {
        return list.map({ item in item.value })
    }

    var availableOptions: [Int] {
        return options.enumerated().filter({ !internalSelectedIndices.contains($0.offset) }).map({ $0.offset })
    }

    var editor: ListEditor<ArrayItem>?

    func popoverWillClose(_ notification: Notification) {
        onChangeSelectedIndices(internalSelectedIndices)
    }

    func showPopover() {
        let frame = NSRect(x: 0, y: 0, width: 250, height: 400)

        func onAddElement() {
            guard
                let editor = self.editor,
                let availableIndex = availableOptions.first
                else { return }

            let item = ArrayItem(value: availableIndex)

            editor.list.append(item)
            editor.reloadData()
            editor.select(item: item, ensureVisible: true)

            internalSelectedIndices = arrayValue(from: editor.list)
        }

        func onRemoveElement(_ item: ArrayItem) {
            guard let editor = self.editor, let index = editor.list.firstIndex(where: { $0 === item }) else { return }

            editor.list.remove(at: index)
            editor.reloadData()

            internalSelectedIndices = arrayValue(from: editor.list)
        }

        func onMoveElement(_ item: ArrayItem) {
            guard let editor = self.editor else { return }

            internalSelectedIndices = arrayValue(from: editor.list)
        }

        func viewFor(_ item: ArrayItem) -> NSView {
            let frame = NSRect(x: 0, y: 0, width: 2000, height: 26)

            let itemTitle = self.options[item.value]
            let availableOptionsType = CSType.variant(tags: availableOptions.map({ self.options[$0] }) + [itemTitle] )
            let components: [CSStatementView.Component] = [
                .value("value", CSUnitValue.wrap(in: availableOptionsType, tagged: itemTitle), [])
            ]

            let cell = CSStatementView(
                frame: frame,
                components: components
            )

            cell.onChangeValue = { [unowned self] name, value, _ in
                guard let editor = self.editor else { return }

                switch name {
                case "value":
                    if let selectedIndex = self.options.firstIndex(of: value.tag()) {
                        item.value = selectedIndex
                    }
                default:
                    break
                }

                editor.reloadData()

                self.internalSelectedIndices = self.arrayValue(from: editor.list)
            }

            return cell
        }

        let editor = ListEditor<ArrayItem>(frame: frame, options: [
            .onAddElement(onAddElement),
            .onRemoveElement(onRemoveElement),
            .onMoveElement(onMoveElement),
            .viewFor(viewFor)
        ])
        self.editor = editor

        let vc = NSViewController()
        vc.view = editor

        editor.list = listValue(from: selectedIndices)
        editor.reloadData()

        let popover = NSPopover()
        popover.delegate = self
        popover.contentSize = NSSize(width: 300, height: 200)
        popover.behavior = .semitransient
        popover.animates = false
        popover.contentViewController = vc

        popover.show(relativeTo: NSRect.zero, of: self, preferredEdge: .maxY)
    }

    @objc func handleClick() {
        showPopover()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
