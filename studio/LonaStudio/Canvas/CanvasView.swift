//
//  CanvasView.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/8/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa
import yoga
import Lottie

struct ConfiguredLayer {
    let layer: CSLayer
    let config: ComponentConfiguration
    let children: [ConfiguredLayer]

    func shadow() -> CSShadow? {
        let logicValue = config.get(attribute: "shadow", for: layer.name).string
        let constantValue = layer.shadow

        guard let shadow = logicValue ?? constantValue else { return nil }

        return CSShadows.shadow(with: shadow)
    }
}

// Passed as a C pointer to Yoga, since we can't pass a struct
class ConfiguredLayerRef {
    let ref: ConfiguredLayer

    init(ref: ConfiguredLayer) {
        self.ref = ref
    }
}

func measureText(string: NSAttributedString, width: CGFloat, maxNumberOfLines: Int = -1) -> NSSize {
    let textStorage = NSTextStorage(attributedString: string)
    let textContainer = NSTextContainer(containerSize: NSSize(width: width, height: CGFloat.greatestFiniteMagnitude))
    if maxNumberOfLines > -1 {
        textContainer.maximumNumberOfLines = maxNumberOfLines
    }
    textContainer.lineBreakMode = .byTruncatingTail
    textContainer.lineFragmentPadding = 0.0
    let layoutManager = NSLayoutManager()
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)
    layoutManager.glyphRange(for: textContainer)
    let newSize = layoutManager.usedRect(for: textContainer)
    return newSize.size
}

func getLayerText(configuredLayer: ConfiguredLayer) -> String {
    let layer = configuredLayer.layer
    return configuredLayer.config.get(
        attribute: "text",
        for: layer.name).string ?? layer.text ?? ""
}

func numberValue(for configuredLayer: ConfiguredLayer, attributeChain: [String], optionalValues: [Double?] = [], defaultValue: Double = 0) -> Double {
    for attribute in attributeChain {
        let raw = configuredLayer.config.get(attribute: attribute, for: configuredLayer.layer.name)
        if raw.number == nil { continue }
        return raw.numberValue
    }

    for value in optionalValues where value != nil {
        return value!
    }

    return defaultValue
}

func measureFunc(node: YGNodeRef?, width: Float, widthMode: YGMeasureMode, height: Float, heightMode: YGMeasureMode) -> YGSize {
    let configuredLayerRef = Unmanaged<ConfiguredLayerRef>.fromOpaque(YGNodeGetContext(node)!).takeUnretainedValue()

    let renderableText = RenderableView.RenderableText.fromConfiguredLayer(configuredLayerRef.ref)

    let measured = measureText(
        string: renderableText.makeAttributedString(),
        width: CGFloat(width),
        maxNumberOfLines: renderableText.numberOfLines)

    let size = YGSize(width: Float(measured.width), height: Float(measured.height))

//    Swift.print(">> Measure text", layer.name, size, node?.flexGrow, node?.flexShrink, node?.flexBasis)

    return size
}

class FlippedView: NSView {
    override var isFlipped: Bool { return true }
}

let BORDERS: [(edge: NSRectEdge, key: String)] = [
    (NSRectEdge.minY, key: "borderTopWidth"),
    (NSRectEdge.maxX, key: "borderRightWidth"),
    (NSRectEdge.maxY, key: "borderBottomWidth"),
    (NSRectEdge.minX, key: "borderLeftWidth")
]

let imageCache = ImageCache<NSImage>()

let svgRenderCache = LRUCache<String, NSImage>()

