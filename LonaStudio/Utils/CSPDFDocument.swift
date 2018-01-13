//
//  CSPDFDocument.swift
//  ComponentStudio
//
//  Created by devin_abbott on 9/9/17.
//  Copyright © 2017 Devin Abbott. All rights reserved.
//

import Foundation
import AppKit

enum PDFOperationType: String {
    
    // Graphics State
    case saveState = "q"
    case restoreState = "Q"
    case setCurrentMatrix = "cm"
    case setLineWidth = "w"
    case setLineCap = "J"
    case setLineJoin = "j"
    case setMiterLimit = "M"
    case setDashPattern = "d"
    case setColorRenderingIntent = "ri"
    case setFlatness = "i"
    case setState = "gs"
    
    // Path Construction
    case beginPath = "m"
    case line = "l"
    case cubicBezier123 = "c"
    case cubicBezier23 = "v"
    case cubicBezier13 = "y"
    case closePath = "h"
    case rectangle = "re"
    
    // Path Painting
    case stroke = "S"
    case strokeAndClose = "s"
    case fill = "f" // Also "F"?
    case fillAndStroke = "B"
    case fillAndStrokeEvenOdd = "B*"
    case closeFillAndStroke = "b"
    case closeFillAndStrokeEvenOdd = "b*"
    case endPathNoop = "n"
    
    // Clipping Paths
    case clippingPath = "W"
    case clippingPathEvenOdd = "W*"
    
    // Color
    case strokeColorSpace = "CS"
    case fillColorSpace = "cs"
    case setStrokeColor = "SC"
    case setFillColor = "sc"
    case setStrokeColorName = "SCN"
    case setFillColorName = "scn"
    case strokeColorRGB = "RG"
    case fillColorRGB = "rg"
    case strokeColorCMYK = "K"
    case fillColorCMYK = "k"
}

enum PDFOperandType {
    case name
    case number
}

enum PDFOperandValue {
    case null
    case name(String)
    case number(CGPDFReal)
    
    var isNull: Bool {
        switch self {
        case .null: return true
        default: return false
        }
    }
    
    func toString() -> String {
        switch self {
        case .null: return "null"
        case .name(let value): return value
        case .number(let value): return String(describing: value)
        }
    }
}

struct PDFOperandDefinition {
    let name: String
    let type: PDFOperandType
    
    init(name: String, type: PDFOperandType) {
        self.name = name
        self.type = type
    }
}

class PDFOperationDefinition {
    let type: PDFOperationType
    let operands: [PDFOperandDefinition]
    
    init(type: PDFOperationType, operands: [PDFOperandDefinition] = []) {
        self.type = type
        self.operands = operands
    }
}

struct PDFOperand {
    let name: String
    let type: PDFOperandType
    let value: PDFOperandValue
    
    init(name: String, type: PDFOperandType, value: PDFOperandValue) {
        self.name = name
        self.type = type
        self.value = value
    }
    
    func toString() -> String {
        return "\(name): \(value.toString())"
    }
    
    var number: CGFloat {
        guard case PDFOperandValue.number(let value) = self.value else { return 0 }
        return value
    }
}

typealias CoordinateTransformation = (CGPoint) -> CGPoint

struct PDFOperation {
    let type: PDFOperationType
    let operands: [PDFOperand]
    
    func toString() -> String {
        return "\(type)(\(operands.map({ $0.toString() }).reversed().joined(separator: ", ")))"
    }
    
    func get(operand name: String) -> PDFOperand? {
        return operands.first(where: { $0.name == name })
    }
    
    func get(number name: String) -> CGFloat? {
        return get(operand: name)?.number
    }
    
    func getPoint(_ xName: String, _ yName: String, _ transform: CoordinateTransformation? = nil) -> CGPoint? {
        guard let x = get(number: xName), let y = get(number: yName) else { return nil }
        let point = CGPoint(x: x, y: y)
        if let transform = transform {
            return transform(point)
        }
        return point
    }
}

