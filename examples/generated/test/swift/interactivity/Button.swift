import UIKit
import Foundation

// MARK: - Button

public class Button: UIView {

  // MARK: Lifecycle

  public init(text: String) {
    self.text = text

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var text: String { didSet { update() } }
  public var onTap: (() -> Void)?

  // MARK: Private

  private var textView = UILabel()

  private var textViewTextStyle = TextStyles.subheading2

  private var topPadding: CGFloat = 12
  private var trailingPadding: CGFloat = 16
  private var bottomPadding: CGFloat = 12
  private var leadingPadding: CGFloat = 16
  private var textViewTopMargin: CGFloat = 0
  private var textViewTrailingMargin: CGFloat = 0
  private var textViewBottomMargin: CGFloat = 0
  private var textViewLeadingMargin: CGFloat = 0

  private var hovered = false
  private var pressed = false
  private var onPress: (() -> Void)?

  private var textViewWidthAnchorParentConstraint: NSLayoutConstraint?
  private var textViewTopAnchorConstraint: NSLayoutConstraint?
  private var textViewBottomAnchorConstraint: NSLayoutConstraint?
  private var textViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    textView.numberOfLines = 0

    addSubview(textView)

    textViewTextStyle = TextStyles.subheading2
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false

    let textViewWidthAnchorParentConstraint = textView
      .widthAnchor
      .constraint(
        lessThanOrEqualTo: widthAnchor,
        constant: -(leadingPadding + textViewLeadingMargin + trailingPadding + textViewTrailingMargin))
    let textViewTopAnchorConstraint = textView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + textViewTopMargin)
    let textViewBottomAnchorConstraint = textView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + textViewBottomMargin))
    let textViewLeadingAnchorConstraint = textView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + textViewLeadingMargin)
    let textViewTrailingAnchorConstraint = textView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + textViewTrailingMargin))
    textViewWidthAnchorParentConstraint.priority = UILayoutPriority.defaultLow

    NSLayoutConstraint.activate([
      textViewWidthAnchorParentConstraint,
      textViewTopAnchorConstraint,
      textViewBottomAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint
    ])

    self.textViewWidthAnchorParentConstraint = textViewWidthAnchorParentConstraint
    self.textViewTopAnchorConstraint = textViewTopAnchorConstraint
    self.textViewBottomAnchorConstraint = textViewBottomAnchorConstraint
    self.textViewLeadingAnchorConstraint = textViewLeadingAnchorConstraint
    self.textViewTrailingAnchorConstraint = textViewTrailingAnchorConstraint

    // For debugging
    textViewWidthAnchorParentConstraint.identifier = "textViewWidthAnchorParentConstraint"
    textViewTopAnchorConstraint.identifier = "textViewTopAnchorConstraint"
    textViewBottomAnchorConstraint.identifier = "textViewBottomAnchorConstraint"
    textViewLeadingAnchorConstraint.identifier = "textViewLeadingAnchorConstraint"
    textViewTrailingAnchorConstraint.identifier = "textViewTrailingAnchorConstraint"
  }

  private func update() {
    backgroundColor = Colors.blue100
    textView.attributedText = textViewTextStyle.apply(to: text)
    onPress = onTap
    if hovered {
      backgroundColor = Colors.blue200
    }
    if pressed {
      backgroundColor = Colors.blue50
    }
  }
}