//
//  LabeledValueInput.swift
//  LonaStudio
//
//  Created by Devin Abbott on 4/12/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

class LabeledValueInput: NSView {

    // MARK: Lifecycle

    public init() {
        super.init(frame: .zero)

        setUpViews()
        setUpConstraints()

        update()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var inputView = NSView()

    public var value: CSValue = CSValue(type: .unit, data: .Null) {
        didSet {
            if oldValue != value {
                if oldValue.type != value.type {
                    inputView.removeFromSuperview()

                    inputView = LabeledValueInput.makeInput(forType: value.type)

                    addSubview(inputView)

                    inputView.translatesAutoresizingMaskIntoConstraints = false

                    inputView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
                    inputView.topAnchor.constraint(equalTo: topAnchor).isActive = true
                    inputView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
                    inputView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
                }

                updateInput(csValue: value)

                update()
            }
        }
    }

    public var onChangeValue: ((CSValue) -> Void)?

    // MARK: Private

    private func setUpViews() {}

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func update() {}

    // MARK: Helpers

    func updateInput(csValue: CSValue) {
        switch csValue.type {
        case CSColorType:
            guard let inputView = inputView as? LabeledColorInput else { return }

            inputView.onChangeColorString = { [unowned self] colorString in
                let newValue = CSValue(type: CSColorType, data: colorString != nil ? .String(colorString!) : .Null)

                self.onChangeValue?(newValue)
            }
        default:
            break
        }
    }

    static func makeInput(forType csType: CSType) -> NSView {
        switch csType {
        case CSColorType:
            return LabeledColorInput(titleText: "Test", colorString: nil)
        default:
            Swift.print("Failed to create value input. Unknown input type \(csType)")
            return NSView()
        }
    }
}