func renderBox(configuredLayer: ConfiguredLayer, node: YGNodeRef, options: RenderOptions) -> Renderable {
    let layout = node.layout
    let config = configuredLayer.config
    let layer = configuredLayer.layer

    var renderableView = RenderableView()

    renderableView.layerName = layer.name
    renderableView.frame = NSRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)

    if layer.text == nil, let color = config.get(attribute: "backgroundColor", for: layer.name).string ?? layer.backgroundColor {
        renderableView.multipliedFillColor = CSColors.parse(css: color, withDefault: NSColor.clear).color
    }

    let opacity = config.get(attribute: "opacity", for: layer.name).number ?? layer.opacity ?? 1
    renderableView.opacity = CGFloat(opacity)

    if let borderRadius = config.get(attribute: "borderRadius", for: layer.name).number ?? layer.borderRadius {
        renderableView.cornerRadius = min(CGFloat(borderRadius), layout.width / 2, layout.height / 2)
    }

    let borderColorString = config.get(attribute: "borderColor", for: layer.name).string ?? layer.borderColor
    var borderColor = borderColorString != nil ? CSColors.parse(css: borderColorString!, withDefault: NSColor.clear).color : nil

    let borderWidth = config.get(attribute: "borderWidth", for: layer.name).number ?? layer.borderWidth

    if let borderWidth = borderWidth, borderWidth > 0 {
        renderableView.borderWidth = CGFloat(borderWidth)
        borderColor ?= NSColor.clear
    }

    if let borderColor = borderColor {
        renderableView.multipliedBorderColor = borderColor
    }

    renderableView.shadow = configuredLayer.shadow()?.nsShadow

//    if layer.type == .animation {
//        let animation: String? = config.get(attribute: "animation", for: layer.name).string ?? layer.animation
//
//        if  let animation = animation,
//            let url = URL(string: animation),
//            let json = AnimationUtils.decode(contentsOf: url) {
//            let assetMap = config
//                .get(attribute: "images", for: layer.name)
//                .objectValue
//                .filterValues(f: { $0.string != nil && URL(string: $0.stringValue) != nil })
//                .mapValues({ URL(string: $0.stringValue)! })
//            AnimationUtils.updateAssets(in: json, withFile: url, assetMap: assetMap)
//            let animationView = LOTAnimationView(json: json as! [AnyHashable: Any])
//            animationView.data = json
//            animationView.animationSpeed = CGFloat(layer.animationSpeed ?? 1)
//            animationView.contentMode = layer.resizeMode?.lotViewContentMode() ?? .scaleAspectFill
//            animationView.frame = frame
//
//            box.addSubview(animationView)
//
//            if options.hideAnimationLayers {
//                animationView.isHidden = true
//            } else {
//                animationView.play()
//            }
//        }
//    } else
    if layer.type == .image {
        let image: String? = config.get(attribute: "image", for: layer.name).string ?? layer.image

        if let image = image, let url = URL(string: image)?.absoluteURLForWorkspaceURL() {
            var scale: CGFloat = options.assetScale

            if url.pathExtension == "pdf", let document = CSPDFDocument(contentsOf: url, parsed: false) {
                let size = document.cgPDFPage!.getBoxRect(CGPDFBox.mediaBox)
                let widthScale = layout.width / size.width
                let heightScale = layout.height / size.height
                scale *= max(widthScale, heightScale)
            }

            scale = ceil(scale)

            let resizingMode = layer.resizeMode?.resizingMode() ?? .scaleAspectFill

            if let cached = imageCache.contents(for: url, at: scale) {
                renderableView.type = .image(
                    RenderableView.RenderableImage.init(image: cached, resizingMode: resizingMode))
            } else {
                let nsImage = NSImage(contentsOf: url)
                nsImage?.cacheMode = .always

                if let contents = nsImage {
                    renderableView.type = .image(
                        RenderableView.RenderableImage.init(image: contents, resizingMode: resizingMode))

                    imageCache.add(contents: contents, for: url, at: scale)
                }
            }
        }
    } else if layer.type == .vectorGraphic {
        let imageValue: String? = config.get(attribute: "image", for: layer.name).string ?? layer.image
        let resizingMode = layer.resizeMode?.resizingMode() ?? .scaleAspectFill

        if let imageValue = imageValue, let url = URL(string: imageValue)?.absoluteURLForWorkspaceURL() {

            let dynamicValues = config.get(attribute: "vector", for: layer.name)

            let cacheKey = "\(imageValue)*w\(layout.width)*h\(layout.height)*r\(resizingMode.hashValue)\(dynamicValues.toData()?.utf8String() ?? "")"

            // We draw the svg into an image that has the exact same dimensions as the view,
            // so we can scale the image to fill the view without it stretching.
            let resizingMode = CGSize.ResizingMode.scaleToFill

            if let cached = svgRenderCache.item(for: cacheKey) {
                renderableView.type = .image(
                    RenderableView.RenderableImage.init(image: cached, resizingMode: resizingMode))
            } else if let image = SVG.renderSync(
                contentsOf: url,
                dynamicValues: dynamicValues,
                size: CGSize(width: layout.width, height: layout.height),
                resizingMode: resizingMode) {

                image.cacheMode = .always

                renderableView.type = .image(
                    RenderableView.RenderableImage.init(image: image, resizingMode: resizingMode))

                svgRenderCache.add(item: image, for: cacheKey)
            }
        }
    }

    if layer.type == .text {
        renderableView.type = .text(
            RenderableView.RenderableText.fromConfiguredLayer(configuredLayer))

        return Renderable(node: renderableView, children: [])
    } else {
        let children = configuredLayer.children.enumerated().map { index, sub in
            return renderBox(configuredLayer: sub, node: YGNodeGetChild(node, UInt32(index)), options: options)
        }

        return Renderable(node: renderableView, children: children)
    }
}

