//
//  ConfiguredLayer.swift
//  LonaStudio
//
//  Created by Devin Abbott on 12/8/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Lottie
import yoga

let imageCache = ImageCache<NSImage>()

let svgRenderCache = LRUCache<String, NSImage>()

struct ConfiguredLayer {
    let layerPath: [String]
    let layer: CSLayer
    let config: ComponentConfiguration
    let children: [ConfiguredLayer]

    func shadow() -> CSShadow? {
        let logicValue = config.get(attribute: "shadow", for: layer.name).string
        let constantValue = layer.shadow

        guard let shadow = logicValue ?? constantValue else { return nil }

        return CSShadows.shadow(with: shadow)
    }

    func stringValue(paramName: String) -> String? {
        return config.get(attribute: paramName, for: layer.name).string
    }

    func numberValue(paramName: String) -> Double? {
        return config.get(attribute: paramName, for: layer.name).number
    }

    // MARK: Renderable Element & Attributes

    func renderableElement(node: YGNodeRef, options: RenderOptions) -> RenderableElement {
        var renderableView = renderableViewAttributes(node: node, options: options)

        switch layer.type {
        case .text:
            renderableView.type = .text(renderableTextAttributes())
        case .animation:
            if let attributes = renderableAnimationAttributes(node: node, options: options) {
                renderableView.type = .animation(attributes)
            }
        case .image:
            if let attributes = renderableImageAttributes(node: node, options: options) {
                renderableView.type = .image(attributes)
            }
        case .vectorGraphic:
            if let attributes = renderableVectorImageAttributes(node: node, options: options) {
                renderableView.type = .image(attributes)
            }
        default:
            break
        }

        if layer.type != .text {
            let children: [RenderableElement] = self.children.enumerated().map { index, sub in
                var childRenderable = sub.renderableElement(node: YGNodeGetChild(node, UInt32(index)), options: options)

                // Children within an NSBox have coordinates starting from inside the border of the NSBox.
                // Our Yoga layout has every child positioned, already taking border width into account.
                // We need to offset the child by the border width so that we don't count the border width twice:
                // once for the NSBox and once in the Yoga layout.
                if renderableView.borderWidth > 0 {
                    childRenderable.attributes.frame.origin.x -= renderableView.borderWidth
                    childRenderable.attributes.frame.origin.y += renderableView.borderWidth
                }

                return childRenderable
            }

            return RenderableElement(attributes: renderableView, children: children)
        } else {
            return RenderableElement(attributes: renderableView, children: [])
        }
    }

    func renderableViewAttributes(node: YGNodeRef, options: RenderOptions) -> RenderableViewAttributes {
        let layout = node.layout

        var renderableView = RenderableViewAttributes()

        renderableView.layerName = layer.name
        renderableView.layerPath = layerPath
        renderableView.frame = NSRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)

        if layer.text == nil, let color = config.get(attribute: "backgroundColor", for: layer.name).string ?? layer.backgroundColor {
            renderableView.multipliedFillColor = CSColors.parse(css: color, withDefault: NSColor.clear).color
        }

        let opacity = config.get(attribute: "opacity", for: layer.name).number ?? layer.opacity ?? 1
        renderableView.opacity = CGFloat(opacity)

        if let borderRadius = config.get(attribute: "borderRadius", for: layer.name).number ?? layer.borderRadius {
            renderableView.cornerRadius = min(CGFloat(borderRadius), layout.width / 2, layout.height / 2)
        }

        let borderStyleData = CSValue.compact(type: CSBorderStyleType, data: config.get(attribute: "borderStyle", for: layer.name))
        renderableView.borderStyle = CSLayer.BorderStyle(rawValue: borderStyleData.stringValue) ?? layer.borderStyle

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

        renderableView.shadow = shadow()?.nsShadow

        return renderableView
    }

    func renderableTextAttributes() -> RenderableTextAttributes {
        let text = stringValue(paramName: "text") ?? layer.text ?? ""
        let textStyleId = stringValue(paramName: "textStyle") ?? layer.font ?? "regular"
        let textStyle = CSTypography.getFontBy(id: textStyleId).font
        let textAlignment = NSTextAlignment(layer.textAlign ?? "left")

        var maximumNumberOfLines = 0
        if let numberOfLines = layer.numberOfLines, numberOfLines > -1 {
            maximumNumberOfLines = numberOfLines
        }

        return RenderableTextAttributes(
            text: text,
            textStyle: textStyle,
            textAlignment: textAlignment,
            numberOfLines: maximumNumberOfLines)
    }

    func renderableImageAttributes(node: YGNodeRef, options: RenderOptions) -> RenderableImageAttributes? {
        let layout = node.layout
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
                return RenderableImageAttributes(image: cached, resizingMode: resizingMode)
            } else {
                let nsImage = NSImage(contentsOf: url)
                nsImage?.cacheMode = .always

                if let contents = nsImage {
                    imageCache.add(contents: contents, for: url, at: scale)

                    return RenderableImageAttributes(image: contents, resizingMode: resizingMode)
                }
            }
        }

        return nil
    }

    func renderableVectorImageAttributes(node: YGNodeRef, options: RenderOptions) -> RenderableImageAttributes? {
        let layout = node.layout
        let imageValue: String? = config.get(attribute: "image", for: layer.name).string ?? layer.image
        let resizingMode = layer.resizeMode?.resizingMode() ?? .scaleAspectFill

        if let imageValue = imageValue, let url = URL(string: imageValue)?.absoluteURLForWorkspaceURL() {

            let dynamicValues = config.get(attribute: "vector", for: layer.name)

            let cacheKey = "\(imageValue)*w\(layout.width)*h\(layout.height)*r\(resizingMode.hashValue)\(dynamicValues.toData()?.utf8String() ?? "")"

            // We draw the svg into an image that has the exact same dimensions as the view,
            // so we can scale the image to fill the view without it stretching.
            let containerResizingMode = CGSize.ResizingMode.scaleToFill

            if let cached = svgRenderCache.item(for: cacheKey) {
                return RenderableImageAttributes(image: cached, resizingMode: containerResizingMode)
            } else if let image = SVG.render(
                contentsOf: url,
                dynamicValues: dynamicValues,
                size: CGSize(width: layout.width, height: layout.height),
                resizingMode: resizingMode) {

                image.cacheMode = .always

                svgRenderCache.add(item: image, for: cacheKey)

                return RenderableImageAttributes(image: image, resizingMode: containerResizingMode)
            }
        }

        return nil
    }

    func renderableAnimationAttributes(node: YGNodeRef, options: RenderOptions) -> RenderableAnimationAttributes? {
        let animation: String? = config.get(attribute: "animation", for: layer.name).string ?? layer.animation

        if  let animation = animation,
            let url = URL(string: animation),
            let json = AnimationUtils.decode(contentsOf: url) {
            let assetMap = config
                .get(attribute: "images", for: layer.name)
                .objectValue
                .filterValues(f: { $0.string != nil && URL(string: $0.stringValue) != nil })
                .mapValues({ URL(string: $0.stringValue)! })
            AnimationUtils.updateAssets(in: json, withFile: url, assetMap: assetMap)

            return RenderableAnimationAttributes(
                data: json,
                isHidden: options.hideAnimationLayers,
                animationSpeed: CGFloat(layer.animationSpeed ?? 1),
                contentMode: layer.resizeMode?.lotViewContentMode() ?? .scaleAspectFill)
        }

        return nil
    }
}
