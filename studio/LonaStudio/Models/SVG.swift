//
//  SVG.swift
//  LonaStudio
//
//  Created by Devin Abbott on 10/18/18.
//  Copyright © 2018 Devin Abbott. All rights reserved.
//

import AppKit
import Foundation

extension NSBezierPath.LineCapStyle: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)

        switch value {
        case "butt":
            self = .buttLineCapStyle
        case "round":
            self = .roundLineCapStyle
        case "square":
            self = .squareLineCapStyle
        default:
            self = .buttLineCapStyle
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .buttLineCapStyle:
            try container.encode("butt")
        case .roundLineCapStyle:
            try container.encode("round")
        case .squareLineCapStyle:
            try container.encode("square")
        }
    }
}

public enum SVG {
    public struct Move: Codable {
        public var to: Point
    }

    public struct Line: Codable {
        public var to: Point
    }

    public struct QuadCurve: Codable {
        public var to: Point
        public var controlPoint: Point
    }

    public struct CubicCurve: Codable {
        public var to: Point
        public var controlPoint1: Point
        public var controlPoint2: Point
    }

    public struct Rect: Codable {
        public var x: CGFloat
        public var y: CGFloat
        public var width: CGFloat
        public var height: CGFloat
    }

    public struct Point: Codable {
        public var x: CGFloat
        public var y: CGFloat
    }

    public struct Size: Codable {
        public var width: CGFloat
        public var height: CGFloat
    }

    struct Style: Codable {
        var fill: String?
        var stroke: String?
        var strokeWidth: CGFloat
        var strokeLineCap: NSBezierPath.LineCapStyle
    }

    struct CircleParams: Codable {
        var center: Point
        var radius: CGFloat
        var style: Style
    }

    public enum PathCommand: Codable {
        case move(Move)
        case line(Line)
        case quadCurve(QuadCurve)
        case cubicCurve(CubicCurve)
        case close

        // MARK: Codable

        public enum CodingKeys: CodingKey {
            case type
            case data
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "move":
                self = .move(try container.decode(Move.self, forKey: .data))
            case "line":
                self = .line(try container.decode(Line.self, forKey: .data))
            case "quadCurve":
                self = .quadCurve(try container.decode(QuadCurve.self, forKey: .data))
            case "cubicCurve":
                self = .cubicCurve(try container.decode(CubicCurve.self, forKey: .data))
            case "close":
                self = .close
            default:
                fatalError("Failed to decode enum due to invalid case type.")
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
            case .move(let value):
                try container.encode("move", forKey: .type)
                try container.encode(value, forKey: .data)
            case .line(let value):
                try container.encode("line", forKey: .type)
                try container.encode(value, forKey: .data)
            case .quadCurve(let value):
                try container.encode("quadCurve", forKey: .type)
                try container.encode(value, forKey: .data)
            case .cubicCurve(let value):
                try container.encode("cubicCurve", forKey: .type)
                try container.encode(value, forKey: .data)
            case .close:
                try container.encode("close", forKey: .type)
            }
        }
    }

    public struct PathParams: Codable {
        var commands: [PathCommand]
        var style: Style
    }

    public struct SVGParams: Codable {
        var viewBox: Rect?
    }

    public struct Svg: Codable {
        public var elementPath: Array<String>
        public var params: SVGParams
        public var children: Array<Node>
    }

    public struct Path: Codable {
        public var elementPath: Array<String>
        public var params: PathParams
    }

    public enum Node: Codable {
        case svg(Svg)
        case path(Path)

        // MARK: Codable

        public enum CodingKeys: CodingKey {
            case type
            case data
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)

            switch type {
            case "svg":
                self = .svg(try container.decode(Svg.self, forKey: .data))
            case "path":
                self = .path(try container.decode(Path.self, forKey: .data))
            default:
                fatalError("Failed to decode enum due to invalid case type.")
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            switch self {
            case .svg(let value):
                try container.encode("svg", forKey: .type)
                try container.encode(value, forKey: .data)
            case .path(let value):
                try container.encode("path", forKey: .type)
                try container.encode(value, forKey: .data)
            }
        }
    }
}

