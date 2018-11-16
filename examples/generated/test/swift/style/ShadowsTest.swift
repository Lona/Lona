import UIKit
import Foundation

// MARK: - ShadowsTest

public class ShadowsTest: UIView {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(largeShadow: Bool) {
    self.init(Parameters(largeShadow: largeShadow))
  }

  public convenience init() {
    self.init(Parameters())
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var largeShadow: Bool {
    get { return parameters.largeShadow }
    set { parameters.largeShadow = newValue }
  }

  public var parameters: Parameters { didSet { update() } }

  // MARK: Private

  private var innerView = UIView(frame: .zero)

  private func setUpViews() {
    addSubview(innerView)

    innerView.backgroundColor = Colors.blue300
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false

    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor, constant: 20)
    let innerViewBottomAnchorConstraint = innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
    let innerViewCenterXAnchorConstraint = innerView.centerXAnchor.constraint(equalTo: centerXAnchor)
    let innerViewHeightAnchorConstraint = innerView.heightAnchor.constraint(equalToConstant: 60)
    let innerViewWidthAnchorConstraint = innerView.widthAnchor.constraint(equalToConstant: 60)

    NSLayoutConstraint.activate([
      innerViewTopAnchorConstraint,
      innerViewBottomAnchorConstraint,
      innerViewCenterXAnchorConstraint,
      innerViewHeightAnchorConstraint,
      innerViewWidthAnchorConstraint
    ])
  }

  private func update() {
    Shadows.elevation2.apply(to: innerView.layer)
    if largeShadow {
      Shadows.elevation3.apply(to: innerView.layer)
    }
  }
}

// MARK: - Parameters

extension ShadowsTest {
  public struct Parameters: Equatable {
    public var largeShadow: Bool

    public init(largeShadow: Bool) {
      self.largeShadow = largeShadow
    }

    public init() {
      self.init(largeShadow: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.largeShadow == rhs.largeShadow
    }
  }
}

// MARK: - Model

extension ShadowsTest {
  public struct Model: LonaViewModel, Equatable {
    public var parameters: Parameters
    public var type: String {
      return "ShadowsTest"
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(largeShadow: Bool) {
      self.init(Parameters(largeShadow: largeShadow))
    }

    public init() {
      self.init(largeShadow: false)
    }
  }
}