func bridge<T : AnyObject>(obj : T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

func bridge<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}

class CSPDFDocument {
    
    static let PDF_OPERATIONS: [PDFOperationDefinition] = [
        
        // Graphics State
        PDFOperationDefinition(type: PDFOperationType.saveState),
        PDFOperationDefinition(type: PDFOperationType.restoreState),
        PDFOperationDefinition(type: PDFOperationType.setCurrentMatrix, operands: [
            PDFOperandDefinition(name: "a", type: PDFOperandType.number),
            PDFOperandDefinition(name: "b", type: PDFOperandType.number),
            PDFOperandDefinition(name: "c", type: PDFOperandType.number),
            PDFOperandDefinition(name: "d", type: PDFOperandType.number),
            PDFOperandDefinition(name: "e", type: PDFOperandType.number),
            PDFOperandDefinition(name: "f", type: PDFOperandType.number),
            ]),
        PDFOperationDefinition(type: PDFOperationType.setLineWidth, operands: [
            PDFOperandDefinition(name: "lineWidth", type: PDFOperandType.number),
            ]),
        PDFOperationDefinition(type: PDFOperationType.setLineCap, operands: [
            PDFOperandDefinition(name: "lineCap", type: PDFOperandType.number),
            ]),
        PDFOperationDefinition(type: PDFOperationType.setLineJoin, operands: [
            PDFOperandDefinition(name: "lineJoin", type: PDFOperandType.number),
            ]),
        PDFOperationDefinition(type: PDFOperationType.setMiterLimit, operands: [
            PDFOperandDefinition(name: "miterLimit", type: PDFOperandType.number),
            ]),
        PDFOperationDefinition(type: PDFOperationType.setDashPattern, operands: [
            // TODO: This needs to be an array
            PDFOperandDefinition(name: "dashArray", type: PDFOperandType.number),
            PDFOperandDefinition(name: "dashPhase", type: PDFOperandType.number),
            ]),
        PDFOperationDefinition(type: PDFOperationType.setColorRenderingIntent, operands: [
            PDFOperandDefinition(name: "intent", type: PDFOperandType.name),
            ]),
        PDFOperationDefinition(type: PDFOperationType.setFlatness, operands: [
            PDFOperandDefinition(name: "flatness", type: PDFOperandType.number),
            ]),
        PDFOperationDefinition(type: PDFOperationType.setState, operands: [
            // TODO: This needs to be a dictionary
            PDFOperandDefinition(name: "gs", type: PDFOperandType.number),
            ]),
        
        // Path Construction
        PDFOperationDefinition(type: PDFOperationType.beginPath, operands: [
            PDFOperandDefinition(name: "x", type: PDFOperandType.number),
            PDFOperandDefinition(name: "y", type: PDFOperandType.number),
        ]),
        PDFOperationDefinition(type: PDFOperationType.line, operands: [
            PDFOperandDefinition(name: "x", type: PDFOperandType.number),
            PDFOperandDefinition(name: "y", type: PDFOperandType.number),
        ]),
        PDFOperationDefinition(type: PDFOperationType.cubicBezier123, operands: [
            PDFOperandDefinition(name: "x1", type: PDFOperandType.number),
            PDFOperandDefinition(name: "y1", type: PDFOperandType.number),
            PDFOperandDefinition(name: "x2", type: PDFOperandType.number),
            PDFOperandDefinition(name: "y2", type: PDFOperandType.number),
            PDFOperandDefinition(name: "x3", type: PDFOperandType.number),
            PDFOperandDefinition(name: "y3", type: PDFOperandType.number),
        ]),
        PDFOperationDefinition(type: PDFOperationType.cubicBezier23, operands: [
            PDFOperandDefinition(name: "x2", type: PDFOperandType.number),
            PDFOperandDefinition(name: "y2", type: PDFOperandType.number),
            PDFOperandDefinition(name: "x3", type: PDFOperandType.number),
            PDFOperandDefinition(name: "y3", type: PDFOperandType.number),
        ]),
        PDFOperationDefinition(type: PDFOperationType.cubicBezier13, operands: [
            PDFOperandDefinition(name: "x1", type: PDFOperandType.number),
            PDFOperandDefinition(name: "y1", type: PDFOperandType.number),
            PDFOperandDefinition(name: "x3", type: PDFOperandType.number),
            PDFOperandDefinition(name: "y3", type: PDFOperandType.number),
        ]),
        PDFOperationDefinition(type: PDFOperationType.closePath),
        PDFOperationDefinition(type: PDFOperationType.rectangle, operands: [
            PDFOperandDefinition(name: "x", type: PDFOperandType.number),
            PDFOperandDefinition(name: "y", type: PDFOperandType.number),
            PDFOperandDefinition(name: "width", type: PDFOperandType.number),
            PDFOperandDefinition(name: "height", type: PDFOperandType.number),
        ]),
        
        // Path Painting
        PDFOperationDefinition(type: PDFOperationType.stroke),
        PDFOperationDefinition(type: PDFOperationType.strokeAndClose),
        PDFOperationDefinition(type: PDFOperationType.fill),
        PDFOperationDefinition(type: PDFOperationType.fillAndStroke),
        PDFOperationDefinition(type: PDFOperationType.fillAndStrokeEvenOdd),
        PDFOperationDefinition(type: PDFOperationType.closeFillAndStroke),
        PDFOperationDefinition(type: PDFOperationType.closeFillAndStrokeEvenOdd),
        PDFOperationDefinition(type: PDFOperationType.endPathNoop),
        
        // Clipping Paths
        PDFOperationDefinition(type: PDFOperationType.clippingPath),
        PDFOperationDefinition(type: PDFOperationType.clippingPathEvenOdd),
        
        // Color
        PDFOperationDefinition(type: PDFOperationType.strokeColorSpace, operands: [
            PDFOperandDefinition(name: "name", type: PDFOperandType.name),
            ]),
        PDFOperationDefinition(type: PDFOperationType.fillColorSpace, operands: [
            PDFOperandDefinition(name: "name", type: PDFOperandType.name),
            ]),
        PDFOperationDefinition(type: PDFOperationType.setStrokeColor, operands: [
            PDFOperandDefinition(name: "c1", type: PDFOperandType.number),
            PDFOperandDefinition(name: "c2", type: PDFOperandType.number),
            PDFOperandDefinition(name: "c3", type: PDFOperandType.number),
            PDFOperandDefinition(name: "c4", type: PDFOperandType.number),
            ]),
        PDFOperationDefinition(type: PDFOperationType.setFillColor, operands: [
            PDFOperandDefinition(name: "c1", type: PDFOperandType.number),
            PDFOperandDefinition(name: "c2", type: PDFOperandType.number),
            PDFOperandDefinition(name: "c3", type: PDFOperandType.number),
            PDFOperandDefinition(name: "c4", type: PDFOperandType.number),
            ]),
        
        PDFOperationDefinition(type: PDFOperationType.setStrokeColorName, operands: [
            PDFOperandDefinition(name: "c1", type: PDFOperandType.number),
            PDFOperandDefinition(name: "c2", type: PDFOperandType.number),
            PDFOperandDefinition(name: "c3", type: PDFOperandType.number),
            PDFOperandDefinition(name: "c4", type: PDFOperandType.number),
            PDFOperandDefinition(name: "name", type: PDFOperandType.name),
            ]),
        PDFOperationDefinition(type: PDFOperationType.setFillColorName, operands: [
            PDFOperandDefinition(name: "c1", type: PDFOperandType.number),
            PDFOperandDefinition(name: "c2", type: PDFOperandType.number),
            PDFOperandDefinition(name: "c3", type: PDFOperandType.number),
            PDFOperandDefinition(name: "c4", type: PDFOperandType.number),
            PDFOperandDefinition(name: "name", type: PDFOperandType.name),
            ]),
        
        PDFOperationDefinition(type: PDFOperationType.strokeColorRGB, operands: [
            PDFOperandDefinition(name: "r", type: PDFOperandType.number),
            PDFOperandDefinition(name: "g", type: PDFOperandType.number),
            PDFOperandDefinition(name: "b", type: PDFOperandType.number),
            ]),
        PDFOperationDefinition(type: PDFOperationType.fillColorRGB, operands: [
            PDFOperandDefinition(name: "r", type: PDFOperandType.number),
            PDFOperandDefinition(name: "g", type: PDFOperandType.number),
            PDFOperandDefinition(name: "b", type: PDFOperandType.number),
            ]),
        PDFOperationDefinition(type: PDFOperationType.strokeColorCMYK, operands: [
            PDFOperandDefinition(name: "c", type: PDFOperandType.number),
            PDFOperandDefinition(name: "m", type: PDFOperandType.number),
            PDFOperandDefinition(name: "y", type: PDFOperandType.number),
            PDFOperandDefinition(name: "k", type: PDFOperandType.number),
            ]),
        PDFOperationDefinition(type: PDFOperationType.fillColorCMYK, operands: [
            PDFOperandDefinition(name: "c", type: PDFOperandType.number),
            PDFOperandDefinition(name: "m", type: PDFOperandType.number),
            PDFOperandDefinition(name: "y", type: PDFOperandType.number),
            PDFOperandDefinition(name: "k", type: PDFOperandType.number),
            ]),
    ]
    
