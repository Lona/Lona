import AppKit
import Foundation

private class IconFolderVector: NSBox {
  public var g2_g0_path0Fill = #colorLiteral(red: 0.933333333333, green: 0.933333333333, blue: 0.933333333333, alpha: 1)
  public var g2_g0_path0Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
  public var g2_g0_path2Stroke = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
  public var g2_g0_path3Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
  public var g2_g0_rect1Fill = #colorLiteral(red: 0.803921568627, green: 0.803921568627, blue: 0.803921568627, alpha: 1)

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
    let g2_g0_path0 = NSBezierPath()
    g2_g0_path0.move(to: transform(point: CGPoint(x: 1.5, y: 19.5)))
    g2_g0_path0.line(to: transform(point: CGPoint(x: 1.5, y: 5.5)))
    g2_g0_path0.curve(
      to: transform(point: CGPoint(x: 2.5, y: 4.5)),
      controlPoint1: transform(point: CGPoint(x: 1.5, y: 4.94771525)),
      controlPoint2: transform(point: CGPoint(x: 1.94771525, y: 4.5)))
    g2_g0_path0.line(to: transform(point: CGPoint(x: 7.08578644, y: 4.5)))
    g2_g0_path0.curve(
      to: transform(point: CGPoint(x: 7.79289322, y: 4.792893219)),
      controlPoint1: transform(point: CGPoint(x: 7.35100293, y: 4.5)),
      controlPoint2: transform(point: CGPoint(x: 7.60535684, y: 4.60535684)))
    g2_g0_path0.line(to: transform(point: CGPoint(x: 9.20710678, y: 6.20710678)))
    g2_g0_path0.curve(
      to: transform(point: CGPoint(x: 9.91421356, y: 6.5)),
      controlPoint1: transform(point: CGPoint(x: 9.39464316, y: 6.39464316)),
      controlPoint2: transform(point: CGPoint(x: 9.64899707, y: 6.5)))
    g2_g0_path0.line(to: transform(point: CGPoint(x: 20.5, y: 6.5)))
    g2_g0_path0.curve(
      to: transform(point: CGPoint(x: 21.5, y: 7.5)),
      controlPoint1: transform(point: CGPoint(x: 21.0522847, y: 6.5)),
      controlPoint2: transform(point: CGPoint(x: 21.5, y: 6.94771525)))
    g2_g0_path0.line(to: transform(point: CGPoint(x: 21.5, y: 19.5)))
    g2_g0_path0.curve(
      to: transform(point: CGPoint(x: 20.5, y: 20.5)),
      controlPoint1: transform(point: CGPoint(x: 21.5, y: 20.0522847)),
      controlPoint2: transform(point: CGPoint(x: 21.0522847, y: 20.5)))
    g2_g0_path0.line(to: transform(point: CGPoint(x: 2.5, y: 20.5)))
    g2_g0_path0.curve(
      to: transform(point: CGPoint(x: 1.5, y: 19.5)),
      controlPoint1: transform(point: CGPoint(x: 1.94771525, y: 20.5)),
      controlPoint2: transform(point: CGPoint(x: 1.5, y: 20.0522847)))
    g2_g0_path0.close()
    g2_g0_path0Fill.setFill()
    g2_g0_path0Stroke.setStroke()
    g2_g0_path0.fill()
    g2_g0_path0.lineWidth = 1 * scale
    g2_g0_path0.lineCapStyle = .buttLineCapStyle
    g2_g0_path0.stroke()
    let g2_g0_rect1 = NSBezierPath()
    g2_g0_rect1.move(to: transform(point: CGPoint(x: 2, y: 9)))
    g2_g0_rect1.line(to: transform(point: CGPoint(x: 21, y: 9)))
    g2_g0_rect1.curve(
      to: transform(point: CGPoint(x: 21, y: 9)),
      controlPoint1: transform(point: CGPoint(x: 21, y: 9)),
      controlPoint2: transform(point: CGPoint(x: 21, y: 9)))
    g2_g0_rect1.line(to: transform(point: CGPoint(x: 21, y: 20)))
    g2_g0_rect1.curve(
      to: transform(point: CGPoint(x: 21, y: 20)),
      controlPoint1: transform(point: CGPoint(x: 21, y: 20)),
      controlPoint2: transform(point: CGPoint(x: 21, y: 20)))
    g2_g0_rect1.line(to: transform(point: CGPoint(x: 2, y: 20)))
    g2_g0_rect1.curve(
      to: transform(point: CGPoint(x: 2, y: 20)),
      controlPoint1: transform(point: CGPoint(x: 2, y: 20)),
      controlPoint2: transform(point: CGPoint(x: 2, y: 20)))
    g2_g0_rect1.line(to: transform(point: CGPoint(x: 2, y: 9)))
    g2_g0_rect1.curve(
      to: transform(point: CGPoint(x: 2, y: 9)),
      controlPoint1: transform(point: CGPoint(x: 2, y: 9)),
      controlPoint2: transform(point: CGPoint(x: 2, y: 9)))
    g2_g0_rect1.close()
    g2_g0_rect1Fill.setFill()
    g2_g0_rect1.fill()
    let g2_g0_path2 = NSBezierPath()
    g2_g0_path2.move(to: transform(point: CGPoint(x: 2.5, y: 19.5)))
    g2_g0_path2.line(to: transform(point: CGPoint(x: 20.5, y: 19.5)))
    g2_g0_path2Stroke.setStroke()
    g2_g0_path2.lineWidth = 1 * scale
    g2_g0_path2.lineCapStyle = .squareLineCapStyle
    g2_g0_path2.stroke()
    let g2_g0_path3 = NSBezierPath()
    g2_g0_path3.move(to: transform(point: CGPoint(x: 2.5, y: 8.5)))
    g2_g0_path3.line(to: transform(point: CGPoint(x: 20.5, y: 8.5)))
    g2_g0_path3Stroke.setStroke()
    g2_g0_path3.lineWidth = 1 * scale
    g2_g0_path3.lineCapStyle = .squareLineCapStyle
    g2_g0_path3.stroke()
  }
}


