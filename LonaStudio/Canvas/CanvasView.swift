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

func measureText(string: NSAttributedString, width: CGFloat, maxNumberOfLines: Int = -1) -> NSSize {
    let textStorage = NSTextStorage(attributedString: string)
    let textContainer = NSTextContainer(containerSize: NSMakeSize(width, CGFloat.greatestFiniteMagnitude))
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

func getLayerText(layer: CSLayer) -> String {
    var text: String = ""
    
    if let config = layer.config {
        text = config.get(attribute: "text", for: layer.name).string ?? layer.text ?? ""
    }

    return text
}

func getLayerFontName(layer: CSLayer) -> String {
    var value: String = "regular"
    
    if let config = layer.config {
        value = config.get(attribute: "textStyle", for: layer.name).string ?? layer.font ?? value
    }
    
    return value
}

func getLayerFont(layer: CSLayer) -> AttributedFont {
    return CSTypography.getFontBy(id: getLayerFontName(layer: layer)).font
}

func getLayoutShadow(layout: CSLayer) -> CSShadow? {
    guard let shadow = layout.shadow else { return nil }
    return CSShadows.shadow(with: shadow)
}

func numberValue(for layer: CSLayer, attributeChain: [String], optionalValues: [Double?] = [], defaultValue: Double = 0) -> Double {
    if let config = layer.config {
        for attribute in attributeChain {
            let raw = config.get(attribute: attribute, for: layer.name)
            
            if raw.number == nil { continue }
            
            return raw.numberValue
        }
    }
    
    for value in optionalValues {
        if value != nil {
            return value!
        }
    }
    
    return defaultValue
}

func attributedString(for layer: CSLayer) -> NSAttributedString {
    let text = getLayerText(layer: layer)
    
    // Font
    var attributeDict = getLayerFont(layer: layer).attributeDictionary()
    
    // Shadow
    if layer.shadow != nil,
        let shadow = getLayoutShadow(layout: layer) {
        let shadowAttributeText = shadow.attributeDictionary()
        attributeDict.merge(with: shadowAttributeText)
    }
    return NSAttributedString(string: text, attributes: attributeDict)
}
    
func paragraph(for layer: CSLayer) -> NSAttributedString {
    let string = NSMutableAttributedString()
    
    string.append(attributedString(for: layer))
    
    guard let config = layer.config else { return string }
    
    layer.computedChildren(for: config)
//        .filter({ $0.text != nil })
        .forEach({ string.append(paragraph(for: $0)) })
//        .forEach({ string.append(attributedString(for: $0)) })
    
    return string
}

func measureFunc(node: YGNodeRef?, width: Float, widthMode: YGMeasureMode, height: Float, heightMode: YGMeasureMode) -> YGSize {
    let layer = Unmanaged<CSLayer>.fromOpaque(YGNodeGetContext(node)!).takeUnretainedValue()
    
    let measured = measureText(string: paragraph(for: layer), width: CGFloat(width), maxNumberOfLines: layer.numberOfLines ?? -1)

    let size = YGSize(width: Float(measured.width), height: Float(measured.height))
    
//    Swift.print(">> Measure text", layer.name, size, node?.flexGrow, node?.flexShrink, node?.flexBasis)
    
    return size
}

func renderTextLayer(layer: CSLayer, width: Float, height: Float) -> NSTextView {
    let textView = CSTextView()
    textView.isEditable = false
    textView.isSelectable = false
    
    textView.frame = NSRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
    textView.textContainer!.lineFragmentPadding = 0.0
    textView.textContainer!.lineBreakMode = .byTruncatingTail
    
    if layer.numberOfLines != nil && layer.numberOfLines! > -1 {
        textView.textContainer!.maximumNumberOfLines = layer.numberOfLines!
    }
    
    textView.textStorage!.append(paragraph(for: layer))
    textView.drawsBackground = false
    
//    if let color = layer.backgroundColor {
//        textView.drawsBackground = true
//        textView.backgroundColor = CSColors.parse(css: color, withDefault: NSColor.clear).color
//    }
    
    return textView
}

class FlippedView: NSView {
    override var isFlipped: Bool { return true }
}

func ensureLayer(for view: NSView) {
    if view.layer == nil {
        view.wantsLayer = true
        view.layer = CALayer()
    }
}

let BORDERS: [(edge: NSRectEdge, key: String)] = [
    (NSRectEdge.minY, key: "borderTopWidth"),
    (NSRectEdge.maxX, key: "borderRightWidth"),
    (NSRectEdge.maxY, key: "borderBottomWidth"),
    (NSRectEdge.minX, key: "borderLeftWidth"),
]

let imageCache = LayerContentsCache()

func renderBox(layer: CSLayer, node: YGNodeRef, options: RenderOptions) -> NSView {
    let layout = node.layout
    
    // TODO: I copied this in from the React Native code to see if it's happening. It's probably not, so we can probably take it out.
    // This works around a breaking change in Yoga layout where setting flexBasis needs to be set explicitly, instead of relying on flex to propagate.
    // We check for it by seeing if a width/height is provided along with a flexBasis of 0 and the width/height is laid out as 0.
    if (YGNodeStyleGetFlexBasis(node).unit == YGUnit.point && YGNodeStyleGetFlexBasis(node).value == 0 &&
        ((YGNodeStyleGetWidth(node).unit == YGUnit.point && YGNodeStyleGetWidth(node).value > 0 && YGNodeLayoutGetWidth(node) == 0) ||
            (YGNodeStyleGetHeight(node).unit == YGUnit.point && YGNodeStyleGetHeight(node).value > 0 && YGNodeLayoutGetHeight(node) == 0))) {
        Swift.print("View was rendered with explicitly set width/height but with a 0 flexBasis. (This might be fixed by changing flex: to flexGrow:)", layer.name);
    }
    
    let handleClick: () -> Void = {_ in options.onSelectLayer(layer) }
    let frame = NSRect(
        x: layout.left,
        y: layout.top,
        width: layout.width,
        height: layout.height
    )
    
    let box = CSView(frame: frame, onClick: handleClick)
    
    box.translatesAutoresizingMaskIntoConstraints = true
    
    if layer.text == nil, let color = layer.config?.get(attribute: "backgroundColor", for: layer.name).string ?? layer.backgroundColor {
        box.layer?.backgroundColor = CSColors.parse(css: color, withDefault: NSColor.clear).color.cgColor
    }
    
    if let id = layer.backgroundGradient, let gradient = CSGradients.gradient(withId: id) {
        box.layer = gradient.caGradientLayer
    }

    if let borderRadius = layer.config?.get(attribute: "borderRadius", for: layer.name).number ?? layer.borderRadius {
        box.layer?.cornerRadius = min(CGFloat(borderRadius), layout.width / 2, layout.height / 2)
    }
    
    let borderColorString = layer.config?.get(attribute: "borderColor", for: layer.name).string ?? layer.borderColor
    var borderColor = borderColorString != nil ? CSColors.parse(css: borderColorString!, withDefault: NSColor.clear).color.cgColor : nil

    if let width = layer.config?.get(attribute: "borderWidth", for: layer.name).number ?? layer.borderWidth, width > 0 {
        box.layer?.borderWidth = CGFloat(width)
        borderColor ?= CGColor.clear
    }
    
    if let borderColor = borderColor {
        box.layer?.borderColor = borderColor
    }
    
    if layer.type == "Animation" {
        let animation: String? = layer.config?.get(attribute: "animation", for: layer.name).string ?? layer.animation
        
        if  let animation = animation,
            let url = URL(string: animation),
            let json = AnimationUtils.decode(contentsOf: url),
            let assetMap = layer.config?
                .get(attribute: "images", for: layer.name)
                .objectValue
                .filterValues(f: { $0.string != nil && URL(string: $0.stringValue) != nil })
                .mapValues({ URL(string: $0.stringValue)! })
        {
            AnimationUtils.updateAssets(in: json, withFile: url, assetMap: assetMap)
            let animationView = LOTAnimationView(json: json as! [AnyHashable : Any])
            animationView.data = json
            animationView.animationSpeed = CGFloat(layer.animationSpeed ?? 1)
            animationView.contentMode = layer.resizeMode?.lotViewContentMode() ?? .scaleAspectFill
            animationView.frame = frame

            box.addSubview(animationView)
            
            if options.hideAnimationLayers {
                animationView.isHidden = true
            } else {
                animationView.play()
            }
        }
    } else if layer.type == "Image" {
        let image: String? = layer.config?.get(attribute: "image", for: layer.name).string ?? layer.image
        
        if let image = image, let url = URL(string: image) {
            var scale: CGFloat = options.assetScale
            
            if url.pathExtension == "pdf", let document = CSPDFDocument(contentsOf: url, parsed: false) {
                let size = document.cgPDFPage!.getBoxRect(CGPDFBox.mediaBox)
                let widthScale = layout.width / size.width
                let heightScale = layout.height / size.height
                scale *= max(widthScale, heightScale)
            }
            
            scale = ceil(scale)
            
//            if let desiredScaleFactor = NSApplication.shared().windows.first?.backingScaleFactor {
//                scale *= desiredScaleFactor
////                let actualScaleFactor = nsImage?.recommendedLayerContentsScale(desiredScaleFactor) ?? 1
////                box.layer?.contents = nsImage?.layerContents(forContentsScale: actualScaleFactor)
////                box.layer?.contentsScale = actualScaleFactor
//            }
            
            box.layer?.contentsGravity = kCAGravityResizeAspectFill
            box.layer?.contentsScale = scale
            box.layer?.masksToBounds = true
            
            if let cached = imageCache.contents(for: url, at: scale) {
                box.layer?.contents = cached
            } else {
                let nsImage = NSImage(contentsOf: url)
                nsImage?.cacheMode = .always
                
                if let contents = nsImage?.layerContents(forContentsScale: scale) {
                    box.layer?.contents = contents
                    imageCache.add(contents: contents, for: url, at: scale)
                }
            }
        }
    }
    
    if layer.config?.scope.get(value: "cs:selected").data.stringValue == layer.name {
        if box.layer == nil {
            box.wantsLayer = true
            box.layer = CALayer()
        }
        
        box.layer!.borderWidth = 2.0
        box.layer!.borderColor = #colorLiteral(red: 0.2352941176, green: 0.7215686275, blue: 0.9960784314, alpha: 1).cgColor
    }
    
//    Swift.print("layer text", layer.text, paragraph(for: layer).string)
    
//    func layerHasText(_ layer: CSLayer) -> Bool {
//        if layer.text != nil { return true }
//        for child in layer.children {
//            if layerHasText(child) { return true }
//        }
//        return false
//    }
    
    if layer.type == "Text" {
        if #available(OSX 10.12, *) {
            let width = YGNodeLayoutGetWidth(node)
            let height = YGNodeLayoutGetHeight(node)
//            print("Style width", YGNodeStyleGetWidth(textNode).value)
            let textLayer = renderTextLayer(layer: layer, width: width, height: height)
            
//            Swift.print("Render text", width, height)
            
            box.frame = NSRect(
                x: CGFloat(YGNodeLayoutGetLeft(node)),
                y: CGFloat(YGNodeLayoutGetTop(node)),
                width: CGFloat(width),
                height: CGFloat(height)
            )
            
            box.addSubview(textLayer)
        } else {
            // Fallback on earlier versions
        }
    } else {
        for (index, sub) in layer.computedChildren(for: layer.config!).enumerated() {
            let child = renderBox(layer: sub, node: YGNodeGetChild(node, UInt32(index)), options: options)
            
            box.addSubview(child)
        }
    }
    
    box.layer?.masksToBounds = true
    
    return box
}

