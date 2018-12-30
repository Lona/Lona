//
//  NSViewExtensions.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/28/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa

private func image(from pixelBuffer: CVPixelBuffer) -> NSImage {
    let imageRep = NSCIImageRep(ciImage: CIImage(cvPixelBuffer: pixelBuffer, options: nil))
    let image = NSImage(size: imageRep.size)
    image.addRepresentation(imageRep)
    return image
}

private func imageData(from pixelBuffer: CVPixelBuffer) -> Data? {
    let nsImage = image(from: pixelBuffer)

    guard let bitmapData = nsImage.tiffRepresentation else {
        Swift.print("Failed to convert to tiff")
        return nil
    }

    guard let bitmapRep = NSBitmapImageRep(data: bitmapData) else {
        Swift.print("Failed to create NSBitmapImageRep")
        return nil
    }

    return bitmapRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:])
}

public extension NSView {

    static func placeholder(ofSize size: CGFloat, withColor color: CGColor = CGColor.clear) -> NSView {
        let view = NSView(frame: NSRect.square(ofSize: size))

        view.wantsLayer = true
        view.layer = CALayer()
        view.layer?.backgroundColor = color

        return view
    }

    func centerWithin(_ other: NSView) {
        frame.origin.y = other.frame.height / 2 - frame.midY
    }

    private func ensureLayer() {
        if !wantsLayer {
            wantsLayer = true
        }

        if layer == nil {
            layer = CALayer()
        }
    }

    var backgroundFill: CGColor? {
        get {
            ensureLayer()
            return layer!.backgroundColor
        }
        set {
            ensureLayer()
            layer!.backgroundColor = newValue
        }
    }

    func apply(layout constraints: [CSConstraint]) {
        CSConstraint.apply(constraints, to: self)
    }

    func constrain(aspectRatio: CGFloat) {
        addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: .width,
                relatedBy: .equal,
                toItem: self,
                attribute: .height,
                multiplier: 1,
                constant: 0
            )
        )
    }

    func constrain(_ attribute: NSLayoutConstraint.Attribute, as value: CGFloat) {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: value
        )

        self.addConstraint(constraint)
    }

    func constrain(_ attribute: NSLayoutConstraint.Attribute, to other: NSView, _ otherAttribute: NSLayoutConstraint.Attribute) {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: .equal,
            toItem: nil,
            attribute: otherAttribute,
            multiplier: 1,
            constant: 0
        )

        self.addConstraint(constraint)
    }

    func constrain(to other: NSView, _ attribute: NSLayoutConstraint.Attribute) {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: .lessThanOrEqual,
            toItem: other,
            attribute: attribute,
            multiplier: 1,
            constant: 0
        )

        self.addConstraint(constraint)
    }

    func constrain(by other: NSView, _ attribute: NSLayoutConstraint.Attribute) {
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: .lessThanOrEqual,
            toItem: other,
            attribute: attribute,
            multiplier: 1,
            constant: 0
        )

        other.addConstraint(constraint)
    }

    func constrain(by other: NSView, _ attributes: [NSLayoutConstraint.Attribute]) {
        attributes.forEach({ self.constrain(by: other, $0) })
    }

    func constrain(to other: NSView, _ attributes: [NSLayoutConstraint.Attribute]) {
        attributes.forEach({ self.constrain(to: other, $0) })
    }

    func addSubviewStretched(subview: NSView) {

        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)

        subview.constrain(by: self, .left)
        subview.constrain(by: self, .top)

        self.constrain(to: subview, .right)
        self.constrain(to: subview, .bottom)
    }

    @discardableResult func addBorderView(to side: NSLayoutConstraint.Attribute, size: CGFloat = 1, color: CGColor = #colorLiteral(red: 0.8379167914, green: 0.8385563493, blue: 0.8380157948, alpha: 1).cgColor) -> NSView {
        let borderView = NSView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.wantsLayer = true
        borderView.layer = CALayer()
        borderView.layer?.backgroundColor = color

        self.addSubview(borderView)

        switch side {
        case .top, .bottom:
            borderView.constrain(.height, as: size)
            borderView.constrain(by: self, .left)
            self.constrain(to: borderView, .right)
        default:
            borderView.constrain(.width, as: size)
            borderView.constrain(by: self, .top)
            self.constrain(to: borderView, .bottom)
        }

        self.constrain(to: borderView, side)

        return borderView
    }

    func pixelBuffer(scaledBy scale: CGFloat = 1) -> CVPixelBuffer? {
        let width = Int(scale * bounds.size.width)
        let height = Int(scale * bounds.size.height)

        func allocatePixelBuffer() -> CVPixelBuffer? {
            let attrs = [
                kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
                ] as CFDictionary

            var pixelBuffer: CVPixelBuffer?
            let status = CVPixelBufferCreate(
                kCFAllocatorDefault,
                width,
                height,
                kCVPixelFormatType_32ARGB,
                attrs,
                &pixelBuffer
            )

            return status == kCVReturnSuccess ? pixelBuffer : nil
        }

        guard let bitmapRep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: NSColorSpaceName.calibratedRGB,
            bitmapFormat: NSBitmapImageRep.Format(rawValue: 0),
            bytesPerRow: 4 * width,
            bitsPerPixel: 32
            ) else { return nil }

        guard let graphicsContext = NSGraphicsContext(bitmapImageRep: bitmapRep) else { return nil }

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = graphicsContext

        graphicsContext.cgContext.scaleBy(x: scale, y: scale)
        displayIgnoringOpacity(bounds, in: graphicsContext)

        guard
            let pixelBuffer = allocatePixelBuffer(),
            let image = CIImage(bitmapImageRep: bitmapRep),
            let ciContext = graphicsContext.ciContext
        else {
            NSGraphicsContext.restoreGraphicsState()

            return nil
        }

        ciContext.render(image, to: pixelBuffer)

        NSGraphicsContext.restoreGraphicsState()

        return pixelBuffer
    }

    func imageRepresentation(scaledBy scale: CGFloat = 1) -> NSImage? {
        guard let buffer = pixelBuffer(scaledBy: scale) else { return nil }
        return image(from: buffer)
    }

    func dataRepresentation(scaledBy scale: CGFloat = 1) -> Data? {
        guard let buffer = pixelBuffer(scaledBy: scale) else { return nil }
        return imageData(from: buffer)
    }

    func firstDescendant(where predicate: (NSView) -> Bool) -> NSView? {
        if predicate(self) {
            return self
        }

        for view in subviews {
            if let first = view.firstDescendant(where: predicate) {
                return first
            }
        }

        return nil
    }
}

public extension NSView {
    var subtreeDescription: String {
        return value(forKey: "_subtreeDescription") as! String
    }
}