typealias SketchFileReference = (id: String, data: String)
typealias SketchFileReferenceMap = [String: SketchFileReference]

func renderBoxJSON(configuredLayer: ConfiguredLayer, node: YGNodeRef, references: inout SketchFileReferenceMap) -> CSData {
    return CSData.Null
}

func setFlexExpand(for layer: CSLayer, node: YGNodeRef) {
    var node = node

    node.flexShrink = 1
    node.flexGrow = 1

    if layer.type == .text {
        node.flexBasis = .value(0)
    } else {
        node.flexBasis = .auto
    }
}

func layoutLayer(configuredLayer: ConfiguredLayer, parentLayoutDirection: YGFlexDirection) -> YGNodeRef {
    var node = YGNodeRef.create()

    let layer = configuredLayer.layer
    if let value = layer.top { node.top = CGFloat(value) }
    if let value = layer.right { node.right = CGFloat(value) }
    if let value = layer.bottom { node.bottom = CGFloat(value) }
    if let value = layer.left { node.left = CGFloat(value) }
    node.position = layer.position == .absolute ? YGPositionType.absolute : YGPositionType.relative

    let flexDirection = layer.flexDirection == "row" ? YGFlexDirection.row : YGFlexDirection.column
    node.flexDirection = flexDirection

    switch layer.heightSizingRule {
    case .Fixed:
        node.height = CGFloat(numberValue(for: configuredLayer, attributeChain: ["height"], optionalValues: [layer.height]))

        if parentLayoutDirection == .column {
            node.flex = 0
        }
    case .Expand:
        if parentLayoutDirection == .column {
            setFlexExpand(for: layer, node: node)
        } else {
            YGNodeStyleSetAlignSelf(node, .stretch)
        }
    case .Shrink:
        if parentLayoutDirection == .column {
            node.flex = 0
        }
    }

    switch layer.widthSizingRule {
    case .Fixed:
        node.width = CGFloat(numberValue(for: configuredLayer, attributeChain: ["width"], optionalValues: [layer.width]))

        if parentLayoutDirection == .row {
            node.flex = 0
        }
    case .Expand:
        if parentLayoutDirection == .row {
            setFlexExpand(for: layer, node: node)
        } else {
            YGNodeStyleSetAlignSelf(node, .stretch)
        }
    case .Shrink:
        if parentLayoutDirection == .row {
            node.flex = 0
        }
    }

    switch layer.horizontalAlignment {
    case "flex-start":
        if flexDirection == .column {
            node.alignItems = .flexStart
        } else {
            node.justifyContent = .flexStart
        }
    case "center":
        if flexDirection == .column {
            node.alignItems = .center
        } else {
            node.justifyContent = .center
        }
    case "flex-end":
        if flexDirection == .column {
            node.alignItems = .flexEnd
        } else {
            node.justifyContent = .flexEnd
        }
    default:
        break
    }

    switch layer.verticalAlignment {
    case "flex-start":
        if flexDirection == .row {
            node.alignItems = .flexStart
        } else {
            node.justifyContent = .flexStart
        }
    case "center":
        if flexDirection == .row {
            node.alignItems = .center
        } else {
            node.justifyContent = .center
        }
    case "flex-end":
        if flexDirection == .row {
            node.alignItems = .flexEnd
        } else {
            node.justifyContent = .flexEnd
        }
    default:
        break
    }

    if layer.itemSpacingRule == .Expand {
        node.justifyContent = .spaceBetween
    }

    node.paddingTop = CGFloat(numberValue(for: configuredLayer, attributeChain: ["paddingTop", "paddingVertical", "padding"], optionalValues: [layer.paddingTop]))
    node.paddingBottom = CGFloat(numberValue(for: configuredLayer, attributeChain: ["paddingBottom", "paddingVertical", "padding"], optionalValues: [layer.paddingBottom]))
    node.paddingLeft = CGFloat(numberValue(for: configuredLayer, attributeChain: ["paddingLeft", "paddingHorizontal", "padding"], optionalValues: [layer.paddingLeft]))
    node.paddingRight = CGFloat(numberValue(for: configuredLayer, attributeChain: ["paddingRight", "paddingHorizontal", "padding"], optionalValues: [layer.paddingRight]))

    node.marginTop = CGFloat(numberValue(for: configuredLayer, attributeChain: ["marginTop", "marginVertical", "margin"], optionalValues: [layer.marginTop]))
    node.marginBottom = CGFloat(numberValue(for: configuredLayer, attributeChain: ["marginBottom", "marginVertical", "margin"], optionalValues: [layer.marginBottom]))
    node.marginLeft = CGFloat(numberValue(for: configuredLayer, attributeChain: ["marginLeft", "marginHorizontal", "margin"], optionalValues: [layer.marginLeft]))
    node.marginRight = CGFloat(numberValue(for: configuredLayer, attributeChain: ["marginRight", "marginHorizontal", "margin"], optionalValues: [layer.marginRight]))

    node.borderTop = CGFloat(numberValue(for: configuredLayer, attributeChain: ["borderTopWidth", "borderVerticalWidth", "borderWidth"], optionalValues: [layer.borderWidth]))
    node.borderBottom = CGFloat(numberValue(for: configuredLayer, attributeChain: ["borderBottomWidth", "borderVerticalWidth", "borderWidth"], optionalValues: [layer.borderWidth]))
    node.borderLeft = CGFloat(numberValue(for: configuredLayer, attributeChain: ["borderLeftWidth", "borderHorizontalWidth", "borderWidth"], optionalValues: [layer.borderWidth]))
    node.borderRight = CGFloat(numberValue(for: configuredLayer, attributeChain: ["borderRightWidth", "borderHorizontalWidth", "borderWidth"], optionalValues: [layer.borderWidth]))

    if let aspectRatio = layer.aspectRatio, aspectRatio > 0 {
        YGNodeStyleSetAspectRatio(node, Float(aspectRatio))
    }

    // Non-text layer
    if layer.type == .text {
        let ref = ConfiguredLayerRef(ref: configuredLayer)
        YGNodeSetContext(node, UnsafeMutableRawPointer(Unmanaged.passRetained(ref).toOpaque()))
        YGNodeSetMeasureFunc(node, measureFunc(node:width:widthMode:height:heightMode:))
    } else {
        for (index, sub) in configuredLayer.children.enumerated() {
            var child = layoutLayer(configuredLayer: sub, parentLayoutDirection: flexDirection)

            if layer.itemSpacingRule == .Fixed {
                let itemSpacing = CGFloat(numberValue(for: configuredLayer, attributeChain: ["itemSpacing"], optionalValues: [layer.itemSpacing]))
                if node.flexDirection == .row && index != 0 {
                    child.marginLeft += itemSpacing
                } else if node.flexDirection == .column && index != 0 {
                    child.marginTop += itemSpacing
                }
            }

            node.insert(child: child, at: index)
        }
    }

    YGNodeStyleSetOverflow(node, .hidden)

    return node
}

