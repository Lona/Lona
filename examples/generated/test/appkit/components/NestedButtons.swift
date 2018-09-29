import AppKit
import Foundation

// MARK: - NestedButtons

public class NestedButtons: NSBox {

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

  private var buttonView = Button()
  private var view1View = NSBox()
  private var button2View = Button()

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero

    addSubview(buttonView)
    addSubview(view1View)
    addSubview(button2View)

    buttonView.label = "Button 1"
    button2View.label = "Button 2"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    buttonView.translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    button2View.translatesAutoresizingMaskIntoConstraints = false

    let buttonViewTopAnchorConstraint = buttonView.topAnchor.constraint(equalTo: topAnchor, constant: 24)
    let buttonViewLeadingAnchorConstraint = buttonView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)
    let buttonViewTrailingAnchorConstraint = buttonView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)
    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: buttonView.bottomAnchor)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)
    let view1ViewTrailingAnchorConstraint = view1View.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)
    let button2ViewBottomAnchorConstraint = button2View.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
    let button2ViewTopAnchorConstraint = button2View.topAnchor.constraint(equalTo: view1View.bottomAnchor)
    let button2ViewLeadingAnchorConstraint = button2View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)
    let button2ViewTrailingAnchorConstraint = button2View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)
    let view1ViewHeightAnchorConstraint = view1View.heightAnchor.constraint(equalToConstant: 8)

    NSLayoutConstraint.activate([
      buttonViewTopAnchorConstraint,
      buttonViewLeadingAnchorConstraint,
      buttonViewTrailingAnchorConstraint,
      view1ViewTopAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewTrailingAnchorConstraint,
      button2ViewBottomAnchorConstraint,
      button2ViewTopAnchorConstraint,
      button2ViewLeadingAnchorConstraint,
      button2ViewTrailingAnchorConstraint,
      view1ViewHeightAnchorConstraint
    ])
  }

  private func update() {}
}
