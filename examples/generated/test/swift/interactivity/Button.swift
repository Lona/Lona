import UIKit
import Foundation

// MARK: - Button

public class Button: UIView {

  // MARK: Lifecycle

  public init(label: String, secondary: Bool) {
    self.label = label
    self.secondary = secondary

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(label: "", secondary: false)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var label: String { didSet { update() } }
  public var onTap: (() -> Void)? { didSet { update() } }
  public var secondary: Bool { didSet { update() } }

  // MARK: Private

  private var textView = UILabel()

  private var textViewTextStyle = TextStyles.button

  private var hovered = false
  private var pressed = false
  private var onPress: (() -> Void)?

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
      .constraint(lessThanOrEqualTo: widthAnchor, constant: -32)
    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: topAnchor, constant: 12)
    let textViewBottomAnchorConstraint = textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16)
    let textViewTrailingAnchorConstraint = textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)

    textViewWidthAnchorParentConstraint.priority = UILayoutPriority.defaultLow

    NSLayoutConstraint.activate([
      textViewWidthAnchorParentConstraint,
      textViewTopAnchorConstraint,
      textViewBottomAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint
    ])
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
    if secondary {
      backgroundColor = Colors.lightblue100
    }
  }
}
