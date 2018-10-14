import UIKit
import Foundation

// MARK: - BorderWidthColor

public class BorderWidthColor: UIView {

  // MARK: Lifecycle

  public init(alternativeStyle: Bool) {
    self.alternativeStyle = alternativeStyle

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(alternativeStyle: false)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var alternativeStyle: Bool { didSet { update() } }

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