typealias SketchFileReference = (id: String, data: String)
typealias SketchFileReferenceMap = [String: SketchFileReference]

func renderBoxJSON(layer: CSLayer, node: YGNodeRef, references: inout SketchFileReferenceMap) -> CSData {
    let layout = node.layout
    
    var output = layer.toData()
    
    let layoutJSON = CSData.Object([
        "left": layout.left.toData(),
        "top": layout.top.toData(),
        "width": layout.width.toData(),
        "height": layout.height.toData(),
    ])
    
    var styleJSON = CSData.Object([:])
    
    styleJSON["overflow"] = "hidden".toData()
    
    var propsJSON = CSData.Object([:])
    
    if layer.text == nil, let color = layer.config?.get(attribute: "backgroundColor", for: layer.name).string ?? layer.backgroundColor {
        styleJSON["backgroundColor"] = CSColors.parse(css: color, withDefault: NSColor.clear).value.toData()
    }
    
    if let borderRadius = layer.config?.get(attribute: "borderRadius", for: layer.name).number ?? layer.borderRadius {
        let radius = min(CGFloat(borderRadius), layout.width / 2, layout.height / 2).toData()
        styleJSON["borderTopLeftRadius"] = radius
        styleJSON["borderTopRightRadius"] = radius
        styleJSON["borderBottomRightRadius"] = radius
        styleJSON["borderBottomLeftRadius"] = radius
    }
    
    if let borderColor = layer.config?.get(attribute: "borderColor", for: layer.name).string ?? layer.borderColor {
        let color = CSColors.parse(css: borderColor, withDefault: NSColor.clear).value.toData()
        styleJSON["borderTopColor"] = color
        styleJSON["borderRightColor"] = color
        styleJSON["borderBottomColor"] = color
        styleJSON["borderLeftColor"] = color
        for (_, key) in BORDERS {
            if let width = layer.config?.get(attribute: key, for: layer.name).number ?? layer.parameters[key]?.number, width > 0 {
                styleJSON[key] = width.toData()
            }
        }
    }
    
    var sketchLayers = CSData.Array([])
    
    if layer.type == "Image" {
        let image: String? = layer.config?.get(attribute: "image", for: layer.name).string ?? layer.image
        
        if let image = image {
            if image.isEmpty {
                // Force this layer into a View since there's no image url
                output.set(keyPath: ["type"], to: "View".toData())
            } else if let url = URL(string: image), url.pathExtension == "pdf",
                let document = CSPDFDocument(contentsOf: url, parsed: true)
            {
                let size = document.cgPDFPage!.getBoxRect(CGPDFBox.mediaBox)
                let widthScale = layout.width / size.width
                let heightScale = layout.height / size.height
                let scale = max(widthScale, heightScale)
                let translate = layout.width > layout.height
                    ? CGPoint(x: 0, y: (layout.height - layout.width) / 2)
                    : CGPoint(x: (layout.width - layout.height) / 2, y: 0)
                
                sketchLayers = document.renderToSketch(scale: scale, translate: translate)
                
                // Force this layer into a View instead of an Image, since we're rendering
                // real Sketch layers rather than an image fill
                output.set(keyPath: ["type"], to: "View".toData())
            } else if let reference = references[image] {
                propsJSON["image"] = CSData.Object(["id": reference.id.toData()])
            } else {
                let id = NSUUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
                
                if let url = URL(string: image), let encoded = url.contentsAsBase64EncodedString() {
                    propsJSON["image"] = CSData.Object(["id": id.toData()])
                    references[image] = (id, encoded)
                }
            }
        } else {
            // Force this layer into a View since there's no image url
            output.set(keyPath: ["type"], to: "View".toData())
        }
    }
    
    if layer.text != nil {
        // TODO: Sketch will strip out multiple styles in an attributed string. Figure out how to pass multiple attributed strings.
        let attributedString = paragraph(for: layer)
        
        output["value"] = attributedString.string.toData()
        output["textStyle"] = CSData.Object([
            "attributedString": NSKeyedArchiver.archivedData(withRootObject: attributedString).base64EncodedString().toData(),
        ])
        
        output["children"] = CSData.Array([])
    } else {
        var children: [CSData] = []
        
        for (index, sub) in layer.computedChildren(for: layer.config!).enumerated() {
            let child = renderBoxJSON(layer: sub, node: node.children[index], references: &references)
            children.append(child)
        }
        
        for sketchLayer in sketchLayers.arrayValue {
            children.append(sketchLayer)
        }
        
        output["children"] = CSData.Array(children)
    }
    
    output["layout"] = layoutJSON
    output["props"] = propsJSON
    output["style"] = styleJSON
    
    return output
}

