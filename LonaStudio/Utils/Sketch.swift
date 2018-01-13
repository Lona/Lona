//
//  Sketch.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/10/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

struct CurvePoint {
    var point: CGPoint
    var curveFrom: CGPoint?
    var curveTo: CGPoint?
    var curveMode: Int
    var cornerRadius: Int
    
    func descriptionOf(point: CGPoint?, within frame: CGRect, transform: CoordinateTransformation) -> String {
        guard let point = point else { return descriptionOf(point: self.point, within: frame, transform: transform) }
        let origin = transform(point - frame.origin)
        return "{\(origin.x / frame.width), \(origin.y / frame.height)}"
    }
    
    func toData(with frame: CGRect, transform: CoordinateTransformation) -> CSData {
        return CSData.Object([
            "_class": "curvePoint".toData(),
            "cornerRadius": cornerRadius.toData(),
            "curveFrom": descriptionOf(point: curveFrom, within: frame, transform: transform).toData(),
            "curveMode": curveMode.toData(),
            "curveTo": descriptionOf(point: curveTo, within: frame, transform: transform).toData(),
            "hasCurveFrom": (curveFrom != nil).toData(),
            "hasCurveTo": (curveTo != nil).toData(),
            "point": descriptionOf(point: point, within: frame, transform: transform).toData()
            ])
    }
}

struct SketchBorder: CSDataSerializable {
    var color: CGColor
    var thickness: CGFloat
    
    func toData() -> CSData {
        let components = color.components!
        return CSData.Object([
            "_class": "border".toData(),
            "isEnabled": true.toData(),
            "color": CSData.Object([
                "_class": "color".toData(),
                "alpha": components[3].toData(),
                "blue": components[2].toData(),
                "green": components[1].toData(),
                "red": components[0].toData()
                ]),
            "fillType": 0.toData(),
            "position": 0.toData(),
            "thickness": thickness.toData(),
            ])
    }
}

struct SketchFill: CSDataSerializable {
    var color: CGColor
    
    func toData() -> CSData {
        let components = color.components!
        return CSData.Object([
            "_class": "fill".toData(),
            "isEnabled": true.toData(),
            "color": CSData.Object([
                "_class": "color".toData(),
                "alpha": components[3].toData(),
                "blue": components[2].toData(),
                "green": components[1].toData(),
                "red": components[0].toData()
                ]),
            "fillType": 0.toData(),
            "noiseIndex": 0.toData(),
            "noiseIntensity": 0.toData(),
            "patternFillType": 1.toData(),
            "patternTileScale": 1.toData()
            ])
    }
}

class SketchPath {
    var path: NSBezierPath
    
    init(path: NSBezierPath) {
        self.path = path
    }
    
    func toData(with frame: CGRect, transform: CoordinateTransformation) -> CSData {
        let curvePoints = path.curvePoints()
        
        return CSData.Object([
            "_class": "path".toData(),
            "isClosed": curvePoints.isClosed.toData(),
            "pointRadiusBehaviour": 1.toData(),
            "points": CSData.Array(curvePoints.points.map({ $0.toData(with: frame, transform: transform) }))
            ])
    }
}

class SketchLayer {
    var name: String? = nil
    
    var frame: CGRect {
        return CGRect.zero
    }
    
    func toData(with parentFrame: CGRect, transform: CoordinateTransformation) -> CSData {
        let origin = transform(frame.origin - parentFrame.origin)
        
        return CSData.Object([
            "do_objectID": NSUUID().uuidString.toData(),
            "exportOptions": CSData.Object([
                "_class": "exportOptions".toData(),
                "exportFormats": CSData.Array([]),
                "includedLayerIds": CSData.Array([]),
                "layerOptions": 0.toData(),
                "shouldTrim": false.toData()
                ]),
            "frame": CSData.Object([
                "_class": "rect".toData(),
                "constrainProportions": false.toData(),
                "height": frame.height.toData(),
                "width": frame.width.toData(),
                "x": origin.x.toData(),
                "y": origin.y.toData()
                ]),
            "isFlippedHorizontal": false.toData(),
            "isFlippedVertical": false.toData(),
            "isLocked": false.toData(),
            "isVisible": true.toData(),
            "layerListExpandedType": 0.toData(),
            "name": (name ?? "layer").toData(),
            "nameIsFixed": false.toData(),
            "resizingConstraint": 63.toData(),
            "resizingType": 0.toData(),
            "rotation": 0.toData(),
            "shouldBreakMaskChain": false.toData(),
            ])
    }
}

