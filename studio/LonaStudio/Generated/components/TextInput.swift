import AppKit
import Foundation

// MARK: - TextInput

public class TextInput: NSBox {

  // MARK: Lifecycle

  public init(textValue: String, onChangeTextValue: StringHandler) {
    self.textValue = textValue
    self.onChangeTextValue = onChangeTextValue

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(textValue: "", onChangeTextValue: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var textValue: String { didSet { update() } }
  public var onChangeTextValue: StringHandler { didSet { update() } }

  // MARK: Private

  private var textView = NSTextField(labelWithString: "")

  private var textViewTextStyle = TextStyles.regular

  private var topPadding: CGFloat = 2
  private var trailingPadding: CGFloat = 2
  private var bottomPadding: CGFloat = 2
  private var leadingPadding: CGFloat = 2
  private var textViewTopMargin: CGFloat = 0
  private var textViewTrailingMargin: CGFloat = 0
  private var textViewBottomMargin: CGFloat = 0
  private var textViewLeadingMargin: CGFloat = 0

  private var textViewTopAnchorConstraint: NSLayoutConstraint?
  private var textViewBottomAnchorConstraint: NSLayoutConstraint?
  private var textViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .lineBorder
    contentViewMargins = .zero
    textView.lineBreakMode = .byWordWrapping

    addSubview(textView)

    fillColor = Colors.white
    borderWidth = 1
    borderColor = Colors.grey400
    textView.attributedStringValue = textViewTextStyle.apply(to: "Input text")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false

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
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + textViewTrailingMargin))

    NSLayoutConstraint.activate([
      textViewTopAnchorConstraint,
      textViewBottomAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint
    ])

    self.textViewTopAnchorConstraint = textViewTopAnchorConstraint
    self.textViewBottomAnchorConstraint = textViewBottomAnchorConstraint
    self.textViewLeadingAnchorConstraint = textViewLeadingAnchorConstraint
    self.textViewTrailingAnchorConstraint = textViewTrailingAnchorConstraint

    // For debugging
    textViewTopAnchorConstraint.identifier = "textViewTopAnchorConstraint"
    textViewBottomAnchorConstraint.identifier = "textViewBottomAnchorConstraint"
    textViewLeadingAnchorConstraint.identifier = "textViewLeadingAnchorConstraint"
    textViewTrailingAnchorConstraint.identifier = "textViewTrailingAnchorConstraint"
  }

  private func update() {}
}
