import AppKit
import Foundation

private class IconBookVector: NSBox {
  public var inner2Fill = #colorLiteral(red: 0.607843137255, green: 0.607843137255, blue: 0.607843137255, alpha: 1)
  public var innerFill = #colorLiteral(red: 0.607843137255, green: 0.607843137255, blue: 0.607843137255, alpha: 1)
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

    let viewBox = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 16, height: 19))
    let croppedRect = viewBox.size.resized(within: bounds.size, usingResizingMode: resizingMode)
    let scale = croppedRect.width / viewBox.width
    func transform(point: CGPoint) -> CGPoint {
      return CGPoint(x: point.x * scale + croppedRect.minX, y: point.y * scale + croppedRect.minY)
    }
    let outer = NSBezierPath()
    outer.move(to: transform(point: CGPoint(x: 0.292893219, y: 1.70710678)))
    outer.line(to: transform(point: CGPoint(x: 1.70710678, y: 0.292893219)))
    outer.curve(
      to: transform(point: CGPoint(x: 2.41421356, y: 0)),
      controlPoint1: transform(point: CGPoint(x: 1.89464316, y: 0.10535684)),
      controlPoint2: transform(point: CGPoint(x: 2.14899707, y: 4.87194788e-17)))
    outer.line(to: transform(point: CGPoint(x: 13.5857864, y: 0)))
    outer.curve(
      to: transform(point: CGPoint(x: 14.2928932, y: 0.292893219)),
      controlPoint1: transform(point: CGPoint(x: 13.8510029, y: 4.22399647e-16)),
      controlPoint2: transform(point: CGPoint(x: 14.1053568, y: 0.10535684)))
    outer.line(to: transform(point: CGPoint(x: 15.7071068, y: 1.70710678)))
    outer.curve(
      to: transform(point: CGPoint(x: 16, y: 2.41421356)),
      controlPoint1: transform(point: CGPoint(x: 15.8946432, y: 1.89464316)),
      controlPoint2: transform(point: CGPoint(x: 16, y: 2.14899707)))
    outer.line(to: transform(point: CGPoint(x: 16, y: 18)))
    outer.curve(
      to: transform(point: CGPoint(x: 15, y: 19)),
      controlPoint1: transform(point: CGPoint(x: 16, y: 18.5522847)),
      controlPoint2: transform(point: CGPoint(x: 15.5522847, y: 19)))
    outer.line(to: transform(point: CGPoint(x: 1, y: 19)))
    outer.curve(
      to: transform(point: CGPoint(x: 0, y: 18)),
      controlPoint1: transform(point: CGPoint(x: 0.44771525, y: 19)),
      controlPoint2: transform(point: CGPoint(x: 6.76353751e-17, y: 18.5522847)))
    outer.line(to: transform(point: CGPoint(x: 0, y: 2.41421356)))
    outer.curve(
      to: transform(point: CGPoint(x: 0.292893219, y: 1.70710678)),
      controlPoint1: transform(point: CGPoint(x: 6.33654162e-16, y: 2.14899707)),
      controlPoint2: transform(point: CGPoint(x: 0.10535684, y: 1.89464316)))
    outer.close()
    outerFill.setFill()
    outer.fill()
    let inner = NSBezierPath()
    inner.move(to: transform(point: CGPoint(x: 8, y: 4)))
    inner.line(to: transform(point: CGPoint(x: 13, y: 4)))
    inner.line(to: transform(point: CGPoint(x: 13, y: 13)))
    inner.line(to: transform(point: CGPoint(x: 10.5, y: 10.5)))
    inner.line(to: transform(point: CGPoint(x: 8, y: 13)))
    inner.close()
    innerFill.setFill()
    inner.fill()
    let inner2 = NSBezierPath()
    inner2.move(to: transform(point: CGPoint(x: 3.41421356, y: 1)))
    inner2.line(to: transform(point: CGPoint(x: 12.5857864, y: 1)))
    inner2.curve(
      to: transform(point: CGPoint(x: 13.2928932, y: 1.29289322)),
      controlPoint1: transform(point: CGPoint(x: 12.8510029, y: 1)),
      controlPoint2: transform(point: CGPoint(x: 13.1053568, y: 1.10535684)))
    inner2.line(to: transform(point: CGPoint(x: 15, y: 3)))
    inner2.line(to: transform(point: CGPoint(x: 15, y: 3)))
    inner2.line(to: transform(point: CGPoint(x: 1, y: 3)))
    inner2.line(to: transform(point: CGPoint(x: 2.70710678, y: 1.29289322)))
    inner2.curve(
      to: transform(point: CGPoint(x: 3.41421356, y: 1)),
      controlPoint1: transform(point: CGPoint(x: 2.89464316, y: 1.10535684)),
      controlPoint2: transform(point: CGPoint(x: 3.14899707, y: 1)))
    inner2.close()
    inner2Fill.setFill()
    inner2.fill()
  }
}


// MARK: - BookIcon

public class BookIcon: NSBox {

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

  private var vectorGraphicView = IconBookVector()

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
    let vectorGraphicViewWidthAnchorConstraint = vectorGraphicView.widthAnchor.constraint(equalToConstant: 16)

    NSLayoutConstraint.activate([
      vectorGraphicViewLeadingAnchorConstraint,
      vectorGraphicViewCenterYAnchorConstraint,
      vectorGraphicViewHeightAnchorConstraint,
      vectorGraphicViewWidthAnchorConstraint
    ])
  }

  private func update() {
    vectorGraphicView.inner2Fill = #colorLiteral(red: 0.607843137255, green: 0.607843137255, blue: 0.607843137255, alpha: 1)
    vectorGraphicView.innerFill = #colorLiteral(red: 0.607843137255, green: 0.607843137255, blue: 0.607843137255, alpha: 1)
    vectorGraphicView.outerFill = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    vectorGraphicView.outerFill = Colors.iconFill
    vectorGraphicView.innerFill = Colors.iconFillAccent
    vectorGraphicView.inner2Fill = Colors.iconFillAccent
    if selected {
      vectorGraphicView.outerFill = Colors.white
      vectorGraphicView.innerFill = Colors.systemSelection30
      vectorGraphicView.inner2Fill = Colors.systemSelection30
    }
    vectorGraphicView.needsDisplay = true
  }
}

// MARK: - Parameters

extension BookIcon {
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

extension BookIcon {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "BookIcon"
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
