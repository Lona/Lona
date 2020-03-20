import AppKit
import Foundation

private class IconFile2Vector: NSBox {
  public var inner2Fill = #colorLiteral(red: 0, green: 0.56862745098, blue: 1, alpha: 1)
  public var inner3Fill = #colorLiteral(red: 0, green: 0.56862745098, blue: 1, alpha: 1)
  public var innerFill = #colorLiteral(red: 0, green: 0.56862745098, blue: 1, alpha: 1)
  public var outerFill = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

  override var isFlipped: Bool {
    return true
  }

  var resizingMode = CGSize.ResizingMode.scaleAspectFill {
    didSet {
      if resizingMode != oldValue {
        needsDisplay = true
      }
    }
  }

  override func draw(_ dirtyRect: CGRect) {
    super.draw(dirtyRect)

    let viewBox = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 13, height: 19))
    let croppedRect = viewBox.size.resized(within: bounds.size, usingResizingMode: resizingMode)
    let scale = croppedRect.width / viewBox.width
    func transform(point: CGPoint) -> CGPoint {
      return CGPoint(x: point.x * scale + croppedRect.minX, y: point.y * scale + croppedRect.minY)
    }
    let outer = NSBezierPath()
    outer.move(to: transform(point: CGPoint(x: 1, y: 0)))
    outer.line(to: transform(point: CGPoint(x: 8.17157288, y: 0)))
    outer.curve(
      to: transform(point: CGPoint(x: 9.58578644, y: 0.585786438)),
      controlPoint1: transform(point: CGPoint(x: 8.70200585, y: -9.74389576e-17)),
      controlPoint2: transform(point: CGPoint(x: 9.21071368, y: 0.210713681)))
    outer.line(to: transform(point: CGPoint(x: 12.4142136, y: 3.41421356)))
    outer.curve(
      to: transform(point: CGPoint(x: 13, y: 4.82842712)),
      controlPoint1: transform(point: CGPoint(x: 12.7892863, y: 3.78928632)),
      controlPoint2: transform(point: CGPoint(x: 13, y: 4.29799415)))
    outer.line(to: transform(point: CGPoint(x: 13, y: 18)))
    outer.curve(
      to: transform(point: CGPoint(x: 12, y: 19)),
      controlPoint1: transform(point: CGPoint(x: 13, y: 18.5522847)),
      controlPoint2: transform(point: CGPoint(x: 12.5522847, y: 19)))
    outer.line(to: transform(point: CGPoint(x: 1, y: 19)))
    outer.curve(
      to: transform(point: CGPoint(x: 0, y: 18)),
      controlPoint1: transform(point: CGPoint(x: 0.44771525, y: 19)),
      controlPoint2: transform(point: CGPoint(x: 6.76353751e-17, y: 18.5522847)))
    outer.line(to: transform(point: CGPoint(x: 0, y: 1)))
    outer.curve(
      to: transform(point: CGPoint(x: 1, y: 0)),
      controlPoint1: transform(point: CGPoint(x: -6.76353751e-17, y: 0.44771525)),
      controlPoint2: transform(point: CGPoint(x: 0.44771525, y: 1.01453063e-16)))
    outer.close()
    outerFill.setFill()
    outer.fill()
    let inner = NSBezierPath()
    inner.move(to: transform(point: CGPoint(x: 3, y: 8)))
    inner.line(to: transform(point: CGPoint(x: 10, y: 8)))
    inner.curve(
      to: transform(point: CGPoint(x: 10, y: 8)),
      controlPoint1: transform(point: CGPoint(x: 10, y: 8)),
      controlPoint2: transform(point: CGPoint(x: 10, y: 8)))
    inner.line(to: transform(point: CGPoint(x: 10, y: 9)))
    inner.curve(
      to: transform(point: CGPoint(x: 10, y: 9)),
      controlPoint1: transform(point: CGPoint(x: 10, y: 9)),
      controlPoint2: transform(point: CGPoint(x: 10, y: 9)))
    inner.line(to: transform(point: CGPoint(x: 3, y: 9)))
    inner.curve(
      to: transform(point: CGPoint(x: 3, y: 9)),
      controlPoint1: transform(point: CGPoint(x: 3, y: 9)),
      controlPoint2: transform(point: CGPoint(x: 3, y: 9)))
    inner.line(to: transform(point: CGPoint(x: 3, y: 8)))
    inner.curve(
      to: transform(point: CGPoint(x: 3, y: 8)),
      controlPoint1: transform(point: CGPoint(x: 3, y: 8)),
      controlPoint2: transform(point: CGPoint(x: 3, y: 8)))
    inner.close()
    innerFill.setFill()
    inner.fill()
    let inner2 = NSBezierPath()
    inner2.move(to: transform(point: CGPoint(x: 3, y: 10)))
    inner2.line(to: transform(point: CGPoint(x: 10, y: 10)))
    inner2.curve(
      to: transform(point: CGPoint(x: 10, y: 10)),
      controlPoint1: transform(point: CGPoint(x: 10, y: 10)),
      controlPoint2: transform(point: CGPoint(x: 10, y: 10)))
    inner2.line(to: transform(point: CGPoint(x: 10, y: 11)))
    inner2.curve(
      to: transform(point: CGPoint(x: 10, y: 11)),
      controlPoint1: transform(point: CGPoint(x: 10, y: 11)),
      controlPoint2: transform(point: CGPoint(x: 10, y: 11)))
    inner2.line(to: transform(point: CGPoint(x: 3, y: 11)))
    inner2.curve(
      to: transform(point: CGPoint(x: 3, y: 11)),
      controlPoint1: transform(point: CGPoint(x: 3, y: 11)),
      controlPoint2: transform(point: CGPoint(x: 3, y: 11)))
    inner2.line(to: transform(point: CGPoint(x: 3, y: 10)))
    inner2.curve(
      to: transform(point: CGPoint(x: 3, y: 10)),
      controlPoint1: transform(point: CGPoint(x: 3, y: 10)),
      controlPoint2: transform(point: CGPoint(x: 3, y: 10)))
    inner2.close()
    inner2Fill.setFill()
    inner2.fill()
    let inner3 = NSBezierPath()
    inner3.move(to: transform(point: CGPoint(x: 3, y: 12)))
    inner3.line(to: transform(point: CGPoint(x: 10, y: 12)))
    inner3.curve(
      to: transform(point: CGPoint(x: 10, y: 12)),
      controlPoint1: transform(point: CGPoint(x: 10, y: 12)),
      controlPoint2: transform(point: CGPoint(x: 10, y: 12)))
    inner3.line(to: transform(point: CGPoint(x: 10, y: 13)))
    inner3.curve(
      to: transform(point: CGPoint(x: 10, y: 13)),
      controlPoint1: transform(point: CGPoint(x: 10, y: 13)),
      controlPoint2: transform(point: CGPoint(x: 10, y: 13)))
    inner3.line(to: transform(point: CGPoint(x: 3, y: 13)))
    inner3.curve(
      to: transform(point: CGPoint(x: 3, y: 13)),
      controlPoint1: transform(point: CGPoint(x: 3, y: 13)),
      controlPoint2: transform(point: CGPoint(x: 3, y: 13)))
    inner3.line(to: transform(point: CGPoint(x: 3, y: 12)))
    inner3.curve(
      to: transform(point: CGPoint(x: 3, y: 12)),
      controlPoint1: transform(point: CGPoint(x: 3, y: 12)),
      controlPoint2: transform(point: CGPoint(x: 3, y: 12)))
    inner3.close()
    inner3Fill.setFill()
    inner3.fill()
  }
}


