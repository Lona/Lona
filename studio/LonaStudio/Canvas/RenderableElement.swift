//
//  RenderableView.swift
//  LonaStudio
//
//  Created by Devin Abbott on 12/5/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Lottie

enum RenderableType: Equatable {
    case view
    case text(RenderableTextAttributes)
    case image(RenderableImageAttributes)
    case animation(RenderableAnimationAttributes)
    case vector(RenderableImageAttributes)
}

struct RenderableViewAttributes: Equatable {
    init() {
        layerName = ""
        frame = .zero
        multipliedFillColor = .clear
        opacity = 1
        cornerRadius = 0
        borderWidth = 0
        multipliedBorderColor = .clear
        shadow = nil
        type = .view
    }

    var layerName: String
    var frame: NSRect
    var multipliedFillColor: NSColor
    var opacity: CGFloat
    var cornerRadius: CGFloat
    var borderWidth: CGFloat
    var multipliedBorderColor: NSColor
    var shadow: NSShadow?
    var type: RenderableType

    func makeView() -> CSView {
        let view = CSView(frame: frame)

        configureView(view)

        return view
    }

    func configureView(_ view: CSView) {
        view.frame = frame
        view.layerName = layerName
        view.multipliedFillColor = multipliedFillColor
        view.opacity = opacity
        view.cornerRadius = cornerRadius
        view.borderWidth = borderWidth
        view.multipliedBorderColor = multipliedBorderColor
        view.shadow = shadow

        view.getInnerSubviews()
            .filter { ($0 is CSTextView) || ($0 is LOTAnimationView) }
            .forEach { $0.removeFromSuperview() }

        switch type {
        case .view:
            view.backgroundImage = nil
        case .text(let params):
            view.backgroundImage = nil
            let textView = params.makeTextView(size: frame.size)

            view.addInnerSubview(textView)
        case .image(let params), .vector(let params):
            view.backgroundImage = params.image
            view.resizingMode = params.resizingMode
        case .animation(let attributes):
            let animationView = LOTAnimationView(json: attributes.data as! [AnyHashable: Any])
            animationView.animationSpeed = attributes.animationSpeed
            animationView.contentMode = attributes.contentMode
            animationView.frame = frame

            view.addInnerSubview(animationView)

            if attributes.isHidden {
                animationView.isHidden = true
            } else {
                animationView.play()
            }
        }
    }
}

struct RenderableTextAttributes: Equatable {
    var text: String
    var textStyle: TextStyle
    var textAlignment: NSTextAlignment
    var numberOfLines: Int

    func makeAttributedString() -> NSAttributedString {
        var attributeDictionary = textStyle.attributeDictionary

        // Add alignment to text style attributes
        let titleParagraphStyle = textStyle.paragraphStyle
        titleParagraphStyle.alignment = textAlignment
        attributeDictionary[.paragraphStyle] = titleParagraphStyle

        return NSAttributedString(string: text, attributes: attributeDictionary)
    }

    func makeTextView(size: CGSize) -> NSTextView {
        let textView = CSTextView()
        textView.isEditable = false
        textView.isSelectable = false

        textView.frame = NSRect(origin: .zero, size: size)
        textView.textContainer?.lineFragmentPadding = 0.0
        textView.textContainer?.lineBreakMode = .byTruncatingTail
        textView.textContainer?.maximumNumberOfLines = numberOfLines

        textView.textStorage?.append(makeAttributedString())
        textView.drawsBackground = false

        return textView
    }
}

struct RenderableImageAttributes: Equatable {
    var image: NSImage
    var resizingMode: CGSize.ResizingMode
}

struct RenderableAnimationAttributes: Equatable {
    var data: NSMutableDictionary
    var isHidden: Bool
    var animationSpeed: CGFloat
    var contentMode: LOTViewContentMode
}

struct RenderableElement {
    var attributes: RenderableViewAttributes
    var children: [RenderableElement]

    func makeViewHierarchy() -> CSView {
        let view = attributes.makeView()

        children.forEach { child in
            let childView = child.makeViewHierarchy()

            view.addInnerSubview(childView)
        }

        return view
    }

    func updateViewHierarchy(_ view: NSView, previous: RenderableElement) {
        guard let view = view as? CSView else { return }

        if attributes != previous.attributes {
            attributes.configureView(view)
        }

        let subviews = view.getInnerSubviews().map { $0 as? CSView }.compactMap { $0 }

        for index in 0..<max(children.count, previous.children.count) {
            if index < children.count && index < previous.children.count {
                children[index].updateViewHierarchy(subviews[index], previous: previous.children[index])
            } else if index < children.count && index >= previous.children.count {
                let childView = children[index].makeViewHierarchy()

                view.addSubview(childView)
            } else if index >= children.count && index < previous.children.count {
                subviews[index].removeFromSuperview()
            }
        }
    }
}
