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

  private var textView = LNATextField(labelWithString: "")

  private var textViewTextStyle = TextStyles.regular

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

    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: topAnchor, constant: 3)
    let textViewBottomAnchorConstraint = textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3)
    let textViewTrailingAnchorConstraint = textView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -3)

    NSLayoutConstraint.activate([
      textViewTopAnchorConstraint,
      textViewBottomAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint
    ])
  }

  private func update() {}
}
