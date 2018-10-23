//
//  LayerThumbnail.swift
//  ComponentStudio
//
//  Created by devin_abbott on 10/3/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

private let layerOutlineColor = NSColor.black.withAlphaComponent(0.5)
private let layerDirectionColor1 = NSColor.parse(css: "rgba(124,124,124,0.8)")!
private let layerDirectionColor2 = NSColor.parse(css: "rgba(124,124,124,0.65)")!
private let layerDirectionColor3 = NSColor.parse(css: "rgba(124,124,124,0.5)")!

class LayerThumbnail {
    static var cache: NSCache<NSString, NSImage> {
        let nsCache = NSCache<NSString, NSImage>()
        nsCache.countLimit = 100
        return nsCache
    }

    static func cacheKeyForView(at scale: CGFloat, direction: String, backgroundColor: String? = nil) -> NSString {
        if let backgroundColor = backgroundColor {
            return NSString(string: "\(backgroundColor):\(scale):\(direction)")
        } else {
            return NSString(string: "View:\(scale):\(direction)")
        }
    }

    static func image(for layer: CSLayer) -> NSImage? {
        let scale = NSApplication.shared.windows.first?.backingScaleFactor ?? 1
        let size = 16 * scale

        switch layer.type {
        case .builtIn(.view):
            let cacheKey = cacheKeyForView(at: scale, direction: layer.flexDirection ?? "column", backgroundColor: layer.backgroundColor)

            if let cached = cache.object(forKey: cacheKey) {
                return cached
            }

            let image = NSImage(size: NSSize(width: size, height: size), flipped: true, drawingHandler: { rect in
                NSGraphicsContext.saveGraphicsState()
                NSBezierPath.defaultLineWidth = scale

                let borderPath = NSBezierPath(rect: rect.insetBy(dx: 2.5 * scale, dy: 2.5 * scale))
                var outlineColor = layerOutlineColor

                if let backgroundColor = layer.backgroundColor {
                    let color = CSColors.parse(css: backgroundColor).color
                    color.set()
                    outlineColor = color.contrastingLabelColor.withAlphaComponent(0.5)
                    NSBezierPath(rect: rect.insetBy(dx: 2 * scale, dy: 2 * scale)).fill()
                }

                outlineColor.setStroke()
                borderPath.stroke()

                let rowThickness = 2 * scale
                let rowLength = 8 * scale

                let rowStart1 = 4 * scale
                let rowStart2 = 7 * scale
                let rowStart3 = 10 * scale

                if layer.flexDirection == "row" {
                    outlineColor.withAlphaComponent(0.4).setFill()
                    NSBezierPath(rect: NSRect(x: rowStart1, y: rowStart1, width: rowThickness, height: rowLength)).fill()
                    outlineColor.withAlphaComponent(0.3).setFill()
                    NSBezierPath(rect: NSRect(x: rowStart2, y: rowStart1, width: rowThickness, height: rowLength)).fill()
                    outlineColor.withAlphaComponent(0.2).setFill()
                    NSBezierPath(rect: NSRect(x: rowStart3, y: rowStart1, width: rowThickness, height: rowLength)).fill()
                } else {
                    outlineColor.withAlphaComponent(0.4).setFill()
                    NSBezierPath(rect: NSRect(x: rowStart1, y: rowStart1, width: rowLength, height: rowThickness)).fill()
                    outlineColor.withAlphaComponent(0.3).setFill()
                    NSBezierPath(rect: NSRect(x: rowStart1, y: rowStart2, width: rowLength, height: rowThickness)).fill()
                    outlineColor.withAlphaComponent(0.2).setFill()
                    NSBezierPath(rect: NSRect(x: rowStart1, y: rowStart3, width: rowLength, height: rowThickness)).fill()
                }

                NSGraphicsContext.restoreGraphicsState()
                return true
            })

            cache.setObject(image, forKey: cacheKey)

            return image
        case .builtIn(.text):
            let template: NSImage = #imageLiteral(resourceName: "icon-layer-list-text")

            if let font = layer.font {
                let cacheKey = font as NSString

                // TODO: Can't use font name, since these may change. Or we need to invalidate on refresh
                if let cached = cache.object(forKey: cacheKey) {
                    return cached
                } else {
                    let color = CSTypography.getFontBy(id: font).font.color
                    let image = template.tinted(color: color ?? layerOutlineColor)
                    cache.setObject(image, forKey: cacheKey)
                    return image
                }
            }

            return template
        case .builtIn(.image):
            if let urlString = layer.image, let url = URL(string: urlString) {
                let cacheKey = NSString(string: urlString)

                if let cached = cache.object(forKey: cacheKey) {
                    return cached
                } else if let image = NSImage(contentsOf: url) {
                    image.size = NSSize(width: 14, height: 14)
                    cache.setObject(image, forKey: cacheKey)
                    return image
                }
            }

            return #imageLiteral(resourceName: "icon-layer-list-image")
        default:
            return nil
        }
    }
}