func assignLayerConfig(layer: CSLayer, config: ComponentConfiguration) {
    layer.config = config
    
    for (_, sub) in layer.computedChildren(for: config, shouldAssignConfig: true).enumerated() {
        var childConfig = config
        
        // TODO This is a hack to return metadata about the layer.
        // Config gets assigned by `computedChildren()`. Figure out a better way.
        if sub.config != nil && sub.config!.scope.get(value: "cs:root").data.boolValue == true {
            childConfig = sub.config!
            sub.config!.scope.undeclare(variable: "cs:root")
        }
        
        sub.config = childConfig
        
        assignLayerConfig(layer: sub, config: childConfig)
    }
}

func setFlexExpand(for layer: CSLayer, node: YGNodeRef) {
    var node = node
    
    node.flexShrink = 1
    node.flexGrow = 1
    
    if layer.type == "Text" {
        node.flexBasis = .value(0)
    } else {
        node.flexBasis = .auto
    }
}

func layoutLayer(layer: CSLayer, parentLayoutDirection: YGFlexDirection) -> YGNodeRef {
    var node = YGNodeRef.create()
    
    if let value = layer.top { node.top = CGFloat(value) }
    if let value = layer.right { node.right = CGFloat(value) }
    if let value = layer.bottom { node.bottom = CGFloat(value) }
    if let value = layer.left { node.left = CGFloat(value) }
    node.position = layer.position == .absolute ? YGPositionType.absolute : YGPositionType.relative
    
    let flexDirection = layer.flexDirection == "row" ? YGFlexDirection.row : YGFlexDirection.column
    node.flexDirection = flexDirection
    
    switch layer.heightSizingRule {
    case .Fixed:
        node.height = CGFloat(numberValue(for: layer, attributeChain: ["height"], optionalValues: [layer.height]))
        
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
        node.width = CGFloat(numberValue(for: layer, attributeChain: ["width"], optionalValues: [layer.width]))
        
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
    
    node.paddingTop = CGFloat(numberValue(for: layer, attributeChain: ["paddingTop", "paddingVertical", "padding"], optionalValues: [layer.paddingTop]))
    node.paddingBottom = CGFloat(numberValue(for: layer, attributeChain: ["paddingBottom", "paddingVertical", "padding"], optionalValues: [layer.paddingBottom]))
    node.paddingLeft = CGFloat(numberValue(for: layer, attributeChain: ["paddingLeft", "paddingHorizontal", "padding"], optionalValues: [layer.paddingLeft]))
    node.paddingRight = CGFloat(numberValue(for: layer, attributeChain: ["paddingRight", "paddingHorizontal", "padding"], optionalValues: [layer.paddingRight]))

    node.marginTop = CGFloat(numberValue(for: layer, attributeChain: ["marginTop", "marginVertical", "margin"], optionalValues: [layer.marginTop]))
    node.marginBottom = CGFloat(numberValue(for: layer, attributeChain: ["marginBottom", "marginVertical", "margin"], optionalValues: [layer.marginBottom]))
    node.marginLeft = CGFloat(numberValue(for: layer, attributeChain: ["marginLeft", "marginHorizontal", "margin"], optionalValues: [layer.marginLeft]))
    node.marginRight = CGFloat(numberValue(for: layer, attributeChain: ["marginRight", "marginHorizontal", "margin"], optionalValues: [layer.marginRight]))
    
    node.borderTop = CGFloat(numberValue(for: layer, attributeChain: ["borderTopWidth", "borderVerticalWidth", "borderWidth"], optionalValues: [layer.borderWidth]))
    node.borderBottom = CGFloat(numberValue(for: layer, attributeChain: ["borderBottomWidth", "borderVerticalWidth", "borderWidth"], optionalValues: [layer.borderWidth]))
    node.borderLeft = CGFloat(numberValue(for: layer, attributeChain: ["borderLeftWidth", "borderHorizontalWidth", "borderWidth"], optionalValues: [layer.borderWidth]))
    node.borderRight = CGFloat(numberValue(for: layer, attributeChain: ["borderRightWidth", "borderHorizontalWidth", "borderWidth"], optionalValues: [layer.borderWidth]))
    
    if let aspectRatio = layer.aspectRatio, aspectRatio > 0 {
        YGNodeStyleSetAspectRatio(node, Float(aspectRatio))
    }
    
    // Non-text layer
    if layer.type == "Text" {
        YGNodeSetContext(node, UnsafeMutableRawPointer(Unmanaged.passUnretained(layer).toOpaque()))
        YGNodeSetMeasureFunc(node, measureFunc(node:width:widthMode:height:heightMode:))
    } else {
        for (index, sub) in layer.computedChildren(for: layer.config!).enumerated() {
            var child = layoutLayer(layer: sub, parentLayoutDirection: flexDirection)
            
            if layer.itemSpacingRule == .Fixed {
                let itemSpacing = CGFloat(numberValue(for: layer, attributeChain: ["itemSpacing"], optionalValues: [layer.itemSpacing]))
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

func emptyCanvas() -> NSView {
    return FlippedView(frame: NSRect.square(ofSize: 100))
}

func layoutRoot(canvas: Canvas, rootLayer: CSLayer, config: ComponentConfiguration) -> (layoutNode: YGNodeRef, rootNode: YGNodeRef, height: CGFloat)? {
    guard let rootNode = YGNodeNew() else { return nil }
    
    let useExactHeight = canvas.heightMode == "Exactly"
    
    // If "At Least", use a very large canvas size to allow the node to expand.
    // We'll then measure the node to determine the canvas height.
    let canvasHeight = useExactHeight ? canvas.height : LARGE_CANVAS_SIZE
    
    assignLayerConfig(layer: rootLayer, config: config)
    
    // Build layout hierarchy
    var child = layoutLayer(layer: rootLayer, parentLayoutDirection: .column)
    
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
    guard let layout = layoutRoot(canvas: canvas, rootLayer: rootLayer, config: config) else { return (CSData.Null, 0) }
    
    let rootLayer = renderBoxJSON(layer: rootLayer, node: layout.layoutNode, references: &references)
    
    layout.rootNode.free(recursive: true)
    
    return (rootLayer, Double(layout.height))
}

func drawRoot(canvas: Canvas, rootLayer: CSLayer, config: ComponentConfiguration, options: RenderOptions) -> NSView {
    guard let layout = layoutRoot(canvas: canvas, rootLayer: rootLayer, config: config) else { return emptyCanvas() }
    
    let canvasView = FlippedView(frame: NSRect(x: 0, y: 0, width: CGFloat(canvas.width), height: layout.height))
    
    // Render the root layer
    let childView = renderBox(layer: rootLayer, node: layout.layoutNode, options: options)
    canvasView.addSubview(childView)
    
    layout.rootNode.free(recursive: true)
    
    return canvasView
}

enum RenderOption {
    case onSelectLayer((CSLayer) -> Void)
    case assetScale(CGFloat)
    case hideAnimationLayers(Bool)
}

struct RenderOptions {
    var onSelectLayer: (CSLayer) -> Void = {_ in}
    var assetScale: CGFloat = 1
    var hideAnimationLayers: Bool = false
    
    mutating func merge(options: [RenderOption]) {
        options.forEach({ option in
            switch option {
            case .onSelectLayer(let f): onSelectLayer = f
            case .assetScale(let value): assetScale = value
            case .hideAnimationLayers(let value): hideAnimationLayers = value
            }
        })
    }
    
    init(_ options: [RenderOption]) {
        merge(options: options)
    }
}

class CanvasView: NSView {
    init(canvas: Canvas, rootLayer: CSLayer, config: ComponentConfiguration, options list: [RenderOption] = []) {
        let options = RenderOptions(list)
        let root = drawRoot(canvas: canvas, rootLayer: rootLayer, config: config, options: options)
        
        super.init(frame: root.frame)

        // TODO: On High Sierra, if the canvas has a transparent fill, shadows show up behind each subview's layer.
        // Maybe we don't want shadows anyway though.
        wantsLayer = true
        
        if let layer = self.layer {
            layer.backgroundColor = CSColors.parse(css: canvas.backgroundColor, withDefault: NSColor.white).color.cgColor
            
//            layer.shadowOpacity = 0.3
//            layer.shadowColor = CGColor.black
//            layer.shadowOffset = NSMakeSize(0, -1)
//            layer.shadowRadius = 2
//            layer.masksToBounds = false
        }
        
        addSubview(root)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


