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

// Passed as a C pointer to Yoga, since we can't pass a struct
class ConfiguredLayerRef {
    let ref: ConfiguredLayer

    init(ref: ConfiguredLayer) {
        self.ref = ref
    }
}

func measureFunc(node: YGNodeRef?, width: Float, widthMode: YGMeasureMode, height: Float, heightMode: YGMeasureMode) -> YGSize {
    let configuredLayerRef = Unmanaged<ConfiguredLayerRef>.fromOpaque(YGNodeGetContext(node)!).takeUnretainedValue()

    let renderableTextAttributes = configuredLayerRef.ref.renderableTextAttributes()

    let measured = renderableTextAttributes.makeAttributedString().measure(
        width: CGFloat(width),
        maxNumberOfLines: renderableTextAttributes.numberOfLines)

    return YGSize(width: Float(measured.width), height: Float(measured.height))
}

typealias SketchFileReference = (id: String, data: String)
typealias SketchFileReferenceMap = [String: SketchFileReference]

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

class CanvasView: FlippedView {
    var parameters: Parameters {
        didSet {
            update()
        }
    }

    var canvas: Canvas? { return parameters.canvas }
    var rootLayer: CSLayer? { return parameters.rootLayer }
    var config: ComponentConfiguration? { return parameters.config }
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

    private var previous: RenderableElement?

    private func render() -> RenderableElement? {
        guard let rootLayer = rootLayer, let config = config, let canvas = canvas else { return nil }

        let configuredRootLayer = CanvasView.configureRoot(layer: rootLayer, with: config)

        guard let layout = CanvasView.layoutRoot(
            canvas: canvas,
            configuredRootLayer: configuredRootLayer,
            config: config)
            else { return nil }

        let renderable = configuredRootLayer.renderableElement(
            node: layout.layoutNode,
            options: options)

        layout.rootNode.free(recursive: true)

        return renderable
    }

    func update() {
        guard let renderable = render() else { return }

        if let previous = previous, !renderable.needsFullRender(previous: previous) {
            renderable.updateViewHierarchy(canvasView.subviews[0], previous: previous)
        } else {
            canvasView.subviews.forEach { $0.removeFromSuperview() }
            canvasView.addSubview(renderable.makeViewHierarchy())
        }

        frame = renderable.attributes.frame
        canvasView.frame = renderable.attributes.frame
        backgroundView.frame = renderable.attributes.frame

        let newBackgroundColor = CSColors.parse(css: canvas?.backgroundColor ?? "white", withDefault: NSColor.white).color
        if backgroundView.fillColor != newBackgroundColor {
            backgroundView.fillColor = newBackgroundColor
        }

        if options.renderCanvasShadow {
            frame.size.width += CanvasView.margin * 2
            frame.size.height += CanvasView.margin * 2
            backgroundView.frame.origin.x += CanvasView.margin
            backgroundView.frame.origin.y += CanvasView.margin
        }

        if let selected = self.firstDescendant(where: { view in
            guard let csView = view as? CSView, let name = options.selectedLayerName else {
                return false
            }

            return csView.layerName == name
        }) {
            let newFrame = convert(selected.bounds.insetBy(dx: -1, dy: -1), from: selected)
            if selectionView.frame != newFrame {
                selectionView.frame = newFrame
            }

            if selectionView.isHidden {
                selectionView.isHidden = false
            }
        } else {
            if !selectionView.isHidden {
                selectionView.isHidden = true
            }
        }

        previous = renderable
    }

    static var margin: CGFloat = 20
}

// MARK: - Static configuration

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

// MARK: - Layout

extension CanvasView {
    static func setFlexExpand(for layer: CSLayer, node: YGNodeRef) {
        var node = node

        node.flexShrink = 1
        node.flexGrow = 1

        if layer.type == .text {
            node.flexBasis = .value(0)
        } else {
            node.flexBasis = .auto
        }
    }

    static func layoutLayer(configuredLayer: ConfiguredLayer, parentLayoutDirection: YGFlexDirection) -> YGNodeRef {
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
            node.height = CGFloat(configuredLayer.numberValue(paramName: "height") ?? layer.height ?? 0)

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
            node.width = CGFloat(configuredLayer.numberValue(paramName: "width") ?? layer.width ?? 0)

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

        node.paddingTop = CGFloat(configuredLayer.numberValue(paramName: "paddingTop") ?? layer.paddingTop ?? 0)
        node.paddingBottom = CGFloat(configuredLayer.numberValue(paramName: "paddingBottom") ?? layer.paddingBottom ?? 0)
        node.paddingLeft = CGFloat(configuredLayer.numberValue(paramName: "paddingLeft") ?? layer.paddingLeft ?? 0)
        node.paddingRight = CGFloat(configuredLayer.numberValue(paramName: "paddingRight") ?? layer.paddingRight ?? 0)

        node.marginTop = CGFloat(configuredLayer.numberValue(paramName: "marginTop") ?? layer.marginTop ?? 0)
        node.marginBottom = CGFloat(configuredLayer.numberValue(paramName: "marginBottom") ?? layer.marginBottom ?? 0)
        node.marginLeft = CGFloat(configuredLayer.numberValue(paramName: "marginLeft") ?? layer.marginLeft ?? 0)
        node.marginRight = CGFloat(configuredLayer.numberValue(paramName: "marginRight") ?? layer.marginRight ?? 0)

        node.borderTop = CGFloat(configuredLayer.numberValue(paramName: "borderWidth") ?? layer.borderWidth ?? 0)
        node.borderBottom = CGFloat(configuredLayer.numberValue(paramName: "borderWidth") ?? layer.borderWidth ?? 0)
        node.borderLeft = CGFloat(configuredLayer.numberValue(paramName: "borderWidth") ?? layer.borderWidth ?? 0)
        node.borderRight = CGFloat(configuredLayer.numberValue(paramName: "borderWidth") ?? layer.borderWidth ?? 0)

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
                let child = layoutLayer(configuredLayer: sub, parentLayoutDirection: flexDirection)

                node.insert(child: child, at: index)
            }
        }

        YGNodeStyleSetOverflow(node, .hidden)

        return node
    }

    static let LARGE_CANVAS_SIZE: Double = 10000

    static func layoutRoot(canvas: Canvas, configuredRootLayer: ConfiguredLayer, config: ComponentConfiguration) -> (layoutNode: YGNodeRef, rootNode: YGNodeRef, height: CGFloat)? {
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
        wrapper.width = CGFloat(canvas.computedWidth)

        if useExactHeight {
            wrapper.height = CGFloat(canvas.computedHeight)
        } else {
            let verticalMargins = child.marginTop + child.marginBottom
            let minHeight = CGFloat(canvas.computedHeight) - verticalMargins

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
        let calculatedHeight = useExactHeight ? CGFloat(canvas.computedHeight) : wrapper.layout.height

        return (child, rootNode, calculatedHeight)
    }
}

// MARK: - Parameters

extension CanvasView {
    struct Parameters {
        var canvas: Canvas?
        var rootLayer: CSLayer?
        var config: ComponentConfiguration?
        var options: RenderOptions
    }
}