extension SVG.Rect {
    var size: CGSize { return CGSize(width: width, height: height) }
    var origin: CGPoint { return CGPoint(x: x, y: y) }
    var cgRect: CGRect { return CGRect(origin: origin, size: size) }
}

extension SVG.Point {
    var cgPoint: CGPoint { return CGPoint(x: x, y: y) }
}

// https://stackoverflow.com/questions/44103678/drawing-quad-curve-in-os-x-app
extension NSBezierPath {
    func quadCurve(to endPoint: CGPoint, controlPoint: CGPoint) {
        let startPoint = self.currentPoint
        let controlPoint1 = CGPoint(
            x: (startPoint.x + (controlPoint.x - startPoint.x) * 2.0 / 3.0),
            y: (startPoint.y + (controlPoint.y - startPoint.y) * 2.0 / 3.0))
        let controlPoint2 = CGPoint(
            x: (endPoint.x + (controlPoint.x - endPoint.x) * 2.0 / 3.0),
            y: (endPoint.y + (controlPoint.y - endPoint.y) * 2.0 / 3.0))
        curve(to: endPoint, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
    }
}

extension SVG.Node {
    func image(size: CGSize) -> NSImage? {
        guard case .svg(let svg) = self else { return nil }

        let viewBox = svg.params.viewBox?.cgRect ?? CGRect(origin: .zero, size: size)
        let croppedRect = viewBox.size.crop(within: size)
        let scale = croppedRect.width / viewBox.width

        func transform(point: CGPoint) -> CGPoint {
            return CGPoint(x: point.x * scale + croppedRect.minX, y: point.y * scale + croppedRect.minY)
        }

        func buildPath(from commands: [SVG.PathCommand]) -> NSBezierPath {
            let path = NSBezierPath()

            for command in commands {
                switch command {
                case .close:
                    path.close()
                case .move(let data):
                    path.move(to: transform(point: data.to.cgPoint))
                case .line(let data):
                    path.line(to: transform(point: data.to.cgPoint))
                case .quadCurve(let data):
                    path.quadCurve(
                        to: transform(point: data.to.cgPoint),
                        controlPoint: transform(point: data.controlPoint.cgPoint))
                case .cubicCurve(let data):
                    path.curve(
                        to: transform(point: data.to.cgPoint),
                        controlPoint1: transform(point: data.controlPoint1.cgPoint),
                        controlPoint2: transform(point: data.controlPoint2.cgPoint))
                }
            }

            return path
        }

        func draw(node: SVG.Node) {
            switch node {
            case .svg(let data):
                data.children.forEach(draw)
            case .path(let data):
                let path = buildPath(from: data.params.commands)
                if let fill = data.params.style.fill, let color = NSColor.parse(css: fill) {
                    color.setFill()
                    path.fill()
                }
                if let stroke = data.params.style.stroke, let color = NSColor.parse(css: stroke) {
                    color.setStroke()
                    path.lineWidth = data.params.style.strokeWidth * scale
                    path.lineCapStyle = data.params.style.strokeLineCap
                    path.stroke()
                }
            }
        }

        return NSImage(size: size, flipped: true, drawingHandler: { rect in
            NSGraphicsContext.saveGraphicsState()

            draw(node: self)

            NSGraphicsContext.restoreGraphicsState()

            return true
        })
    }
}

extension SVG {
    public static func render(contentsOf url: URL, size: CGSize, successHandler: @escaping (NSImage) -> Void) {
        guard size != .zero else { return }

        guard let compilerPath = CSUserPreferences.compilerURL?.path else { return }

        LonaNode.run(
            arguments: [compilerPath, "convertSvg", url.path],
            inputData: nil,
            onSuccess: { result in
                guard let result = result else { return }

                // TODO: No need to convert back and forth from data. Compiler should return data.
                guard let data = result.data(using: .utf8) else { return }

                do {
                    let svg = try JSONDecoder().decode(SVG.Node.self, from: data)

                    DispatchQueue.main.async {
                        guard let image = svg.image(size: size) else { return }
                        successHandler(image)
                    }
                } catch let e {
                    Swift.print("Failed to load svg", e)
                }
        }, onFailure: { code, message in
            Swift.print("Failed", code, message as Any)
        })
    }
}
