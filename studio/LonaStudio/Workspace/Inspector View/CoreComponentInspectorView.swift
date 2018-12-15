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
//        case position
//        case top
//        case right
//        case bottom
//        case left
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

        // Contents
        case opacity
        case backgroundColor
        case backgroundColorEnabled
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

        // Metadata
        case backingElementClass
    }

    var value: Properties = [:]
    var onChange: (Properties) -> Void = {_ in}
    var onChangeProperty: (Property, CSData) -> Void = {_, _  in}

    func handlePropertyChange(for property: Property, value: CSData) {
        self.value[property] = value
        updateInternalState(for: property)
        onChangeProperty(property, value)
        onChange(self.value)
    }

    override var isFlipped: Bool { return true }

    var textSection: DisclosureContentRow!
    var imageSection: DisclosureContentRow!
    var animationSection: DisclosureContentRow!
    var shadowSection: DisclosureContentRow!

    var layoutInspector = LayoutInspector()
    var dimensionsInspector = DimensionsInspector()

//    var positionView = PopupField(
//        frame: NSRect.zero,
//        values: ["relative", "absolute"],
//        valueToTitle: ["relative": "Self", "absolute": "Parent"]
//    )
//    var topView = NumberField(frame: NSRect.zero)
//    var rightView = NumberField(frame: NSRect.zero)
//    var bottomView = NumberField(frame: NSRect.zero)
//    var leftView = NumberField(frame: NSRect.zero)

    var opacityView = NumberField(frame: NSRect.zero)
    var backgroundColorButton = ColorPickerButton(frame: NSRect.zero)
    var backgroundColorEnabledView = CheckboxField(frame: NSRect.zero)
    var borderColorButton = ColorPickerButton(frame: NSRect.zero)
    var borderColorEnabledView = CheckboxField(frame: NSRect.zero)
    var borderRadiusView = NumberField(frame: NSRect.zero)
    var shadowEnabledView = CheckboxField(frame: NSRect.zero)
    var shadowButton = ShadowStylePickerButton(frame: NSRect.zero)

    var textAlignView = PopupField(
        frame: NSRect.zero,
        values: ["left", "center", "right"],
        valueToTitle: ["left": "Left", "center": "Center", "right": "Right"]
    )
    var textStyleView = TextStylePickerButton(frame: NSRect.zero)
    var numberOfLinesView = NumberField(frame: NSRect.zero)

    var paddingTopView = NumberField(frame: NSRect.zero)
    var paddingLeftView = NumberField(frame: NSRect.zero)
    var paddingRightView = NumberField(frame: NSRect.zero)
    var paddingBottomView = NumberField(frame: NSRect.zero)
    var marginTopView = NumberField(frame: NSRect.zero)
    var marginLeftView = NumberField(frame: NSRect.zero)
    var marginRightView = NumberField(frame: NSRect.zero)
    var marginBottomView = NumberField(frame: NSRect.zero)
    var borderWidthView = NumberField(frame: NSRect.zero)

    var backgroundGradientView = TextField(frame: NSRect.zero)
    var textView = TextField(frame: NSRect.zero)
    var imageView = ImageField(frame: NSRect.zero)
    var imageURLView = TextField(frame: NSRect.zero)
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

    var backingElement = CSValueField(
        value: CSValue(
            type: PlatformSpecificString,
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

//    func renderPositionSection() -> DisclosureContentRow {
//
//        topView.nextKeyView = rightView
//        rightView.nextKeyView = bottomView
//        bottomView.nextKeyView = leftView
//
//        let top = NSStackView(views: [
//            NSTextField(labelWithString: "Top"),
//            topView
//            ], orientation: .vertical, stretched: true)
//
//        let right = NSStackView(views: [
//            NSTextField(labelWithString: "Right"),
//            rightView
//            ], orientation: .vertical, stretched: true)
//
//        let bottom = NSStackView(views: [
//            NSTextField(labelWithString: "Bottom"),
//            bottomView
//            ], orientation: .vertical, stretched: true)
//
//        let left = NSStackView(views: [
//            NSTextField(labelWithString: "Left"),
//            leftView
//            ], orientation: .vertical, stretched: true)
//
//        let positionContainer = NSStackView(
//            views: [top, right, bottom, left],
//            orientation: .horizontal,
//            stretched: true
//        )
//        positionContainer.distribution = .fillEqually
//        positionContainer.spacing = 20
//
//        let dimensionsSection = renderSection(title: "Position", views: [
//            NSTextField(labelWithString: "Coordinate System"),
//            positionView,
//            positionContainer
//            ])
//        dimensionsSection.addContentSpacing(of: 14, after: positionView)
//
//        return dimensionsSection
//    }

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
            borderContainer
            ])
        borderSection.addContentSpacing(of: 14, after: borderColorContainer)

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

        let labels = [
            marginTopView, marginRightView, marginBottomView, marginLeftView,
            paddingTopView, paddingRightView, paddingBottomView, paddingLeftView
        ]

        for label in labels {
            label.widthAnchor.constraint(equalToConstant: 40).isActive = true
            label.alignment = .center
            label.isBordered = false
            label.backgroundColor = NSColor.clear
        }

        let inner = NSView()
        inner.heightAnchor.constraint(equalToConstant: 30).isActive = true
        inner.wantsLayer = true
        inner.layer?.backgroundColor = NSColor.parse(css: "rgb(225,225,225)")!.cgColor
        inner.layer?.borderWidth = 1
        inner.layer?.borderColor = NSColor.parse(css: "rgb(201,201,201)")!.cgColor
        inner.layer?.cornerRadius = 3

        let paddingRow = NSStackView(views: [
            paddingLeftView,
            inner,
            paddingRightView
        ], orientation: .horizontal)
        paddingRow.distribution = .fill
        paddingRow.spacing = 0
        paddingRow.edgeInsets = NSEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)

        let padding = NSStackView(views: [
            paddingTopView,
            paddingRow,
            paddingBottomView
        ], orientation: .vertical)
        padding.spacing = 6
        padding.wantsLayer = true
        padding.layer?.backgroundColor = NSColor.parse(css: "rgb(238,238,238)")!.cgColor
        padding.layer?.borderWidth = 1
        padding.layer?.borderColor = NSColor.parse(css: "rgb(209,209,209)")!.cgColor
        padding.layer?.cornerRadius = 3
        padding.edgeInsets = NSEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)

        add(label: "PADDING", to: padding)

        let marginRow = NSStackView(views: [
            marginLeftView,
            padding,
            marginRightView
        ], orientation: .horizontal)
        marginRow.distribution = .fill
        marginRow.spacing = 0
        marginRow.edgeInsets = NSEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)

        let margin = BorderedStackView(views: [], orientation: .vertical)
        margin.addArrangedSubview(marginTopView)
        margin.addArrangedSubview(marginRow, stretched: true)
        margin.addArrangedSubview(marginBottomView)
        margin.edgeInsets = NSEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)

        add(label: "MARGIN", to: margin)

        let spacingSection = renderSection(title: "Spacing", views: [margin])
        spacingSection.contentEdgeInsets = NSEdgeInsets(top: 0, left: 0, bottom: 25, right: 0)

        return spacingSection
    }

    func renderBackgroundSection() -> DisclosureContentRow {
        backgroundColorEnabledView.imagePosition = .imageOnly

        let backgroundColorContainer = NSStackView(
            views: [
                backgroundColorEnabledView,
                backgroundColorButton
            ],
            orientation: .horizontal,
            stretched: true
        )

        let backgroundSection = renderSection(title: "Opacity & Background", views: [
            NSTextField(labelWithString: "Opacity"),
            opacityView,
            NSTextField(labelWithString: "Background Color"),
            backgroundColorContainer,
            NSTextField(labelWithString: "Gradient"),
            backgroundGradientView
        ])

        [opacityView, backgroundColorContainer, backgroundGradientView].forEach {
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
        let backgroundSection = renderSection(title: "Metadata", views: [backingRow])
        return backgroundSection
    }

    func renderTextSection() -> DisclosureContentRow {
        textView.usesSingleLineMode = false

        let textSection = renderSection(title: "Text", views: [
            NSTextField(labelWithString: "Value"),
            textView,
            NSTextField(labelWithString: "Style"),
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

        let button = Button(titleText: "Browse...")
        button.onPress = {
            let dialog = NSOpenPanel()

            dialog.title = "Choose an image"
            dialog.showsResizeIndicator = true
            dialog.showsHiddenFiles = false
            dialog.canCreateDirectories = false
            dialog.canChooseDirectories = false
            dialog.canChooseFiles = true
            dialog.allowsMultipleSelection = false

            if dialog.runModal() == NSApplication.ModalResponse.OK {
                guard let url = dialog.url else { return }

                let path: String
                if let relativePath = url.path.pathRelativeTo(basePath: CSUserPreferences.workspaceURL.path) {
                    path = "file://" + relativePath
                } else {
                    path = url.absoluteString
                }

                self.handlePropertyChange(for: .image, value: CSData.String(path))
            }
        }

        let urlContainer = NSStackView(views: [
            imageURLView,
            button
        ], orientation: .horizontal)

        let imageSection = renderSection(title: "Image", views: [
            NSTextField(labelWithString: "URL"),
            urlContainer,
            NSTextField(labelWithString: "Scaling"),
            imageResizeModeView,
            NSTextField(labelWithString: "Asset"),
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

    func render(properties: Properties) {

        textSection = renderTextSection()
        imageSection = renderImageSection()
        animationSection = renderAnimationSection()
        shadowSection = renderShadowSection()

        let sections = [
            layoutInspector,
            textSection!,
            dimensionsInspector,
//            renderPositionSection(),
            renderSpacingSection(),
            renderBorderSection(),
            renderBackgroundSection(),
            shadowSection!,
            imageSection!,
            animationSection!,
            renderMetadataSection()
        ]

        for section in sections {
            addArrangedSubview(section, stretched: true)
        }
    }

    func setup(properties: Properties) {
        render(properties: properties)

        marginTopView.nextKeyView = marginRightView
        marginRightView.nextKeyView = marginBottomView
        marginBottomView.nextKeyView = marginLeftView
        marginLeftView.nextKeyView = paddingTopView

        paddingTopView.nextKeyView = paddingRightView
        paddingRightView.nextKeyView = paddingBottomView
        paddingBottomView.nextKeyView = paddingLeftView
    }

    init(frame frameRect: NSRect, layerType: CSLayer.LayerType, properties: Properties) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
        orientation = .vertical
        alignment = .left
        spacing = 0

        setup(properties: properties)

        switch layerType {
        case .builtIn(.text):
            textSection.isHidden = false
            layoutInspector.isHidden = true
        case .builtIn(.image), .builtIn(.vectorGraphic):
            imageSection.isHidden = false
        case .builtIn(.animation):
            animationSection.isHidden = false
        default:
            break
        }

//        switch layerType {
//        case .builtIn(.image), .builtIn(.vectorGraphic):
//            let values = DIMENSION_SIZING_IMAGE_VALUES
//            let valueToTitle = DIMENSION_SIZING_IMAGE_VALUE_TO_TITLE
//            widthSizingRuleView.set(values: values, valueToTitle: valueToTitle)
//            heightSizingRuleView.set(values: values, valueToTitle: valueToTitle)
//        default:
//            let values = DIMENSION_SIZING_VALUES
//            let valueToTitle = DIMENSION_SIZING_VALUE_TO_TITLE
//            widthSizingRuleView.set(values: values, valueToTitle: valueToTitle)
//            heightSizingRuleView.set(values: values, valueToTitle: valueToTitle)
//        }

        switch layerType {
        case .builtIn(.image):
            let values = RESIZE_MODE_VALUES
            let valueToTitle = RESIZE_MODE_VALUE_TO_TITLE
            imageResizeModeView.set(values: values, valueToTitle: valueToTitle)
        case .builtIn(.vectorGraphic):
            let values = RESIZE_MODE_VECTOR_VALUES
            let valueToTitle = RESIZE_MODE_VECTOR_VALUE_TO_TITLE
            imageResizeModeView.set(values: values, valueToTitle: valueToTitle)
        default:
            break
        }

        let fields: [(control: CSControl, property: Property)] = [
            // Box Model
//            (positionView, .position),
//            (topView, .top),
//            (rightView, .right),
//            (bottomView, .bottom),
//            (leftView, .left),
            (marginTopView, .marginTop),
            (marginRightView, .marginRight),
            (marginBottomView, .marginBottom),
            (marginLeftView, .marginLeft),
            (paddingTopView, .paddingTop),
            (paddingRightView, .paddingRight),
            (paddingBottomView, .paddingBottom),
            (paddingLeftView, .paddingLeft),

            // Border
            (borderRadiusView, .borderRadius),
            (borderColorButton, .borderColor),
            (borderColorEnabledView, .borderColorEnabled),
            (borderWidthView, .borderWidth),

            // Contents
            (opacityView, .opacity),
            (backgroundColorButton, .backgroundColor),
            (backgroundColorEnabledView, .backgroundColorEnabled),
            (backgroundGradientView, .backgroundGradient),

            // Shadow
            (shadowButton, .shadow),
            (shadowEnabledView, .shadowEnabled),

            // Text
            (textView, .text),
            (textAlignView, .textAlign),
            (textStyleView, .textStyle),
            (numberOfLinesView, .numberOfLines),

            // Image
            (imageView, .image),
            (imageURLView, .image),
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
                        type: PlatformSpecificString,
                        data: value))
                backingRow.addArrangedSubview(backingElement.view, stretched: true)
                backingElement.onChangeData = { data in
                    self.handlePropertyChange(for: .backingElementClass, value: data)
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

        let updateList: [Property] = [
            .backgroundColorEnabled,
            .animation
        ]

        if let value = properties[.animation] {
            self.value[.animation] = value
        }

        updateList.forEach({ self.updateInternalState(for: $0) })

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
    }

    private func dimensionTypeValue(for index: Int) -> String {
        switch index {
        case 0:
            return "Shrink"
        case 1:
            return "Expand"
        case 2:
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
        default:
            break
        }
    }

    let controlledProperties: [Property] = [
        Property.direction,
        Property.horizontalAlignment,
        Property.verticalAlignment,
        Property.width,
        Property.height,
        Property.aspectRatio
    ]

    func updateInternalState(for property: Property) {
        controlledProperties.forEach {
            self.update(property: $0, value: self.value[$0])
        }

        switch property {
        case .backgroundColor:
            self.backgroundColorEnabledView.value = true
        case .backgroundColorEnabled:
            if self.value[property]?.bool == false {
                self.backgroundColorButton.value = "transparent"
            }
        case .borderColor:
            self.borderColorEnabledView.value = true
        case .borderColorEnabled:
            if self.value[property]?.bool == false {
                self.borderColorButton.value = "transparent"
            }
        case .shadow:
            self.shadowEnabledView.value = true
        case .shadowEnabled:
            if self.value[property]?.bool == false {
                self.shadowButton.value = CSShadows.defaultName
            }
        case .image:
            if let value = self.value[property]?.string {
                self.imageView.value = value
                self.imageURLView.value = value
            }
        case .animation:
            self.animationViewContainer.subviews.forEach({ $0.removeFromSuperview() })

            if let value = self.value[property]?.string, let url = URL(string: value) {
                addAnimationViewToContainer(for: url)
                self.animationURLView.value = value
            }
        default: break
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
