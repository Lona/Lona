import UIKit
import Foundation

// MARK: - BorderWidthColor

public class BorderWidthColor: UIView {

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

  private var view1View = UIView(frame: .zero)

  private func setUpViews() {
    addSubview(view1View)

    view1View.layer.cornerRadius = 10
    view1View.layer.borderWidth = 20
    view1View.layer.borderColor = Colors.blue300.cgColor
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false

    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: topAnchor)
    let view1ViewBottomAnchorConstraint = view1View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewHeightAnchorConstraint = view1View.heightAnchor.constraint(equalToConstant: 100)
    let view1ViewWidthAnchorConstraint = view1View.widthAnchor.constraint(equalToConstant: 100)

    NSLayoutConstraint.activate([
      view1ViewTopAnchorConstraint,
      view1ViewBottomAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewHeightAnchorConstraint,
      view1ViewWidthAnchorConstraint
    ])
  }

  private func update() {}
}
