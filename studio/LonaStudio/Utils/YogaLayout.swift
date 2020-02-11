//
//  FlexboxLayout.swift
//  ComponentStudio
//
//  Created by devin_abbott on 5/23/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import Cocoa
import yoga

struct YGLayout {
    var left: CGFloat
    var top: CGFloat
    var right: CGFloat
    var bottom: CGFloat
    var width: CGFloat
    var height: CGFloat
}

extension YGJustify {
    static func from(string value: String) -> YGJustify {
        switch value {
        case "flex-start":
            return .flexStart
        case "flex-end":
            return .flexEnd
        case "center":
            return .center
        case "space-around":
            return .spaceAround
        case "space-between":
            return .spaceBetween
        default:
            return .flexStart
        }
    }

    var string: String {
        switch self {
        case .flexStart:
            return "flex-start"
        case .center:
            return "center"
        case .flexEnd:
            return "flex-end"
        case .spaceAround:
            return "space-around"
        case .spaceBetween:
            return "space-between"
        // We don't use this
        case .spaceEvenly:
            return "flex-start"
        @unknown default:
            return "flex-start"
        }
    }
}

extension YGAlign {
    static func from(string value: String) -> YGAlign {
        switch value {
        case "flex-start":
            return .flexStart
        case "flex-end":
            return .flexEnd
        case "center":
            return .center
        case "stretch":
            return .stretch
        default:
            return .flexStart
        }
    }

    var string: String {
        switch self {
        case .flexStart:
            return "flex-start"
        case .center:
            return "center"
        case .flexEnd:
            return "flex-end"
        case .stretch:
            return "stretch"
        default:
            return "flex-start"
        }
    }
}

enum YGFlexBasis {
    case auto
    case value(Float)
    case percent(Float)
}

extension YGNodeRef {
    static func create() -> YGNodeRef {
        return YGNodeNew()
    }

    var flexBasis: YGFlexBasis? {
        set {
            switch newValue! {
            case .auto: YGNodeStyleSetFlexBasisAuto(self)
            case .value(let value): YGNodeStyleSetFlexBasis(self, value)
            case .percent(let value): YGNodeStyleSetFlexBasisPercent(self, value)
            }
        }
        // TODO how to get these?
        get {
            return nil
        }
    }

    var flexDirection: YGFlexDirection {
        get { return YGNodeStyleGetFlexDirection(self) }
        set { return YGNodeStyleSetFlexDirection(self, newValue) }
    }

    var justifyContent: YGJustify {
        get { return YGNodeStyleGetJustifyContent(self) }
        set { return YGNodeStyleSetJustifyContent(self, newValue) }
    }

    var alignItems: YGAlign {
        get { return YGNodeStyleGetAlignItems(self) }
        set { return YGNodeStyleSetAlignItems(self, newValue) }
    }

    var flex: CGFloat {
        get { return CGFloat(YGNodeStyleGetFlex(self)) }
        set { return YGNodeStyleSetFlex(self, Float(newValue)) }
    }

    var flexGrow: CGFloat {
        get { return CGFloat(YGNodeStyleGetFlexGrow(self)) }
        set { return YGNodeStyleSetFlexGrow(self, Float(newValue)) }
    }

    var flexShrink: CGFloat {
        get { return CGFloat(YGNodeStyleGetFlexShrink(self)) }
        set { return YGNodeStyleSetFlexShrink(self, Float(newValue)) }
    }

    var flexWrap: YGWrap {
        get { return YGNodeStyleGetFlexWrap(self) }
        set { return YGNodeStyleSetFlexWrap(self, newValue) }
    }

    var paddingTop: CGFloat {
        get { return CGFloat(YGNodeStyleGetPadding(self, .top).value) }
        set { return YGNodeStyleSetPadding(self, .top, Float(newValue)) }
    }

    var paddingRight: CGFloat {
        get { return CGFloat(YGNodeStyleGetPadding(self, .right).value) }
        set { return YGNodeStyleSetPadding(self, .right, Float(newValue)) }
    }

