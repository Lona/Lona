//
//  DimensionsView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/8/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa
import Lottie

private let DIMENSION_SIZING_VALUES = ["Fixed", "Expand", "Shrink"]
private let DIMENSION_SIZING_VALUE_TO_TITLE = [
    "Fixed": "Fixed",
    "Expand": "Fill",
    "Shrink": "Fit Content"
]
private let DIMENSION_SIZING_IMAGE_VALUES = ["Fixed", "Expand"]
private let DIMENSION_SIZING_IMAGE_VALUE_TO_TITLE = [
    "Fixed": "Fixed",
    "Expand": "Fill"
]

private let RESIZE_MODE_VALUES = ["cover", "contain", "stretch"]
private let RESIZE_MODE_VALUE_TO_TITLE = [
    "cover": "Aspect-preserving Fill",
    "contain": "Aspect-preserving Fit",
    "stretch": "Stretch Fill"
]
private let RESIZE_MODE_VECTOR_VALUES = ["cover", "contain"]
private let RESIZE_MODE_VECTOR_VALUE_TO_TITLE = [
    "cover": "Aspect-preserving Fill",
    "contain": "Aspect-preserving Fit"
]

class CoreComponentInspectorView: NSStackView {

    typealias Properties = [Property: CSData]

    enum Property: String {
        // Layout
        case direction
        case horizontalAlignment
        case verticalAlignment

        // Box Model
        case width
        case height
        case marginTop
        case marginRight
        case marginBottom
        case marginLeft
        case paddingTop
        case paddingRight
        case paddingBottom
        case paddingLeft
        case aspectRatio

        // Border
        case borderRadius
        case borderColor
        case borderColorEnabled
        case borderWidth
        case borderStyle

        // Contents
        case opacity
        case backgroundColor
        case backgroundGradient

        // Shadow
        case shadowEnabled
        case shadow

        // Text
        case text
        case textStyle
        case textAlign
        case numberOfLines

        // Image
        case image
        case resizeMode

        // Animation
        case animation
        case animationSpeed

        // Accessibility
        case accessibilityType
        case accessibilityLabel
        case accessibilityHint
        case accessibilityElements
        case accessibilityRole

        // Metadata
        case accessLevel
        case backingElementClass
    }

    var value: Properties = [:]
    var onChange: (Properties) -> Void = {_ in}
    var onChangeProperty: (Property, CSData) -> Void = {_, _  in}
    var onChangeLayer: (CSLayer) -> Void = {_ in}

    func handlePropertyChange(for property: Property, value: CSData) {
        self.value[property] = value

        onChangeProperty(property, value)
        onChange(self.value)

        CoreComponentInspectorView.update(layer: csLayer, property: property, to: value)
        onChangeLayer(csLayer)
    }

    override var isFlipped: Bool { return true }

    var textSection: DisclosureContentRow!
    var imageSection: DisclosureContentRow!
    var animationSection: DisclosureContentRow!
    var shadowSection: DisclosureContentRow!

    var layoutInspector = LayoutInspector()
    var dimensionsInspector = DimensionsInspector()
    var accessibilityInspector = AccessibilityInspector()

    var opacityView = NumberField(frame: NSRect.zero)
    let backgroundColorInput = LabeledColorInput(titleText: "Background Color", colorString: nil)
    var borderColorButton = ColorPickerButton(frame: NSRect.zero)
    var borderColorEnabledView = CheckboxField(frame: NSRect.zero)
    var borderRadiusView = NumberField(frame: NSRect.zero)
    var borderStyleView = LabeledDropdownRow(
        selectedIndex: 0,
        labelText: "Border Style",
        options: CSLayer.BorderStyle.displayNames)
    var shadowEnabledView = CheckboxField(frame: NSRect.zero)
    var shadowButton = ShadowStylePickerButton(frame: NSRect.zero)

    var textAlignView = PopupField(
        frame: NSRect.zero,
        values: ["left", "center", "right"],
        valueToTitle: ["left": "Left", "center": "Center", "right": "Right"]
    )
    var textStyleView = LabeledLogicInput(titleText: "Text Style", titleWidth: 60)
    var numberOfLinesView = NumberField(frame: NSRect.zero)

    var paddingTopView = LogicNumberInput()
    var paddingLeftView = LogicNumberInput()
    var paddingRightView = LogicNumberInput()
    var paddingBottomView = LogicNumberInput()
    var marginTopView = LogicNumberInput()
    var marginLeftView = LogicNumberInput()
    var marginRightView = LogicNumberInput()
    var marginBottomView = LogicNumberInput()
    var borderWidthView = NumberField(frame: NSRect.zero)

    var backgroundGradientView = TextField(frame: NSRect.zero)
    var textView = LabeledLogicInput(titleText: "Text", titleWidth: 60)
    var imageView = ImageField(frame: NSRect.zero)
    var imageURLView = LabeledLogicInput(titleText: "Image", titleWidth: 60)
    var animationViewContainer = NSView(frame: NSRect.zero)
    var animationURLView = TextField(frame: NSRect.zero)
    var animationSpeedView = NumberField(frame: NSRect.zero)
    var animationResizeModeView = PopupField(
        frame: NSRect.zero,
        values: ["cover", "contain", "stretch"],
        valueToTitle: ["cover": "Aspect Fill", "contain": "Aspect Fit", "stretch": "Stretch Fill"]
    )
    var imageResizeModeView = PopupField(
        frame: NSRect.zero,
        values: ["cover", "contain", "stretch"],
        valueToTitle: ["cover": "Aspect-preserving Fill", "contain": "Aspect-preserving Fit", "stretch": "Stretch Fill"]
    )

