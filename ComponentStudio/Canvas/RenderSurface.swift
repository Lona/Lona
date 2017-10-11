//
//  RenderSurface.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/11/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyJSON
import Lottie

typealias ExampleDictionary = [String: CSData]
typealias TaggedCanvas = (view: CanvasView, tags: [String], canvas: Canvas)

class RenderSurface: NSView {
    
    enum Layout {
        case canvasXcaseY
        case caseXcanvasY
    }

    static let xMargin: CGFloat = 100.0
    static let yMargin: CGFloat = 100.0
    
    static func renderCanvasStack(
        component: CSComponent,
        canvas: Canvas,
        options: [RenderOption] = []
    ) -> ([TaggedCanvas]) {
        return component.computedCases(for: canvas).map({ caseItem in
            let config = ComponentConfiguration(
                component: component,
                arguments: caseItem.value.objectValue,
                canvas: canvas
            )
            
//            if let selected = selected {
//                config.scope.declare(value: "cs:selected", as: CSValue(type: .string, data: .String(selected)))
//            }
            
            let tags = [canvas.name, caseItem.name, canvas.dimensionsString()]
            
            let canvasView = CanvasView(
                canvas: canvas,
                rootLayer: component.rootLayer,
                config: config,
                options: [
                    RenderOption.assetScale(CGFloat(canvas.exportScale))
                ] + options
            )
            
            return (canvasView, tags, canvas)
        })
    }
    
    func renderTag(title: String) -> NSView {
        if #available(OSX 10.12, *) {
            let label = NSButton(title: title, target: nil, action: nil)
            label.bezelStyle = NSBezelStyle.inline
            label.frame.size.height = 16
            label.frame.size.width = label.frame.size.width - 14
            label.wantsLayer = true
            label.layer?.opacity = 0.6
            return label
        } else {
            return NSView()
        }
    }
    
    func renderTagList(with titles: [String]) -> NSView {
        var views = [NSView]()
        let container = NSView()
        
        for (index, tag) in titles.enumerated() {
            let tagView = renderTag(title: tag)
            
            if (index > 0) {
                tagView.frame.origin.x = views[index - 1].frame.maxX + 4
            }
            
            views.append(tagView)
        }
        
        views.forEach({ container.addSubview($0) })
        
        container.frame.size.height = 16
        container.frame.size.width = views.isEmpty ? 0 : views.last!.frame.maxX
        
        return container
    }
    
    func renderTagList(with titles: [String], for view: NSView) -> NSView {
        let tagListView = renderTagList(with: titles)
        tagListView.frame.origin.x = view.frame.origin.x
        tagListView.frame.origin.y = view.frame.origin.y - 22
        return tagListView
    }
    
    func addCanvasToDocument(_ taggedCanvas: TaggedCanvas) {
        let (view, tags, _) = taggedCanvas
        
        documentView.addSubview(view)
        documentView.addSubview(renderTagList(with: tags, for: view))
    }
    
    static func renderToImages(component: CSComponent, directory: URL) {
        component.computedCanvases().forEach({ canvas in
            let stack = renderCanvasStack(component: component, canvas: canvas)
            
            for taggedCanvas in stack {
                let (view, tags, _) = taggedCanvas
                
                if let animationView = AnimationUtils.findAnimationView(in: view) {
                    animationView.layout()
                }
                
                let url = directory.appendingPathComponent(tags.joined(separator: "_")).appendingPathExtension("png")
                try? view.dataRepresentation(scaledBy: CGFloat(canvas.exportScale))?.write(to: url)
            }
        })
    }
    
    static func renderToAnimations(component: CSComponent, directory: URL) {
        component.computedCanvases().forEach({ canvas in
            let stack = renderCanvasStack(component: component, canvas: canvas, options: [
                RenderOption.hideAnimationLayers(true)
                ])
            
            for taggedCanvas in stack {
                let (view, tags, _) = taggedCanvas

                let url = directory.appendingPathComponent(tags.joined(separator: "_")).appendingPathExtension("json")
                
                guard let animationView = AnimationUtils.findAnimationView(in: view) else { continue }
                guard var animationData = animationView.data else { continue }
                guard let overlay = view.dataRepresentation(scaledBy: CGFloat(canvas.exportScale)) else { continue }
                
                if AnimationUtils.add(overlay: overlay, to: &animationData) {
                    let jsonString = try? JSONSerialization.data(withJSONObject: animationData, options: JSONSerialization.WritingOptions.prettyPrinted)
                    
                    try? jsonString?.write(to: url)
                }
                
//                let imageURL = directory.appendingPathComponent(tags.joined(separator: "_")).appendingPathExtension("png")
//                try? view.dataRepresentation(scaledBy: CGFloat(canvas.exportScale))?.write(to: imageURL)
            }
        })
    }
    
    static func renderToVideos(component: CSComponent, directory: URL) {
        component.computedCanvases().forEach({ canvas in
            let stack = renderCanvasStack(component: component, canvas: canvas)
            
            for taggedCanvas in stack {
                let (view, tags, _) = taggedCanvas
                
                let url = directory.appendingPathComponent(tags.joined(separator: "_")).appendingPathExtension("mp4")
                
                VideoUtils.writeVideo(capturing: view, scaledBy: CGFloat(canvas.exportScale), atFPS: 24, to: url)
            }
        })
    }
    
