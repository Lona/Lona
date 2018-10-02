import AppKit
import Foundation

// MARK: - ShadowsTest

public class ShadowsTest: NSBox {

  // MARK: Lifecycle

  public init(largeShadow: Bool) {
    self.largeShadow = largeShadow

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(largeShadow: false)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var largeShadow: Bool { didSet { update() } }

  // MARK: Private

  private var innerView = NSBox()

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .noBorder
    innerView.contentViewMargins = .zero

    addSubview(innerView)

    innerView.fillColor = Colors.blue300
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
    innerView.shadow = Shadows.elevation2
    if largeShadow {
      innerView.shadow = Shadows.elevation3
    }
  }
}
