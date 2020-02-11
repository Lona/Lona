import AppKit
import Foundation

// MARK: - CustomParametersEditorSheet

public class CustomParametersEditorSheet: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(titleText: String, cancelText: String, submitText: String) {
    self.init(Parameters(titleText: titleText, cancelText: cancelText, submitText: submitText))
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

  public var onSubmit: (() -> Void)? {
    get { return parameters.onSubmit }
    set { parameters.onSubmit = newValue }
  }

  public var onCancel: (() -> Void)? {
    get { return parameters.onCancel }
    set { parameters.onCancel = newValue }
  }

  public var titleText: String {
    get { return parameters.titleText }
    set {
      if parameters.titleText != newValue {
        parameters.titleText = newValue
      }
    }
  }

  public var cancelText: String {
    get { return parameters.cancelText }
    set {
      if parameters.cancelText != newValue {
        parameters.cancelText = newValue
      }
    }
  }

  public var submitText: String {
    get { return parameters.submitText }
    set {
      if parameters.submitText != newValue {
        parameters.submitText = newValue
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

  private var titleView = LNATextField(labelWithString: "")
  var customContentView = NSBox()
  private var footerView = NSBox()
  private var cancelButtonView = Button()
  private var footerSpacerView = NSBox()
  private var doneButtonView = Button()

  private var titleViewTextStyle = TextStyles.large

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    customContentView.boxType = .custom
    customContentView.borderType = .lineBorder
    customContentView.contentViewMargins = .zero
    footerView.boxType = .custom
    footerView.borderType = .noBorder
    footerView.contentViewMargins = .zero
    footerSpacerView.boxType = .custom
    footerSpacerView.borderType = .noBorder
    footerSpacerView.contentViewMargins = .zero

    addSubview(titleView)
    addSubview(customContentView)
    addSubview(footerView)
    footerView.addSubview(cancelButtonView)
    footerView.addSubview(footerSpacerView)
    footerView.addSubview(doneButtonView)

    titleViewTextStyle = TextStyles.large
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    customContentView.fillColor = Colors.dividerSubtle
    customContentView.borderColor = Colors.darkTransparentOutline
    customContentView.cornerRadius = 1
    customContentView.borderWidth = 1
    footerSpacerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    customContentView.translatesAutoresizingMaskIntoConstraints = false
    footerView.translatesAutoresizingMaskIntoConstraints = false
    cancelButtonView.translatesAutoresizingMaskIntoConstraints = false
    footerSpacerView.translatesAutoresizingMaskIntoConstraints = false
    doneButtonView.translatesAutoresizingMaskIntoConstraints = false

    let widthAnchorConstraint = widthAnchor.constraint(equalToConstant: 480)
    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: topAnchor, constant: 20)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
    let titleViewTrailingAnchorConstraint = titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
    let customContentViewTopAnchorConstraint = customContentView
      .topAnchor
      .constraint(equalTo: titleView.bottomAnchor, constant: 20)
    let customContentViewLeadingAnchorConstraint = customContentView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: 20)
    let customContentViewTrailingAnchorConstraint = customContentView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -20)
    let footerViewBottomAnchorConstraint = footerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
    let footerViewTopAnchorConstraint = footerView
      .topAnchor
      .constraint(equalTo: customContentView.bottomAnchor, constant: 20)
    let footerViewLeadingAnchorConstraint = footerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
    let footerViewTrailingAnchorConstraint = footerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -20)
    let customContentViewHeightAnchorConstraint = customContentView.heightAnchor.constraint(equalToConstant: 200)
    let cancelButtonViewHeightAnchorParentConstraint = cancelButtonView
      .heightAnchor
      .constraint(lessThanOrEqualTo: footerView.heightAnchor)
    let footerSpacerViewHeightAnchorParentConstraint = footerSpacerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: footerView.heightAnchor)
    let doneButtonViewHeightAnchorParentConstraint = doneButtonView
      .heightAnchor
      .constraint(lessThanOrEqualTo: footerView.heightAnchor)
    let cancelButtonViewLeadingAnchorConstraint = cancelButtonView
      .leadingAnchor
      .constraint(equalTo: footerView.leadingAnchor)
    let cancelButtonViewTopAnchorConstraint = cancelButtonView.topAnchor.constraint(equalTo: footerView.topAnchor)
    let cancelButtonViewBottomAnchorConstraint = cancelButtonView
      .bottomAnchor
      .constraint(equalTo: footerView.bottomAnchor)
    let footerSpacerViewLeadingAnchorConstraint = footerSpacerView
      .leadingAnchor
      .constraint(equalTo: cancelButtonView.trailingAnchor)
    let footerSpacerViewBottomAnchorConstraint = footerSpacerView
      .bottomAnchor
      .constraint(equalTo: footerView.bottomAnchor)
    let doneButtonViewTrailingAnchorConstraint = doneButtonView
      .trailingAnchor
      .constraint(equalTo: footerView.trailingAnchor)
    let doneButtonViewLeadingAnchorConstraint = doneButtonView
      .leadingAnchor
      .constraint(equalTo: footerSpacerView.trailingAnchor)
    let doneButtonViewTopAnchorConstraint = doneButtonView.topAnchor.constraint(equalTo: footerView.topAnchor)
    let doneButtonViewBottomAnchorConstraint = doneButtonView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor)
    let footerSpacerViewHeightAnchorConstraint = footerSpacerView.heightAnchor.constraint(equalToConstant: 0)

    cancelButtonViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    footerSpacerViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    doneButtonViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      widthAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      customContentViewTopAnchorConstraint,
      customContentViewLeadingAnchorConstraint,
      customContentViewTrailingAnchorConstraint,
      footerViewBottomAnchorConstraint,
      footerViewTopAnchorConstraint,
      footerViewLeadingAnchorConstraint,
      footerViewTrailingAnchorConstraint,
      customContentViewHeightAnchorConstraint,
      cancelButtonViewHeightAnchorParentConstraint,
      footerSpacerViewHeightAnchorParentConstraint,
      doneButtonViewHeightAnchorParentConstraint,
      cancelButtonViewLeadingAnchorConstraint,
      cancelButtonViewTopAnchorConstraint,
      cancelButtonViewBottomAnchorConstraint,
      footerSpacerViewLeadingAnchorConstraint,
      footerSpacerViewBottomAnchorConstraint,
      doneButtonViewTrailingAnchorConstraint,
      doneButtonViewLeadingAnchorConstraint,
      doneButtonViewTopAnchorConstraint,
      doneButtonViewBottomAnchorConstraint,
      footerSpacerViewHeightAnchorConstraint
    ])
  }

  private func update() {
    doneButtonView.onClick = handleOnSubmit
    cancelButtonView.onClick = handleOnCancel
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleText)
    doneButtonView.titleText = submitText
    cancelButtonView.titleText = cancelText
  }

  private func handleOnSubmit() {
    onSubmit?()
  }

  private func handleOnCancel() {
    onCancel?()
  }
}