let LARGE_CANVAS_SIZE: Double = 10000

func layoutRoot(canvas: Canvas, configuredRootLayer: ConfiguredLayer, config: ComponentConfiguration) -> (layoutNode: YGNodeRef, rootNode: YGNodeRef, height: CGFloat)? {
    guard let rootNode = YGNodeNew() else { return nil }

    let rootLayer = configuredRootLayer.layer

    let useExactHeight = canvas.heightMode == "Exactly"

    // If "At Least", use a very large canvas size to allow the node to expand.
    // We'll then measure the node to determine the canvas height.
    let canvasHeight = useExactHeight ? canvas.height : LARGE_CANVAS_SIZE

    // Build layout hierarchy
    var child = layoutLayer(configuredLayer: configuredRootLayer, parentLayoutDirection: .column)

    // Use an extra child which can have a height greater than the root layer, allowing the root to expand
    guard var wrapper = YGNodeNew() else { return nil }
    wrapper.width = CGFloat(canvas.width)

    if useExactHeight {
        wrapper.height = CGFloat(canvas.height)
    } else {
        let verticalMargins = child.marginTop + child.marginBottom
        let minHeight = CGFloat(canvas.height) - verticalMargins

        wrapper.minHeight = minHeight

        if rootLayer.heightSizingRule == .Shrink {
            // Force a min height so that children set to "Expand" will fill the canvas vertically.
            // The only downside is that this can be misleading - the top level element won't behave
            // quite the same when used within another component
            child.minHeight = minHeight
        }
    }

    wrapper.insert(child: child, at: 0)
    rootNode.insert(child: wrapper, at: 0)

    // Calculate the layout
    rootNode.calculateLayout(width: CGFloat(canvas.width), height: CGFloat(canvasHeight))

    // Create the canvas based on the calculated height of the layout
    let calculatedHeight = useExactHeight ? CGFloat(canvas.height) : wrapper.layout.height

    return (child, rootNode, calculatedHeight)
}

