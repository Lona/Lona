import AppKit
import Foundation

// MARK: - BorderWidthColor

public class BorderWidthColor: NSBox {

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
    innerView.cornerRadius = 10
    innerView.borderWidth = 20
    innerView.borderColor = Colors.blue300
    if alternativeStyle {
      innerView.borderColor = Colors.reda400
      innerView.borderWidth = 4
      innerView.cornerRadius = 20
    }
  }
}
