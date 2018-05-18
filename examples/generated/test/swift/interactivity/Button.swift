import UIKit
import Foundation

// MARK: - Button

public class Button: UIView {

  // MARK: Lifecycle

  public init(label: String) {
    self.label = label

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(label: "")
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var label: String { didSet { update() } }
  public var onTap: (() -> Void)? { didSet { update() } }

  // MARK: Private

  private var textView = UILabel()

  private var textViewTextStyle = TextStyles.button

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

    textViewTextStyle = TextStyles.button
    textView.attributedText = textViewTextStyle.apply(to: textView.attributedText ?? NSAttributedString())
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
    textView.attributedText = textViewTextStyle.apply(to: label)
    onPress = onTap
    if hovered {
      backgroundColor = Colors.blue200
    }
    if pressed {
      backgroundColor = Colors.blue50
    }
  }
}
