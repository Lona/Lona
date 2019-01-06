import Foundation
import Cocoa

class NSMenuItemView: NSView {
    var handleChange: () -> Void
    var selected: Bool = false {
        didSet {
            let color = selected ? NSColor.selectedMenuItemTextColor : Colors.textColor
            let backgroundColor = selected ? NSColor.selectedMenuItemColor : NSColor.clear

            colorizeText(view: self, color: color, backgroundColor: backgroundColor)
            layer?.backgroundColor = backgroundColor.cgColor
        }
    }

    init(frame frameRect: NSRect, subview: NSView, onChange: @escaping () -> Void) {
        self.handleChange = onChange

        super.init(frame: frameRect)

        self.autoresizingMask.insert(NSView.AutoresizingMask.width)

        wantsLayer = true

        let backgroundField = NSTextField(frame: frameRect)
        backgroundField.autoresizingMask.insert(NSView.AutoresizingMask.width)

        addSubview(backgroundField)
        addSubview(subview)
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return false
    }

    func performAction() {
        guard let item = enclosingMenuItem else { return }
        guard let menu = item.menu else { return }
        menu.cancelTracking()
        menu.performActionForItem(at: menu.index(of: item))
    }

    // Was this the selected item when the menu opened? If so, a mouseup shouldn't
    // trigger this item. (Although it does anyway, but only after the mouse has
    // moved a bit, so it's fine)
    var initiallySelected = false

    var performActionOnMouseUp = false

    func reset(selected: Bool) {
        performActionOnMouseUp = false
        initiallySelected = selected
    }

    override func mouseUp(with event: NSEvent) {
        if initiallySelected {
            if performActionOnMouseUp {
                performAction()
            }
        } else {
            performAction()
        }
    }

    // The next mouseUp should trigger the action. This is if you click the initially
    // selected item without first moving the mouse out.
    override func mouseDown(with event: NSEvent) {
        performActionOnMouseUp = true
    }

    // Since the mouse initially begins on top of the selected item, we don't want to
    // listen to the mouseUp unless the mouse has first exited the item
    override func mouseExited(with event: NSEvent) {
        if performActionOnMouseUp { return }
        performActionOnMouseUp = true
    }

    func colorizeText(view: NSView, color: NSColor, backgroundColor: NSColor) {
        for subview in view.subviews {
            if let text = subview as? NSTextField {
                text.textColor = color
                text.isBezeled = false
                text.isEditable = false
                text.drawsBackground = false
            } else {
                colorizeText(view: subview, color: color, backgroundColor: backgroundColor)
            }
        }
    }

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()

        let trackingArea = NSTrackingArea(rect: bounds, options: [NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.activeInActiveApp], owner: self, userInfo: nil)

        addTrackingArea(trackingArea)
    }

    override var allowsVibrancy: Bool {
        return true
    }
}

class CustomPopupField<Value: Equatable>: NSPopUpButton, NSMenuDelegate {

    override init(frame buttonFrame: NSRect, pullsDown flag: Bool) {
        super.init(frame: buttonFrame, pullsDown: flag)
    }

    func menuDidClose(_ menu: NSMenu) {
        for item in menu.items {
            guard let view = item.view as? NSMenuItemView else { continue }
            view.reset(selected: item == selectedItem)
        }
    }

    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        for item in menu.items {
            guard let view = item.view as? NSMenuItemView else { continue }
            view.selected = false
            view.needsDisplay = true
        }

        guard let item = item else { return }
        guard let view = item.view as? NSMenuItemView else { return }

        view.selected = true
    }

    init(
        values: [Value],
        initialValue: Value,
        displayValue: (Value) -> String,
        view: (Value) -> NSView,
        onChange: @escaping (Value) -> Void,
        frame frameRect: NSRect = NSRect.zero
    ) {
        super.init(frame: frameRect)

        var values = values

        if !values.contains(initialValue) {
            values.append(initialValue)
        }

        for value in values {
            let item = NSMenuItem(title: displayValue(value), onClick: {
                onChange(value)
            })

            let itemView = view(value)
            let wrapper = NSMenuItemView(frame: itemView.frame, subview: itemView, onChange: {
                onChange(value)
            })

            item.view = wrapper

            if displayValue(initialValue) == displayValue(value) {
                wrapper.initiallySelected = true
            }

            menu?.addItem(item)
            menu?.delegate = self
        }

        selectItem(withTitle: displayValue(initialValue))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
