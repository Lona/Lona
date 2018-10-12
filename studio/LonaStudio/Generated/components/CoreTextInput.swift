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
    let textInputViewTopAnchorConstraint = textInputView.topAnchor.constraint(equalTo: topAnchor)
    let textInputViewLeadingAnchorConstraint = textInputView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let textInputViewTrailingAnchorConstraint = textInputView.trailingAnchor.constraint(equalTo: trailingAnchor)

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      textInputViewTopAnchorConstraint,
      textInputViewLeadingAnchorConstraint,
      textInputViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    textInputView.textValue = textValue
    textInputView.onChangeTextValue = onChangeTextValue
  }
}