    static var PDF_OPERATION_FOR_TYPE: [PDFOperationType: PDFOperationDefinition] {
        return PDF_OPERATIONS.keyBy({ $0.type })
    }
    
    static var PARSER_FOR_TYPE: [PDFOperationType: CGPDFOperatorCallback] = [
        
        // Graphics State
        PDFOperationType.saveState: { parse(scanner: $0, type: PDFOperationType.saveState, for: bridge(ptr: $1!)) },
        PDFOperationType.restoreState: { parse(scanner: $0, type: PDFOperationType.restoreState, for: bridge(ptr: $1!)) },
        PDFOperationType.setCurrentMatrix: { parse(scanner: $0, type: PDFOperationType.setCurrentMatrix, for: bridge(ptr: $1!)) },
        PDFOperationType.setLineWidth: { parse(scanner: $0, type: PDFOperationType.setLineWidth, for: bridge(ptr: $1!)) },
        PDFOperationType.setLineCap: { parse(scanner: $0, type: PDFOperationType.setLineCap, for: bridge(ptr: $1!)) },
        PDFOperationType.setLineJoin: { parse(scanner: $0, type: PDFOperationType.setLineJoin, for: bridge(ptr: $1!)) },
        PDFOperationType.setMiterLimit: { parse(scanner: $0, type: PDFOperationType.setMiterLimit, for: bridge(ptr: $1!)) },
        PDFOperationType.setDashPattern: { parse(scanner: $0, type: PDFOperationType.setDashPattern, for: bridge(ptr: $1!)) },
        PDFOperationType.setColorRenderingIntent: { parse(scanner: $0, type: PDFOperationType.setColorRenderingIntent, for: bridge(ptr: $1!)) },
        PDFOperationType.setFlatness: { parse(scanner: $0, type: PDFOperationType.setFlatness, for: bridge(ptr: $1!)) },
        PDFOperationType.setState: { parse(scanner: $0, type: PDFOperationType.setState, for: bridge(ptr: $1!)) },
        
        // Path Construction
        PDFOperationType.beginPath: { parse(scanner: $0, type: PDFOperationType.beginPath, for: bridge(ptr: $1!)) },
        PDFOperationType.line: { parse(scanner: $0, type: PDFOperationType.line, for: bridge(ptr: $1!)) },
        PDFOperationType.cubicBezier123: { parse(scanner: $0, type: PDFOperationType.cubicBezier123, for: bridge(ptr: $1!)) },
        PDFOperationType.cubicBezier23: { parse(scanner: $0, type: PDFOperationType.cubicBezier23, for: bridge(ptr: $1!)) },
        PDFOperationType.cubicBezier13: { parse(scanner: $0, type: PDFOperationType.cubicBezier13, for: bridge(ptr: $1!)) },
        PDFOperationType.closePath: { parse(scanner: $0, type: PDFOperationType.closePath, for: bridge(ptr: $1!)) },
        PDFOperationType.rectangle: { parse(scanner: $0, type: PDFOperationType.rectangle, for: bridge(ptr: $1!)) },
        
        // Path Painting
        PDFOperationType.stroke: { parse(scanner: $0, type: PDFOperationType.stroke, for: bridge(ptr: $1!)) },
        PDFOperationType.strokeAndClose: { parse(scanner: $0, type: PDFOperationType.strokeAndClose, for: bridge(ptr: $1!)) },
        PDFOperationType.fill: { parse(scanner: $0, type: PDFOperationType.fill, for: bridge(ptr: $1!)) },
        PDFOperationType.fillAndStroke: { parse(scanner: $0, type: PDFOperationType.fillAndStroke, for: bridge(ptr: $1!)) },
        PDFOperationType.fillAndStrokeEvenOdd: { parse(scanner: $0, type: PDFOperationType.fillAndStrokeEvenOdd, for: bridge(ptr: $1!)) },
        PDFOperationType.closeFillAndStroke: { parse(scanner: $0, type: PDFOperationType.closeFillAndStroke, for: bridge(ptr: $1!)) },
        PDFOperationType.closeFillAndStrokeEvenOdd: { parse(scanner: $0, type: PDFOperationType.closeFillAndStrokeEvenOdd, for: bridge(ptr: $1!)) },
        PDFOperationType.endPathNoop: { parse(scanner: $0, type: PDFOperationType.endPathNoop, for: bridge(ptr: $1!)) },
        
        // Clipping Path
        PDFOperationType.clippingPath: { parse(scanner: $0, type: PDFOperationType.clippingPath, for: bridge(ptr: $1!)) },
        PDFOperationType.clippingPathEvenOdd: { parse(scanner: $0, type: PDFOperationType.clippingPathEvenOdd, for: bridge(ptr: $1!)) },
        
        // Color
        PDFOperationType.strokeColorSpace: { parse(scanner: $0, type: PDFOperationType.strokeColorSpace, for: bridge(ptr: $1!)) },
        PDFOperationType.fillColorSpace: { parse(scanner: $0, type: PDFOperationType.fillColorSpace, for: bridge(ptr: $1!)) },
        PDFOperationType.setStrokeColor: { parse(scanner: $0, type: PDFOperationType.setStrokeColor, for: bridge(ptr: $1!)) },
        PDFOperationType.setFillColor: { parse(scanner: $0, type: PDFOperationType.setFillColor, for: bridge(ptr: $1!)) },
        PDFOperationType.setStrokeColorName: { parse(scanner: $0, type: PDFOperationType.setStrokeColorName, for: bridge(ptr: $1!)) },
        PDFOperationType.setFillColorName: { parse(scanner: $0, type: PDFOperationType.setFillColorName, for: bridge(ptr: $1!)) },
        PDFOperationType.strokeColorRGB: { parse(scanner: $0, type: PDFOperationType.strokeColorRGB, for: bridge(ptr: $1!)) },
        PDFOperationType.fillColorRGB: { parse(scanner: $0, type: PDFOperationType.fillColorRGB, for: bridge(ptr: $1!)) },
        PDFOperationType.strokeColorCMYK: { parse(scanner: $0, type: PDFOperationType.strokeColorCMYK, for: bridge(ptr: $1!)) },
        PDFOperationType.fillColorCMYK: { parse(scanner: $0, type: PDFOperationType.fillColorCMYK, for: bridge(ptr: $1!)) },
    ]
    