// MARK: - FolderIcon

public class FolderIcon: NSBox {

  // MARK: Lifecycle

  public init(selected: Bool) {
    self.selected = selected

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(selected: false)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var selected: Bool { didSet { update() } }

  // MARK: Private

  private var vectorGraphicView = IconFolderVector()

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    vectorGraphicView.boxType = .custom
    vectorGraphicView.borderType = .noBorder
    vectorGraphicView.contentViewMargins = .zero

    addSubview(vectorGraphicView)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    vectorGraphicView.translatesAutoresizingMaskIntoConstraints = false

    let vectorGraphicViewHeightAnchorParentConstraint = vectorGraphicView
      .heightAnchor
      .constraint(lessThanOrEqualTo: heightAnchor)
    let vectorGraphicViewLeadingAnchorConstraint = vectorGraphicView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let vectorGraphicViewCenterYAnchorConstraint = vectorGraphicView.centerYAnchor.constraint(equalTo: centerYAnchor)
    let vectorGraphicViewHeightAnchorConstraint = vectorGraphicView.heightAnchor.constraint(equalToConstant: 24)
    let vectorGraphicViewWidthAnchorConstraint = vectorGraphicView.widthAnchor.constraint(equalToConstant: 24)

    vectorGraphicViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      vectorGraphicViewHeightAnchorParentConstraint,
      vectorGraphicViewLeadingAnchorConstraint,
      vectorGraphicViewCenterYAnchorConstraint,
      vectorGraphicViewHeightAnchorConstraint,
      vectorGraphicViewWidthAnchorConstraint
    ])
  }

  private func update() {
    vectorGraphicView.g2_g0_path0Fill = #colorLiteral(red: 0.933333333333, green: 0.933333333333, blue: 0.933333333333, alpha: 1)
    vectorGraphicView.g2_g0_path0Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
    vectorGraphicView.g2_g0_path2Stroke = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2)
    vectorGraphicView.g2_g0_path3Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
    vectorGraphicView.g2_g0_rect1Fill = #colorLiteral(red: 0.803921568627, green: 0.803921568627, blue: 0.803921568627, alpha: 1)
    if selected {
      vectorGraphicView.g2_g0_rect1Fill = Colors.selectedIcon
      vectorGraphicView.g2_g0_path0Stroke = Colors.selectedIconStroke
      vectorGraphicView.g2_g0_path0Fill = Colors.selectedIcon
      vectorGraphicView.g2_g0_path2Stroke = Colors.transparent
      vectorGraphicView.g2_g0_path3Stroke = Colors.selectedIconStroke
    }
    vectorGraphicView.needsDisplay = true
  }
}