func renderRootToJSON(canvas: Canvas, rootLayer: CSLayer, config: ComponentConfiguration, references: inout SketchFileReferenceMap) -> (layer: CSData, height: Double) {
    let configuredRootLayer = CanvasView.configureRoot(layer: rootLayer, with: config)

    guard let layout = layoutRoot(
        canvas: canvas,
        configuredRootLayer:
        configuredRootLayer, config: config)
    else { return (CSData.Null, 0) }

    let rootLayer = renderBoxJSON(configuredLayer: configuredRootLayer, node: layout.layoutNode, references: &references)

    layout.rootNode.free(recursive: true)

    return (rootLayer, Double(layout.height))
}

enum RenderOption {
    case onSelectLayer((CSLayer) -> Void)
    case assetScale(CGFloat)
    case hideAnimationLayers(Bool)
    case renderCanvasShadow(Bool)
    case selectedLayerName(String?)
}

struct RenderOptions {
    var onSelectLayer: (CSLayer) -> Void = {_ in}
    var assetScale: CGFloat = 1
    var hideAnimationLayers: Bool = false
    var renderCanvasShadow: Bool = false
    var selectedLayerName: String?

    mutating func merge(options: [RenderOption]) {
        options.forEach({ option in
            switch option {
            case .onSelectLayer(let f): onSelectLayer = f
            case .assetScale(let value): assetScale = value
            case .hideAnimationLayers(let value): hideAnimationLayers = value
            case .renderCanvasShadow(let value): renderCanvasShadow = value
            case .selectedLayerName(let value): selectedLayerName = value
            }
        })
    }

    init(_ options: [RenderOption]) {
        merge(options: options)
    }
}

class CanvasView: NSView {
    var parameters: Parameters {
        didSet {
            update()
        }
    }

    var canvas: Canvas { return parameters.canvas }
    var rootLayer: CSLayer { return parameters.rootLayer }
    var config: ComponentConfiguration { return parameters.config }
    var options: RenderOptions { return parameters.options }

    private let backgroundView = NSBox()
    private let selectionView = NSBox()
    private let canvasView = FlippedView(frame: .zero)

    init(_ parameters: Parameters) {
        self.parameters = parameters

        super.init(frame: .zero)

        setUpViews()

        update()
    }

