//
//  ShadowStylePickerButton.swift
//  LonaStudio
//
//  Created by Nghia Tran on 12/9/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

class ShadowStylePickerButton: NSButton, CSControl {

    // MARK: - Variable
    var data: CSData {
        get { return CSData.String(value) }
        set { value = newValue.stringValue }
    }
    var onChangeData: (CSData) -> Void = { _ in }
    var onChange: (String) -> Void = {_ in}
    var value: String = CSShadows.defaultShadow.id {
        didSet {
            let shadow = CSShadows.shadow(with: value)
            setImage(with: shadow)
            setTitle(with: shadow)
        }
    }
    
    // MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    private func setup() {
        action = #selector(handleClick)
        target = self
        
        setButtonType(.momentaryPushIn)
        imagePosition = .imageLeft
        alignment = .left
        bezelStyle = .rounded
        title = "Custom shadow"
    }
    
    // MARK: - Public
    func showPopover() {
        let picker = ShadowStylePickerView(selectedID: data.string!)
        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = false
        popover.contentViewController = picker.embeddedViewController()
        popover.contentSize = picker.bounds.size
        popover.show(relativeTo: NSRect.zero, of: self, preferredEdge: .maxY)
        picker.onClickFont = { [weak self ] textStyle in
            guard let strongSelf = self else { return }
            popover.close()
            strongSelf.value = textStyle.id
            strongSelf.onChange(strongSelf.value)
            strongSelf.onChangeData(strongSelf.data)
        }
    }
    
    func handleClick() {
        showPopover()
    }
}

extension ShadowStylePickerButton {
    
    fileprivate func setImage(with shadow: CSShadow) {
        image = createCircularImage(size: 10, color: shadow.color)
    }
    
    fileprivate func setTitle(with shadow: CSShadow) {
        if shadow.id == CSShadows.unstyledDefaultName {
            title = "\(shadow.name)"
            return
        }
        title = "\(shadow.name) x: \(shadow.x) y: \(shadow.y) blur: \(shadow.blur)"
    }
}
