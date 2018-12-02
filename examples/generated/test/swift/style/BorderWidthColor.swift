import UIKit
import Foundation

// MARK: - BorderWidthColor

public class BorderWidthColor: UIView {

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
    set { parameters.alternativeStyle = newValue }
  }

  public var parameters: Parameters { didSet { update() } }

  // MARK: Private

  private var innerView = UIView(frame: .zero)

  private func setUpViews() {
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
    innerView.layer.cornerRadius = 10
    innerView.layer.borderWidth = 20
    innerView.layer.borderColor = Colors.blue300.cgColor
    if alternativeStyle {
      innerView.layer.borderColor = Colors.reda400.cgColor
      innerView.layer.borderWidth = 4
      innerView.layer.cornerRadius = 20
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
    public var parameters: Parameters
    public var type: String {
      return "BorderWidthColor"
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
