import AppKit
import Foundation

// MARK: - ControlledDropdown

public class ControlledDropdown: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(values: [String], selectedIndex: Int) {
    self.init(Parameters(values: values, selectedIndex: selectedIndex))
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

  public var values: [String] {
    get { return parameters.values }
    set {
      if parameters.values != newValue {
        parameters.values = newValue
      }
    }
  }

  public var selectedIndex: Int {
    get { return parameters.selectedIndex }
    set {
      if parameters.selectedIndex != newValue {
        parameters.selectedIndex = newValue
      }
    }
  }

  public var onChangeIndex: ((Int) -> Void)? {
    get { return parameters.onChangeIndex }
    set { parameters.onChangeIndex = newValue }
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
  private var arrowsView = NSBox()

  private var textViewTextStyle = TextStyles.regular

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    textView.lineBreakMode = .byWordWrapping
    arrowsView.boxType = .custom
    arrowsView.borderType = .noBorder
    arrowsView.contentViewMargins = .zero

    addSubview(textView)
    addSubview(arrowsView)

    fillColor = Colors.headerBackground
    cornerRadius = 4
    textView.attributedStringValue = textViewTextStyle.apply(to: "Value")
    arrowsView.fillColor = Colors.bluea400
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    arrowsView.translatesAutoresizingMaskIntoConstraints = false

    let textViewHeightAnchorParentConstraint = textView
      .heightAnchor
      .constraint(lessThanOrEqualTo: heightAnchor, constant: -8)
    let arrowsViewHeightAnchorParentConstraint = arrowsView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4)
    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: topAnchor, constant: 4)
    let textViewBottomAnchorConstraint = textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
    let arrowsViewTrailingAnchorConstraint = arrowsView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let arrowsViewLeadingAnchorConstraint = arrowsView
      .leadingAnchor
      .constraint(equalTo: textView.trailingAnchor, constant: 4)
    let arrowsViewTopAnchorConstraint = arrowsView.topAnchor.constraint(equalTo: topAnchor)
    let arrowsViewBottomAnchorConstraint = arrowsView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let arrowsViewWidthAnchorConstraint = arrowsView.widthAnchor.constraint(equalToConstant: 16)

    textViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    arrowsViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      textViewHeightAnchorParentConstraint,
      arrowsViewHeightAnchorParentConstraint,
      textViewLeadingAnchorConstraint,
      textViewTopAnchorConstraint,
      textViewBottomAnchorConstraint,
      arrowsViewTrailingAnchorConstraint,
      arrowsViewLeadingAnchorConstraint,
      arrowsViewTopAnchorConstraint,
      arrowsViewBottomAnchorConstraint,
      arrowsViewWidthAnchorConstraint
    ])
  }

  private func update() {}

  private func handleOnChangeIndex(_ arg0: Int) {
    onChangeIndex?(arg0)
  }
}

// MARK: - Parameters

extension ControlledDropdown {
  public struct Parameters: Equatable {
    public var values: [String]
    public var selectedIndex: Int
    public var onChangeIndex: ((Int) -> Void)?

    public init(values: [String], selectedIndex: Int, onChangeIndex: ((Int) -> Void)? = nil) {
      self.values = values
      self.selectedIndex = selectedIndex
      self.onChangeIndex = onChangeIndex
    }

    public init() {
      self.init(values: [], selectedIndex: 0)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.values == rhs.values && lhs.selectedIndex == rhs.selectedIndex
    }
  }
}

// MARK: - Model

extension ControlledDropdown {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "ControlledDropdown"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(values: [String], selectedIndex: Int, onChangeIndex: ((Int) -> Void)? = nil) {
      self.init(Parameters(values: values, selectedIndex: selectedIndex, onChangeIndex: onChangeIndex))
    }

    public init() {
      self.init(values: [], selectedIndex: 0)
    }
  }
}
