//
//  ControlledDropdown.swift
//  LonaStudio
//
//  Created by Devin Abbott on 12/9/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit

// MARK: - ControlledDropdown

public class ControlledDropdown: NSPopUpButton {

    // MARK: Lifecycle

    override init(frame buttonFrame: NSRect, pullsDown flag: Bool) {
        self.parameters = Parameters()

        super.init(frame: buttonFrame, pullsDown: flag)
    }

    public convenience init(_ parameters: Parameters = Parameters()) {
        self.init(frame: .zero, pullsDown: false)

        self.parameters = parameters

        setup()
        update()
    }

    public convenience init(values: [String] = [], selectedIndex: Int) {
        self.init(Parameters(values: values, selectedIndex: selectedIndex))
    }

    public required init?(coder aDecoder: NSCoder) {
        self.parameters = Parameters()

        super.init(coder: aDecoder)

        setup()
        update()
    }

    // MARK: Public

    public var parameters: Parameters {
        didSet {
            update()
        }
    }

    public var selectedIndex: Int {
        get { return parameters.selectedIndex }
        set { parameters.selectedIndex = newValue }
    }

    public var values: [String] {
        get { return parameters.values }
        set { parameters.values = newValue }
    }

    public var onChangeIndex: ((Int) -> Void)? {
        get { return parameters.onChangeIndex }
        set { parameters.onChangeIndex = newValue }
    }

    // MARK: Private

    private func update() {
        if itemTitles != parameters.values {
            removeAllItems()
            addItems(withTitles: parameters.values)
        }

        if parameters.selectedIndex != indexOfSelectedItem &&
            parameters.selectedIndex < parameters.values.count {
            selectItem(at: parameters.selectedIndex)
        }
    }

    private func setup() {
        action = #selector(handleChange)
        target = self

        heightAnchor.constraint(equalToConstant: 22).isActive = true
    }

    @objc func handleChange() {
        let newValue = indexOfSelectedItem

        // Don't allow changing to the same value
        if newValue == parameters.selectedIndex { return }

        // Revert the value to before it was toggled
        selectItem(at: parameters.selectedIndex)

        // This view's owner should update the index if needed
        parameters.onChangeIndex?(newValue)
    }
}

// MARK: - Parameters

extension ControlledDropdown {
    public struct Parameters: Equatable {
        public var values: [String]
        public var selectedIndex: Int
        public var onChangeIndex: ((Int) -> Void)?

        public init(values: [String] = [], selectedIndex: Int = -1, onChangeIndex: ((Int) -> Void)? = nil) {
            self.values = values
            self.selectedIndex = selectedIndex
            self.onChangeIndex = onChangeIndex
        }

        public static func == (lhs: ControlledDropdown.Parameters, rhs: ControlledDropdown.Parameters) -> Bool {
            return lhs.values == rhs.values && lhs.selectedIndex == rhs.selectedIndex
        }
    }
}