// MARK: - Parameters

extension CustomParametersEditorSheet {
  public struct Parameters: Equatable {
    public var titleText: String
    public var cancelText: String
    public var submitText: String
    public var onSubmit: (() -> Void)?
    public var onCancel: (() -> Void)?

    public init(
      titleText: String,
      cancelText: String,
      submitText: String,
      onSubmit: (() -> Void)? = nil,
      onCancel: (() -> Void)? = nil)
    {
      self.titleText = titleText
      self.cancelText = cancelText
      self.submitText = submitText
      self.onSubmit = onSubmit
      self.onCancel = onCancel
    }

    public init() {
      self.init(titleText: "", cancelText: "", submitText: "")
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.titleText == rhs.titleText && lhs.cancelText == rhs.cancelText && lhs.submitText == rhs.submitText
    }
  }
}

// MARK: - Model

extension CustomParametersEditorSheet {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "CustomParametersEditorSheet"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      titleText: String,
      cancelText: String,
      submitText: String,
      onSubmit: (() -> Void)? = nil,
      onCancel: (() -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            titleText: titleText,
            cancelText: cancelText,
            submitText: submitText,
            onSubmit: onSubmit,
            onCancel: onCancel))
    }

    public init() {
      self.init(titleText: "", cancelText: "", submitText: "")
    }
  }
}