    var paddingBottom: CGFloat {
        get { return CGFloat(YGNodeStyleGetPadding(self, .bottom).value) }
        set { return YGNodeStyleSetPadding(self, .bottom, Float(newValue)) }
    }

    var paddingLeft: CGFloat {
        get { return CGFloat(YGNodeStyleGetPadding(self, .left).value) }
        set { return YGNodeStyleSetPadding(self, .left, Float(newValue)) }
    }

    var marginTop: CGFloat {
        get { return CGFloat(YGNodeStyleGetMargin(self, .top).value) }
        set { return YGNodeStyleSetMargin(self, .top, Float(newValue)) }
    }

    var marginRight: CGFloat {
        get { return CGFloat(YGNodeStyleGetMargin(self, .right).value) }
        set { return YGNodeStyleSetMargin(self, .right, Float(newValue)) }
    }

    var marginBottom: CGFloat {
        get { return CGFloat(YGNodeStyleGetMargin(self, .bottom).value) }
        set { return YGNodeStyleSetMargin(self, .bottom, Float(newValue)) }
    }

    var marginLeft: CGFloat {
        get { return CGFloat(YGNodeStyleGetMargin(self, .left).value) }
        set { return YGNodeStyleSetMargin(self, .left, Float(newValue)) }
    }

    var borderTop: CGFloat {
        get { return CGFloat(YGNodeStyleGetBorder(self, .top)) }
        set { return YGNodeStyleSetBorder(self, .top, Float(newValue)) }
    }

    var borderRight: CGFloat {
        get { return CGFloat(YGNodeStyleGetBorder(self, .right)) }
        set { return YGNodeStyleSetBorder(self, .right, Float(newValue)) }
    }

    var borderBottom: CGFloat {
        get { return CGFloat(YGNodeStyleGetBorder(self, .bottom)) }
        set { return YGNodeStyleSetBorder(self, .bottom, Float(newValue)) }
    }

    var borderLeft: CGFloat {
        get { return CGFloat(YGNodeStyleGetBorder(self, .left)) }
        set { return YGNodeStyleSetBorder(self, .left, Float(newValue)) }
    }

    var width: CGFloat {
        get { return CGFloat(YGNodeStyleGetWidth(self).value) }
        set { return YGNodeStyleSetWidth(self, Float(newValue)) }
    }

    var height: CGFloat {
        get { return CGFloat(YGNodeStyleGetHeight(self).value) }
        set { return YGNodeStyleSetHeight(self, Float(newValue)) }
    }

    var minHeight: CGFloat {
        get { return CGFloat(YGNodeStyleGetMinHeight(self).value) }
        set { return YGNodeStyleSetMinHeight(self, Float(newValue)) }
    }

    var maxHeight: CGFloat {
        get { return CGFloat(YGNodeStyleGetMaxHeight(self).value) }
        set { return YGNodeStyleSetMaxHeight(self, Float(newValue)) }
    }

    var left: CGFloat {
        get { return CGFloat(YGNodeStyleGetPosition(self, .left).value) }
        set { return YGNodeStyleSetPosition(self, .left, Float(newValue)) }
    }

    var x: CGFloat {
        get { return left }
        set { left = newValue }
    }

    var top: CGFloat {
        get { return CGFloat(YGNodeStyleGetPosition(self, .top).value) }
        set { return YGNodeStyleSetPosition(self, .top, Float(newValue)) }
    }

    var y: CGFloat {
        get { return top }
        set { top = newValue }
    }

    var right: CGFloat {
        get { return CGFloat(YGNodeStyleGetPosition(self, .right).value) }
        set { return YGNodeStyleSetPosition(self, .right, Float(newValue)) }
    }

    var bottom: CGFloat {
        get {
            return CGFloat(YGNodeStyleGetPosition(self, .bottom).value)
        }
        set {
            return YGNodeStyleSetPosition(self, .bottom, Float(newValue))
        }
    }

