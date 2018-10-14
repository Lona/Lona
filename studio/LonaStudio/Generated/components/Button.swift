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
      .constraint(lessThanOrEqualTo: widthAnchor, constant: -22)
    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: topAnchor, constant: 3)
    let textViewBottomAnchorConstraint = textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 11)
    let textViewCenterXAnchorConstraint = textView.centerXAnchor.constraint(equalTo: centerXAnchor)
    let textViewTrailingAnchorConstraint = textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -11)

    textViewWidthAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      textViewWidthAnchorParentConstraint,
      textViewTopAnchorConstraint,
      textViewBottomAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewCenterXAnchorConstraint,
      textViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    textView.attributedStringValue = textViewTextStyle.apply(to: titleText)
  }
}