    var operations: [PDFOperation] = []
    
    static func parse(scanner: CGPDFScannerRef, type: PDFOperationType, for document: CSPDFDocument) {
        guard let operationDefinition = PDF_OPERATION_FOR_TYPE[type] else { return }
        
        let reversedOperands: [PDFOperandDefinition] = operationDefinition.operands.reversed()
        
        let parsed: [PDFOperandValue] = reversedOperands.map({ operand in
            switch operand.type {
            case .number:
                var value: CGPDFReal = 0
                if !CGPDFScannerPopNumber(scanner, &value) { return PDFOperandValue.null }
                return PDFOperandValue.number(value)
            case .name:
                var value: UnsafePointer<Int8>?
                if !CGPDFScannerPopName(scanner, &value) { return PDFOperandValue.null }
                return PDFOperandValue.name(String(cString: value!))
            }
        }).filter({ !$0.isNull })
        
        let operands: [PDFOperand] = parsed.enumerated().map({ item in
            let definition = reversedOperands[item.offset]
            return PDFOperand(name: definition.name, type: definition.type, value: item.element)
        })
        
        let operation = PDFOperation(type: operationDefinition.type, operands: operands)
        
        document.operations.append(operation)
    }
    
    var cgPDFDocument: CGPDFDocument? = nil
    var cgPDFPage: CGPDFPage? = nil
    var size: CGRect {
        return cgPDFPage?.getBoxRect(CGPDFBox.mediaBox) ?? CGRect.zero
    }
    