    var position: YGPositionType {
        get {
            return YGNodeStyleGetPositionType(self)
        }
        set {
            return YGNodeStyleSetPositionType(self, newValue)
        }
    }

    var layout: YGLayout {
        return YGLayout(
            left: CGFloat(YGNodeLayoutGetLeft(self)),
            top: CGFloat(YGNodeLayoutGetTop(self)),
            right: CGFloat(YGNodeLayoutGetRight(self)),
            bottom: CGFloat(YGNodeLayoutGetBottom(self)),
            width: CGFloat(YGNodeLayoutGetWidth(self)),
            height: CGFloat(YGNodeLayoutGetHeight(self))
        )
    }

    var children: [YGNodeRef] {
        let count = YGNodeGetChildCount(self)
        var nodes = [YGNodeRef]()

        for index in 0..<count {
           nodes.append(YGNodeGetChild(self, UInt32(index)))
        }

        return nodes
    }

    func insert(child: YGNodeRef, at index: Int) {
        YGNodeInsertChild(self, child, UInt32(index))
    }

    func calculateLayout(width: CGFloat, height: CGFloat, direction: YGDirection = YGDirection.LTR) {
        YGNodeCalculateLayout(self, Float(width), Float(height), direction)
    }

    func calculateLayout(direction: YGDirection = YGDirection.LTR) {
        calculateLayout(width: width, height: height)
    }

    func free(recursive: Bool = false) {
        if recursive {
            YGNodeFreeRecursive(self)
        } else {
            YGNodeFree(self)
        }
    }

    func print() {
        YGNodePrint(self, .style)
    }
}

var LAYOUT_FOR_VIEW = [NSView: YGNodeRef]()

extension NSView {
    var ygNode: YGNodeRef? {
        get {
            return LAYOUT_FOR_VIEW[self]
        }
        set {
            LAYOUT_FOR_VIEW[self] = newValue
        }
    }

    var useYogaLayout: Bool {
        get {
            return true
        }
        set {
            _ = newValue
            ygNode = detectYogaLayout()
        }
    }

    func detectYogaLayout() -> YGNodeRef {
        var node = YGNodeRef.create()

        node.width = frame.size.width
        node.height = frame.size.height
        node.x = frame.origin.x
        node.y = frame.origin.y

        return node
    }

    static func createSpacer(size: CGFloat = -1, horizontal: Bool = false) -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: horizontal ? max(size, 0) : 0, height: horizontal ? 0 : max(size, 0)))
        view.useYogaLayout = true

        if size < 0 {
            view.ygNode?.flex = 1
        }

        return view
    }

    func addSpacer(size: CGFloat, horizontal: Bool = false) {
        let spacer = NSView.createSpacer(size: size, horizontal: horizontal)

        addSubview(spacer)
    }

    func layoutWithYoga() {
        guard let rootNode = ygNode else { return }

//        Swift.print("Layout with yoga")

        func buildNodeTree(view: NSView, node: YGNodeRef) {
            for (index, subview) in view.subviews.enumerated() {
                if let childNode = subview.ygNode {
                    if YGNodeGetParent(childNode) != nil {
                        continue
                    }

//                    Swift.print("Insert childnode", childNode, "at", index)
                    node.insert(child: childNode, at: index)

                    buildNodeTree(view: subview, node: childNode)
                }
            }
        }

        buildNodeTree(view: self, node: rootNode)

        rootNode.calculateLayout()

        func applyYogaLayout(view: NSView, node: YGNodeRef) {
            let layout = node.layout

            view.frame = NSRect(x: layout.left, y: layout.top, width: layout.width, height: layout.height)

//            Swift.print("updated frame", view.frame)

            for (index, childNode) in node.children.enumerated() {
                let subview = view.subviews[index]

                applyYogaLayout(view: subview, node: childNode)
            }
        }

        applyYogaLayout(view: self, node: rootNode)
    }
}
