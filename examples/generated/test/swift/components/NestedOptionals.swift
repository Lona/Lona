import UIKit
import Foundation

// MARK: - NestedOptionals

public class NestedOptionals: UIView {

  // MARK: Lifecycle

  public init() {
    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private

  private var optionalsView = Optionals()

  private func setUpViews() {
    addSubview(optionalsView)

    optionalsView.boolParam = nil
    optionalsView.stringParam = "Text"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    optionalsView.translatesAutoresizingMaskIntoConstraints = false

    let optionalsViewTopAnchorConstraint = optionalsView.topAnchor.constraint(equalTo: topAnchor)
    let optionalsViewBottomAnchorConstraint = optionalsView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let optionalsViewLeadingAnchorConstraint = optionalsView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let optionalsViewTrailingAnchorConstraint = optionalsView.trailingAnchor.constraint(equalTo: trailingAnchor)

    NSLayoutConstraint.activate([
      optionalsViewTopAnchorConstraint,
      optionalsViewBottomAnchorConstraint,
      optionalsViewLeadingAnchorConstraint,
      optionalsViewTrailingAnchorConstraint
    ])
  }

  private func update() {}
}