    var accessLevelElement = CSValueField(
        value: CSValue(
            type: CSType.platformSpecificAccessLevel,
            data: CSData.Object([:])))
    var accessLevelRow = NSStackView(
        views: [NSTextField(labelWithString: "Access Level")],
        orientation: .horizontal,
        stretched: true)

    var backingElement = CSValueField(
        value: CSValue(
            type: CSType.platformSpecificString,
            data: CSData.Object([:])))
    var backingRow = NSStackView(
        views: [NSTextField(labelWithString: "Backing Element")],
        orientation: .horizontal,
        stretched: true)

    var width: CGFloat = 280
    var labelX: CGFloat = 10
    var column1X: CGFloat = 90
    var columnMargin: CGFloat = 10
    var halfFieldWidth: CGFloat = 86

    var column2X: CGFloat { return column1X + halfFieldWidth + columnMargin }
    var fieldWidth: CGFloat { return halfFieldWidth * 2 + columnMargin }

    func renderLabel(withString value: String) -> NSTextField {
        let label: NSTextField

        if #available(OSX 10.12, *) {
            label = NSTextField(labelWithString: value)
        } else {
            label = NSTextField()
        }

        label.frame.origin.x = labelX

        return label
    }

    func renderRow(children: [NSView]) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: frame.size.width, height: 30))
        view.useYogaLayout = true

        children.forEach({ view.addSubview($0) })
        children.forEach({ $0.frame.origin.y = view.frame.height / 2 - $0.frame.midY })

        return view
    }

    func renderSectionHeader(withTitle value: String) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: frame.size.width, height: 30))
        view.useYogaLayout = true

        view.wantsLayer = true
        view.layer = CALayer()
