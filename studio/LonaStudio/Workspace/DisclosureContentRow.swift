//
//  DisclosureContentRow.swift
//  ComponentStudio
//
//  Created by devin_abbott on 8/17/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

private class DisclosureHeader: NSStackView {
    var onPress: () -> Void = {}

    override func mouseDown(with event: NSEvent) {
        onPress()
    }

    init(onPress: @escaping () -> Void = {}) {
        super.init(frame: NSRect.zero)
        self.onPress = onPress
        translatesAutoresizingMaskIntoConstraints = false
        orientation = .horizontal
        alignment = .centerY
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class DisclosureContentRow: NSStackView {

    let disclosureContent: NSStackView
    let disclosureArrow: Button
    var disclosureState: Bool
    let title: String

    var contentSpacing: CGFloat {
        get { return disclosureContent.spacing }
        set { disclosureContent.spacing = newValue }
    }

    var contentEdgeInsets: NSEdgeInsets {
        get { return disclosureContent.edgeInsets }
        set { disclosureContent.edgeInsets = newValue }
    }

    func addContent(view: NSView, stretched: Bool = false) {
        disclosureContent.addArrangedSubview(view, stretched: stretched)
    }

    func addContentSpacing(of size: CGFloat, after: NSView? = nil) {
        if let lastSubview = after ?? disclosureContent.arrangedSubviews.last {
            disclosureContent.setCustomSpacing(size, after: lastSubview)
        }
    }

    func toggleViewState(animated: Bool) {
        if disclosureState {
            hideViews(views: [disclosureContent], animated: animated)
            disclosureState = false
            disclosureArrow.state = NSControl.StateValue(rawValue: 0)
        } else {
            showViews(views: [disclosureContent], animated: animated)
            disclosureState = true
            disclosureArrow.state = NSControl.StateValue(rawValue: 1)
        }
        UserDefaults().set(disclosureState, forKey: title)
    }

    convenience init(title: String, views: [NSView], stretched: Bool = false) {
        self.init(title: title)

        for view in views { addContent(view: view, stretched: stretched) }
    }

    init(title: String) {

        // Restore State
        let initialState = UserDefaults().value(forKey: title) as? Bool ?? false
        self.title = title
        self.disclosureState = initialState

        disclosureContent = NSStackView()
        disclosureContent.translatesAutoresizingMaskIntoConstraints = false
        disclosureContent.orientation = .vertical
        disclosureContent.alignment = .leading
        disclosureContent.spacing = 0

        disclosureArrow = Button(frame: NSRect.zero)
        disclosureArrow.translatesAutoresizingMaskIntoConstraints = false
        disclosureArrow.bezelStyle = .disclosure
        disclosureArrow.title = ""
        disclosureArrow.setButtonType(.pushOnPushOff)
        disclosureArrow.state = NSControl.StateValue(rawValue: initialState ? 1 : 0)

        super.init(frame: NSRect.zero)

        self.translatesAutoresizingMaskIntoConstraints = false
        self.orientation = .vertical
        self.spacing = 0

        let disclosureHeader = DisclosureHeader(onPress: {
            self.toggleViewState(animated: true)
        })

        let headerTitle = NSTextField(labelWithAttributedString: TextStyles.sectionTitle.apply(to: title))
        headerTitle.translatesAutoresizingMaskIntoConstraints = false

        let bottomDivider = NSView()
        bottomDivider.translatesAutoresizingMaskIntoConstraints = false
        bottomDivider.backgroundFill = Colors.dividerSubtle.cgColor

        // Adding subviews
        disclosureHeader.addArrangedSubview(disclosureArrow)
        disclosureHeader.addArrangedSubview(headerTitle)

        self.addArrangedSubview(disclosureHeader)
        self.addArrangedSubview(disclosureContent)
        self.addArrangedSubview(bottomDivider)

        // Contraints
        bottomDivider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        disclosureContent.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        disclosureContent.isHidden = !initialState

        disclosureHeader.heightAnchor.constraint(equalToConstant: 50).isActive = true
        disclosureHeader.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true

        // Interactions
        disclosureArrow.onPress = {
            self.toggleViewState(animated: true)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
