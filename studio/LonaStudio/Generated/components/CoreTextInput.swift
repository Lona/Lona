import AppKit
import Foundation

// MARK: - CoreTextInput

public class CoreTextInput: NSBox {

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

  private var textInputView = TextInput()

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var textInputViewTopMargin: CGFloat = 0
  private var textInputViewTrailingMargin: CGFloat = 0
  private var textInputViewBottomMargin: CGFloat = 0
  private var textInputViewLeadingMargin: CGFloat = 0

  private var heightAnchorConstraint: NSLayoutConstraint?
  private var textInputViewTopAnchorConstraint: NSLayoutConstraint?
  private var textInputViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textInputViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero

    addSubview(textInputView)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    textInputView.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 21)
    let textInputViewTopAnchorConstraint = textInputView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + textInputViewTopMargin)
    let textInputViewLeadingAnchorConstraint = textInputView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + textInputViewLeadingMargin)
    let textInputViewTrailingAnchorConstraint = textInputView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + textInputViewTrailingMargin))

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      textInputViewTopAnchorConstraint,
      textInputViewLeadingAnchorConstraint,
      textInputViewTrailingAnchorConstraint
    ])

    self.heightAnchorConstraint = heightAnchorConstraint
    self.textInputViewTopAnchorConstraint = textInputViewTopAnchorConstraint
    self.textInputViewLeadingAnchorConstraint = textInputViewLeadingAnchorConstraint
    self.textInputViewTrailingAnchorConstraint = textInputViewTrailingAnchorConstraint

    // For debugging
    heightAnchorConstraint.identifier = "heightAnchorConstraint"
    textInputViewTopAnchorConstraint.identifier = "textInputViewTopAnchorConstraint"
    textInputViewLeadingAnchorConstraint.identifier = "textInputViewLeadingAnchorConstraint"
    textInputViewTrailingAnchorConstraint.identifier = "textInputViewTrailingAnchorConstraint"
  }

  private func update() {
    textInputView.textValue = textValue
    textInputView.onChangeTextValue = onChangeTextValue
  }
}
