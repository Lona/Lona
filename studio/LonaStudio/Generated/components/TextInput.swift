import AppKit
import Foundation

// MARK: - TextInput

public class TextInput: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(textValue: String) {
    self.init(Parameters(textValue: textValue))
  }

  public convenience init() {
    self.init(Parameters())
  }

  public required init?(coder aDecoder: NSCoder) {
    self.parameters = Parameters()

    super.init(coder: aDecoder)

    setUpViews()
    setUpConstraints()

    update()
  }

  // MARK: Public

  public var textValue: String {
    get { return parameters.textValue }
    set {
      if parameters.textValue != newValue {
        parameters.textValue = newValue
      }
    }
  }

  public var onChangeTextValue: StringHandler {
    get { return parameters.onChangeTextValue }
    set { parameters.onChangeTextValue = newValue }
  }

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

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

  private func handleOnChangeTextValue(_ arg0: String) {
    onChangeTextValue?(arg0)
  }
}

// MARK: - Parameters

extension TextInput {
  public struct Parameters: Equatable {
    public var textValue: String
    public var onChangeTextValue: StringHandler

    public init(textValue: String, onChangeTextValue: StringHandler = nil) {
      self.textValue = textValue
      self.onChangeTextValue = onChangeTextValue
    }

    public init() {
      self.init(textValue: "")
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.textValue == rhs.textValue
    }
  }
}

// MARK: - Model

extension TextInput {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "TextInput"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(textValue: String, onChangeTextValue: StringHandler = nil) {
      self.init(Parameters(textValue: textValue, onChangeTextValue: onChangeTextValue))
    }

    public init() {
      self.init(textValue: "")
    }
  }
}
