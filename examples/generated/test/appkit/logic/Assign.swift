import AppKit
import Foundation

// MARK: - Assign

public class Assign: NSBox {

  // MARK: Lifecycle

  public init(text: String) {
    self.text = text

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(text: "")
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var text: String { didSet { update() } }

  // MARK: Private

  private var textView = NSTextField(labelWithString: "")

  private var textViewTextStyle = TextStyles.body1

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    textView.lineBreakMode = .byWordWrapping

    addSubview(textView)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false

    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: topAnchor)
    let textViewBottomAnchorConstraint = textView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let textViewTrailingAnchorConstraint = textView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)

    NSLayoutConstraint.activate([
      textViewTopAnchorConstraint,
      textViewBottomAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    textView.attributedStringValue = textViewTextStyle.apply(to: text)
  }
}
