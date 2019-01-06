//
//  ImagePreview.swift
//  LonaStudio
//
//  Created by Devin Abbott on 1/5/19.
//  Copyright © 2019 Devin Abbott. All rights reserved.
//

import AppKit

// An image view that supports image resizing modes
public class ImagePreview: NSImageView {
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: NSView.noIntrinsicMetric, height: NSView.noIntrinsicMetric)
    }

    private var originalImage: NSImage?

    override public var image: NSImage? {
        didSet {
            originalImage = image
        }
    }

    var resizingMode = CGSize.ResizingMode.scaleAspectFill {
        didSet {
            if resizingMode != oldValue {
                setNeedsDisplay()
            }
        }
    }

    // Use draw instead of viewWillDraw to ensure this is called after layout changes
    public override func draw(_ dirtyRect: NSRect) {
        if let image = image, let originalImage = originalImage {
            if originalImage.size.width <= frame.width && originalImage.size.height <= frame.height {
                if originalImage.size != image.size {
                    super.image = originalImage
                }
            } else if image.size != originalImage.size.resized(within: bounds.size, usingResizingMode: resizingMode).size {
                super.image = originalImage.resized(within: bounds.size, usingCroppingMode: resizingMode)
            }
        }

        super.draw(dirtyRect)
    }
}
