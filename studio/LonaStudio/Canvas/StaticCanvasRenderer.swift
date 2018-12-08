//
//  RenderSurface.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/11/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa
import Lottie

struct RenderDescriptor {
    let canvasName: String
    let caseName: String
    let dimensions: String
}

typealias ExampleDictionary = [String: CSData]
typealias TaggedCanvas = (view: CanvasView, tags: RenderDescriptor, canvas: Canvas)

enum StaticCanvasRenderer {
    enum Layout {
        case canvasXcaseY
        case caseXcanvasY
    }

    static let xMargin: CGFloat = 100.0
    static let yMargin: CGFloat = 100.0

    static func renderCanvasList(
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

            let descriptor = RenderDescriptor(
                canvasName: canvas.name,
                caseName: caseItem.name,
                dimensions: canvas.dimensionsString())

            let canvasView = CanvasView(
                canvas: canvas,
                rootLayer: component.rootLayer,
                config: config,
                options: [
                    RenderOption.assetScale(CGFloat(canvas.exportScale))
                ] + options
            )

            return (canvasView, descriptor, canvas)
        })
    }

    func renderTag(title: String) -> NSView {
        let label = NSButton(title: title, target: nil, action: nil)
        label.bezelStyle = NSButton.BezelStyle.inline
        label.frame.size.height = 16
        label.frame.size.width = label.frame.size.width - 14
        label.wantsLayer = true
        label.layer?.opacity = 0.6
        return label
    }

    func renderTagList(with titles: [String]) -> NSView {
        var views = [NSView]()
        let container = NSView()

        for (index, tag) in titles.enumerated() {
            let tagView = renderTag(title: tag)
            if index > 0 {
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

    static func renderCurrentModuleToImages(savedTo directory: URL) {
        LonaModule.current.componentFiles()
            .forEach({ componentFile in
                guard let component = CSComponent(url: componentFile.url) else { return }

                renderToImages(component: component, directory: directory, namingScheme: { descriptor in
                    return [componentFile.name, descriptor.canvasName, descriptor.caseName]
                      .joined(separator: "_")
                      .replacingOccurrences(of: " ", with: "_")
                      .replacingOccurrences(of: "(", with: "_")
                      .replacingOccurrences(of: ")", with: "_")
                      .replacingOccurrences(of: "+", with: "_")
                      .replacingOccurrences(of: ",", with: "_")
                }, options: [RenderOption.renderCanvasShadow(true)])
            })
    }

    static func renderToImages(
        component: CSComponent,
        directory: URL,
        namingScheme: ((RenderDescriptor) -> String)? = nil,
        options: [RenderOption] = []) {

        component.computedCanvases().forEach({ canvas in
            let stack = renderCanvasList(component: component, canvas: canvas, options: options)

            for taggedCanvas in stack {
                let (view, descriptor, _) = taggedCanvas

                if let animationView = AnimationUtils.findAnimationView(in: view) {
                    animationView.layout()
                }

                let filename = namingScheme?(descriptor)
                    ?? [descriptor.canvasName, descriptor.caseName, descriptor.dimensions].joined(separator: "_")
                let url = directory.appendingPathComponent(filename).appendingPathExtension("png")

                try? view.dataRepresentation(scaledBy: CGFloat(canvas.exportScale))?.write(to: url)
            }
        })
    }

    static func renderToAnimations(component: CSComponent, directory: URL) {
        component.computedCanvases().forEach({ canvas in
            let stack = renderCanvasList(component: component, canvas: canvas, options: [
                RenderOption.hideAnimationLayers(true)
                ])

            for taggedCanvas in stack {
                let (view, descriptor, _) = taggedCanvas

                let tags: [String] = [descriptor.canvasName, descriptor.caseName, descriptor.dimensions]
                let filename = tags.joined(separator: "_")
                let url = directory.appendingPathComponent(filename).appendingPathExtension("json")

                guard let animationView = AnimationUtils.findAnimationView(in: view) else { continue }
                guard var animationData = animationView.data else { continue }
                guard let overlay = view.dataRepresentation(scaledBy: CGFloat(canvas.exportScale)) else { continue }

                if AnimationUtils.add(overlay: overlay, to: &animationData) {
                    let jsonString = try? JSONSerialization.data(withJSONObject: animationData, options: JSONSerialization.WritingOptions.prettyPrinted)

                    try? jsonString?.write(to: url)
                }
            }
        })
    }

    static func renderToVideos(component: CSComponent, directory: URL) {
        component.computedCanvases().forEach({ canvas in
            let stack = renderCanvasList(component: component, canvas: canvas)

            for taggedCanvas in stack {
                let (view, descriptor, _) = taggedCanvas

                let tags: [String] = [descriptor.canvasName, descriptor.caseName, descriptor.dimensions]
                let filename = tags.joined(separator: "_")
                let url = directory.appendingPathComponent(filename).appendingPathExtension("mp4")

                VideoUtils.writeVideo(capturing: view, scaledBy: CGFloat(canvas.exportScale), atFPS: 24, to: url)
            }
        })
    }
}
