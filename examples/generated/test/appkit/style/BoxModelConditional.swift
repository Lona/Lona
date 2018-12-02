import AppKit
import Foundation

// MARK: - BoxModelConditional

public class BoxModelConditional: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(margin: CGFloat, size: CGFloat) {
    self.init(Parameters(margin: margin, size: size))
  }

  public convenience init() {
    self.init(Parameters())
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var margin: CGFloat {
    get { return parameters.margin }
    set { parameters.margin = newValue }
  }

  public var size: CGFloat {
    get { return parameters.size }
    set { parameters.size = newValue }
  }

  public var parameters: Parameters { didSet { update() } }

  // MARK: Private

  private var innerView = NSBox()

  private var innerViewTopAnchorConstraint: NSLayoutConstraint?
  private var innerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var innerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var innerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var innerViewWidthAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .noBorder
    innerView.contentViewMargins = .zero

    addSubview(innerView)

    innerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false

    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor, constant: 4)
    let innerViewBottomAnchorConstraint = innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4)
    let innerViewHeightAnchorConstraint = innerView.heightAnchor.constraint(equalToConstant: 60)
    let innerViewWidthAnchorConstraint = innerView.widthAnchor.constraint(equalToConstant: 60)

    self.innerViewTopAnchorConstraint = innerViewTopAnchorConstraint
    self.innerViewBottomAnchorConstraint = innerViewBottomAnchorConstraint
    self.innerViewLeadingAnchorConstraint = innerViewLeadingAnchorConstraint
    self.innerViewHeightAnchorConstraint = innerViewHeightAnchorConstraint
    self.innerViewWidthAnchorConstraint = innerViewWidthAnchorConstraint

    NSLayoutConstraint.activate([
      innerViewTopAnchorConstraint,
      innerViewBottomAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewHeightAnchorConstraint,
      innerViewWidthAnchorConstraint
    ])
  }

  private func update() {
    // TODO: Margin & padding: innerView.marginTop = // TODO: Margin & padding: margin
    // TODO: Margin & padding: innerView.marginRight = // TODO: Margin & padding: margin
    // TODO: Margin & padding: innerView.marginBottom = // TODO: Margin & padding: margin
    // TODO: Margin & padding: innerView.marginLeft = // TODO: Margin & padding: margin
    innerViewHeightAnchorConstraint?.constant = size
    innerViewWidthAnchorConstraint?.constant = size
  }
}

// MARK: - Parameters

extension BoxModelConditional {
  public struct Parameters: Equatable {
    public var margin: CGFloat
    public var size: CGFloat

    public init(margin: CGFloat, size: CGFloat) {
      self.margin = margin
      self.size = size
    }

    public init() {
      self.init(margin: 0, size: 0)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.margin == rhs.margin && lhs.size == rhs.size
    }
  }
}

// MARK: - Model

extension BoxModelConditional {
  public struct Model: LonaViewModel, Equatable {
    public var parameters: Parameters
    public var type: String {
      return "BoxModelConditional"
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(margin: CGFloat, size: CGFloat) {
      self.init(Parameters(margin: margin, size: size))
    }

    public init() {
      self.init(margin: 0, size: 0)
    }
  }
}
