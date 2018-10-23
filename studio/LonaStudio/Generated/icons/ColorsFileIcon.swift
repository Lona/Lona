import AppKit
import Foundation

private class IconColorsFileVector: NSBox {
  public var g2_g0_path0Fill = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
  public var g2_g0_path0Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
  public var g2_g0_path2Fill = #colorLiteral(red: 0.933333333333, green: 0.933333333333, blue: 0.933333333333, alpha: 1)
  public var g2_g0_path2Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
  public var g2_rect1Fill = #colorLiteral(red: 0.933333333333, green: 0.933333333333, blue: 0.933333333333, alpha: 1)
  public var g2_rect1Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
  public var g2_rect2Fill = #colorLiteral(red: 0.933333333333, green: 0.933333333333, blue: 0.933333333333, alpha: 1)
  public var g2_rect2Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
  public var g2_rect3Fill = #colorLiteral(red: 0.933333333333, green: 0.933333333333, blue: 0.933333333333, alpha: 1)
  public var g2_rect3Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
  public var g2_rect4Fill = #colorLiteral(red: 0.933333333333, green: 0.933333333333, blue: 0.933333333333, alpha: 1)
  public var g2_rect4Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)

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
    g2_g0_path0.move(to: transform(point: CGPoint(x: 5.5, y: 2.5)))
    g2_g0_path0.line(to: transform(point: CGPoint(x: 12.67157288, y: 2.5)))
    g2_g0_path0.curve(
      to: transform(point: CGPoint(x: 14.0857864, y: 3.08578644)),
      controlPoint1: transform(point: CGPoint(x: 13.20200585, y: 2.5)),
      controlPoint2: transform(point: CGPoint(x: 13.71071368, y: 2.710713681)))
    g2_g0_path0.line(to: transform(point: CGPoint(x: 17.9142136, y: 6.91421356)))
    g2_g0_path0.curve(
      to: transform(point: CGPoint(x: 18.5, y: 8.32842712)),
      controlPoint1: transform(point: CGPoint(x: 18.2892863, y: 7.28928632)),
      controlPoint2: transform(point: CGPoint(x: 18.5, y: 7.79799415)))
    g2_g0_path0.line(to: transform(point: CGPoint(x: 18.5, y: 20.5)))
    g2_g0_path0.curve(
      to: transform(point: CGPoint(x: 17.5, y: 21.5)),
      controlPoint1: transform(point: CGPoint(x: 18.5, y: 21.0522847)),
      controlPoint2: transform(point: CGPoint(x: 18.0522847, y: 21.5)))
    g2_g0_path0.line(to: transform(point: CGPoint(x: 5.5, y: 21.5)))
    g2_g0_path0.curve(
      to: transform(point: CGPoint(x: 4.5, y: 20.5)),
      controlPoint1: transform(point: CGPoint(x: 4.94771525, y: 21.5)),
      controlPoint2: transform(point: CGPoint(x: 4.5, y: 21.0522847)))
    g2_g0_path0.line(to: transform(point: CGPoint(x: 4.5, y: 3.5)))
    g2_g0_path0.curve(
      to: transform(point: CGPoint(x: 5.5, y: 2.5)),
      controlPoint1: transform(point: CGPoint(x: 4.5, y: 2.94771525)),
      controlPoint2: transform(point: CGPoint(x: 4.94771525, y: 2.5)))
    g2_g0_path0.close()
    g2_g0_path0Fill.setFill()
    g2_g0_path0Stroke.setStroke()
    g2_g0_path0.fill()
    g2_g0_path0.lineWidth = 1 * scale
    g2_g0_path0.lineCapStyle = .buttLineCapStyle
    g2_g0_path0.stroke()
    let g2_g0_path1 = NSBezierPath()
    g2_g0_path1.move(to: transform(point: CGPoint(x: 5.5, y: 20.5)))
    g2_g0_path1.line(to: transform(point: CGPoint(x: 17.5, y: 20.5)))
    #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2).setStroke()
    g2_g0_path1.lineWidth = 1 * scale
    g2_g0_path1.lineCapStyle = .squareLineCapStyle
    g2_g0_path1.stroke()
    let g2_g0_path2 = NSBezierPath()
    g2_g0_path2.move(to: transform(point: CGPoint(x: 17.0857864, y: 8.5)))
    g2_g0_path2.line(to: transform(point: CGPoint(x: 13.5, y: 8.5)))
    g2_g0_path2.curve(
      to: transform(point: CGPoint(x: 12.5, y: 7.5)),
      controlPoint1: transform(point: CGPoint(x: 12.94771525, y: 8.5)),
      controlPoint2: transform(point: CGPoint(x: 12.5, y: 8.05228475)))
    g2_g0_path2.line(to: transform(point: CGPoint(x: 12.5, y: 3.91421356)))
    g2_g0_path2.curve(
      to: transform(point: CGPoint(x: 13.5, y: 2.914213562)),
      controlPoint1: transform(point: CGPoint(x: 12.5, y: 3.36192881)),
      controlPoint2: transform(point: CGPoint(x: 12.94771525, y: 2.914213562)))
    g2_g0_path2.curve(
      to: transform(point: CGPoint(x: 14.2071068, y: 3.20710678)),
      controlPoint1: transform(point: CGPoint(x: 13.76521649, y: 2.914213562)),
      controlPoint2: transform(point: CGPoint(x: 14.0195704, y: 3.0195704)))
    g2_g0_path2.line(to: transform(point: CGPoint(x: 17.7928932, y: 6.79289322)))
    g2_g0_path2.curve(
      to: transform(point: CGPoint(x: 17.7928932, y: 8.20710678)),
      controlPoint1: transform(point: CGPoint(x: 18.1834175, y: 7.18341751)),
      controlPoint2: transform(point: CGPoint(x: 18.1834175, y: 7.81658249)))
    g2_g0_path2.curve(
      to: transform(point: CGPoint(x: 17.0857864, y: 8.5)),
      controlPoint1: transform(point: CGPoint(x: 17.6053568, y: 8.39464316)),
      controlPoint2: transform(point: CGPoint(x: 17.3510029, y: 8.5)))
    g2_g0_path2.close()
    g2_g0_path2Fill.setFill()
    g2_g0_path2Stroke.setStroke()
    g2_g0_path2.fill()
    g2_g0_path2.lineWidth = 1 * scale
    g2_g0_path2.lineCapStyle = .buttLineCapStyle
    g2_g0_path2.stroke()
    let g2_rect1 = NSBezierPath()
    g2_rect1.move(to: transform(point: CGPoint(x: 8.5, y: 10.5)))
    g2_rect1.line(to: transform(point: CGPoint(x: 9.5, y: 10.5)))
    g2_rect1.curve(
      to: transform(point: CGPoint(x: 10.5, y: 11.5)),
      controlPoint1: transform(point: CGPoint(x: 10.0522847498, y: 10.5)),
      controlPoint2: transform(point: CGPoint(x: 10.5, y: 10.9477152502)))
    g2_rect1.line(to: transform(point: CGPoint(x: 10.5, y: 12.5)))
    g2_rect1.curve(
      to: transform(point: CGPoint(x: 9.5, y: 13.5)),
      controlPoint1: transform(point: CGPoint(x: 10.5, y: 13.0522847498)),
      controlPoint2: transform(point: CGPoint(x: 10.0522847498, y: 13.5)))
    g2_rect1.line(to: transform(point: CGPoint(x: 8.5, y: 13.5)))
    g2_rect1.curve(
      to: transform(point: CGPoint(x: 7.5, y: 12.5)),
      controlPoint1: transform(point: CGPoint(x: 7.94771525017, y: 13.5)),
      controlPoint2: transform(point: CGPoint(x: 7.5, y: 13.0522847498)))
    g2_rect1.line(to: transform(point: CGPoint(x: 7.5, y: 11.5)))
    g2_rect1.curve(
      to: transform(point: CGPoint(x: 8.5, y: 10.5)),
      controlPoint1: transform(point: CGPoint(x: 7.5, y: 10.9477152502)),
      controlPoint2: transform(point: CGPoint(x: 7.94771525017, y: 10.5)))
    g2_rect1.close()
    g2_rect1Fill.setFill()
    g2_rect1Stroke.setStroke()
    g2_rect1.fill()
    g2_rect1.lineWidth = 1 * scale
    g2_rect1.lineCapStyle = .buttLineCapStyle
    g2_rect1.stroke()
    let g2_rect2 = NSBezierPath()
    g2_rect2.move(to: transform(point: CGPoint(x: 13.5, y: 10.5)))
    g2_rect2.line(to: transform(point: CGPoint(x: 14.5, y: 10.5)))
    g2_rect2.curve(
      to: transform(point: CGPoint(x: 15.5, y: 11.5)),
      controlPoint1: transform(point: CGPoint(x: 15.0522847498, y: 10.5)),
      controlPoint2: transform(point: CGPoint(x: 15.5, y: 10.9477152502)))
    g2_rect2.line(to: transform(point: CGPoint(x: 15.5, y: 12.5)))
    g2_rect2.curve(
      to: transform(point: CGPoint(x: 14.5, y: 13.5)),
      controlPoint1: transform(point: CGPoint(x: 15.5, y: 13.0522847498)),
      controlPoint2: transform(point: CGPoint(x: 15.0522847498, y: 13.5)))
    g2_rect2.line(to: transform(point: CGPoint(x: 13.5, y: 13.5)))
    g2_rect2.curve(
      to: transform(point: CGPoint(x: 12.5, y: 12.5)),
      controlPoint1: transform(point: CGPoint(x: 12.9477152502, y: 13.5)),
      controlPoint2: transform(point: CGPoint(x: 12.5, y: 13.0522847498)))
    g2_rect2.line(to: transform(point: CGPoint(x: 12.5, y: 11.5)))
    g2_rect2.curve(
      to: transform(point: CGPoint(x: 13.5, y: 10.5)),
      controlPoint1: transform(point: CGPoint(x: 12.5, y: 10.9477152502)),
      controlPoint2: transform(point: CGPoint(x: 12.9477152502, y: 10.5)))
    g2_rect2.close()
    g2_rect2Fill.setFill()
    g2_rect2Stroke.setStroke()
    g2_rect2.fill()
    g2_rect2.lineWidth = 1 * scale
    g2_rect2.lineCapStyle = .buttLineCapStyle
    g2_rect2.stroke()
    let g2_rect3 = NSBezierPath()
    g2_rect3.move(to: transform(point: CGPoint(x: 13.5, y: 15.5)))
    g2_rect3.line(to: transform(point: CGPoint(x: 14.5, y: 15.5)))
    g2_rect3.curve(
      to: transform(point: CGPoint(x: 15.5, y: 16.5)),
      controlPoint1: transform(point: CGPoint(x: 15.0522847498, y: 15.5)),
      controlPoint2: transform(point: CGPoint(x: 15.5, y: 15.9477152502)))
    g2_rect3.line(to: transform(point: CGPoint(x: 15.5, y: 17.5)))
    g2_rect3.curve(
      to: transform(point: CGPoint(x: 14.5, y: 18.5)),
      controlPoint1: transform(point: CGPoint(x: 15.5, y: 18.0522847498)),
      controlPoint2: transform(point: CGPoint(x: 15.0522847498, y: 18.5)))
    g2_rect3.line(to: transform(point: CGPoint(x: 13.5, y: 18.5)))
    g2_rect3.curve(
      to: transform(point: CGPoint(x: 12.5, y: 17.5)),
      controlPoint1: transform(point: CGPoint(x: 12.9477152502, y: 18.5)),
      controlPoint2: transform(point: CGPoint(x: 12.5, y: 18.0522847498)))
    g2_rect3.line(to: transform(point: CGPoint(x: 12.5, y: 16.5)))
    g2_rect3.curve(
      to: transform(point: CGPoint(x: 13.5, y: 15.5)),
      controlPoint1: transform(point: CGPoint(x: 12.5, y: 15.9477152502)),
      controlPoint2: transform(point: CGPoint(x: 12.9477152502, y: 15.5)))
    g2_rect3.close()
    g2_rect3Fill.setFill()
    g2_rect3Stroke.setStroke()
    g2_rect3.fill()
    g2_rect3.lineWidth = 1 * scale
    g2_rect3.lineCapStyle = .buttLineCapStyle
    g2_rect3.stroke()
    let g2_rect4 = NSBezierPath()
    g2_rect4.move(to: transform(point: CGPoint(x: 8.5, y: 15.5)))
    g2_rect4.line(to: transform(point: CGPoint(x: 9.5, y: 15.5)))
    g2_rect4.curve(
      to: transform(point: CGPoint(x: 10.5, y: 16.5)),
      controlPoint1: transform(point: CGPoint(x: 10.0522847498, y: 15.5)),
      controlPoint2: transform(point: CGPoint(x: 10.5, y: 15.9477152502)))
    g2_rect4.line(to: transform(point: CGPoint(x: 10.5, y: 17.5)))
    g2_rect4.curve(
      to: transform(point: CGPoint(x: 9.5, y: 18.5)),
      controlPoint1: transform(point: CGPoint(x: 10.5, y: 18.0522847498)),
      controlPoint2: transform(point: CGPoint(x: 10.0522847498, y: 18.5)))
    g2_rect4.line(to: transform(point: CGPoint(x: 8.5, y: 18.5)))
    g2_rect4.curve(
      to: transform(point: CGPoint(x: 7.5, y: 17.5)),
      controlPoint1: transform(point: CGPoint(x: 7.94771525017, y: 18.5)),
      controlPoint2: transform(point: CGPoint(x: 7.5, y: 18.0522847498)))
    g2_rect4.line(to: transform(point: CGPoint(x: 7.5, y: 16.5)))
    g2_rect4.curve(
      to: transform(point: CGPoint(x: 8.5, y: 15.5)),
      controlPoint1: transform(point: CGPoint(x: 7.5, y: 15.9477152502)),
      controlPoint2: transform(point: CGPoint(x: 7.94771525017, y: 15.5)))
    g2_rect4.close()
    g2_rect4Fill.setFill()
    g2_rect4Stroke.setStroke()
    g2_rect4.fill()
    g2_rect4.lineWidth = 1 * scale
    g2_rect4.lineCapStyle = .buttLineCapStyle
    g2_rect4.stroke()
  }
}


