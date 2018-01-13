//
//  ColorPickerView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/10/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Cocoa

final class TextStyleRowView: NSStackView, Hoverable {
    
    // MARK: - Variable
    fileprivate let tickView = NSImageView(image: NSImage(named: NSImage.Name(rawValue: "icon-layer-list-tick"))!)
    fileprivate let titleView: NSTextField
    fileprivate let attributeText: NSAttributedString
    fileprivate lazy var contractAttributeText: NSAttributedString = {
        var highlight = NSMutableAttributedString(attributedString: self.attributeText)
        highlight.addAttributes([NSAttributedStringKey.foregroundColor: NSColor.white],
                                range: NSRange(location: 0, length: self.attributeText.length))
        return highlight
    }()
    var onClick: () -> Void = {}
    
    // MARK: - Init
    init(textStyle: CSTextStyle, selected: Bool) {
        attributeText = textStyle.font.apply(to: textStyle.name)
        titleView = NSTextField(labelWithAttributedString: attributeText)
        super.init(frame: NSRect.zero)
        
        spacing = 8
        orientation = .horizontal
        distribution = .fill
        alignment = .centerY
        edgeInsets = NSEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        tickView.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 251), for: .horizontal)
        
        addArrangedSubview(titleView)
        update(selected: selected)
        
        // Hover
        startTrackingHover()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: NSPoint) -> NSView? {
        return nil
    }
    
    override func mouseDown(with event: NSEvent) {
        onClick()
    }
    
    func update(selected: Bool) {
        if selected {
            guard !arrangedSubviews.contains(tickView) else { return }
            insertArrangedSubview(tickView, at: 0)
            tickView.isHidden = false
        } else {
            guard arrangedSubviews.contains(tickView) else { return }
            removeArrangedSubview(tickView)
            tickView.isHidden = true
        }
    }

    // MARK: - Hover
    override func mouseEntered(with theEvent: NSEvent) {
        onHover(true)
    }
    
    override func mouseExited(with theEvent: NSEvent) {
        onHover(false)
    }
}

// MARK: - PickerRowViewType
extension TextStyleRowView: PickerRowViewType {
    
    func onHover(_ hover: Bool) {
        if hover {
            startHover { [weak self] in
                guard let strongSelf = `self` else { return }
                strongSelf.titleView.attributedStringValue = strongSelf.contractAttributeText
                strongSelf.backgroundFill = NSColor.parse(css: "#0169D9")!.cgColor
            }
        } else {
            stopHover { [weak self] in
                guard let strongSelf = `self` else { return }
                strongSelf.titleView.attributedStringValue = strongSelf.attributeText
                strongSelf.backgroundFill = NSColor.clear.cgColor
            }
        }
    }
}
