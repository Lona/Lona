import UIKit
import Foundation

// MARK: - VisibilityTest

public class VisibilityTest: UIView {

  // MARK: Lifecycle

  public init(enabled: Bool) {
    self.enabled = enabled

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(enabled: false)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var enabled: Bool { didSet { update() } }

  // MARK: Private

  private var innerView = UIView(frame: .zero)
  private var titleView = UILabel()

  private var titleViewTextStyle = TextStyles.body1

  private func setUpViews() {
    titleView.numberOfLines = 0

    addSubview(innerView)
    addSubview(titleView)

    innerView.isHidden = !false
    innerView.backgroundColor = Colors.green300
    titleView.attributedText = titleViewTextStyle.apply(to: "Enabled")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false

    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor)
    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let titleViewBottomAnchorConstraint = titleView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: innerView.bottomAnchor)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let titleViewTrailingAnchorConstraint = titleView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let innerViewHeightAnchorConstraint = innerView.heightAnchor.constraint(equalToConstant: 100)
    let innerViewWidthAnchorConstraint = innerView.widthAnchor.constraint(equalToConstant: 100)

    NSLayoutConstraint.activate([
      innerViewTopAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      titleViewBottomAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      innerViewHeightAnchorConstraint,
      innerViewWidthAnchorConstraint
    ])
  }

  private func update() {
    titleView.isHidden = !enabled
  }
}