// MARK: - ColorsFileIcon

public class ColorsFileIcon: NSBox {

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

  private var vectorGraphicView = IconColorsFileVector()

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
    vectorGraphicView.g2_g0_path0Fill = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    vectorGraphicView.g2_g0_path0Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
    vectorGraphicView.g2_g0_path2Fill = #colorLiteral(red: 0.933333333333, green: 0.933333333333, blue: 0.933333333333, alpha: 1)
    vectorGraphicView.g2_g0_path2Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
    vectorGraphicView.g2_rect1Fill = #colorLiteral(red: 0.933333333333, green: 0.933333333333, blue: 0.933333333333, alpha: 1)
    vectorGraphicView.g2_rect1Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
    vectorGraphicView.g2_rect2Fill = #colorLiteral(red: 0.933333333333, green: 0.933333333333, blue: 0.933333333333, alpha: 1)
    vectorGraphicView.g2_rect2Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
    vectorGraphicView.g2_rect3Fill = #colorLiteral(red: 0.933333333333, green: 0.933333333333, blue: 0.933333333333, alpha: 1)
    vectorGraphicView.g2_rect3Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
    vectorGraphicView.g2_rect4Fill = #colorLiteral(red: 0.933333333333, green: 0.933333333333, blue: 0.933333333333, alpha: 1)
    vectorGraphicView.g2_rect4Stroke = #colorLiteral(red: 0.549019607843, green: 0.549019607843, blue: 0.549019607843, alpha: 1)
    if selected {
      vectorGraphicView.g2_g0_path0Stroke = Colors.selectedIconStroke
      vectorGraphicView.g2_g0_path0Fill = Colors.selectedIcon
      vectorGraphicView.g2_g0_path2Stroke = Colors.selectedIconStroke
      vectorGraphicView.g2_g0_path2Fill = Colors.selectedIcon
      vectorGraphicView.g2_rect1Stroke = Colors.selectedIconStroke
      vectorGraphicView.g2_rect2Stroke = Colors.selectedIconStroke
      vectorGraphicView.g2_rect3Stroke = Colors.selectedIconStroke
      vectorGraphicView.g2_rect4Stroke = Colors.selectedIconStroke
      vectorGraphicView.g2_rect1Fill = Colors.selectedIcon
      vectorGraphicView.g2_rect2Fill = Colors.selectedIcon
      vectorGraphicView.g2_rect3Fill = Colors.selectedIcon
      vectorGraphicView.g2_rect4Fill = Colors.selectedIcon
    }
    vectorGraphicView.needsDisplay = true
  }
}
