import UIKit
import Foundation

// MARK: - PressableRootView

public class PressableRootView: UIView {

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

  // MARK: Public

  public var onPressOuter: (() -> Void)?
  public var onPressInner: (() -> Void)?

  // MARK: Private

  private var innerView = UIView(frame: .zero)
  private var innerTextView = UILabel()

  private var innerTextViewTextStyle = TextStyles.headline

  private var topPadding: CGFloat = 24
  private var trailingPadding: CGFloat = 24
  private var bottomPadding: CGFloat = 24
  private var leadingPadding: CGFloat = 24
  private var innerViewTopMargin: CGFloat = 0
  private var innerViewTrailingMargin: CGFloat = 0
  private var innerViewBottomMargin: CGFloat = 0
  private var innerViewLeadingMargin: CGFloat = 0
  private var innerViewTopPadding: CGFloat = 0
  private var innerViewTrailingPadding: CGFloat = 0
  private var innerViewBottomPadding: CGFloat = 0
  private var innerViewLeadingPadding: CGFloat = 0
  private var innerTextViewTopMargin: CGFloat = 0
  private var innerTextViewTrailingMargin: CGFloat = 0
  private var innerTextViewBottomMargin: CGFloat = 0
  private var innerTextViewLeadingMargin: CGFloat = 0

  private var hovered = false
  private var pressed = false
  private var onPress: (() -> Void)?
  private var innerViewHovered = false
  private var innerViewPressed = false
  private var innerViewOnPress: (() -> Void)?

  private var innerViewTopAnchorConstraint: NSLayoutConstraint?
  private var innerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var innerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var innerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var innerViewWidthAnchorConstraint: NSLayoutConstraint?
  private var innerTextViewTopAnchorConstraint: NSLayoutConstraint?
  private var innerTextViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var innerTextViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    innerTextView.numberOfLines = 0

    addSubview(innerView)
    innerView.addSubview(innerTextView)

    innerTextViewTextStyle = TextStyles.headline
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    innerTextView.translatesAutoresizingMaskIntoConstraints = false

    let innerViewTopAnchorConstraint = innerView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + innerViewTopMargin)
    let innerViewBottomAnchorConstraint = innerView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + innerViewBottomMargin))
    let innerViewLeadingAnchorConstraint = innerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + innerViewLeadingMargin)
    let innerViewHeightAnchorConstraint = innerView.heightAnchor.constraint(equalToConstant: 100)
    let innerViewWidthAnchorConstraint = innerView.widthAnchor.constraint(equalToConstant: 100)
    let innerTextViewTopAnchorConstraint = innerTextView
      .topAnchor
      .constraint(equalTo: innerView.topAnchor, constant: innerViewTopPadding + innerTextViewTopMargin)
    let innerTextViewLeadingAnchorConstraint = innerTextView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: innerViewLeadingPadding + innerTextViewLeadingMargin)
    let innerTextViewTrailingAnchorConstraint = innerTextView
      .trailingAnchor
      .constraint(
        equalTo: innerView.trailingAnchor,
        constant: -(innerViewTrailingPadding + innerTextViewTrailingMargin))

    NSLayoutConstraint.activate([
      innerViewTopAnchorConstraint,
      innerViewBottomAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewHeightAnchorConstraint,
      innerViewWidthAnchorConstraint,
      innerTextViewTopAnchorConstraint,
      innerTextViewLeadingAnchorConstraint,
      innerTextViewTrailingAnchorConstraint
    ])

    self.innerViewTopAnchorConstraint = innerViewTopAnchorConstraint
    self.innerViewBottomAnchorConstraint = innerViewBottomAnchorConstraint
    self.innerViewLeadingAnchorConstraint = innerViewLeadingAnchorConstraint
    self.innerViewHeightAnchorConstraint = innerViewHeightAnchorConstraint
    self.innerViewWidthAnchorConstraint = innerViewWidthAnchorConstraint
    self.innerTextViewTopAnchorConstraint = innerTextViewTopAnchorConstraint
    self.innerTextViewLeadingAnchorConstraint = innerTextViewLeadingAnchorConstraint
    self.innerTextViewTrailingAnchorConstraint = innerTextViewTrailingAnchorConstraint

    // For debugging
    innerViewTopAnchorConstraint.identifier = "innerViewTopAnchorConstraint"
    innerViewBottomAnchorConstraint.identifier = "innerViewBottomAnchorConstraint"
    innerViewLeadingAnchorConstraint.identifier = "innerViewLeadingAnchorConstraint"
    innerViewHeightAnchorConstraint.identifier = "innerViewHeightAnchorConstraint"
    innerViewWidthAnchorConstraint.identifier = "innerViewWidthAnchorConstraint"
    innerTextViewTopAnchorConstraint.identifier = "innerTextViewTopAnchorConstraint"
    innerTextViewLeadingAnchorConstraint.identifier = "innerTextViewLeadingAnchorConstraint"
    innerTextViewTrailingAnchorConstraint.identifier = "innerTextViewTrailingAnchorConstraint"
  }

  private func update() {
    innerView.backgroundColor = Colors.blue500
    innerTextView.attributedText = innerTextViewTextStyle.apply(to: "")
    backgroundColor = Colors.grey50
    onPress = onPressOuter
    innerViewOnPress = onPressInner
    if hovered {
      backgroundColor = Colors.grey100
    }
    if pressed {
      backgroundColor = Colors.grey300
    }
    if innerViewHovered {
      innerView.backgroundColor = Colors.blue300
      innerTextView.attributedText = innerTextViewTextStyle.apply(to: "Hovered")
    }
    if innerViewPressed {
      innerView.backgroundColor = Colors.blue800
      innerTextView.attributedText = innerTextViewTextStyle.apply(to: "Pressed")
    }
    if innerViewHovered {
      if innerViewPressed {
        innerTextView.attributedText = innerTextViewTextStyle.apply(to: "Hovered & Pressed")
      }
    }
  }
}