    init?(contentsOf url: URL, parsed: Bool) {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        
        self.cgPDFDocument = document
        
        if document.numberOfPages == 0 { return }
        
        guard let page = document.page(at: 1) else { return }
        
        self.cgPDFPage = page
        
        if parsed {
            guard let operatorTable = CGPDFOperatorTableCreate() else { return }
            
            for operationType in CSPDFDocument.PDF_OPERATIONS.map({ $0.type }) {
                CGPDFOperatorTableSetCallback(
                    operatorTable,
                    operationType.rawValue,
                    CSPDFDocument.PARSER_FOR_TYPE[operationType]!
                )
            }
            
            let contentStream = CGPDFContentStreamCreateWithPage(page)
            let pointer = UnsafeMutableRawPointer(mutating: bridge(obj: self))
            let scanner = CGPDFScannerCreate(contentStream, operatorTable, pointer)
            
            CGPDFScannerScan(scanner);
        }
    }
    
    let COLORS = [
        NSColor.red.cgColor,
        NSColor.blue.cgColor,
        NSColor.green.cgColor,
        NSColor.magenta.cgColor,
        NSColor.purple.cgColor,
        NSColor.brown.cgColor,
    ]
    
    class RenderContext {
        var fillColor: CGColor = CGColor.clear
        var strokeColor: CGColor = CGColor.clear
        var lineWidth: CGFloat = 1
        var lineCap: NSBezierPath.LineCapStyle = NSBezierPath.LineCapStyle.buttLineCapStyle
        var lineJoin: NSBezierPath.LineJoinStyle = NSBezierPath.LineJoinStyle.miterLineJoinStyle
        var clippingPath: NSBezierPath? = nil
        var transformation: AffineTransform = AffineTransform.identity
        
