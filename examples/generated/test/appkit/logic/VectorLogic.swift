import AppKit
import Foundation

private class CheckCircleVector: NSBox {
  public var ovalFill = #colorLiteral(red: 0, green: 0.756862745098, blue: 0.129411764706, alpha: 1)
  public var pathStroke = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

  override var isFlipped: Bool {
    return true
  }

  override func draw(_ dirtyRect: CGRect) {
    super.draw(dirtyRect)

    let viewBox = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 24, height: 24))
    let croppedRect = viewBox.size.resized(within: bounds.size)
    let scale = croppedRect.width / viewBox.width
    func transform(point: CGPoint) -> CGPoint {
      return CGPoint(x: point.x * scale + croppedRect.minX, y: point.y * scale + croppedRect.minY)
    }
    let oval = NSBezierPath()
    oval.move(to: transform(point: CGPoint(x: 12, y: 0)))
    oval.line(to: transform(point: CGPoint(x: 12, y: 0)))
    oval.curve(
      to: transform(point: CGPoint(x: 24, y: 12)),
      controlPoint1: transform(point: CGPoint(x: 18.627416998, y: 0)),
      controlPoint2: transform(point: CGPoint(x: 24, y: 5.37258300203)))
    oval.line(to: transform(point: CGPoint(x: 24, y: 12)))
    oval.curve(
      to: transform(point: CGPoint(x: 12, y: 24)),
      controlPoint1: transform(point: CGPoint(x: 24, y: 18.627416998)),
      controlPoint2: transform(point: CGPoint(x: 18.627416998, y: 24)))
    oval.line(to: transform(point: CGPoint(x: 12, y: 24)))
    oval.curve(
      to: transform(point: CGPoint(x: 0, y: 12)),
      controlPoint1: transform(point: CGPoint(x: 5.37258300203, y: 24)),
      controlPoint2: transform(point: CGPoint(x: 0, y: 18.627416998)))
    oval.line(to: transform(point: CGPoint(x: 0, y: 12)))
    oval.curve(
      to: transform(point: CGPoint(x: 12, y: 0)),
      controlPoint1: transform(point: CGPoint(x: 0, y: 5.37258300203)),
      controlPoint2: transform(point: CGPoint(x: 5.37258300203, y: 0)))
    oval.close()
    ovalFill.setFill()
    oval.fill()
    let path = NSBezierPath()
    path.move(to: transform(point: CGPoint(x: 6.5, y: 12.6)))
    path.line(to: transform(point: CGPoint(x: 9.75, y: 15.85)))
    path.line(to: transform(point: CGPoint(x: 17.25, y: 8.35)))
    pathStroke.setStroke()
    path.lineWidth = 2 * scale
    path.lineCapStyle = .roundLineCapStyle
    path.stroke()
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
    checkView.ovalFill = #colorLiteral(red: 0, green: 0.756862745098, blue: 0.129411764706, alpha: 1)
    checkView.pathStroke = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    checkView.ovalFill = Colors.grey300
    if active {
      checkView.ovalFill = Colors.green400
      checkView.pathStroke = Colors.green100
    }
    checkView.needsDisplay = true
  }
}
