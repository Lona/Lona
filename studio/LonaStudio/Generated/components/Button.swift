import AppKit
import Foundation

// MARK: - Button

public class Button: NSBox {

  // MARK: Lifecycle

  public init(titleText: String) {
    self.titleText = titleText

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(titleText: "")
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var titleText: String { didSet { update() } }
  public var onClick: (() -> Void)? { didSet { update() } }

  // MARK: Private

  private var textView = NSTextField(labelWithString: "")

  private var textViewTextStyle = TextStyles.regular

  private var topPadding: CGFloat = 2
  private var trailingPadding: CGFloat = 10
  private var bottomPadding: CGFloat = 2
  private var leadingPadding: CGFloat = 10
  private var textViewTopMargin: CGFloat = 0
  private var textViewTrailingMargin: CGFloat = 0
  private var textViewBottomMargin: CGFloat = 0
  private var textViewLeadingMargin: CGFloat = 0

  private var textViewWidthAnchorParentConstraint: NSLayoutConstraint?
  private var textViewTopAnchorConstraint: NSLayoutConstraint?
  private var textViewBottomAnchorConstraint: NSLayoutConstraint?
  private var textViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var textViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .lineBorder
    contentViewMargins = .zero
    textView.lineBreakMode = .byWordWrapping

    addSubview(textView)

    fillColor = Colors.white
    cornerRadius = 3
    borderWidth = 1
    borderColor = Colors.darkTransparentOutline
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
    let textViewCenterXAnchorConstraint = textView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0)
    let textViewTrailingAnchorConstraint = textView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + textViewTrailingMargin))

    textViewWidthAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      textViewWidthAnchorParentConstraint,
      textViewTopAnchorConstraint,
      textViewBottomAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewCenterXAnchorConstraint,
      textViewTrailingAnchorConstraint
    ])

    self.textViewWidthAnchorParentConstraint = textViewWidthAnchorParentConstraint
    self.textViewTopAnchorConstraint = textViewTopAnchorConstraint
    self.textViewBottomAnchorConstraint = textViewBottomAnchorConstraint
    self.textViewLeadingAnchorConstraint = textViewLeadingAnchorConstraint
    self.textViewCenterXAnchorConstraint = textViewCenterXAnchorConstraint
    self.textViewTrailingAnchorConstraint = textViewTrailingAnchorConstraint

    // For debugging
    textViewWidthAnchorParentConstraint.identifier = "textViewWidthAnchorParentConstraint"
    textViewTopAnchorConstraint.identifier = "textViewTopAnchorConstraint"
    textViewBottomAnchorConstraint.identifier = "textViewBottomAnchorConstraint"
    textViewLeadingAnchorConstraint.identifier = "textViewLeadingAnchorConstraint"
    textViewCenterXAnchorConstraint.identifier = "textViewCenterXAnchorConstraint"
    textViewTrailingAnchorConstraint.identifier = "textViewTrailingAnchorConstraint"
  }

  private func update() {
    textView.attributedStringValue = textViewTextStyle.apply(to: titleText)
  }
}