        init() {}
        
        func copy() -> RenderContext {
            let context = RenderContext()
            context.fillColor = fillColor
            context.strokeColor = strokeColor
            context.lineWidth = lineWidth
            context.lineCap = lineCap
            context.lineJoin = lineJoin
            context.clippingPath = clippingPath?.copy() as? NSBezierPath
            context.transformation = transformation
            return context
        }
    }
    
    func renderToSketch(scale: CGFloat, translate: CGPoint) -> CSData {
        var layers: [SketchLayer] = []
        
        var stack: [RenderContext] = [RenderContext()]
        var currentPath: NSBezierPath = NSBezierPath()
        
        func context() -> RenderContext { return stack.last! }
        func saveContext() { stack.append(context().copy()) }
        func restoreContext() { stack.removeLast() }
        func terminatePathOperation() {
//            if let clippingPath = context().clippingPath {
//                clippingPath.append(currentPath)
//            } else {
//                context().clippingPath = currentPath
//            }
            
            currentPath = NSBezierPath()
        }
        func currentPathSnapshot() -> NSBezierPath {
            let path = currentPath.copy() as! NSBezierPath
            path.transform(using: context().transformation)
            path.lineCapStyle = context().lineCap
            path.lineJoinStyle = context().lineJoin
            path.lineWidth = context().lineWidth
            return path
        }
        func clippingPathSnapshot() -> NSBezierPath {
            let clippingPath = context().clippingPath ?? NSBezierPath()
            let path = clippingPath.copy() as! NSBezierPath
            path.transform(using: context().transformation)
            //            path.lineCapStyle = context().lineCap
            //            path.lineJoinStyle = context().lineJoin
            //            path.lineWidth = context().lineWidth
            return path
        }
        let convert: CoordinateTransformation = { point in
//            return CGPoint(x: point.x, y: point.y * -self.size.height)
//            let transformed = (point * CGPoint(x: 1, y: -1)) + CGPoint(x: 0, y: self.size.height)
//            Swift.print("\(point.debugDescription) -> \(transformed.debugDescription)")
//            return transformed
            return point
        }
        
        context().transformation.prepend(AffineTransform(translationByX: translate.x, byY: translate.y))
        context().transformation.prepend(AffineTransform(scale: scale))
        context().lineWidth *= scale
        
        loop: for op in operations {
            Swift.print(op.toString())
            
            switch op.type {
            case .saveState: saveContext()
            case .restoreState: restoreContext()
            case .setCurrentMatrix:
                if let a = op.get(number: "a"), let b = op.get(number: "b"), let c = op.get(number: "c"),
                    let d = op.get(number: "d"), let e = op.get(number: "e"), let f = op.get(number: "f")
                {
                    let transformation = AffineTransform(m11: a, m12: b, m21: c, m22: d, tX: e, tY: f)
                    context().transformation.prepend(transformation)
                }
            case .beginPath:
                if let point = op.getPoint("x", "y") {
                    currentPath.move(to: point)
                }
            case .line:
                if let point = op.getPoint("x", "y") {
                    currentPath.line(to: point)
                }
            case .cubicBezier123:
                if let p1 = op.getPoint("x1", "y1"),
                    let p2 = op.getPoint("x2", "y2"),
                    let p3 = op.getPoint("x3", "y3")
                {
                    currentPath.curve(to: p3, controlPoint1: p1, controlPoint2: p2)
                }
            case .rectangle:
                if let point = op.getPoint("x", "y"),
                    let width = op.get(number: "width"),
                    let height = op.get(number: "height")
                {
                    currentPath = NSBezierPath()
                    currentPath.move(to: point)
                    currentPath.line(to: point + CGPoint(x: width, y: 0))
                    currentPath.line(to: point + CGPoint(x: width, y: height))
                    currentPath.line(to: point + CGPoint(x: 0, y: height))
                    currentPath.close()
                }
            case .setLineWidth:
                if let width = op.get(number: "lineWidth") {
                    context().lineWidth = width * scale
                }
            case .setLineCap:
                if let value = op.get(number: "lineCap") {
                    context().lineCap = NSBezierPath.LineCapStyle(rawValue: UInt(value))!
                }
            case .setLineJoin:
                if let value = op.get(number: "lineJoin") {
                    context().lineJoin = NSBezierPath.LineJoinStyle(rawValue: UInt(value))!
                }
            case .closePath:
                currentPath.close()
                
//                let shapeLayer = SketchShapeGroup(
//                    layers: [SketchShapePath(bezierPath: currentPath)],
//                    fills: [SketchFill(color: COLORS[layers.endIndex % COLORS.count])],
//                    borders: [],
//                    hasClippingMask: false
//                )
//                layers.append(shapeLayer)
                
//                currentPath = NSBezierPath()
//                break loop
            case .clippingPath, .clippingPathEvenOdd:
                context().clippingPath = currentPath.copy() as? NSBezierPath
                
//                let shapeLayer = SketchShapeGroup(
//                    layers: [SketchShapePath(bezierPath: currentPath)],
//                    fills: [SketchFill(color: NSColor.green.cgColor)],
//                    borders: [],
//                    hasClippingMask: false
//                )
//                layers.append(shapeLayer)
//                break loop
                
            case .endPathNoop:
                currentPath = NSBezierPath()
            case .setFillColor:
                if let r = op.get(number: "c2"), let g = op.get(number: "c3"), let b = op.get(number: "c4") {
                    context().fillColor = CGColor.init(red: r, green: g, blue: b, alpha: 1.0)
                }
            case .setStrokeColor:
                if let r = op.get(number: "c2"), let g = op.get(number: "c3"), let b = op.get(number: "c4") {
                    context().strokeColor = CGColor.init(red: r, green: g, blue: b, alpha: 1.0)
                }
            case .stroke:
                var sublayers: [SketchLayer] = []
                
                if context().clippingPath != nil {
                    let maskLayer = SketchShapeGroup(
                        layers: [SketchShapePath(bezierPath: clippingPathSnapshot())],
                        fills: [],
                        borders: [],
                        borderOptions: nil,
                        hasClippingMask: true
                    )
                    sublayers.append(maskLayer)
                }
                    
                let shapeLayer = SketchShapeGroup(
                    layers: [SketchShapePath(bezierPath: currentPathSnapshot())],
                    fills: [],
                    borders: [SketchBorder(color: context().strokeColor, thickness: context().lineWidth)],
                    borderOptions: SketchBorderOptions(lineCapStyle: context().lineCap, lineJoinStyle: context().lineJoin),
                    hasClippingMask: false
                )
                sublayers.append(shapeLayer)
                
                let groupLayer = SketchGroup(layers: sublayers)
                layers.append(groupLayer)
                
                terminatePathOperation()
            case .fill:
                var sublayers: [SketchLayer] = []
                
                if context().clippingPath != nil {
                    let maskLayer = SketchShapeGroup(
                        layers: [SketchShapePath(bezierPath: clippingPathSnapshot())],
                        fills: [],
                        borders: [],
                        borderOptions: nil,
                        hasClippingMask: true
                    )
                    sublayers.append(maskLayer)
                }
                
                let shapeLayer = SketchShapeGroup(
                    layers: [SketchShapePath(bezierPath: currentPathSnapshot())],
                    fills: [SketchFill(color: context().fillColor)],
                    borders: [],
                    borderOptions: nil,
                    hasClippingMask: false
                )
                sublayers.append(shapeLayer)
                
                let groupLayer = SketchGroup(layers: sublayers)
                layers.append(groupLayer)
                
                terminatePathOperation()
            default: break
            }
        }
        
        // Create a wrapper group which we can then flip vertically to match the Sketch coordinate system
        let group = SketchGroup(layers: layers)
        var data = group.toData(with: NSRect.zero, transform: convert)
        
//        func printFrames(layer: CSData, depth: Int = 0) {
//            let frame = layer.get(key: "frame")
//            Swift.print(String(repeating: "  ", count: depth), "origin", frame.get(key: "x"), frame.get(key: "y"), "size", frame.get(key: "width"), frame.get(key: "height"))
//            layer.get(key: "layers").arrayValue.forEach({ printFrames(layer: $0, depth: depth + 1) })
//        }
//        printFrames(layer: data)
        
        data["isFlippedVertical"] = true.toData()
        return CSData.Array([data])
    }
}