//        view.layer?.backgroundColor = CGColor.white

        let border = CALayer()
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 1)
        border.backgroundColor = #colorLiteral(red: 0.8379167914, green: 0.8385563493, blue: 0.8380157948, alpha: 1).cgColor

        view.layer?.addSublayer(border)

        let label = renderLabel(withString: value)
        label.centerWithin(view)
        label.font = NSFont.boldSystemFont(ofSize: 12)
        label.frame.size.width = frame.size.width

        view.addSubview(label)

        return view
    }

    func renderDivider() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: frame.size.width, height: 1))
        view.useYogaLayout = true

        view.wantsLayer = true
        view.layer = CALayer()
        view.layer?.backgroundColor = #colorLiteral(red: 0.8379167914, green: 0.8385563493, blue: 0.8380157948, alpha: 1).cgColor

        return view
    }

    class BorderedStackView: NSStackView {
        override func draw(_ dirtyRect: NSRect) {
            super.draw(dirtyRect)

            // dash customization parameters
            let dashHeight: CGFloat = 1
            let dashLength: CGFloat = 3
            let dashColor: NSColor = NSColor.parse(css: "rgb(190,190,190)")!

            // setup the context
            let currentContext = NSGraphicsContext.current!.cgContext
            currentContext.setLineWidth(dashHeight)
            currentContext.setLineDash(phase: 0, lengths: [dashLength])
            currentContext.setStrokeColor(dashColor.cgColor)

            // draw the dashed path
            currentContext.addRect(bounds.insetBy(dx: dashHeight, dy: dashHeight))
            currentContext.strokePath()
        }
    }

    func renderSection(title: String, views: [NSView]) -> DisclosureContentRow {
        let section = DisclosureContentRow(title: title, views: views, stretched: true)
        section.contentSpacing = 8
        section.contentEdgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)

        return section
    }

    func renderBorderSection() -> DisclosureContentRow {
        borderRadiusView.nextKeyView = borderWidthView

        let width = NSStackView(views: [
            NSTextField(labelWithString: "Width"),
            borderWidthView
            ], orientation: .vertical, stretched: true)

        let radius = NSStackView(views: [
            NSTextField(labelWithString: "Radius"),
            borderRadiusView
            ], orientation: .vertical, stretched: true)

        let borderContainer = NSStackView(
            views: [width, radius],
            orientation: .horizontal,
            stretched: true
        )
        borderContainer.distribution = .fillEqually
        borderContainer.spacing = 20

        borderColorEnabledView.imagePosition = .imageOnly

        let borderColorContainer = NSStackView(
            views: [
                borderColorEnabledView,
                borderColorButton
                ],
            orientation: .horizontal,
            stretched: true
        )

        let borderSection = renderSection(title: "Border", views: [
            NSTextField(labelWithString: "Color"),
            borderColorContainer,
            borderContainer,
            borderStyleView
            ])
        borderSection.addContentSpacing(of: 14, after: borderColorContainer)
        borderSection.addContentSpacing(of: 14, after: borderContainer)

        return borderSection
    }

    func renderSpacingSection() -> DisclosureContentRow {

        func add(label string: String, to view: NSView) {
            let label = NSTextField(labelWithString: string)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = NSFont.systemFont(ofSize: 9)

            view.addSubview(label)
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 13).isActive = true
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        }

        let inputs = [
            marginTopView, marginRightView, marginBottomView, marginLeftView,
            paddingTopView, paddingRightView, paddingBottomView, paddingLeftView
        ]

        for input in inputs {
            input.widthAnchor.constraint(equalToConstant: 40).isActive = true
        }

        let inner = NSView()
        inner.heightAnchor.constraint(equalToConstant: 30).isActive = true
        inner.wantsLayer = true
        inner.layer?.backgroundColor = Colors.headerBackground.cgColor
        inner.layer?.borderWidth = 1
        inner.layer?.borderColor = Colors.dividerSubtle.cgColor
        inner.layer?.cornerRadius = 3

        let paddingRow = NSStackView(views: [
            paddingLeftView,
            inner,
            paddingRightView
        ], orientation: .horizontal)
        paddingRow.distribution = .fill
        paddingRow.spacing = 0
        paddingRow.edgeInsets = NSEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)

        let padding = NSStackView(views: [
            paddingTopView,
            paddingRow,
            paddingBottomView
        ], orientation: .vertical)
        padding.spacing = 2
        padding.wantsLayer = true
        padding.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        padding.layer?.borderWidth = 1
        padding.layer?.borderColor = NSColor.controlBackgroundColor.cgColor
        padding.layer?.cornerRadius = 3
        padding.edgeInsets = NSEdgeInsets(top: 5, left: 0, bottom: 7, right: 0)

        add(label: "PADDING", to: padding)

        let marginRow = NSStackView(views: [
            marginLeftView,
            padding,
            marginRightView
        ], orientation: .horizontal)
        marginRow.distribution = .fill
        marginRow.spacing = 0
        marginRow.edgeInsets = NSEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)

        let margin = BorderedStackView(views: [], orientation: .vertical)
        margin.spacing = 2
        margin.addArrangedSubview(marginTopView)
        margin.addArrangedSubview(marginRow, stretched: true)
        margin.addArrangedSubview(marginBottomView)
        margin.edgeInsets = NSEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)

        add(label: "MARGIN", to: margin)

        let spacingSection = renderSection(title: "Spacing", views: [margin])
        spacingSection.contentEdgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)

        return spacingSection
    }

    func renderBackgroundSection() -> DisclosureContentRow {
        let backgroundSection = renderSection(title: "Opacity & Background", views: [
            NSTextField(labelWithString: "Opacity"),
            opacityView,
            backgroundColorInput,
            NSTextField(labelWithString: "Gradient"),
            backgroundGradientView
        ])

        [opacityView, backgroundColorInput, backgroundGradientView].forEach {
            backgroundSection.addContentSpacing(of: 14, after: $0)
        }

        return backgroundSection
    }

    func renderShadowSection() -> DisclosureContentRow {
        shadowEnabledView.imagePosition = .imageOnly

        let shadowContainer = NSStackView(
            views: [
                shadowEnabledView,
                shadowButton
                ],
            orientation: .horizontal,
            stretched: true
        )

        let backgroundSection = renderSection(title: "Shadow", views: [shadowContainer])
        return backgroundSection
    }

    func renderMetadataSection() -> DisclosureContentRow {
        let metadataSection = renderSection(title: "Metadata", views: [accessLevelRow, backingRow])
        [accessLevelRow].forEach {
            metadataSection.addContentSpacing(of: 14, after: $0)
        }
        return metadataSection
    }

    func renderTextSection() -> DisclosureContentRow {
        let textSection = renderSection(title: "Text", views: [
            textView,
            textStyleView,
            NSTextField(labelWithString: "Alignment"),
            textAlignView,
            NSTextField(labelWithString: "Max Lines"),
            numberOfLinesView
        ])

        textSection.isHidden = true
        //        hideViews(views: [textFields], animated: false)

        return textSection
    }

    func renderImageSection() -> DisclosureContentRow {
        imageView.constrain(aspectRatio: 1)
        imageView.widthAnchor.constraint(equalToConstant: 240).isActive = true

        let imageSection = renderSection(title: "Image", views: [
            imageURLView,
            imageResizeModeView,
            imageView
        ])

        imageSection.isHidden = true

        return imageSection
    }

    func addAnimationViewToContainer(for url: URL) {
        let animationView = LOTAnimationView(contentsOf: url)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFill

        self.animationViewContainer.addSubview(animationView)

        animationView.widthAnchor.constraint(equalTo: self.animationViewContainer.widthAnchor).isActive = true
        animationView.heightAnchor.constraint(equalTo: self.animationViewContainer.heightAnchor).isActive = true
        animationView.play()
    }

    func renderAnimationSection() -> DisclosureContentRow {
        animationViewContainer.translatesAutoresizingMaskIntoConstraints = false
        animationViewContainer.constrain(aspectRatio: 1)
        animationViewContainer.widthAnchor.constraint(equalToConstant: 240).isActive = true

        let button = Button(titleText: "Browse...")
        button.onPress = {
            let dialog = NSOpenPanel()

            dialog.title = "Choose an animation file"
            dialog.showsResizeIndicator = true
            dialog.showsHiddenFiles = false
            dialog.canCreateDirectories = false
            dialog.canChooseDirectories = false
            dialog.canChooseFiles = true
            dialog.allowsMultipleSelection = false

            if dialog.runModal() == NSApplication.ModalResponse.OK {
                self.handlePropertyChange(for: .animation, value: CSData.String(dialog.url!.absoluteString))
            }
        }

        let urlContainer = NSStackView(views: [
            animationURLView,
            button
            ], orientation: .horizontal)

        let animationSection = renderSection(title: "Animation", views: [
            NSTextField(labelWithString: "URL"),
            urlContainer,
            NSTextField(labelWithString: "Asset"),
            animationViewContainer,
            NSTextField(labelWithString: "Scale Mode"),
            animationResizeModeView,
            NSTextField(labelWithString: "Animation Speed"),
            animationSpeedView
            ])

        animationSection.isHidden = true

        return animationSection
    }

    private var properties: [Property: CSData] = [:]

    public var csLayer: CSLayer {
        didSet {
            let newProperties = CoreComponentInspectorView.properties(from: csLayer)

            if oldValue.type != csLayer.type || properties != newProperties {
                properties = newProperties
                update()
            }
        }
    }

    // MARK: Lifecycle

    convenience init(layer: CSLayer) {
        self.init(frame: .zero, layer: layer)
    }

    init(frame frameRect: NSRect, layer: CSLayer) {
        csLayer = layer
        properties = CoreComponentInspectorView.properties(from: layer)

        super.init(frame: frameRect)

        setUpViews()
        setUpConstraints()

        update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Private

    func setUpViews() {
        orientation = .vertical
        alignment = .left
        spacing = 0

        marginTopView.nextKeyView = marginRightView
        marginRightView.nextKeyView = marginBottomView
        marginBottomView.nextKeyView = marginLeftView
        marginLeftView.nextKeyView = paddingTopView

        paddingTopView.nextKeyView = paddingRightView
        paddingRightView.nextKeyView = paddingBottomView
        paddingBottomView.nextKeyView = paddingLeftView

        textSection = renderTextSection()
        imageSection = renderImageSection()
        animationSection = renderAnimationSection()
        shadowSection = renderShadowSection()

        let sections = [
            layoutInspector,
            textSection!,
            dimensionsInspector,
            renderSpacingSection(),
            renderBorderSection(),
            renderBackgroundSection(),
            shadowSection!,
            imageSection!,
            animationSection!,
            accessibilityInspector,
            renderMetadataSection()
        ]

        for section in sections {
            addArrangedSubview(section, stretched: true)
        }
    }

    func setUpConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
    }

    func update() {
        let layerType = csLayer.type
        let properties = self.properties

        switch layerType {
        case .builtIn(.view):
            layoutInspector.isHidden = false
            textSection.isHidden = true
            imageSection.isHidden = true
            animationSection.isHidden = true
        case .builtIn(.text):
            layoutInspector.isHidden = true
            textSection.isHidden = false
            imageSection.isHidden = true
            animationSection.isHidden = true
        case .builtIn(.image), .builtIn(.vectorGraphic):
            layoutInspector.isHidden = true
            textSection.isHidden = true
            imageSection.isHidden = false
            animationSection.isHidden = true
        case .builtIn(.animation):
            layoutInspector.isHidden = true
            textSection.isHidden = true
            imageSection.isHidden = true
            animationSection.isHidden = false
        default:
            break
        }

        switch layerType {
        case .builtIn(.image):
            let values = RESIZE_MODE_VALUES
            let valueToTitle = RESIZE_MODE_VALUE_TO_TITLE
            imageResizeModeView.set(values: values, valueToTitle: valueToTitle)
            imageURLView.isVectorInput = false
        case .builtIn(.vectorGraphic):
            let values = RESIZE_MODE_VECTOR_VALUES
            let valueToTitle = RESIZE_MODE_VECTOR_VALUE_TO_TITLE
            imageResizeModeView.set(values: values, valueToTitle: valueToTitle)
            imageURLView.isVectorInput = true
        default:
            break
        }

        let fields: [(control: CSControl, property: Property)] = [
            // Border
            (borderRadiusView, .borderRadius),
            (borderColorButton, .borderColor),
            (borderColorEnabledView, .borderColorEnabled),
            (borderWidthView, .borderWidth),

            // Contents
            (opacityView, .opacity),
            (backgroundGradientView, .backgroundGradient),

            // Shadow
            (shadowButton, .shadow),
            (shadowEnabledView, .shadowEnabled),

            // Text
            (textAlignView, .textAlign),
            (numberOfLinesView, .numberOfLines),

            // Image
            (imageView, .image),
            (imageResizeModeView, .resizeMode),

            // Animation
//            (animationView, .animation),
            (animationURLView, .animation),
            (animationSpeedView, .animationSpeed),
            (animationResizeModeView, .resizeMode)
        ]

        // CSValueField needs to be recreated on change since it doesn't support updating
        // TODO: When we switch to controlled components, we won't need to do this
        if let value = properties[.backingElementClass] {
            func setup(value: CSData) {
                backingElement.view.removeFromSuperview()
                backingElement = CSValueField(
                    value: CSValue(
                        type: CSType.platformSpecificString,
                        data: value))
                backingRow.addArrangedSubview(backingElement.view, stretched: true)
                backingElement.onChangeData = { data in
                    self.handlePropertyChange(for: .backingElementClass, value: data)
                    setup(value: data)
                }
            }

            setup(value: value)
        }
        if let value = properties[.accessLevel] {
            func setup(value: CSData) {
                accessLevelElement.view.removeFromSuperview()
                accessLevelElement = CSValueField(
                    value: CSValue(
                        type: CSType.platformSpecificAccessLevel,
                        data: value))
                accessLevelRow.addArrangedSubview(accessLevelElement.view, stretched: true)
                accessLevelElement.onChangeData = { data in
                    self.handlePropertyChange(for: .accessLevel, value: data)
                    setup(value: data)
                }
            }

            setup(value: value)
        }

        fields.forEach({ (control, property) in
            var control = control

            // Set default value before setting onChangeData in order to avoid calling twice
            if let value = properties[property] {
                control.data = value
                self.value[property] = value
            }

            // Setup onChangeData
            control.onChangeData = { data in

                let oldValue = self.value[property]
                guard oldValue != data else {
                    return
                }

                // Register Undo
                UndoManager.shared.run(name: property.rawValue, execute: {[unowned self] in
                    control.data = data
                    self.handlePropertyChange(for: property, value: data)
                }, undo: { [unowned self] in
                    let value = oldValue ?? properties[property]!
                    control.data = value
                    self.handlePropertyChange(for: property, value: value)
                })
            }
        })

        if let value = properties[.animation] {
            self.value[.animation] = value
        }

        // Controlled Properties

        controlledProperties.forEach {
            self.update(property: $0, value: properties[$0])
        }

        func change(property: Property, to newValue: CSData) {
            let oldValue = self.value[property] ?? properties[property]!

            UndoManager.shared.run(
                name: property.rawValue,
                execute: { [unowned self] in
                    self.handlePropertyChange(for: property, value: newValue)
                },
                undo: { [unowned self] in
                    self.handlePropertyChange(for: property, value: oldValue)
                }
            )
        }

        layoutInspector.isExpanded = UserDefaults.standard.bool(forKey: "layoutInspectorExpanded")
        layoutInspector.onClickHeader = { [unowned self] in
            let newValue = !self.layoutInspector.isExpanded
            self.layoutInspector.isExpanded = newValue
            UserDefaults.standard.set(newValue, forKey: "layoutInspectorExpanded")
        }

        layoutInspector.onChangeDirectionIndex = { index in
            let newValue = (index == 1 ? "column" : "row").toData()
            change(property: Property.direction, to: newValue)
        }

        layoutInspector.onChangeHorizontalAlignmentIndex = { [unowned self] index in
            let newValue = self.alignmentValue(for: index).toData()
            change(property: Property.horizontalAlignment, to: newValue)
        }

        layoutInspector.onChangeVerticalAlignmentIndex = { [unowned self] index in
            let newValue = self.alignmentValue(for: index).toData()
            change(property: Property.verticalAlignment, to: newValue)
        }

        // Dimensions

        dimensionsInspector.isExpanded = UserDefaults.standard.bool(forKey: "dimensionsInspectorExpanded")
        dimensionsInspector.onClickHeader = { [unowned self] in
            let newValue = !self.dimensionsInspector.isExpanded
            self.dimensionsInspector.isExpanded = newValue
            UserDefaults.standard.set(newValue, forKey: "dimensionsInspectorExpanded")
        }

        switch layerType {
        case .builtIn(.image), .builtIn(.vectorGraphic):
            dimensionsInspector.allowsFitContent = false
        default:
            dimensionsInspector.allowsFitContent = true
        }

        dimensionsInspector.onChangeWidthTypeIndex = { [unowned self] index in
            let property = Property.width
            let oldValue = self.value[property] ?? properties[property]!

            let newValue = oldValue.merge(
                CSData.Object(["case": self.dimensionTypeValue(for: index).toData()]))
            change(property: property, to: newValue)
        }

        dimensionsInspector.onChangeWidthValue = { [unowned self] widthValue in
            let property = Property.width
            let oldValue = self.value[property] ?? properties[property]!

            let newValue = oldValue.merge(
                CSData.Object(["data": widthValue.toData()]))
            change(property: property, to: newValue)
        }

        dimensionsInspector.onChangeHeightTypeIndex = { [unowned self] index in
            let property = Property.height
            let oldValue = self.value[property] ?? properties[property]!

            let newValue = oldValue.merge(
                CSData.Object(["case": self.dimensionTypeValue(for: index).toData()]))
            change(property: property, to: newValue)
        }

        dimensionsInspector.onChangeHeightValue = { [unowned self] heightValue in
            let property = Property.height
            let oldValue = self.value[property] ?? properties[property]!

            let newValue = oldValue.merge(
                CSData.Object(["data": heightValue.toData()]))
            change(property: property, to: newValue)
        }

        dimensionsInspector.onChangeAspectRatioValue = { aspectRatio in
            change(property: Property.aspectRatio, to: aspectRatio.toData())
        }

        paddingTopView.onChangeNumberValue = { value in
            change(property: Property.paddingTop, to: value.toData())
        }

        paddingRightView.onChangeNumberValue = { value in
            change(property: Property.paddingRight, to: value.toData())
        }

        paddingBottomView.onChangeNumberValue = { value in
            change(property: Property.paddingBottom, to: value.toData())
        }

        paddingLeftView.onChangeNumberValue = { value in
            change(property: Property.paddingLeft, to: value.toData())
        }

        marginTopView.onChangeNumberValue = { value in
            change(property: Property.marginTop, to: value.toData())
        }

        marginRightView.onChangeNumberValue = { value in
            change(property: Property.marginRight, to: value.toData())
        }

        marginBottomView.onChangeNumberValue = { value in
            change(property: Property.marginBottom, to: value.toData())
        }

        marginLeftView.onChangeNumberValue = { value in
            change(property: Property.marginLeft, to: value.toData())
        }

        accessibilityInspector.isExpanded = UserDefaults.standard.bool(forKey: "accessibilityInspectorExpanded")
        accessibilityInspector.onClickHeader = { [unowned self] in
            let newValue = !self.accessibilityInspector.isExpanded
            self.accessibilityInspector.isExpanded = newValue
            UserDefaults.standard.set(newValue, forKey: "accessibilityInspectorExpanded")
        }

        accessibilityInspector.onChangeAccessibilityTypeIndex = { index in
            let newValue = self.accessibilityTypeValue(for: index).toData()
            change(property: Property.accessibilityType, to: newValue)
        }

        accessibilityInspector.onChangeAccessibilityLabel = { value in
            change(property: Property.accessibilityLabel, to: value.toData())
        }

        accessibilityInspector.onChangeAccessibilityHintText = { value in
            change(property: Property.accessibilityHint, to: value.toData())
        }

        accessibilityInspector.onChangeAccessibilityRoleIndex = { value in
            change(property: Property.accessibilityRole, to: CSLayer.accessibilityRoles[value].toData())
        }

        accessibilityInspector.accessibilityRoles = CSLayer.accessibilityRoles
        accessibilityInspector.accessibilityElements = csLayer.descendantLayerNames(includingSelf: false)
        accessibilityInspector.onChangeSelectedElementIndices = { value in
            change(property: Property.accessibilityElements, to: value.toData())
        }

        borderStyleView.onChangeSelectedIndex = { value in
            change(property: Property.borderStyle, to: value.toData())
        }

        backgroundColorInput.onChangeColorString = { value in
            change(property: Property.backgroundColor, to: value?.toData() ?? CSData.Null)
        }

        textView.onChangeValue = { csValue in
            change(property: Property.text, to: csValue.data)
        }

        textStyleView.onChangeValue = { csValue in
            change(property: Property.textStyle, to: csValue.data)
        }

        imageURLView.onChangeValue = { csValue in
            change(property: Property.image, to: csValue.data)
        }
    }

    let controlledProperties: [Property] = [
        Property.text,
        Property.textStyle,
        Property.direction,
        Property.horizontalAlignment,
        Property.verticalAlignment,
        Property.width,
        Property.height,
        Property.aspectRatio,
        Property.paddingTop,
        Property.paddingRight,
        Property.paddingBottom,
        Property.paddingLeft,
        Property.marginTop,
        Property.marginRight,
        Property.marginBottom,
        Property.marginLeft,
        Property.image,
        Property.borderStyle,
        Property.backgroundColor,
        Property.accessibilityType,
        Property.accessibilityLabel,
        Property.accessibilityHint,
        Property.accessibilityRole,
        Property.accessibilityElements
    ]

    private func accessibilityTypeValue(for index: Int) -> String {
        switch index {
        case 0:
            return "default"
        case 1:
            return "none"
        case 2:
            return "element"
        case 3:
            return "container"
        default:
            return "default"
        }
    }

    private func dimensionTypeValue(for index: Int) -> String {
        switch index {
        case 2:
            return "Shrink"
        case 1:
            return "Expand"
        case 0:
            return "Fixed"
        default:
            return ""
        }
    }

    private func alignmentValue(for index: Int) -> String {
        switch index {
        case 0:
            return "flex-start"
        case 1:
            return "center"
        case 2:
            return "flex-end"
        default:
            return ""
        }
    }

    private func update(property: Property, value: CSData?) {
        guard let value = value else { return }

        let layerName = csLayer.name

        switch property {
        case .width:
            switch value.get(key: "case").stringValue {
            case "Shrink":
                dimensionsInspector.widthType = .fitContent
            case "Expand":
                dimensionsInspector.widthType = .fill
            case "Fixed":
                let numberValue = CGFloat(value.get(key: "data").numberValue)
                dimensionsInspector.widthValue = numberValue
                dimensionsInspector.widthType = .fixed(numberValue)
            default:
                fatalError("WARNING: Invalid width")
            }
        case .height:
            switch value.get(key: "case").stringValue {
            case "Shrink":
                dimensionsInspector.heightType = .fitContent
            case "Expand":
                dimensionsInspector.heightType = .fill
            case "Fixed":
                let numberValue = CGFloat(value.get(key: "data").numberValue)
                dimensionsInspector.heightValue = numberValue
                dimensionsInspector.heightType = .fixed(numberValue)
            default:
                fatalError("WARNING: Invalid height")
            }
        case .paddingTop:
            paddingTopView.numberValue = CGFloat(value.numberValue)
        case .paddingRight:
            paddingRightView.numberValue = CGFloat(value.numberValue)
        case .paddingBottom:
            paddingBottomView.numberValue = CGFloat(value.numberValue)
        case .paddingLeft:
            paddingLeftView.numberValue = CGFloat(value.numberValue)
        case .marginTop:
            marginTopView.numberValue = CGFloat(value.numberValue)
        case .marginRight:
            marginRightView.numberValue = CGFloat(value.numberValue)
        case .marginBottom:
            marginBottomView.numberValue = CGFloat(value.numberValue)
        case .marginLeft:
            marginLeftView.numberValue = CGFloat(value.numberValue)
        case .direction:
            layoutInspector.direction = value.stringValue == "column" ? .vertical : .horizontal
        case .horizontalAlignment:
            switch value.stringValue {
            case "flex-start":
                layoutInspector.horizontalAlignment = .left
            case "center":
                layoutInspector.horizontalAlignment = .center
            case "flex-end":
                layoutInspector.horizontalAlignment = .right
            default:
                Swift.print("WARNING: Invalid horizontalAlignment")
            }
        case .verticalAlignment:
            switch value.stringValue {
            case "flex-start":
                layoutInspector.verticalAlignment = .top
            case "center":
                layoutInspector.verticalAlignment = .middle
            case "flex-end":
                layoutInspector.verticalAlignment = .bottom
            default:
                Swift.print("WARNING: Invalid verticalAlignment")
            }
        case .aspectRatio:
            dimensionsInspector.aspectRatioValue = CGFloat(value.numberValue)
        case .borderStyle:
            borderStyleView.selectedIndex = value.int
        case .backgroundColor:
            let csValue = CSValue(type: CSColorType, data: value)
            backgroundColorInput.colorString = value.string
            backgroundColorInput.getPasteboardItem = {
                return CSParameter(name: "backgroundColor", type: csValue.type, defaultValue: csValue)
                    .makePasteboardItem(withAssignmentTo: layerName)
            }
        case .text:
            let csValue = CSValue(type: .string, data: value)
            textView.value = csValue
            textView.getPasteboardItem = {
                return CSParameter(name: "text", type: csValue.type, defaultValue: csValue)
                    .makePasteboardItem(withAssignmentTo: layerName)
            }
        case .textStyle:
            let csValue = CSValue(type: CSTextStyleType, data: value)
            textStyleView.value = csValue
            textStyleView.getPasteboardItem = {
                return CSParameter(name: "textStyle", type: csValue.type, defaultValue: csValue)
                    .makePasteboardItem(withAssignmentTo: layerName)
            }
        case .image:
            let csValue = CSValue(type: CSURLType, data: value)
            imageURLView.value = csValue
            imageURLView.getPasteboardItem = {
                return CSParameter(name: "image", type: csValue.type, defaultValue: csValue)
                    .makePasteboardItem(withAssignmentTo: layerName)
            }
        case .accessibilityType:
            switch value.stringValue {
            case "default":
                accessibilityInspector.accessibilityTypeIndex = 0
            case "none":
                accessibilityInspector.accessibilityTypeIndex = 1
            case "element":
                accessibilityInspector.accessibilityTypeIndex = 2
            case "container":
                accessibilityInspector.accessibilityTypeIndex = 3
            default:
                Swift.print("WARNING: Invalid accessibilityTypeIndex")
            }
        case .accessibilityLabel:
            accessibilityInspector.accessibilityLabelText = value.stringValue
        case .accessibilityHint:
            accessibilityInspector.accessibilityHintText = value.stringValue
        case .accessibilityRole:
            accessibilityInspector.accessibilityRoleIndex = CSLayer.accessibilityRoles.firstIndex(of: value.stringValue) ?? 0
        case .accessibilityElements:
            accessibilityInspector.selectedElementIndices = value.arrayValue.map { $0.int }
        default:
            break
        }
    }

    static func properties(from layer: CSLayer) -> [Property: CSData] {
        let accessibilityIndices = layer.accessibility.elements.compactMap({ layer.descendantLayerNames(includingSelf: false).lastIndex(of: $0) })

        return [
            // Layout
            CoreComponentInspectorView.Property.direction: CSData.String(layer.flexDirection ?? "column"),
            CoreComponentInspectorView.Property.horizontalAlignment: CSData.String(layer.horizontalAlignment),
            CoreComponentInspectorView.Property.verticalAlignment: CSData.String(layer.verticalAlignment),

            // Box Model
            CoreComponentInspectorView.Property.width: CSData.Object([
                "case": CSData.String(layer.widthSizingRule.toString()),
                "data": CSData.Number(layer.width ?? 0)
                ]),
            CoreComponentInspectorView.Property.height: CSData.Object([
                "case": CSData.String(layer.heightSizingRule.toString()),
                "data": CSData.Number(layer.height ?? 0)
                ]),
            CoreComponentInspectorView.Property.marginTop: CSData.Number(layer.marginTop ?? 0),
            CoreComponentInspectorView.Property.marginRight: CSData.Number(layer.marginRight ?? 0),
            CoreComponentInspectorView.Property.marginBottom: CSData.Number(layer.marginBottom ?? 0),
            CoreComponentInspectorView.Property.marginLeft: CSData.Number(layer.marginLeft ?? 0),
            CoreComponentInspectorView.Property.paddingTop: CSData.Number(layer.paddingTop ?? 0),
            CoreComponentInspectorView.Property.paddingRight: CSData.Number(layer.paddingRight ?? 0),
            CoreComponentInspectorView.Property.paddingBottom: CSData.Number(layer.paddingBottom ?? 0),
            CoreComponentInspectorView.Property.paddingLeft: CSData.Number(layer.paddingLeft ?? 0),
            CoreComponentInspectorView.Property.aspectRatio: CSData.Number(layer.aspectRatio ?? 0),

            // Border
            CoreComponentInspectorView.Property.borderRadius: CSData.Number(layer.borderRadius ?? 0),
            CoreComponentInspectorView.Property.borderColor: CSData.String(layer.borderColor ?? "transparent"),
            CoreComponentInspectorView.Property.borderColorEnabled: CSData.Bool(layer.borderColor != nil),
            CoreComponentInspectorView.Property.borderWidth: CSData.Number(layer.borderWidth ?? 0),
            CoreComponentInspectorView.Property.borderStyle: layer.borderStyle.index.toData(),

            // Contents
            CoreComponentInspectorView.Property.opacity: CSData.Number(layer.opacity ?? 1),
            CoreComponentInspectorView.Property.backgroundColor: layer.backgroundColor != nil
                ? CSData.String(layer.backgroundColor!) : CSData.Null,
            CoreComponentInspectorView.Property.backgroundGradient: CSData.String(layer.backgroundGradient ?? ""),

            // Shadow
            CoreComponentInspectorView.Property.shadow: CSData.String(layer.shadow ?? "default"),
            CoreComponentInspectorView.Property.shadowEnabled: CSData.Bool(layer.shadow != nil),

            // Text
            CoreComponentInspectorView.Property.text: CSData.String(layer.text ?? ""),
            CoreComponentInspectorView.Property.textStyle: CSData.String(layer.font ?? CSTypography.defaultName),
            CoreComponentInspectorView.Property.textAlign: CSData.String(layer.textAlign ?? "left"),
            CoreComponentInspectorView.Property.numberOfLines: CSData.Number(Double(layer.numberOfLines ?? -1)),

            // Image
            CoreComponentInspectorView.Property.image: CSData.String(layer.image ?? ""),
            CoreComponentInspectorView.Property.resizeMode: CSData.String(layer.resizeMode?.rawValue ?? "cover"),

            // Animation
            CoreComponentInspectorView.Property.animation: CSData.String(layer.animation ?? ""),
            CoreComponentInspectorView.Property.animationSpeed: CSData.Number(layer.animationSpeed ?? 1),

            // Accessibility
            CoreComponentInspectorView.Property.accessibilityType: layer.accessibility.typeName.toData(),
            CoreComponentInspectorView.Property.accessibilityLabel: (layer.accessibility.label ?? "").toData(),
            CoreComponentInspectorView.Property.accessibilityHint: (layer.accessibility.hint ?? "").toData(),
            CoreComponentInspectorView.Property.accessibilityRole: (layer.accessibility.role?.rawValue ?? "none").toData(),
            CoreComponentInspectorView.Property.accessibilityElements: accessibilityIndices.toData(),

            // Metadata
            CoreComponentInspectorView.Property.accessLevel: CSValue.expand(
                type: CSType.platformSpecificAccessLevel, data: layer.metadata["accessLevel"] ?? CSData.Object([:])),
            CoreComponentInspectorView.Property.backingElementClass: layer.metadata["backingElementClass"] ?? CSData.Object([:])
        ]
    }

    static func update(layer: CSLayer, property: Property, to value: CSData) {
        switch property {

        // Layout
        case .direction: layer.flexDirection = value.stringValue
        case .horizontalAlignment: layer.horizontalAlignment = value.stringValue
        case .verticalAlignment: layer.verticalAlignment = value.stringValue

        // Box Model
        case .width:
            let tag = DimensionSizingRule.fromString(rawValue: value.get(key: "case").stringValue)
            // Order seems to matter here. Setting widthSizingRule before width doesn't work.
            layer.width = tag == .Fixed ? value.get(key: "data").numberValue : 0
            layer.widthSizingRule = tag
        case .height:
            let tag = DimensionSizingRule.fromString(rawValue: value.get(key: "case").stringValue)
            // Order seems to matter here. Setting heightSizingRule before height doesn't work.
            layer.height = tag == .Fixed ? value.get(key: "data").numberValue : 0
            layer.heightSizingRule = tag
        case .marginTop: layer.marginTop = value.numberValue
        case .marginRight: layer.marginRight = value.numberValue
        case .marginBottom: layer.marginBottom = value.numberValue
        case .marginLeft: layer.marginLeft = value.numberValue
        case .paddingTop: layer.paddingTop = value.numberValue
        case .paddingRight: layer.paddingRight = value.numberValue
        case .paddingBottom: layer.paddingBottom = value.numberValue
        case .paddingLeft: layer.paddingLeft = value.numberValue
        case .aspectRatio: layer.aspectRatio = value.numberValue

        // Border
        case .borderRadius: layer.borderRadius = value.numberValue
        case .borderColor: layer.borderColor = value.stringValue
        case .borderColorEnabled: layer.borderColor = value.boolValue ? "transparent" : nil
        case .borderWidth: layer.borderWidth = value.numberValue
        case .borderStyle: layer.borderStyle = CSLayer.BorderStyle(index: value.int)

        // Content
        case .opacity: layer.opacity = max(min(value.numberValue, 1), 0)
        case .backgroundColor: layer.backgroundColor = value.string
        case .backgroundGradient: layer.backgroundGradient = value.string

        // Shadow
        case .shadowEnabled: layer.shadow = value.boolValue ? CSShadows.defaultName : nil
        case .shadow: layer.shadow = value.stringValue

        // Text
        case .text: layer.text = value.stringValue
        case .numberOfLines: layer.numberOfLines = Int(value.numberValue)
        case .textStyle: layer.font = value.stringValue
        case .textAlign: layer.textAlign = value.stringValue

        // Image
        case .image: layer.image = value.stringValue
        case .resizeMode: layer.resizeMode = ResizeMode(rawValue: value.stringValue)

        // Animation
        case .animation: layer.animation = value.stringValue
        case .animationSpeed: layer.animationSpeed = value.numberValue

        // Accessibility
        case .accessibilityType: layer.accessibility = layer.accessibility.withType(value.stringValue)
        case .accessibilityLabel: layer.accessibility = layer.accessibility.withLabel(value.stringValue.isEmpty ? nil : value.string)
        case .accessibilityHint: layer.accessibility = layer.accessibility.withHint(value.stringValue.isEmpty ? nil : value.string)
        case .accessibilityElements:
            let layerNames = layer.descendantLayerNames(includingSelf: false)
            let elements = value.arrayValue.map { $0.int }.map { layerNames[$0] }
            layer.accessibility = layer.accessibility.withElements(elements)
        case .accessibilityRole: layer.accessibility = layer.accessibility.withRole(AccessibilityRole(rawValue: value.stringValue))
        // Metadata
        case .accessLevel: layer.metadata["accessLevel"] = CSValue.compact(
            type: CSType.platformSpecificAccessLevel, data: CSData.Object(value.objectValue))
        case .backingElementClass: layer.metadata["backingElementClass"] = CSData.Object(value.objectValue)
        }
    }
}
