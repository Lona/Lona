//
//  InspectorContentView.swift
//  LonaStudio
//
//  Created by Nghia Tran on 2/19/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import Cocoa
import Colors
import ColorPicker

final class InspectorView: NSBox {

    enum ChangeType {
        case canvas
        case full
    }

    enum Content {
        case layer(CSLayer)
        case color(CSColor)
        case textStyle(CSTextStyle)
        case canvas(Canvas)

        init?(_ color: CSColor?) {
            guard let color = color else { return nil }

            self = .color(color)
        }

        init?(_ textStyle: CSTextStyle?) {
            guard let textStyle = textStyle else { return nil }

            self = .textStyle(textStyle)
        }

        init?(_ canvas: Canvas) {
            self = .canvas(canvas)
        }
    }

    // MARK: Lifecycle

    init() {
        super.init(frame: NSRect.zero)

        setUpViews()
        setUpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Public

    var content: Content? { didSet { update() } }

    var onChangeContent: ((Content, InspectorView.ChangeType) -> Void)?

    // MARK: Private

    private let headerView = EditorHeader(
        titleText: "Parameters",
        subtitleText: "",
        dividerColor: .clear,
        fileIcon: nil)

    private let scrollView = NSScrollView(frame: .zero)

    // Flip the content within the scrollview so it starts at the top
    private let flippedView = FlippedView()

    private func setUpViews() {
        boxType = .custom
        borderType = .noBorder
        contentViewMargins = .zero

        addSubview(headerView)

        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        scrollView.automaticallyAdjustsContentInsets = false
        scrollView.contentInsets = NSEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        scrollView.addSubview(flippedView)
        scrollView.documentView = flippedView

        addSubview(scrollView)
    }

    private func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        flippedView.translatesAutoresizingMaskIntoConstraints = false

        // The layout gets completely messed up without this
        flippedView.wantsLayer = true

        headerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true

        scrollView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true

        flippedView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        flippedView.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 20).isActive = true
        flippedView.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -20).isActive = true

