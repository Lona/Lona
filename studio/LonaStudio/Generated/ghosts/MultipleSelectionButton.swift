import AppKit
import Foundation

// MARK: - MultipleSelectionButton

public class MultipleSelectionButton: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(selectedIndices: [Int], options: [String]) {
    self.init(Parameters(selectedIndices: selectedIndices, options: options))
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

  public var selectedIndices: [Int] {
    get { return parameters.selectedIndices }
    set {
      if parameters.selectedIndices != newValue {
        parameters.selectedIndices = newValue
      }
    }
  }

  public var onChangeSelectedIndices: (([Int]) -> Void)? {
    get { return parameters.onChangeSelectedIndices }
    set { parameters.onChangeSelectedIndices = newValue }
  }

  public var options: [String] {
    get { return parameters.options }
    set {
      if parameters.options != newValue {
        parameters.options = newValue
      }
    }
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

    borderColor = Colors.dividerSubtle
    borderWidth = 1
    textView.attributedStringValue = textViewTextStyle.apply(to: "Multiple selection button")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false

    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: topAnchor, constant: 1)
    let textViewBottomAnchorConstraint = textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1)
    let textViewLeadingAnchorConstraint = textView
      .leadingAnchor
      .constraint(greaterThanOrEqualTo: leadingAnchor, constant: 1)
    let textViewCenterXAnchorConstraint = textView.centerXAnchor.constraint(equalTo: centerXAnchor)
    let textViewTrailingAnchorConstraint = textView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -1)

    NSLayoutConstraint.activate([
      textViewTopAnchorConstraint,
      textViewBottomAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewCenterXAnchorConstraint,
      textViewTrailingAnchorConstraint
    ])
  }

  private func update() {}

  private func handleOnChangeSelectedIndices(_ arg0: [Int]) {
    onChangeSelectedIndices?(arg0)
  }
}

// MARK: - Parameters

extension MultipleSelectionButton {
  public struct Parameters: Equatable {
    public var selectedIndices: [Int]
    public var options: [String]
    public var onChangeSelectedIndices: (([Int]) -> Void)?

    public init(selectedIndices: [Int], options: [String], onChangeSelectedIndices: (([Int]) -> Void)? = nil) {
      self.selectedIndices = selectedIndices
      self.options = options
      self.onChangeSelectedIndices = onChangeSelectedIndices
    }

    public init() {
      self.init(selectedIndices: [], options: [])
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.selectedIndices == rhs.selectedIndices && lhs.options == rhs.options
    }
  }
}

// MARK: - Model

extension MultipleSelectionButton {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "MultipleSelectionButton"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(selectedIndices: [Int], options: [String], onChangeSelectedIndices: (([Int]) -> Void)? = nil) {
      self
        .init(
          Parameters(
            selectedIndices: selectedIndices,
            options: options,
            onChangeSelectedIndices: onChangeSelectedIndices))
    }

    public init() {
      self.init(selectedIndices: [], options: [])
    }
  }
}
