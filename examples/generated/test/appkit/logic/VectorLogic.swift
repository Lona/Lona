import AppKit
import Foundation

private class CheckCircleVector: NSBox {
  public var g0_circle0Fill = #colorLiteral(red: 0, green: 0.756862745098, blue: 0.129411764706, alpha: 1) { didSet { needsDisplay = true } }
  public var g0_polyline1Stroke = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) { didSet { needsDisplay = true } }

  override var isFlipped: Bool {
    return true
  }

  override func draw(_ dirtyRect: CGRect) {
    super.draw(dirtyRect)

    let viewBox = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 24, height: 24))
    let croppedRect = viewBox.size.crop(within: bounds.size)
    let scale = croppedRect.width / viewBox.width
    func transform(point: CGPoint) -> CGPoint {
      return CGPoint(x: point.x * scale + croppedRect.minX, y: point.y * scale + croppedRect.minY)
    }
    let g0_circle0 = NSBezierPath()
    g0_circle0.move(to: transform(point: CGPoint(x: 12, y: 0)))
    g0_circle0.line(to: transform(point: CGPoint(x: 12, y: 0)))
    g0_circle0.curve(
      to: transform(point: CGPoint(x: 24, y: 12)),
      controlPoint1: transform(point: CGPoint(x: 18.627416998, y: 0)),
      controlPoint2: transform(point: CGPoint(x: 24, y: 5.37258300203)))
    g0_circle0.line(to: transform(point: CGPoint(x: 24, y: 12)))
    g0_circle0.curve(
      to: transform(point: CGPoint(x: 12, y: 24)),
      controlPoint1: transform(point: CGPoint(x: 24, y: 18.627416998)),
      controlPoint2: transform(point: CGPoint(x: 18.627416998, y: 24)))
    g0_circle0.line(to: transform(point: CGPoint(x: 12, y: 24)))
    g0_circle0.curve(
      to: transform(point: CGPoint(x: 0, y: 12)),
      controlPoint1: transform(point: CGPoint(x: 5.37258300203, y: 24)),
      controlPoint2: transform(point: CGPoint(x: 0, y: 18.627416998)))
    g0_circle0.line(to: transform(point: CGPoint(x: 0, y: 12)))
    g0_circle0.curve(
      to: transform(point: CGPoint(x: 12, y: 0)),
      controlPoint1: transform(point: CGPoint(x: 0, y: 5.37258300203)),
      controlPoint2: transform(point: CGPoint(x: 5.37258300203, y: 0)))
    g0_circle0.close()
    g0_circle0Fill.setFill()
    g0_circle0.fill()
    let g0_polyline1 = NSBezierPath()
    g0_polyline1.move(to: transform(point: CGPoint(x: 6.5, y: 12.6)))
    g0_polyline1.line(to: transform(point: CGPoint(x: 9.75, y: 15.85)))
    g0_polyline1.line(to: transform(point: CGPoint(x: 17.25, y: 8.35)))
    g0_polyline1Stroke.setStroke()
    g0_polyline1.lineWidth = 2 * scale
    g0_polyline1.lineCapStyle = .roundLineCapStyle
    g0_polyline1.stroke()
  }
}


// MARK: - VectorLogic

public class VectorLogic: NSBox {

  // MARK: Lifecycle

  public init(active: Bool) {
    self.active = active

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(active: false)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var active: Bool { didSet { update() } }

  // MARK: Private

  private var checkView = CheckCircleVector()

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    checkView.boxType = .custom
    checkView.borderType = .noBorder
    checkView.contentViewMargins = .zero

    addSubview(checkView)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    checkView.translatesAutoresizingMaskIntoConstraints = false

    let checkViewTopAnchorConstraint = checkView.topAnchor.constraint(equalTo: topAnchor)
    let checkViewBottomAnchorConstraint = checkView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let checkViewLeadingAnchorConstraint = checkView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let checkViewHeightAnchorConstraint = checkView.heightAnchor.constraint(equalToConstant: 100)
    let checkViewWidthAnchorConstraint = checkView.widthAnchor.constraint(equalToConstant: 100)

    NSLayoutConstraint.activate([
      checkViewTopAnchorConstraint,
      checkViewBottomAnchorConstraint,
      checkViewLeadingAnchorConstraint,
      checkViewHeightAnchorConstraint,
      checkViewWidthAnchorConstraint
    ])
  }

  private func update() {
    if active == false {
      checkView.g0_circle0Fill = Colors.grey300
    }
    if active {
      checkView.g0_circle0Fill = Colors.green400
      checkView.g0_polyline1Stroke = Colors.green100
    }
  }
}
