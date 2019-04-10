//
//  LabeledLogicInput.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/10/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit
import Logic

// MARK: - LabeledLogicInput

public class LabeledLogicInput: NSBox {

    // MARK: Lifecycle

    public init(titleText: String = "") {
        self.titleText = titleText

        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var titleText: String {
        didSet {
            if titleText != oldValue {
                update()
            }
        }
    }

    public var logicEditor = LogicEditor()

    // MARK: Private

    private var titleView = LNATextField(labelWithString: "")
    private var dividerView = NSBox()

    private func setUpViews() {
        boxType = .custom
        borderType = .lineBorder
        contentViewMargins = .zero
        cornerRadius = 2
        borderColor = Colors.divider

        dividerView.boxType = .custom
        dividerView.borderType = .noBorder
        dividerView.contentViewMargins = .zero
        dividerView.fillColor = Colors.divider

        logicEditor.fillColor = Colors.contentBackground
        logicEditor.showsDropdown = false
        logicEditor.supportsLineSelection = false
        logicEditor.scrollsVertically = false
        logicEditor.canvasStyle.textMargin.height = 4
        logicEditor.canvasStyle.textMargin.width -= 1

        addSubview(titleView)
        addSubview(dividerView)
        addSubview(logicEditor)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        logicEditor.translatesAutoresizingMaskIntoConstraints = false

        titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        titleView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1).isActive = true

        dividerView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        dividerView.leadingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: 8).isActive = true
        dividerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        dividerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        logicEditor.leadingAnchor.constraint(equalTo: dividerView.trailingAnchor).isActive = true
        logicEditor.topAnchor.constraint(equalTo: topAnchor, constant: 1).isActive = true
        logicEditor.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 2).isActive = true
        logicEditor.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }

    private func update() {
        titleView.attributedStringValue = TextStyles.labelTitle.apply(to: titleText)
    }
}