struct Shape {
    var path: [CurvePoint] = []
    var isClosed: Bool = false
}

class SketchShapePath: SketchLayer {
    var path: SketchPath
    
    override var frame: CGRect {
        //        return path.path.bounds
        
        let points = path.path.curvePoints().points
        let x = points.map({ $0.point.x }).min() ?? 0
        let y = points.map({ $0.point.y }).min() ?? 0
        let width = (points.map({ $0.point.x }).max() ?? 0) - x
        let height = (points.map({ $0.point.y }).max() ?? 0) - y
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    init(bezierPath: NSBezierPath) {
        self.path = SketchPath(path: bezierPath)
    }
    
    init(path: SketchPath) {
        self.path = path
    }
    
    override func toData(with parentFrame: CGRect, transform: CoordinateTransformation) -> CSData {
        return super.toData(with: parentFrame, transform: transform).merge(CSData.Object([
            "_class": "shapePath".toData(),
            "booleanOperation": (-1).toData(),
            "edited": true.toData(),
            "path": path.toData(with: frame, transform: transform),
            ]))
    }
}

class SketchGroup: SketchLayer {
    var layers: [SketchLayer] = []
    
    override var frame: CGRect {
        // Use the mask's frame if it exists, since a mask will clip all content outside
        if let maskLayer = layers.first(where: { layer in
            guard let layer = layer as? SketchShapeGroup else { return false }
            return layer.hasClippingMask
        }) as? SketchShapeGroup {
            return maskLayer.frame
        }
        
        return layers.reduce(nil) { (result, layer) -> CGRect? in
            if let result = result {
                return result.union(layer.frame)
            }
            return layer.frame
        } ?? CGRect.zero
    }
    
    init(layers: [SketchLayer]) {
        self.layers = layers
    }
    
    override func toData(with parentFrame: CGRect, transform: CoordinateTransformation) -> CSData {
        return super.toData(with: parentFrame, transform: transform).merge(CSData.Object([
            "_class": "group".toData(),
            "style": CSData.Object([
                "_class": "style".toData(),
                "endDecorationType": 0.toData(),
                "miterLimit": 10.toData(),
                "startDecorationType": 0.toData()
                ]),
            "layers": CSData.Array(self.layers.map({ $0.toData(with: self.frame, transform: transform) })),
            "hasClickThrough": false.toData(),
            ]))
    }
}

struct SketchBorderOptions {
    var lineCapStyle: NSBezierPath.LineCapStyle = NSBezierPath.LineCapStyle.buttLineCapStyle
    var lineJoinStyle: NSBezierPath.LineJoinStyle = NSBezierPath.LineJoinStyle.miterLineJoinStyle
    
    init() {}
    
    init(lineCapStyle: NSBezierPath.LineCapStyle, lineJoinStyle: NSBezierPath.LineJoinStyle) {
        self.lineCapStyle = lineCapStyle
        self.lineJoinStyle = lineJoinStyle
    }
    
    func toData() -> CSData {
        return CSData.Object([
            "_class": "borderOptions".toData(),
            "dashPattern": CSData.Array([]),
            "isEnabled": false.toData(),
            "lineCapStyle": lineCapStyle.rawValue.toData(),
            "lineJoinStyle": lineJoinStyle.rawValue.toData()
            ])
    }
}

class SketchShapeGroup: SketchGroup {
    var fills: [SketchFill] = []
    var borders: [SketchBorder] = []
    var borderOptions: SketchBorderOptions?
    var hasClippingMask: Bool = false
    