//    func update(layout: Layout, component: CSComponent, selected: String?, onSelectLayer: @escaping (CSLayer) -> Void) {
//        clear()
//
//        let matrix = component.canvas.map({ canvas in
//            return renderCanvasStack(component: component, canvas: canvas, selected: selected, onSelectLayer: onSelectLayer)
//        })
//        
//        switch layout {
//        case .canvasXcaseY:
//            var yOffset = yMargin
//            var xOffset = xMargin
//            var maxY: CGFloat = 0.0
//
//            var maxHeights: [CGFloat] = []
//            for (_, stack) in matrix.enumerated() {
//                for (y, taggedCanvas) in stack.enumerated() {
//                    if maxHeights.count <= y { maxHeights.append(0) }
//                    maxHeights[y] = max(maxHeights[y], taggedCanvas.view.frame.size.height)
//                }
//            }
//
//            for stack in matrix {
//                var maxWidth: CGFloat = 0.0
//                yOffset = yMargin
//
//                for (index, taggedCanvas) in stack.enumerated() {
//                    taggedCanvas.view.frame.origin = CGPoint(x: xOffset, y: yOffset)
//
//                    yOffset += maxHeights[index] + yMargin
//                    maxWidth = max(taggedCanvas.view.frame.size.width, maxWidth)
//
//                    addCanvasToDocument(taggedCanvas)
//                }
//
//                xOffset += maxWidth + xMargin
//                maxY = max(yOffset, maxY)
//            }
//
//            documentView.frame = NSRect(x: 0, y: 0, width: xOffset, height: maxY)
//        case .caseXcanvasY:
//            var yOffset = yMargin
//            var xOffset = xMargin
//            var maxX: CGFloat = 0.0
//
//            var maxWidths: [CGFloat] = []
//            for (_, stack) in matrix.enumerated() {
//                for (x, taggedCanvas) in stack.enumerated() {
//                    if maxWidths.count <= x { maxWidths.append(0) }
//                    maxWidths[x] = max(maxWidths[x], taggedCanvas.view.frame.size.width)
//                }
//            }
//
//            for stack in matrix {
//                var maxHeight: CGFloat = 0.0
//                xOffset = xMargin
//
//                for (x, taggedCanvas) in stack.enumerated() {
//
//                    taggedCanvas.view.frame.origin = CGPoint(x: xOffset, y: yOffset)
//
//                    xOffset += maxWidths[x] + xMargin
//                    maxHeight = max(taggedCanvas.view.frame.size.height, maxHeight)
//
//                    addCanvasToDocument(taggedCanvas)
//                }
//
//                yOffset += maxHeight + yMargin
//                maxX = max(xOffset, maxX)
//            }
//
//            documentView.frame = NSRect(x: 0, y: 0, width: maxX, height: yOffset)
//        }
//
//
//    }
//
    static func renderCanvasStackToJSON(
        component: CSComponent,
        canvas: Canvas,
        selected: String?,
        references: inout SketchFileReferenceMap
    ) -> CSData {
        let dataArray: [CSData] = component.computedCases(for: canvas).map({ caseItem in
            let config = ComponentConfiguration(
                component: component,
                arguments: caseItem.value.objectValue,
                canvas: canvas
            )
            
            if let selected = selected {
                config.scope.declare(value: "cs:selected", as: CSValue(type: .string, data: .String(selected)))
            }
            
            var canvasJSON = canvas.toData()
            
            let root = renderRootToJSON(
                canvas: canvas,
                rootLayer: component.rootLayer,
                config: config,
                references: &references
            )
            
            canvasJSON["name"] = "\(canvas.name) \(caseItem.name)".toData() // Not currently used
            canvasJSON["height"] = root.height.toData()
            canvasJSON["rootLayer"] = root.layer
            
            return canvasJSON
        })
        
        return CSData.Array(dataArray)
    }
    
    static func renderToJSON(
        layout: Layout,
        component: CSComponent,
        selected: String?
    ) -> CSData {
        var artboards: [CSData] = []
        
        var references = SketchFileReferenceMap()
        
        let matrix = component.computedCanvases().map({ canvas in
            return renderCanvasStackToJSON(component: component, canvas: canvas, selected: selected, references: &references)
        })
        
        let xMargin = Double(self.xMargin)
        let yMargin = Double(self.yMargin)
        
        switch layout {
        case .canvasXcaseY:
            var yOffset = yMargin
            var xOffset = xMargin
            var maxY: Double = 0.0
            
            var maxHeights: [Double] = []
            for (_, stack) in matrix.enumerated() {
                for (y, taggedCanvas) in stack.arrayValue.enumerated() {
                    if maxHeights.count <= y { maxHeights.append(0) }
                    maxHeights[y] = max(maxHeights[y], taggedCanvas.get(key: "height").numberValue)
                }
            }
            
            for stack in matrix {
                var maxWidth: Double = 0.0
                yOffset = yMargin
                
                for (index, taggedCanvas) in stack.arrayValue.enumerated() {
                    var taggedCanvas = taggedCanvas
                    taggedCanvas["left"] = xOffset.toData()
                    taggedCanvas["top"] = yOffset.toData()
                    
                    yOffset += maxHeights[index] + yMargin
                    maxWidth = max(taggedCanvas.get(key: "width").numberValue, maxWidth)
                    
                    artboards.append(taggedCanvas)
                }
                
                xOffset += maxWidth + xMargin
                maxY = max(yOffset, maxY)
            }
            
//            documentView.frame = NSRect(x: 0, y: 0, width: xOffset, height: maxY)
        case .caseXcanvasY:
            var yOffset = yMargin
            var xOffset = xMargin
            var maxX: Double = 0.0
            
            var maxWidths: [Double] = []
            for (_, stack) in matrix.enumerated() {
                for (x, taggedCanvas) in stack.arrayValue.enumerated() {
                    if maxWidths.count <= x { maxWidths.append(0) }
                    maxWidths[x] = max(maxWidths[x], taggedCanvas.get(key: "width").numberValue)
                }
            }
            
            for stack in matrix {
                var maxHeight: Double = 0.0
                xOffset = xMargin
                
                for (x, taggedCanvas) in stack.arrayValue.enumerated() {
                    var taggedCanvas = taggedCanvas
                    taggedCanvas["left"] = xOffset.toData()
                    taggedCanvas["top"] = yOffset.toData()
                    
                    xOffset += maxWidths[x] + xMargin
                    maxHeight = max(taggedCanvas.get(key: "height").numberValue, maxHeight)
                    
                    artboards.append(taggedCanvas)
                }
                
                yOffset += maxHeight + yMargin
                maxX = max(xOffset, maxX)
            }
            
//            documentView.frame = NSRect(x: 0, y: 0, width: maxX, height: yOffset)
        }
        
        let referencesList: [CSData] = references.map({ item in
            return CSData.Object([
                "id": item.value.id.toData(),
                "data": item.value.data.toData(),
            ])
        })
        
        return CSData.Object([
            "layers": CSData.Array(artboards),
            "references": CSData.Array(referencesList),
        ])
    }
    
    func clear() {
        documentView.subviews.forEach({ $0.removeFromSuperview() })
    }
    
    private var scrollView: NSScrollView
    private var documentView: NSView
    
    init() {
        documentView = FlippedView()
        
        scrollView = NSScrollView()
        scrollView.documentView = documentView
        scrollView.verticalScrollElasticity = .allowed
        scrollView.horizontalScrollElasticity = .allowed
        scrollView.allowsMagnification = true
        
        super.init(frame: NSRect.zero)
        
        wantsLayer = true
        
        addSubviewStretched(subview: scrollView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
