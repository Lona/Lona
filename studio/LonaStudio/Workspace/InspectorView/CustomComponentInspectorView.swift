//
//  ComponentInspectorView.swift
//  LonaStudio
//
//  Created by Nghia Tran on 2/15/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Cocoa

final class CustomComponentInspectorView: NSStackView {

    // MARK: - Lifecycle

    init() {
        super.init(frame: NSRect.zero)

        setUpViews()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public

    var layerName: String = "" {
        didSet {
            if oldValue != layerName {
                update()
            }
        }
    }

    var parameterValues: [String: CSData] = [:] {
        didSet {
            if oldValue != parameterValues {
                update()
            }
        }
    }

    var parameters: [CSParameter] = [] {
        didSet {
            if oldValue != parameters {
                update()
            }
        }
    }

    var onChangeData: (([String: CSData]) -> Void)?

    // MARK: - Private

    private let parametersSection = DisclosureContentRow(title: "Parameters", views: [], stretched: true)

    private func setUpViews() {
        parametersSection.contentSpacing = 8
        parametersSection.contentEdgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)

        orientation = .vertical
        [parametersSection].forEach { (item) in
            addArrangedSubview(item, stretched: true)
        }
        translatesAutoresizingMaskIntoConstraints = false
    }

    private func update() {
        let layerName = self.layerName

        parametersSection.contentViews.enumerated().forEach { index, subview in
            if index > parameters.count - 1 {
                subview.removeFromSuperview()
            }
        }

        parameters.enumerated().forEach { [unowned self] index, parameter in
            if index > parametersSection.contentViews.count - 1 {
                let inputView = LabeledLogicInput(titleText: parameter.name)
                inputView.titleWidth = 75
                inputView.translatesAutoresizingMaskIntoConstraints = false

                parametersSection.addContent(view: inputView, stretched: true)
            }

            guard let inputView = parametersSection.contentViews[index] as? LabeledLogicInput else { return }

            let defaultData: CSData
            if parameter.type.unwrappedNamedType().isOptional() {
                defaultData = CSUnitValue.wrap(in: parameter.type, tagged: "None").data
            } else if parameter.type.unwrappedNamedType().isVariant {
                defaultData = CSValue.defaultValue(for: parameter.type).data
            } else {
                defaultData = CSData.Null
            }

            let value = CSValue(type: parameter.type, data: parameterValues[parameter.name] ?? defaultData)

            inputView.getPasteboardItem = {
                return CSParameter(name: parameter.name, type: parameter.type, defaultValue: value)
                    .makePasteboardItem(withAssignmentTo: layerName)
            }

            inputView.value = value
            inputView.onChangeValue = {[unowned self] value in
                var data = value.data

                if case .named("URL", .string) = value.type, let url = URL(string: data.stringValue) {
                    if url.scheme == nil || url.scheme == "file",
                        let relativePath = url.path.pathRelativeTo(basePath: CSUserPreferences.workspaceURL.path) {
                        data = ("file://" + relativePath).toData()
                    } else {
                        data = url.absoluteString.toData()
                    }
                }

                var updated = self.parameterValues
                updated[parameter.name] = data

                self.onChangeData?(updated)
            }
        }

//        parametersSection.contentViews.enumerated().forEach { [unowned self] index, view in
//            if index < parametersSection.contentViews.count - 1 {
//                view.nextKeyView = self.parametersSection.contentViews[index + 1]
//            }
//        }
    }
}
