//
//  CustomParametersEditorView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/5/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

class CustomParametersEditorView: NSBox {

    // MARK: Lifecycle

    init(parameters: [CSParameter], initialValues: [String: CSData]) {
        self.parameters = parameters

        super.init(frame: .zero)

        self.currentValues = initialValues

        setUpViews()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    public var parameters: [CSParameter]

    public var onSubmit: (([String: CSData]) -> Void)?

    static func presentSheet(titleText: String, parameters: [CSParameter], initialValues: [String: CSData], onCompletion: @escaping ([String: CSData]?) -> Void) {
        let sheetView = CustomParametersEditorView(parameters: parameters, initialValues: initialValues)

        guard let rootViewController = NSApp.mainWindow?.contentViewController else {
            onCompletion(nil)
            return
        }

        let container = CustomParametersEditorSheet(titleText: titleText, cancelText: "Cancel", submitText: "Continue")

        container.customContentView.addSubview(sheetView)

        sheetView.topAnchor.constraint(equalTo: container.customContentView.topAnchor).isActive = true
        sheetView.leadingAnchor.constraint(equalTo: container.customContentView.leadingAnchor).isActive = true
        sheetView.trailingAnchor.constraint(equalTo: container.customContentView.trailingAnchor).isActive = true
        sheetView.bottomAnchor.constraint(equalTo: container.customContentView.bottomAnchor).isActive = true

        let viewController = NSViewController(view: container)

        rootViewController.presentViewControllerAsSheet(viewController)

        container.onSubmit = {
            rootViewController.dismissViewController(viewController)
            onCompletion(sheetView.currentValues)
        }

        container.onCancel = {
            rootViewController.dismissViewController(viewController)
            onCompletion(nil)
        }
    }

    // MARK: Private

    private var customContentView: NSView?

    private func setUpViews() {
        let box = self
        box.boxType = .custom
        box.borderType = .noBorder

        var mounted = true

        // Since onChangeData may be called when removing the content view from the superview,
        // we guard against unwanted calls using the `mounted` variable. We can remove this
        // whenever we improve value field creation.
        let (contentView, valueFields) = CustomParametersEditorView.createContentView(
            for: parameters,
            initialValues: currentValues,
            onChangeData: { [unowned self] data, parameter in
                if !mounted { return }

                mounted = false

                Swift.print("Changed data", parameter.name, data)
                self.currentValues[parameter.name] = data

                self.customContentView?.removeFromSuperview()
                self.valueFields = []

                self.setUpViews()
            }
        )

        self.valueFields = valueFields

        box.addSubview(contentView)

        box.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        contentView.topAnchor.constraint(equalTo: box.topAnchor, constant: 20).isActive = true
        contentView.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 20).isActive = true
        contentView.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -20).isActive = true
        contentView.bottomAnchor.constraint(lessThanOrEqualTo: box.bottomAnchor, constant: -20).isActive = true

        self.customContentView = contentView
    }

    // We need to retain these or they're deallocated
    private var valueFields: [CSValueField] = []

    private var currentValues: [String: CSData] = [:]

    private static var valueFieldOptions: [CSValueField.Options: Bool] = [
        CSValueField.Options.isBordered: true,
        CSValueField.Options.drawsBackground: true,
        CSValueField.Options.submitOnChange: false,
        CSValueField.Options.usesLinkStyle: false,
        CSValueField.Options.usesUrlSavePanel: true
    ]

    private static func createContentView(
        for parameters: [CSParameter],
        initialValues: [String: CSData],
        onChangeData: @escaping (CSData, CSParameter) -> Void)
        -> (contentView: NSView, fields: [CSValueField]) {

        let stackView = NSStackView()

        let views = createValueFields(for: parameters, initialValues: initialValues, onChangeData: onChangeData)
        let valueFields = views.map { $0.field }

        stackView.orientation = .vertical
        stackView.distribution = .fill
        stackView.spacing = 20

        views.map { $0.view }.forEach { (item) in
            stackView.addArrangedSubview(item, stretched: true)
        }

        stackView.translatesAutoresizingMaskIntoConstraints = false

        return (stackView, valueFields)
    }

    private static func createValueFields(
        for parameters: [CSParameter],
        initialValues: [String: CSData],
        onChangeData: @escaping (CSData, CSParameter) -> Void
        ) -> [(view: NSView, field: CSValueField)] {

        let views: [(view: NSView, field: CSValueField)] = parameters.map({ parameter in
            let value = CSValue(type: parameter.type, data: initialValues[parameter.name] ?? CSData.Null)

            let valueField = CSValueField(value: value, options: valueFieldOptions)
            valueField.onChangeData = { data in onChangeData(data, parameter) }
            valueField.view.translatesAutoresizingMaskIntoConstraints = false

            let stackView = NSStackView(
                views: [NSTextField(labelWithString: parameter.name)],
                orientation: .vertical)
            stackView.alignment = .left
            stackView.addArrangedSubview(valueField.view, stretched: !(valueField.view is CheckboxField))
            return (view: stackView, field: valueField)
        })

        for (index, view) in views.enumerated() {
            if index == views.count - 1 { continue }
            view.field.view.nextKeyView = views[index + 1].field.view
        }

        return views
    }
}
