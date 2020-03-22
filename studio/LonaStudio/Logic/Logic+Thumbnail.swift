//
//  Logic+Thumbnail.swift
//  LonaStudio
//
//  Created by Devin Abbott on 3/21/20.
//  Copyright © 2020 Devin Abbott. All rights reserved.
//

import Defaults
import Foundation
import Logic

extension LogicViewController {

    // MARK: Public

    public enum ThumbnailStyle: Int {
        case standard, bordered
    }

    public static func thumbnail(
        for url: URL,
        within size: NSSize,
        canvasSize: NSSize = .init(width: 800, height: 200),
        viewportRect: NSRect = .init(x: 0, y: 0, width: 200, height: 200),
        style: ThumbnailStyle
    ) -> NSImage {
        let key = cacheKey(size: size)

        if let image = thumbnailImageCache[url]?[key] {
            return image
        } else {
            let image = makeThumbnail(for: url, within: size, canvasSize: canvasSize, viewportRect: viewportRect, style: style)

            if thumbnailImageCache[url] == nil {
                thumbnailImageCache[url] = [:]
            }

            thumbnailImageCache[url]?[key] = image

            return image
        }
    }

    // MARK: Private

    public static func invalidateThumbnail(url: URL) {
        thumbnailImageCache.removeValue(forKey: url)
    }

    private static var thumbnailImageCache: [URL: [Int: NSImage]] = [:]

    private static func cacheKey(size: NSSize) -> Int {
        var hasher = Hasher()
        hasher.combine(size.width)
        hasher.combine(size.height)
        return hasher.finalize()
    }

    private static func makeThumbnail(
        for url: URL,
        within size: NSSize,
        canvasSize: NSSize,
        viewportRect: NSRect,
        style: ThumbnailStyle
    ) -> NSImage {
        guard let rootNode = LogicModule.load(url: url) else { return NSImage() }

        let compiled = LonaModule.current.logic.compiled

        let formattingOptions = LogicFormattingOptions(
            style: Defaults[.formattingStyle],
            getColor: ({ id in
                guard let colorString = compiled.evaluation?.evaluate(uuid: id)?.colorString,
                    let color = NSColor.parse(css: colorString) else { return nil }
                return (colorString, color)
            })
        )

        let getElementDecoration: (UUID) -> LogicElement.Decoration? = { uuid in
            return LogicViewController.decorationForNodeID(
                rootNode: compiled.programNode,
                formattingOptions: formattingOptions,
                evaluationContext: compiled.evaluation,
                id: uuid
            )
        }

        guard let pdfData = LogicCanvasView.pdf(
            size: canvasSize,
            mediaBox: viewportRect,
            formattedContent: .init(LGCSyntaxNode.program(rootNode).formatted(using: formattingOptions)),
            getElementDecoration: getElementDecoration) else { return NSImage() }

        let image = NSImage(size: size, flipped: false, drawingHandler: { rect in
            NSGraphicsContext.saveGraphicsState()

            switch style {
            case .bordered:
                let inset = NSSize(width: 1, height: 1)
                let insetRect = rect.insetBy(dx: inset.width, dy: inset.height)

                let outline = NSBezierPath(roundedRect: insetRect, xRadius: 2, yRadius: 2)
                outline.lineWidth = 2

                NSColor.parse(css: "rgb(210,210,212)")!.setStroke()
                NSColor.white.withAlphaComponent(0.9).setFill()

                outline.fill()
                outline.setClip()

                if let pdfImage = NSImage(data: pdfData) {
                    pdfImage.draw(in: NSRect(x: inset.width, y: inset.height, width: rect.width, height: rect.height))
                }

                outline.stroke()
            case .standard:
                if let pdfImage = NSImage(data: pdfData) {
                    pdfImage.draw(in: rect)
                }
            }

            NSGraphicsContext.restoreGraphicsState()
            return true
        })

        return image
    }
}
