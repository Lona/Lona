import AppKit
import Foundation

// MARK: - BorderWidthColor

public class BorderWidthColor: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(alternativeStyle: Bool) {
    self.init(Parameters(alternativeStyle: alternativeStyle))
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

  public var alternativeStyle: Bool {
    get { return parameters.alternativeStyle }
    set {
      if parameters.alternativeStyle != newValue {
        parameters.alternativeStyle = newValue
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

  private var innerView = NSBox()

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .lineBorder
    innerView.contentViewMargins = .zero

    addSubview(innerView)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false

    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor)
    let innerViewBottomAnchorConstraint = innerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let innerViewHeightAnchorConstraint = innerView.heightAnchor.constraint(equalToConstant: 100)
    let innerViewWidthAnchorConstraint = innerView.widthAnchor.constraint(equalToConstant: 100)

    NSLayoutConstraint.activate([
      innerViewTopAnchorConstraint,
      innerViewBottomAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewHeightAnchorConstraint,
      innerViewWidthAnchorConstraint
    ])
  }

  private func update() {
    innerView.borderColor = Colors.blue300
    innerView.cornerRadius = 10
    innerView.borderStyle = "dashed"
    innerView.borderWidth = 20
    if alternativeStyle {
      innerView.borderColor = Colors.reda400
      innerView.borderWidth = 4
      innerView.cornerRadius = 20
      innerView.borderStyle = "solid"
    }
  }
}

// MARK: - Parameters

extension BorderWidthColor {
  public struct Parameters: Equatable {
    public var alternativeStyle: Bool

    public init(alternativeStyle: Bool) {
      self.alternativeStyle = alternativeStyle
    }

    public init() {
      self.init(alternativeStyle: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.alternativeStyle == rhs.alternativeStyle
    }
  }
}

// MARK: - Model

extension BorderWidthColor {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "BorderWidthColor"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(alternativeStyle: Bool) {
      self.init(Parameters(alternativeStyle: alternativeStyle))
    }

    public init() {
      self.init(alternativeStyle: false)
    }
  }
}
