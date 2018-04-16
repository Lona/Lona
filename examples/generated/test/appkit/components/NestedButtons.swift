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

  private var buttonView = Button(text: "A")
  private var view1View = NSBox()
  private var button2View = Button(text: "B")

  private var topPadding: CGFloat = 24
  private var trailingPadding: CGFloat = 24
  private var bottomPadding: CGFloat = 24
  private var leadingPadding: CGFloat = 24
  private var buttonViewTopMargin: CGFloat = 0
  private var buttonViewTrailingMargin: CGFloat = 0
  private var buttonViewBottomMargin: CGFloat = 0
  private var buttonViewLeadingMargin: CGFloat = 0
  private var view1ViewTopMargin: CGFloat = 0
  private var view1ViewTrailingMargin: CGFloat = 0
  private var view1ViewBottomMargin: CGFloat = 0
  private var view1ViewLeadingMargin: CGFloat = 0
  private var button2ViewTopMargin: CGFloat = 0
  private var button2ViewTrailingMargin: CGFloat = 0
  private var button2ViewBottomMargin: CGFloat = 0
  private var button2ViewLeadingMargin: CGFloat = 0

  private var buttonViewTopAnchorConstraint: NSLayoutConstraint?
  private var buttonViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var buttonViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var view1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var view1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var view1ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var button2ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var button2ViewTopAnchorConstraint: NSLayoutConstraint?
  private var button2ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var button2ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var view1ViewHeightAnchorConstraint: NSLayoutConstraint?

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

//    buttonView.attributedStringValue = buttonViewTextStyle.apply(to: "Button 1")
//    button2View.attributedStringValue = button2ViewTextStyle.apply(to: "Button 2")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    buttonView.translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    button2View.translatesAutoresizingMaskIntoConstraints = false

    let buttonViewTopAnchorConstraint = buttonView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + buttonViewTopMargin)
    let buttonViewLeadingAnchorConstraint = buttonView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + buttonViewLeadingMargin)
    let buttonViewTrailingAnchorConstraint = buttonView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + buttonViewTrailingMargin))
    let view1ViewTopAnchorConstraint = view1View
      .topAnchor
      .constraint(equalTo: buttonView.bottomAnchor, constant: buttonViewBottomMargin + view1ViewTopMargin)
    let view1ViewLeadingAnchorConstraint = view1View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + view1ViewLeadingMargin)
    let view1ViewTrailingAnchorConstraint = view1View
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + view1ViewTrailingMargin))
    let button2ViewBottomAnchorConstraint = button2View
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + button2ViewBottomMargin))
    let button2ViewTopAnchorConstraint = button2View
      .topAnchor
      .constraint(equalTo: view1View.bottomAnchor, constant: view1ViewBottomMargin + button2ViewTopMargin)
    let button2ViewLeadingAnchorConstraint = button2View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + button2ViewLeadingMargin)
    let button2ViewTrailingAnchorConstraint = button2View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + button2ViewTrailingMargin))
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

    self.buttonViewTopAnchorConstraint = buttonViewTopAnchorConstraint
    self.buttonViewLeadingAnchorConstraint = buttonViewLeadingAnchorConstraint
    self.buttonViewTrailingAnchorConstraint = buttonViewTrailingAnchorConstraint
    self.view1ViewTopAnchorConstraint = view1ViewTopAnchorConstraint
    self.view1ViewLeadingAnchorConstraint = view1ViewLeadingAnchorConstraint
    self.view1ViewTrailingAnchorConstraint = view1ViewTrailingAnchorConstraint
    self.button2ViewBottomAnchorConstraint = button2ViewBottomAnchorConstraint
    self.button2ViewTopAnchorConstraint = button2ViewTopAnchorConstraint
    self.button2ViewLeadingAnchorConstraint = button2ViewLeadingAnchorConstraint
    self.button2ViewTrailingAnchorConstraint = button2ViewTrailingAnchorConstraint
    self.view1ViewHeightAnchorConstraint = view1ViewHeightAnchorConstraint

    // For debugging
    buttonViewTopAnchorConstraint.identifier = "buttonViewTopAnchorConstraint"
    buttonViewLeadingAnchorConstraint.identifier = "buttonViewLeadingAnchorConstraint"
    buttonViewTrailingAnchorConstraint.identifier = "buttonViewTrailingAnchorConstraint"
    view1ViewTopAnchorConstraint.identifier = "view1ViewTopAnchorConstraint"
    view1ViewLeadingAnchorConstraint.identifier = "view1ViewLeadingAnchorConstraint"
    view1ViewTrailingAnchorConstraint.identifier = "view1ViewTrailingAnchorConstraint"
    button2ViewBottomAnchorConstraint.identifier = "button2ViewBottomAnchorConstraint"
    button2ViewTopAnchorConstraint.identifier = "button2ViewTopAnchorConstraint"
    button2ViewLeadingAnchorConstraint.identifier = "button2ViewLeadingAnchorConstraint"
    button2ViewTrailingAnchorConstraint.identifier = "button2ViewTrailingAnchorConstraint"
    view1ViewHeightAnchorConstraint.identifier = "view1ViewHeightAnchorConstraint"
  }

  private func update() {}
}