// MARK: - FileIcon

public class FileIcon: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(selected: Bool) {
    self.init(Parameters(selected: selected))
  }

  public convenience init() {
    self.init(Parameters())
  }

  public required init?(coder aDecoder: NSCoder) {
    self.parameters = Parameters()

    super.init(coder: aDecoder)

    setUpViews()
    setUpConstraints()

    update()
  }

  // MARK: Public

  public var selected: Bool {
    get { return parameters.selected }
    set {
      if parameters.selected != newValue {
        parameters.selected = newValue
      }
    }
  }

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private var vectorGraphicView = IconFile2Vector()

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    vectorGraphicView.boxType = .custom
    vectorGraphicView.borderType = .noBorder
    vectorGraphicView.contentViewMargins = .zero

    addSubview(vectorGraphicView)

    vectorGraphicView.resizingMode = .scaleAspectFit
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    vectorGraphicView.translatesAutoresizingMaskIntoConstraints = false

    let vectorGraphicViewLeadingAnchorConstraint = vectorGraphicView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: 5)
    let vectorGraphicViewCenterYAnchorConstraint = vectorGraphicView.centerYAnchor.constraint(equalTo: centerYAnchor)
    let vectorGraphicViewHeightAnchorConstraint = vectorGraphicView.heightAnchor.constraint(equalToConstant: 19)
    let vectorGraphicViewWidthAnchorConstraint = vectorGraphicView.widthAnchor.constraint(equalToConstant: 13)

    NSLayoutConstraint.activate([
      vectorGraphicViewLeadingAnchorConstraint,
      vectorGraphicViewCenterYAnchorConstraint,
      vectorGraphicViewHeightAnchorConstraint,
      vectorGraphicViewWidthAnchorConstraint
    ])
  }

  private func update() {
    vectorGraphicView.inner2Fill = #colorLiteral(red: 0, green: 0.56862745098, blue: 1, alpha: 1)
    vectorGraphicView.inner3Fill = #colorLiteral(red: 0, green: 0.56862745098, blue: 1, alpha: 1)
    vectorGraphicView.innerFill = #colorLiteral(red: 0, green: 0.56862745098, blue: 1, alpha: 1)
    vectorGraphicView.outerFill = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    vectorGraphicView.outerFill = Colors.iconFill
    vectorGraphicView.innerFill = Colors.iconFillAccent
    vectorGraphicView.inner2Fill = Colors.iconFillAccent
    vectorGraphicView.inner3Fill = Colors.iconFillAccent
    if selected {
      vectorGraphicView.outerFill = Colors.white
      vectorGraphicView.innerFill = Colors.systemSelection30
      vectorGraphicView.inner2Fill = Colors.systemSelection30
      vectorGraphicView.inner3Fill = Colors.systemSelection30
    }
    vectorGraphicView.needsDisplay = true
  }
}

// MARK: - Parameters

extension FileIcon {
  public struct Parameters: Equatable {
    public var selected: Bool

    public init(selected: Bool) {
      self.selected = selected
    }

    public init() {
      self.init(selected: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.selected == rhs.selected
    }
  }
}

// MARK: - Model

extension FileIcon {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "FileIcon"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(selected: Bool) {
      self.init(Parameters(selected: selected))
    }

    public init() {
      self.init(selected: false)
    }
  }
}
