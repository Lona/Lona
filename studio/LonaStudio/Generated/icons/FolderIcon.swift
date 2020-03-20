import AppKit
import Foundation

private class IconFolder2Vector: NSBox {
  public var innerFill = #colorLiteral(red: 0.0156862745098, green: 0.388235294118, blue: 0.882352941176, alpha: 1)
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

    let viewBox = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 19, height: 15))
    let croppedRect = viewBox.size.resized(within: bounds.size, usingResizingMode: resizingMode)
    let scale = croppedRect.width / viewBox.width
    func transform(point: CGPoint) -> CGPoint {
      return CGPoint(x: point.x * scale + croppedRect.minX, y: point.y * scale + croppedRect.minY)
    }
    let outer = NSBezierPath()
    outer.move(to: transform(point: CGPoint(x: 1, y: 0)))
    outer.line(to: transform(point: CGPoint(x: 4.18578644, y: 0)))
    outer.curve(
      to: transform(point: CGPoint(x: 4.89289322, y: 0.292893219)),
      controlPoint1: transform(point: CGPoint(x: 4.45100293, y: -4.87194788e-17)),
      controlPoint2: transform(point: CGPoint(x: 4.70535684, y: 0.10535684)))
    outer.line(to: transform(point: CGPoint(x: 6.30710678, y: 1.70710678)))
    outer.curve(
      to: transform(point: CGPoint(x: 7.01421356, y: 2)),
      controlPoint1: transform(point: CGPoint(x: 6.49464316, y: 1.89464316)),
      controlPoint2: transform(point: CGPoint(x: 6.74899707, y: 2)))
    outer.line(to: transform(point: CGPoint(x: 18, y: 2)))
    outer.curve(
      to: transform(point: CGPoint(x: 19, y: 3)),
      controlPoint1: transform(point: CGPoint(x: 18.5522847, y: 2)),
      controlPoint2: transform(point: CGPoint(x: 19, y: 2.44771525)))
    outer.line(to: transform(point: CGPoint(x: 19, y: 14)))
    outer.curve(
      to: transform(point: CGPoint(x: 18, y: 15)),
      controlPoint1: transform(point: CGPoint(x: 19, y: 14.5522847)),
      controlPoint2: transform(point: CGPoint(x: 18.5522847, y: 15)))
    outer.line(to: transform(point: CGPoint(x: 1, y: 15)))
    outer.curve(
      to: transform(point: CGPoint(x: 0, y: 14)),
      controlPoint1: transform(point: CGPoint(x: 0.44771525, y: 15)),
      controlPoint2: transform(point: CGPoint(x: 6.76353751e-17, y: 14.5522847)))
    outer.line(to: transform(point: CGPoint(x: 0, y: 1)))
    outer.curve(
      to: transform(point: CGPoint(x: 1, y: 0)),
      controlPoint1: transform(point: CGPoint(x: -6.76353751e-17, y: 0.44771525)),
      controlPoint2: transform(point: CGPoint(x: 0.44771525, y: 1.01453063e-16)))
    outer.close()
    outerFill.setFill()
    outer.fill()
    let inner = NSBezierPath()
    inner.move(to: transform(point: CGPoint(x: 2, y: 1)))
    inner.line(to: transform(point: CGPoint(x: 3.58578644, y: 1)))
    inner.curve(
      to: transform(point: CGPoint(x: 4.29289322, y: 1.29289322)),
      controlPoint1: transform(point: CGPoint(x: 3.85100293, y: 1)),
      controlPoint2: transform(point: CGPoint(x: 4.10535684, y: 1.10535684)))
    inner.line(to: transform(point: CGPoint(x: 5.70710678, y: 2.70710678)))
    inner.curve(
      to: transform(point: CGPoint(x: 6.41421356, y: 3)),
      controlPoint1: transform(point: CGPoint(x: 5.89464316, y: 2.89464316)),
      controlPoint2: transform(point: CGPoint(x: 6.14899707, y: 3)))
    inner.line(to: transform(point: CGPoint(x: 17, y: 3)))
    inner.curve(
      to: transform(point: CGPoint(x: 18, y: 4)),
      controlPoint1: transform(point: CGPoint(x: 17.5522847, y: 3)),
      controlPoint2: transform(point: CGPoint(x: 18, y: 3.44771525)))
    inner.line(to: transform(point: CGPoint(x: 18, y: 5)))
    inner.line(to: transform(point: CGPoint(x: 18, y: 5)))
    inner.line(to: transform(point: CGPoint(x: 1, y: 5)))
    inner.line(to: transform(point: CGPoint(x: 1, y: 2)))
    inner.curve(
      to: transform(point: CGPoint(x: 2, y: 1)),
      controlPoint1: transform(point: CGPoint(x: 1, y: 1.44771525)),
      controlPoint2: transform(point: CGPoint(x: 1.44771525, y: 1)))
    inner.close()
    innerFill.setFill()
    inner.fill()
  }
}


// MARK: - FolderIcon

public class FolderIcon: NSBox {

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

  private var vectorGraphic2View = IconFolder2Vector()

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    vectorGraphic2View.boxType = .custom
    vectorGraphic2View.borderType = .noBorder
    vectorGraphic2View.contentViewMargins = .zero

    addSubview(vectorGraphic2View)

    vectorGraphic2View.resizingMode = .scaleAspectFit
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    vectorGraphic2View.translatesAutoresizingMaskIntoConstraints = false

    let vectorGraphic2ViewLeadingAnchorConstraint = vectorGraphic2View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: 2)
    let vectorGraphic2ViewTopAnchorConstraint = vectorGraphic2View.topAnchor.constraint(equalTo: topAnchor, constant: 4)
    let vectorGraphic2ViewHeightAnchorConstraint = vectorGraphic2View.heightAnchor.constraint(equalToConstant: 15)
    let vectorGraphic2ViewWidthAnchorConstraint = vectorGraphic2View.widthAnchor.constraint(equalToConstant: 19)

    NSLayoutConstraint.activate([
      vectorGraphic2ViewLeadingAnchorConstraint,
      vectorGraphic2ViewTopAnchorConstraint,
      vectorGraphic2ViewHeightAnchorConstraint,
      vectorGraphic2ViewWidthAnchorConstraint
    ])
  }

  private func update() {
    vectorGraphic2View.innerFill = #colorLiteral(red: 0.0156862745098, green: 0.388235294118, blue: 0.882352941176, alpha: 1)
    vectorGraphic2View.outerFill = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    vectorGraphic2View.innerFill = Colors.iconFillAccent
    vectorGraphic2View.outerFill = Colors.iconFill
    if selected {
      vectorGraphic2View.innerFill = Colors.systemSelection30
      vectorGraphic2View.outerFill = Colors.white
    }
    vectorGraphic2View.needsDisplay = true
  }
}

// MARK: - Parameters

extension FolderIcon {
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

extension FolderIcon {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "FolderIcon"
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