    init(layers: [SketchLayer], fills: [SketchFill], borders: [SketchBorder], borderOptions: SketchBorderOptions?, hasClippingMask: Bool) {
        super.init(layers: layers)
        self.fills = fills
        self.borders = borders
        self.borderOptions = borderOptions
        self.hasClippingMask = hasClippingMask
    }
    
    override func toData(with parentFrame: CGRect, transform: CoordinateTransformation) -> CSData {
        var style = CSData.Object([
            "_class": "style".toData(),
            "endDecorationType": 0.toData(),
            "miterLimit": 10.toData(),
            "startDecorationType": 0.toData()
            ])
        
        if !fills.isEmpty { style["fills"] = fills.toData() }
        if !borders.isEmpty { style["borders"] = borders.toData() }
        if borderOptions != nil { style["borderOptions"] = borderOptions!.toData() }
        
        return super.toData(with: parentFrame, transform: transform).merge(CSData.Object([
            "_class": "shapeGroup".toData(),
            "style": style,
            "clippingMaskMode": 0.toData(),
            "hasClippingMask": hasClippingMask.toData(),
            "windingRule": 1.toData(),
            ]))
    }
}

typealias PathElement = (type: NSBezierPath.ElementType, points: [CGPoint])

extension NSBezierPath {
    func curvePoints() -> (points: [CurvePoint], isClosed: Bool) {
        var curvePoints: [CurvePoint] = []
        var points = [CGPoint](repeating: .zero, count: 3)
        
        var isClosed = false
        var i = 0
        
//        let y = bounds.origin.y
//        let transformation = AffineTransform()
        
        
        let path = self.copy() as! NSBezierPath
//        path.transform(using: transformation)
        
        var elements: [PathElement] = []
        for i in 0..<path.elementCount {
            let type = path.element(at: i, associatedPoints: &points)
            elements.append((type, points))
        }
        
        loop: while i < path.elementCount {
            let type = path.element(at: i, associatedPoints: &points)
            
            switch type {
            case .moveToBezierPathElement:
                let point = CurvePoint(
                    point: points[0],
                    curveFrom: nil,
                    curveTo: nil,
                    curveMode: 1,
                    cornerRadius: 0
                )
                
                curvePoints.append(point)
            case .lineToBezierPathElement:
                let point = CurvePoint(
                    point: points[0],
                    curveFrom: nil,
                    curveTo: nil,
                    curveMode: 1,
                    cornerRadius: 0
                )
                
                curvePoints.append(point)
            case .curveToBezierPathElement:
                if var last = curvePoints.last {
                    last.curveFrom = points[0]
                    last.curveMode = 2
                    curvePoints[curvePoints.index(before: curvePoints.endIndex)] = last
                }
                
                let point = CurvePoint(
                    point: points[2],
                    curveFrom: nil,
                    curveTo: points[1],
                    curveMode: 2,
                    cornerRadius: 0
                )
                
                curvePoints.append(point)
            case .closePathBezierPathElement:
                isClosed = true
                
                // Attempt to consolidate
                if var first = curvePoints.first, let last = curvePoints.last, first.point.equalTo(last.point) {
                    if last.curveTo != nil {
                        first.curveTo = last.curveTo
                        first.curveMode = 2
                        curvePoints[0] = first
                    }
                    
                    curvePoints.removeLast()
                }
                
                break loop
            }
            
            i += 1
        }
        
        //        Swift.print("serialized")
        //        Swift.print(self)
        //        Swift.print(curvePoints)
        //        Swift.print("")
        
        // Sketch shapes have their points in the reverse order. Both ways should render
        // properly, but it could potentially affect clipping via winding rule? It at least
        // affects tab order.
        let reversed: [CurvePoint] = curvePoints.reversed().map({ curvePoint in
            var curvePoint = curvePoint
            let temp = curvePoint.curveFrom
            curvePoint.curveFrom = curvePoint.curveTo
            curvePoint.curveTo = temp
            return curvePoint
        })
        return (points: reversed, isClosed: isClosed)
        
        //        return (points: curvePoints, isClosed: isClosed)
    }
}


