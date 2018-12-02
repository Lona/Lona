import UIKit
import Foundation

private class CheckCircleVector: UIView {
  public var ovalFill = #colorLiteral(red: 0, green: 0.756862745098, blue: 0.129411764706, alpha: 1)
  public var pathStroke = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

  var resizingMode = CGSize.ResizingMode.scaleAspectFill {
    didSet {
      if resizingMode != oldValue {
        setNeedsDisplay()
      }
    }
  }

  override func draw(_ dirtyRect: CGRect) {
    let viewBox = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 24, height: 24))
    let croppedRect = viewBox.size.resized(within: bounds.size, usingResizingMode: resizingMode)
    let scale = croppedRect.width / viewBox.width
    func transform(point: CGPoint) -> CGPoint {
      return CGPoint(x: point.x * scale + croppedRect.minX, y: point.y * scale + croppedRect.minY)
    }
    let oval = UIBezierPath()
    oval.move(to: transform(point: CGPoint(x: 12, y: 0)))
    oval.addLine(to: transform(point: CGPoint(x: 12, y: 0)))
    oval.addCurve(
      to: transform(point: CGPoint(x: 24, y: 12)),
      controlPoint1: transform(point: CGPoint(x: 18.627416998, y: 0)),
      controlPoint2: transform(point: CGPoint(x: 24, y: 5.37258300203)))
    oval.addLine(to: transform(point: CGPoint(x: 24, y: 12)))
    oval.addCurve(
      to: transform(point: CGPoint(x: 12, y: 24)),
      controlPoint1: transform(point: CGPoint(x: 24, y: 18.627416998)),
      controlPoint2: transform(point: CGPoint(x: 18.627416998, y: 24)))
    oval.addLine(to: transform(point: CGPoint(x: 12, y: 24)))
    oval.addCurve(
      to: transform(point: CGPoint(x: 0, y: 12)),
      controlPoint1: transform(point: CGPoint(x: 5.37258300203, y: 24)),
      controlPoint2: transform(point: CGPoint(x: 0, y: 18.627416998)))
    oval.addLine(to: transform(point: CGPoint(x: 0, y: 12)))
    oval.addCurve(
      to: transform(point: CGPoint(x: 12, y: 0)),
      controlPoint1: transform(point: CGPoint(x: 0, y: 5.37258300203)),
      controlPoint2: transform(point: CGPoint(x: 5.37258300203, y: 0)))
    oval.close()
    ovalFill.setFill()
    oval.fill()
    let path = UIBezierPath()
    path.move(to: transform(point: CGPoint(x: 6.5, y: 12.6)))
    path.addLine(to: transform(point: CGPoint(x: 9.75, y: 15.85)))
    path.addLine(to: transform(point: CGPoint(x: 17.25, y: 8.35)))
    pathStroke.setStroke()
    path.lineWidth = 2 * scale
    path.lineCapStyle = .round
    path.stroke()
  }
}


// MARK: - RepeatedVector

public class RepeatedVector: UIView {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(active: Bool) {
    self.init(Parameters(active: active))
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

  public var active: Bool {
    get { return parameters.active }
    set { parameters.active = newValue }
  }

  public var parameters: Parameters { didSet { update() } }

  // MARK: Private

  private var checkView = CheckCircleVector()
  private var anotherCheckView = CheckCircleVector()

  private func setUpViews() {
    checkView.isUserInteractionEnabled = false
    checkView.isOpaque = false
    anotherCheckView.isUserInteractionEnabled = false
    anotherCheckView.isOpaque = false

    addSubview(checkView)
    addSubview(anotherCheckView)

    checkView.resizingMode = .scaleAspectFit
    anotherCheckView.resizingMode = .scaleAspectFit
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    checkView.translatesAutoresizingMaskIntoConstraints = false
    anotherCheckView.translatesAutoresizingMaskIntoConstraints = false

    let checkViewHeightAnchorParentConstraint = checkView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor)
    let anotherCheckViewHeightAnchorParentConstraint = anotherCheckView
      .heightAnchor
      .constraint(lessThanOrEqualTo: heightAnchor)
    let checkViewLeadingAnchorConstraint = checkView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let checkViewTopAnchorConstraint = checkView.topAnchor.constraint(equalTo: topAnchor)
    let anotherCheckViewLeadingAnchorConstraint = anotherCheckView
      .leadingAnchor
      .constraint(equalTo: checkView.trailingAnchor)
    let anotherCheckViewTopAnchorConstraint = anotherCheckView.topAnchor.constraint(equalTo: topAnchor)
    let checkViewHeightAnchorConstraint = checkView.heightAnchor.constraint(equalToConstant: 100)
    let checkViewWidthAnchorConstraint = checkView.widthAnchor.constraint(equalToConstant: 100)
    let anotherCheckViewHeightAnchorConstraint = anotherCheckView.heightAnchor.constraint(equalToConstant: 100)
    let anotherCheckViewWidthAnchorConstraint = anotherCheckView.widthAnchor.constraint(equalToConstant: 100)

    checkViewHeightAnchorParentConstraint.priority = UILayoutPriority.defaultLow
    anotherCheckViewHeightAnchorParentConstraint.priority = UILayoutPriority.defaultLow

    NSLayoutConstraint.activate([
      checkViewHeightAnchorParentConstraint,
      anotherCheckViewHeightAnchorParentConstraint,
      checkViewLeadingAnchorConstraint,
      checkViewTopAnchorConstraint,
      anotherCheckViewLeadingAnchorConstraint,
      anotherCheckViewTopAnchorConstraint,
      checkViewHeightAnchorConstraint,
      checkViewWidthAnchorConstraint,
      anotherCheckViewHeightAnchorConstraint,
      anotherCheckViewWidthAnchorConstraint
    ])
  }

  private func update() {
    checkView.ovalFill = #colorLiteral(red: 0, green: 0.756862745098, blue: 0.129411764706, alpha: 1)
    anotherCheckView.pathStroke = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    checkView.ovalFill = Colors.grey300
    if active {
      checkView.ovalFill = Colors.green400
    }
    anotherCheckView.pathStroke = Colors.green800
    checkView.setNeedsDisplay()
    anotherCheckView.setNeedsDisplay()
  }
}

// MARK: - Parameters

extension RepeatedVector {
  public struct Parameters: Equatable {
    public var active: Bool

    public init(active: Bool) {
      self.active = active
    }

    public init() {
      self.init(active: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.active == rhs.active
    }
  }
}

// MARK: - Model

extension RepeatedVector {
  public struct Model: LonaViewModel, Equatable {
    public var parameters: Parameters
    public var type: String {
      return "RepeatedVector"
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(active: Bool) {
      self.init(Parameters(active: active))
    }

    public init() {
      self.init(active: false)
    }
  }
}