    convenience init(canvas: Canvas, rootLayer: CSLayer, config: ComponentConfiguration, options list: [RenderOption] = []) {
        self.init(Parameters(canvas: canvas, rootLayer: rootLayer, config: config, options: RenderOptions(list)))
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpViews() {
        addSubview(backgroundView)
        addSubview(selectionView)
        backgroundView.addSubview(canvasView)

        backgroundView.borderType = .noBorder
        backgroundView.boxType = .custom
        backgroundView.contentViewMargins = .zero

        selectionView.boxType = .custom
        selectionView.borderType = .lineBorder
        selectionView.borderWidth = 1
        selectionView.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        selectionView.cornerRadius = 2
        selectionView.contentViewMargins = .zero

        // TODO: Update on canvas change
        backgroundView.fillColor = CSColors.parse(css: canvas.backgroundColor, withDefault: NSColor.white).color

        // TODO: On High Sierra, if the canvas has a transparent fill,
        // shadows show up behind each subview's layer.
        if options.renderCanvasShadow {
            backgroundView.shadow = NSShadow(
                color: NSColor.black.withAlphaComponent(0.5),
                offset: NSSize(width: 0, height: -1),
                blur: 2)
        }
    }

    // MARK: Render

    private var previous: Renderable?

    private func render() -> Renderable? {
        let configuredRootLayer = CanvasView.configureRoot(layer: rootLayer, with: config)

        guard let layout = layoutRoot(
            canvas: canvas,
            configuredRootLayer: configuredRootLayer,
            config: config)
            else { return nil }

        let renderable = renderBox(
            configuredLayer: configuredRootLayer,
            node: layout.layoutNode,
            options: options)

        layout.rootNode.free(recursive: true)

        return renderable
    }

    func update() {
        guard let renderable = render() else { return }

        if let previous = previous {
//            Swift.print("Updating")
            renderable.updateViewHierarchy(canvasView.subviews[0], previous: previous)
        } else {
//            Swift.print("Mounting")
            let viewHierarchy = renderable.makeViewHierarchy()
            canvasView.addSubview(viewHierarchy)
        }

        frame = renderable.node.frame
        canvasView.frame = renderable.node.frame
        backgroundView.frame = renderable.node.frame

        if options.renderCanvasShadow {
            frame.size.width += 10
            frame.size.height += 10
            backgroundView.frame.origin.x += 5
            backgroundView.frame.origin.y += 5
        }

        if let selected = self.firstDescendant(where: { view in
            guard let csView = view as? CSView, let name = options.selectedLayerName else {
                return false
            }

            return csView.layerName == name
        }) {
            selectionView.frame = convert(selected.bounds.insetBy(dx: -1, dy: -1), from: selected)
            selectionView.isHidden = false
        } else {
            selectionView.isHidden = true
        }

        previous = renderable
    }
}

// MARK: Static configuration

extension CanvasView {

    static func configureRoot(layer: CSLayer, with config: ComponentConfiguration) -> ConfiguredLayer {
        return self.configure(layer: layer, with: config)[0]
    }

    static func configure(layer: CSLayer, with config: ComponentConfiguration) -> [ConfiguredLayer] {
        let children: [ConfiguredLayer] = layer.visibleChildren(for: config).map({ child in
            self.configure(layer: child, with: config)
        }).flatMap({ $0 })

        switch layer.type {
        case .custom:
            guard let componentLayer = layer as? CSComponentLayer else { return [] }

            let componentConfig = ComponentConfiguration(
                component: componentLayer.component,
                arguments: config.getAllAttributes(for: componentLayer.name),
                canvas: config.canvas)
            componentConfig.configuredChildren = children

            return self.configure(layer: componentLayer.component.rootLayer, with: componentConfig)
        case .builtIn(.children):
            guard let parameterLayer = layer as? CSParameterLayer else { return [] }

            if parameterLayer.parameterName == "children" {
                if let componentChildren = config.configuredChildren {
                    return componentChildren
                    // Show children element directly when viewing parent element file
                } else {
                    return [ConfiguredLayer(layer: layer, config: config, children: children)]
                }
            } else {
                let argument = config.scope.getValueAt(keyPath: ["parameters", parameterLayer.parameterName]).data

                guard let layer = CSLayer.deserialize(argument) else { return [] }

                layer.name = parameterLayer.parameterName

                config.scope.set(keyPath: ["layers", parameterLayer.parameterName], to: layer.value())

                return [ConfiguredLayer(layer: layer, config: config, children: children)]
            }
        case .builtIn:
            return [ConfiguredLayer(layer: layer, config: config, children: children)]
        }
    }
}

extension CanvasView {
    struct Parameters {
        var canvas: Canvas
        var rootLayer: CSLayer
        var config: ComponentConfiguration
        var options: RenderOptions
    }
}
