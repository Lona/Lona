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

class InspectorView: NSStackView {
    
    typealias Properties = [Property: CSData]
    
    enum Property {
        // Layout
        case direction
        case horizontalAlignment
        case verticalAlignment
        case heightSizingRule
        case widthSizingRule
        case itemSpacingRule
        
        // Box Model
        case position
        case top
        case right
        case bottom
        case left
        case width
        case height
        case itemSpacing
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
        
        // Color
        case backgroundColor
        case backgroundColorEnabled
        case backgroundGradient
        
        // Shadow
        case shadowEnabled
        case shadow
        
        // Text
        case text
        case textStyle
        case numberOfLines
        
        // Image
        case image
        case resizeMode
        
        // Animation
        case animation
        case animationSpeed
    }
    
    var value: Properties = [:]
    var onChange: (Properties) -> Void = {_ in}
    var onChangeProperty: (Property, CSData) -> Void = {_ in}
    
    func handlePropertyChange(for property: Property, value: CSData) {
        self.value[property] = value
        updateInternalState(for: property)
        onChangeProperty(property, value)
        onChange(self.value)
    }
    
    override var isFlipped: Bool { return true }
    
    var layoutSection: DisclosureContentRow!
    var textSection: DisclosureContentRow!
    var imageSection: DisclosureContentRow!
    var animationSection: DisclosureContentRow!
    var shadowSection: DisclosureContentRow!
    
    var directionView = PopupField(
        frame: NSRect.zero,
        values: ["row", "column"],
        valueToTitle: ["row": "Horizontal", "column": "Vertical"]
    )
    var horizontalAlignmentView = PopupField(
        frame: NSRect.zero,
        values: ["flex-start", "center", "flex-end"],
        valueToTitle: ["flex-start": "Left", "center": "Center", "flex-end": "Right"]
    )
    var verticalAlignmentView = PopupField(
        frame: NSRect.zero,
        values: ["flex-start", "center", "flex-end"],
        valueToTitle: ["flex-start": "Top", "center": "Middle", "flex-end": "Bottom"]
    )
    
    var widthSizingRuleView = PopupField(
        frame: NSRect.zero,
        values: ["Fixed", "Expand", "Shrink"],
        valueToTitle: ["Fixed": "Fixed", "Expand": "Fill",  "Shrink": "Fit Content"]
    )
    var heightSizingRuleView = PopupField(
        frame: NSRect.zero,
        values: ["Fixed", "Expand", "Shrink"],
        valueToTitle: ["Fixed": "Fixed", "Expand": "Fill",  "Shrink": "Fit Content"]
    )
    var widthView = NumberField(frame: NSRect.zero)
    var heightView = NumberField(frame: NSRect.zero)
    var itemSpacingRuleView = PopupField(
        frame: NSRect.zero,
        values: ["Shrink", "Fixed", "Expand"],
        valueToTitle: ["Fixed": "Fixed (experimental)", "Expand": "Distribute",  "Shrink": "None"]
    )
    var itemSpacingView = NumberField(frame: NSRect.zero)
    var aspectRatioView = NumberField(frame: NSRect.zero)
    
    var positionView = PopupField(
        frame: NSRect.zero,
        values: ["relative", "absolute"],
        valueToTitle: ["relative": "Self", "absolute": "Parent"]
    )
    var topView = NumberField(frame: NSRect.zero)
    var rightView = NumberField(frame: NSRect.zero)
    var bottomView = NumberField(frame: NSRect.zero)
    var leftView = NumberField(frame: NSRect.zero)
    