//        flippedView.leftAnchor.constraint(equalTo: scrollView.contentView.leftAnchor, constant: 20).isActive = true
//        flippedView.rightAnchor.constraint(equalTo: scrollView.contentView.rightAnchor, constant: -20).isActive = true
    }

    private var inspectorView = NSView()

    func update() {
        guard let content = content else {
            headerView.titleText = ""
            headerView.subtitleText = ""

            inspectorView.removeFromSuperview()
            inspectorView = NSView()
            return
        }

        switch content {
        case .layer(let content):
            headerView.titleText = content.name
            headerView.subtitleText = " — \(content.type.displayName)"

            if case CSLayer.LayerType.custom = content.type, let componentLayer = content as? CSComponentLayer {
                inspectorView.removeFromSuperview()

                let componentInspectorView = CustomComponentInspectorView()
                componentInspectorView.layerName = componentLayer.name
                componentInspectorView.parameters = componentLayer.component.parameters
                componentInspectorView.parameterValues = componentLayer.parameters
                componentInspectorView.onChangeData = {[unowned self] parameterValues in
                    componentLayer.parameters = parameterValues

                    self.onChangeContent?(.layer(componentLayer), InspectorView.ChangeType.full)

                    // We don't currently call update here, so we need to update manually
                    componentInspectorView.parameters = componentLayer.component.parameters
                    componentInspectorView.parameterValues = componentLayer.parameters
                }
                inspectorView = componentInspectorView
            } else {
                if let layerInspector = flippedView.subviews.first as? CoreComponentInspectorView {
                    layerInspector.csLayer = content
                    layerInspector.onChangeLayer = {[unowned self] csLayer in
                        self.onChangeContent?(.layer(csLayer), .canvas)
                    }

                } else {
                    inspectorView.removeFromSuperview()

                    let layerInspector = CoreComponentInspectorView(layer: content)
                    layerInspector.onChangeLayer = {[unowned self] csLayer in
                        self.onChangeContent?(.layer(csLayer), .canvas)
                    }

                    inspectorView = layerInspector
                }
            }

            flippedView.addSubview(inspectorView)

            inspectorView.widthAnchor.constraint(equalTo: flippedView.widthAnchor).isActive = true
            inspectorView.heightAnchor.constraint(equalTo: flippedView.heightAnchor).isActive = true

        case .color(let color):
            let alreadyShowingColorInspector = inspectorView is ColorInspector

            if !alreadyShowingColorInspector {
                inspectorView.removeFromSuperview()
            }

            headerView.titleText = color.name
            headerView.subtitleText = " — Color"

            let editor = (inspectorView as? ColorInspector) ?? ColorInspector()

            editor.idText = color.id
            editor.nameText = color.name
            editor.valueText = color.value
            editor.descriptionText = color.comment ?? ""

            let cssColor = parseCSSColor(color.value) ?? CSSColor(0, 0, 0, 0)
            var colorValue = Color(redInt: cssColor.r, greenInt: cssColor.g, blueInt: cssColor.b)
            colorValue.alpha = Float(cssColor.a)

            if editor.colorValue?.rgbaString != colorValue.rgbaString {
                editor.colorValue = colorValue
            }

            editor.onChangeColorValue = { value in
                editor.colorValue = value

                var updated = color
                updated.value = value.rgbaString
                self.onChangeContent?(.color(updated), .canvas)
            }

            editor.onChangeIdText = { value in
                var updated = color
                updated.id = value
                self.onChangeContent?(.color(updated), .canvas)
            }

            editor.onChangeNameText = { value in
                var updated = color
                updated.name = value
                self.onChangeContent?(.color(updated), .canvas)
            }

            editor.onChangeValueText = { value in
                var updated = color
                updated.value = value
                self.onChangeContent?(.color(updated), .canvas)
            }

            editor.onChangeDescriptionText = { value in
                var updated = color
                updated.comment = value.isEmpty ? nil : value
                self.onChangeContent?(.color(updated), .canvas)
            }

            if !alreadyShowingColorInspector {
                inspectorView = editor

                flippedView.addSubview(inspectorView)

                inspectorView.widthAnchor.constraint(equalTo: flippedView.widthAnchor).isActive = true
                inspectorView.heightAnchor.constraint(equalTo: flippedView.heightAnchor).isActive = true
                inspectorView.topAnchor.constraint(equalTo: flippedView.topAnchor).isActive = true
                inspectorView.bottomAnchor.constraint(equalTo: flippedView.bottomAnchor).isActive = true
            }

        case .textStyle(let textStyle):
            let alreadyShowingTextStyleInspector = inspectorView is TextStyleInspector

            if !alreadyShowingTextStyleInspector {
                inspectorView.removeFromSuperview()
            }

            headerView.titleText = textStyle.name
            headerView.subtitleText = " — Text Style"

            let editor = (inspectorView as? TextStyleInspector) ?? TextStyleInspector()

            editor.idText = textStyle.id
            editor.nameText = textStyle.name
            editor.descriptionText = textStyle.comment ?? ""
            editor.fontFamilyText = textStyle.fontFamily ?? ""
            editor.fontNameText = textStyle.fontName ?? ""
            editor.fontWeightText = textStyle.fontWeight ?? ""
            editor.fontSizeNumber = CGFloat(textStyle.fontSize ?? -1)
            editor.lineHeightNumber = CGFloat(textStyle.lineHeight ?? -1)
            editor.letterSpacingNumber = CGFloat(textStyle.letterSpacing ?? -1)
            editor.colorValue = textStyle.color ?? ""

            editor.onChangeIdText = { value in
                var updated = textStyle
                updated.id = value
                self.onChangeContent?(.textStyle(updated), .canvas)
            }

            editor.onChangeNameText = { value in
                var updated = textStyle
                updated.name = value
                self.onChangeContent?(.textStyle(updated), .canvas)
            }

            editor.onChangeDescriptionText = { value in
                var updated = textStyle
                updated.comment = value
                self.onChangeContent?(.textStyle(updated), .canvas)
            }

            editor.onChangeFontNameText = { value in
                var updated = textStyle
                updated.fontName = value
                self.onChangeContent?(.textStyle(updated), .canvas)
            }

            editor.onChangeFontFamilyText = { value in
                var updated = textStyle
                updated.fontFamily = value
                self.onChangeContent?(.textStyle(updated), .canvas)
            }

            editor.onChangeFontWeightText = { value in
                var updated = textStyle
                updated.fontWeight = value
                self.onChangeContent?(.textStyle(updated), .canvas)
            }

            editor.onChangeColorValue = { value in
                var updated = textStyle
                updated.color = value
                self.onChangeContent?(.textStyle(updated), .canvas)
            }

            editor.onChangeFontSizeNumber = { value in
                var updated = textStyle
                updated.fontSize = Double(value)
                self.onChangeContent?(.textStyle(updated), .canvas)
            }

            editor.onChangeLineHeightNumber = { value in
                var updated = textStyle
                updated.lineHeight = Double(value)
                self.onChangeContent?(.textStyle(updated), .canvas)
            }

            editor.onChangeLetterSpacingNumber = { value in
                var updated = textStyle
                updated.letterSpacing = Double(value)
                self.onChangeContent?(.textStyle(updated), .canvas)
            }

            if !alreadyShowingTextStyleInspector {
                inspectorView = editor

                flippedView.addSubview(inspectorView)

                inspectorView.widthAnchor.constraint(equalTo: flippedView.widthAnchor).isActive = true
                inspectorView.heightAnchor.constraint(equalTo: flippedView.heightAnchor).isActive = true
                inspectorView.topAnchor.constraint(equalTo: flippedView.topAnchor).isActive = true
                inspectorView.bottomAnchor.constraint(equalTo: flippedView.bottomAnchor).isActive = true
            }
        case .canvas(let canvas):
            let alreadyShowing = inspectorView is CanvasInspector

            if !alreadyShowing {
                inspectorView.removeFromSuperview()
            }

            let canvasInspector = (inspectorView as? CanvasInspector) ?? CanvasInspector()

            let devicePresets = ["Custom"] + Canvas.devicePresets.map { $0.name }

            canvasInspector.showsDimensionInputs = canvas.device == .custom
            canvasInspector.canvasHeight = CGFloat(canvas.height)
            canvasInspector.canvasWidth = CGFloat(canvas.width)
            canvasInspector.heightMode = canvas.heightMode == "At Least" ? .flexibleHeight : .fixedHeight
            canvasInspector.backgroundColorId = canvas.backgroundColor
            canvasInspector.availableDevices = devicePresets

            switch canvas.device {
            case .custom:
                canvasInspector.deviceIndex = 0
                canvasInspector.canvasNamePlaceholder = "Custom name"
                canvasInspector.canvasName = canvas.name
            case .preset(let device):
                canvasInspector.deviceIndex = devicePresets.firstIndex(of: device.name) ?? 0
                canvasInspector.canvasNamePlaceholder = device.name
                canvasInspector.canvasName = canvas.name == device.name ? nil : canvas.name
            }

            canvasInspector.onChangeCanvasName = { name in
                let newCanvas = canvas.copy() as! Canvas

                switch canvas.device {
                case .custom:
                    newCanvas.name = name
                case .preset(let device):
                    newCanvas.name = name == "" ? device.name : name
                }

                self.onChangeContent?(.canvas(newCanvas), .canvas)
            }

            canvasInspector.onChangeCanvasWidth = { value in
                let newCanvas = canvas.copy() as! Canvas
                newCanvas.width = Double(value)
                self.onChangeContent?(.canvas(newCanvas), .canvas)
            }

            canvasInspector.onChangeCanvasHeight = { value in
                let newCanvas = canvas.copy() as! Canvas
                newCanvas.height = Double(value)
                self.onChangeContent?(.canvas(newCanvas), .canvas)
            }

            canvasInspector.onChangeBackgroundColorId = { value in
                let newCanvas = canvas.copy() as! Canvas
                newCanvas.backgroundColor = value
                self.onChangeContent?(.canvas(newCanvas), .canvas)
            }

            canvasInspector.onChangeHeightModeIndex = { index in
                let newCanvas = canvas.copy() as! Canvas

                if index == 0 {
                    newCanvas.heightMode = "At Least"

                    switch canvas.device {
                    case .custom:
                        break
                    case .preset:
                        newCanvas.height = 1
                    }
                } else {
                    newCanvas.heightMode = "Exactly"

                    switch canvas.device {
                    case .custom:
                        break
                    case .preset(let device):
                        newCanvas.height = Double(device.height)
                    }
                }

                self.onChangeContent?(.canvas(newCanvas), .canvas)
            }

            canvasInspector.onChangeDeviceIndex = { index in
                let newCanvas = canvas.copy() as! Canvas

                if index == 0 {
                    newCanvas.device = .custom

                    switch canvas.device {
                    case .custom:
                        break
                    case .preset(let device):
                        newCanvas.width = Double(device.width)

                        if canvas.heightMode == "At Least" {
                            newCanvas.height = 1
                        } else {
                            newCanvas.height = Double(device.height)
                        }
                    }
                } else {
                    // Subtract one from the index, since we added "Custom" to the array of names
                    let preset = Canvas.devicePresets[index - 1]
                    newCanvas.device = .preset(preset)
                    newCanvas.width = Double(preset.width)

                    if canvas.heightMode == "At Least" {
                        newCanvas.height = 1
                    } else {
                        newCanvas.height = Double(preset.height)
                    }
                }

                self.onChangeContent?(.canvas(newCanvas), .canvas)
            }

            inspectorView = canvasInspector

            flippedView.addSubview(inspectorView)

            inspectorView.leadingAnchor.constraint(equalTo: flippedView.leadingAnchor).isActive = true
            inspectorView.trailingAnchor.constraint(equalTo: flippedView.trailingAnchor).isActive = true
            inspectorView.topAnchor.constraint(equalTo: flippedView.topAnchor).isActive = true
            inspectorView.bottomAnchor.constraint(equalTo: flippedView.bottomAnchor).isActive = true
        }
    }
}