    var backgroundColorButton = ColorPickerButton(frame: NSRect.zero)
    var backgroundColorEnabledView = CheckboxField(frame: NSRect.zero)
    var borderColorButton = ColorPickerButton(frame: NSRect.zero)
    var borderColorEnabledView = CheckboxField(frame: NSRect.zero)
    var borderRadiusView = NumberField(frame: NSRect.zero)
    var shadowEnabledView = CheckboxField(frame: NSRect.zero)
    var shadowButton = ShadowStylePickerButton(frame: NSRect.zero)
    
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
    var resizeModeView = PopupField(
        frame: NSRect.zero,
        values: ["cover", "contain", "stretch"],
        valueToTitle: ["cover": "Aspect Fill", "contain": "Aspect Fit", "stretch": "Stretch Fill"]
    )
    
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
            let currentContext = NSGraphicsContext.current()!.cgContext
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
        section.contentEdgeInsets = EdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        
        return section
    }
    
    func renderLayoutSection() -> DisclosureContentRow {
        let alignmentContainer = NSStackView(views: [horizontalAlignmentView, verticalAlignmentView], orientation: .horizontal, stretched: true)
        alignmentContainer.distribution = .fillEqually
        alignmentContainer.spacing = 20
        
        let spacingContainer = NSStackView(views: [
            NSTextField(labelWithStringCompat: "Child Spacing"),
            itemSpacingRuleView,
            itemSpacingView,
            ], orientation: .vertical, stretched: true)
        
        let layoutSection = renderSection(title: "Layout", views: [
            NSTextField(labelWithStringCompat: "Direction"),
            directionView,
            NSTextField(labelWithStringCompat: "Children Alignment"),
            alignmentContainer,
            spacingContainer,
        ])
        layoutSection.addContentSpacing(of: 14, after: directionView)
        layoutSection.addContentSpacing(of: 14, after: alignmentContainer)
        
        return layoutSection
    }
    
    func renderDimensionsSection() -> DisclosureContentRow {
        let dimensionsLeft = NSStackView(views: [
            NSTextField(labelWithStringCompat: "Width"),
            widthSizingRuleView,
            widthView,
        ], orientation: .vertical, stretched: true)
        
        let dimensionsRight = NSStackView(views: [
            NSTextField(labelWithStringCompat: "Height"),
            heightSizingRuleView,
            heightView,
        ], orientation: .vertical, stretched: true)
        
        let dimensionsContainer = NSStackView(views: [
            dimensionsLeft,
            dimensionsRight,
        ], orientation: .horizontal, stretched: true)
        dimensionsContainer.distribution = .fillEqually
        dimensionsContainer.spacing = 20
        
        aspectRatioView = NumberField(frame: NSRect.zero)
        
        let dimensionsSection = renderSection(title: "Dimensions", views: [
            dimensionsContainer,
            NSTextField(labelWithStringCompat: "Aspect Ratio"),
            aspectRatioView,
        ])
        dimensionsSection.addContentSpacing(of: 14, after: dimensionsContainer)
        
        return dimensionsSection
    }
    
    
    func renderPositionSection() -> DisclosureContentRow {

        topView.nextKeyView = rightView
        rightView.nextKeyView = bottomView
        bottomView.nextKeyView = leftView
        
        let top = NSStackView(views: [
            NSTextField(labelWithStringCompat: "Top"),
            topView,
            ], orientation: .vertical, stretched: true)
        
        let right = NSStackView(views: [
            NSTextField(labelWithStringCompat: "Right"),
            rightView,
            ], orientation: .vertical, stretched: true)
        
        let bottom = NSStackView(views: [
            NSTextField(labelWithStringCompat: "Bottom"),
            bottomView,
            ], orientation: .vertical, stretched: true)
        
        let left = NSStackView(views: [
            NSTextField(labelWithStringCompat: "Left"),
            leftView,
            ], orientation: .vertical, stretched: true)
        
        let positionContainer = NSStackView(
            views: [top, right, bottom, left],
            orientation: .horizontal,
            stretched: true
        )
        positionContainer.distribution = .fillEqually
        positionContainer.spacing = 20
        
        let dimensionsSection = renderSection(title: "Position", views: [
            NSTextField(labelWithStringCompat: "Coordinate System"),
            positionView,
            positionContainer,
            ])
        dimensionsSection.addContentSpacing(of: 14, after: positionView)
        
        return dimensionsSection
    }
    
    func renderBorderSection() -> DisclosureContentRow {
        borderRadiusView.nextKeyView = borderWidthView
        
        let width = NSStackView(views: [
            NSTextField(labelWithStringCompat: "Width"),
            borderWidthView,
            ], orientation: .vertical, stretched: true)
        
        let radius = NSStackView(views: [
            NSTextField(labelWithStringCompat: "Radius"),
            borderRadiusView,
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
                borderColorButton,
                ],
            orientation: .horizontal,
            stretched: true
        )
        
        let borderSection = renderSection(title: "Border", views: [
            NSTextField(labelWithStringCompat: "Color"),
            borderColorContainer,
            borderContainer,
            ])
        borderSection.addContentSpacing(of: 14, after: borderColorContainer)
        
        return borderSection
    }
    
    func renderSpacingSection() -> DisclosureContentRow {
        
        func add(label string: String, to view: NSView) {
            let label = NSTextField(labelWithStringCompat: string)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = NSFont.systemFont(ofSize: 9)
            
            view.addSubview(label)
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 13).isActive = true
            label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        }
        
        let labels = [
            marginTopView, marginRightView, marginBottomView, marginLeftView,
            paddingTopView, paddingRightView, paddingBottomView, paddingLeftView,
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
            paddingRightView,
        ], orientation: .horizontal)
        paddingRow.distribution = .fill
        paddingRow.spacing = 0
        paddingRow.edgeInsets = EdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        let padding = NSStackView(views: [
            paddingTopView,
            paddingRow,
            paddingBottomView,
        ], orientation: .vertical)
        padding.spacing = 6
        padding.wantsLayer = true
        padding.layer?.backgroundColor = NSColor.parse(css: "rgb(238,238,238)")!.cgColor
        padding.layer?.borderWidth = 1
        padding.layer?.borderColor = NSColor.parse(css: "rgb(209,209,209)")!.cgColor
        padding.layer?.cornerRadius = 3
        padding.edgeInsets = EdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        add(label: "PADDING", to: padding)
        
        let marginRow = NSStackView(views: [
            marginLeftView,
            padding,
            marginRightView,
        ], orientation: .horizontal)
        marginRow.distribution = .fill
        marginRow.spacing = 0
        marginRow.edgeInsets = EdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        let margin = BorderedStackView(views: [], orientation: .vertical)
        margin.addArrangedSubview(marginTopView)
        margin.addArrangedSubview(marginRow, stretched: true)
        margin.addArrangedSubview(marginBottomView)
        margin.edgeInsets = EdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        
        add(label: "MARGIN", to: margin)
        
        let spacingSection = renderSection(title: "Spacing", views: [margin])
        spacingSection.contentEdgeInsets = EdgeInsets(top: 0, left: 0, bottom: 25, right: 0)
        
        return spacingSection
    }
    
    func renderBackgroundSection() -> DisclosureContentRow {
        backgroundColorEnabledView.imagePosition = .imageOnly
        
        let backgroundColorContainer = NSStackView(
            views: [
                backgroundColorEnabledView,
                backgroundColorButton,
            ],
            orientation: .horizontal,
            stretched: true
        )
        
        let backgroundSection = renderSection(title: "Background", views: [
            backgroundColorContainer,
            backgroundGradientView,
        ])
        
        return backgroundSection
    }
    
    func renderShadowSection() -> DisclosureContentRow {
        shadowEnabledView.imagePosition = .imageOnly
        
        let shadowContainer = NSStackView(
            views: [
                shadowEnabledView,
                shadowButton,
                ],
            orientation: .horizontal,
            stretched: true
        )
        
        let backgroundSection = renderSection(title: "Shadow", views: [shadowContainer])
        backgroundSection.isHidden = true
        return backgroundSection
    }
    
    func renderTextSection() -> DisclosureContentRow {
        textView.usesSingleLineMode = false
        
        let textSection = renderSection(title: "Text", views: [
            NSTextField(labelWithStringCompat: "Value"),
            textView,
            NSTextField(labelWithStringCompat: "Style"),
            textStyleView,
            NSTextField(labelWithStringCompat: "Max Lines"),
            numberOfLinesView,
        ])
        
        textSection.isHidden = true
        //        hideViews(views: [textFields], animated: false)
        
        return textSection
    }
    
    func renderImageSection() -> DisclosureContentRow {
        imageView.constrain(aspectRatio: 1)
        imageView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        
        let button = Button(title: "Browse...")
        button.onPress = {
            let dialog = NSOpenPanel()
            
            dialog.title = "Choose an image"
            dialog.showsResizeIndicator = true
            dialog.showsHiddenFiles = false
            dialog.canCreateDirectories = false
            dialog.canChooseDirectories = false
            dialog.canChooseFiles = true
            dialog.allowsMultipleSelection = false
            
            if dialog.runModal() == NSModalResponseOK {
                self.handlePropertyChange(for: .image, value: CSData.String(dialog.url!.absoluteString))
            }
        }
        
        let urlContainer = NSStackView(views: [
            imageURLView,
            button,
        ], orientation: .horizontal)
        
        let imageSection = renderSection(title: "Image", views: [
            NSTextField(labelWithStringCompat: "URL"),
            urlContainer,
            NSTextField(labelWithStringCompat: "Asset"),
            imageView,
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
        
        let button = Button(title: "Browse...")
        button.onPress = {
            let dialog = NSOpenPanel()
            
            dialog.title = "Choose an animation file"
            dialog.showsResizeIndicator = true
            dialog.showsHiddenFiles = false
            dialog.canCreateDirectories = false
            dialog.canChooseDirectories = false
            dialog.canChooseFiles = true
            dialog.allowsMultipleSelection = false
            
            if dialog.runModal() == NSModalResponseOK {
                self.handlePropertyChange(for: .animation, value: CSData.String(dialog.url!.absoluteString))
            }
        }
        
        let urlContainer = NSStackView(views: [
            animationURLView,
            button,
            ], orientation: .horizontal)
        
        let animationSection = renderSection(title: "Animation", views: [
            NSTextField(labelWithStringCompat: "URL"),
            urlContainer,
            NSTextField(labelWithStringCompat: "Asset"),
            animationViewContainer,
            NSTextField(labelWithStringCompat: "Scale Mode"),
            resizeModeView,
            NSTextField(labelWithStringCompat: "Animation Speed"),
            animationSpeedView,
            ])
        
        animationSection.isHidden = true
        
        return animationSection
    }
    
    func render(properties: Properties) {
        
        layoutSection = renderLayoutSection()
        textSection = renderTextSection()
        imageSection = renderImageSection()
        animationSection = renderAnimationSection()
        shadowSection = renderShadowSection()
        
        let sections = [
            layoutSection!,
            textSection!,
            renderDimensionsSection(),
            renderPositionSection(),
            renderSpacingSection(),
            renderBorderSection(),
            renderBackgroundSection(),
            shadowSection!,
            imageSection!,
            animationSection!
        ]
        
        for section in sections {
            addArrangedSubview(section, stretched: true)
        }
    }
    
    func setup(properties: Properties) {
        render(properties: properties)

        widthView.nextKeyView = heightView
        heightView.nextKeyView = marginTopView
        
        marginTopView.nextKeyView = marginRightView
        marginRightView.nextKeyView = marginBottomView
        marginBottomView.nextKeyView = marginLeftView
        marginLeftView.nextKeyView = paddingTopView
        
        paddingTopView.nextKeyView = paddingRightView
        paddingRightView.nextKeyView = paddingBottomView
        paddingBottomView.nextKeyView = paddingLeftView
    }
    
    init(frame frameRect: NSRect, layerType: String, properties: Properties) {
        super.init(frame: frameRect)
        translatesAutoresizingMaskIntoConstraints = false
        orientation = .vertical
        alignment = .left
        spacing = 0
        
        setup(properties: properties)
        
        switch layerType {
        case "Text":
            textSection.isHidden = false
            layoutSection.isHidden = true
            shadowSection.isHidden = false
        case "Image":
            imageSection.isHidden = false
        case "Animation":
            animationSection.isHidden = false
        default:
            break
        }
        
        let fields: [(control: CSControl, property: Property)] = [
            // Layout
            (directionView, .direction),
            (horizontalAlignmentView, .horizontalAlignment),
            (verticalAlignmentView, .verticalAlignment),
            (heightSizingRuleView, .heightSizingRule),
            (widthSizingRuleView, .widthSizingRule),
            (itemSpacingRuleView, .itemSpacingRule),
            (itemSpacingView, .itemSpacing),
            
            // Box Model
            (positionView, .position),
            (topView, .top),
            (rightView, .right),
            (bottomView, .bottom),
            (leftView, .left),
            (widthView, .width),
            (heightView, .height),
            (marginTopView, .marginTop),
            (marginRightView, .marginRight),
            (marginBottomView, .marginBottom),
            (marginLeftView, .marginLeft),
            (paddingTopView, .paddingTop),
            (paddingRightView, .paddingRight),
            (paddingBottomView, .paddingBottom),
            (paddingLeftView, .paddingLeft),
            (aspectRatioView, .aspectRatio),
            
            // Border
            (borderRadiusView, .borderRadius),
            (borderColorButton, .borderColor),
            (borderColorEnabledView, .borderColorEnabled),
            (borderWidthView, .borderWidth),
            
            // Color
            (backgroundColorButton, .backgroundColor),
            (backgroundColorEnabledView, .backgroundColorEnabled),
            (backgroundGradientView, .backgroundGradient),
            
            // Shadow
            (shadowButton, .shadow),
            (shadowEnabledView, .shadowEnabled),
            
            // Text
            (textView, .text),
            (textStyleView, .textStyle),
            (numberOfLinesView, .numberOfLines),
            
            // Image
            (imageView, .image),
            (imageURLView, .image),
            (resizeModeView, .resizeMode),
            
            // Animation
//            (animationView, .animation),
            (animationURLView, .animation),
            (animationSpeedView, .animationSpeed),
        ]
        
        fields.forEach({ (control, property) in
            var control = control
            control.onChangeData = { data in self.handlePropertyChange(for: property, value: data) }
            if let value = properties[property] { control.data = value }
        })
        
        let updateList: [Property] = [
            .heightSizingRule,
            .widthSizingRule,
            .backgroundColorEnabled,
            .animation,
        ]
        
        if let value = properties[.animation] {
            self.value[.animation] = value
        }
        
        updateList.forEach({ self.updateInternalState(for: $0) })
    }
    
    func updateInternalState(for property: Property) {
        switch property {
        case .heightSizingRule:
            if let value = self.value[property]?.string {
                self.heightView.isHidden = value != "Fixed"
                if value != "Fixed" {
                    self.heightView.value = 0
                }
            }
        case .widthSizingRule:
            if let value = self.value[property]?.string {
                self.widthView.isHidden = value != "Fixed"
                if value != "Fixed" {
                    self.widthView.value = 0
                }
            }
        case .itemSpacingRule:
            if let value = self.value[property]?.string {
                self.itemSpacingView.isHidden = value != "Fixed"
                if value != "Fixed" {
                    self.itemSpacingView.value = 0
                }
            }
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
