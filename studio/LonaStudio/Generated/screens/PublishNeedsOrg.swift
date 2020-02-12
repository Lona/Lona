import AppKit
import Foundation

// MARK: - PublishNeedsOrg

public class PublishNeedsOrg: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(workspaceName: String, organizationName: String) {
    self.init(Parameters(workspaceName: workspaceName, organizationName: organizationName))
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

  public var workspaceName: String {
    get { return parameters.workspaceName }
    set {
      if parameters.workspaceName != newValue {
        parameters.workspaceName = newValue
      }
    }
  }

  public var organizationName: String {
    get { return parameters.organizationName }
    set {
      if parameters.organizationName != newValue {
        parameters.organizationName = newValue
      }
    }
  }

  public var onClickSubmit: (() -> Void)? {
    get { return parameters.onClickSubmit }
    set { parameters.onClickSubmit = newValue }
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

  private var titleContainerView = NSBox()
  private var publishTextView = LNATextField(labelWithString: "")
  private var workspaceTitleView = LNATextField(labelWithString: "")
  private var vSpacerView = NSBox()
  private var bodyTextView = LNATextField(labelWithString: "")
  private var vSpacer1View = NSBox()
  private var textView = LNATextField(labelWithString: "")
  private var vSpacer3View = NSBox()
  private var view1View = NSBox()
  private var organizationNameInputView = TextInput()
  private var vSpacer2View = NSBox()
  private var viewView = NSBox()
  private var submitButtonView = PrimaryButton()

  private var publishTextViewTextStyle = TextStyles.titleLight
  private var workspaceTitleViewTextStyle = TextStyles.title
  private var bodyTextViewTextStyle = TextStyles.body
  private var textViewTextStyle = TextStyles.subtitle

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    titleContainerView.boxType = .custom
    titleContainerView.borderType = .noBorder
    titleContainerView.contentViewMargins = .zero
    vSpacerView.boxType = .custom
    vSpacerView.borderType = .noBorder
    vSpacerView.contentViewMargins = .zero
    bodyTextView.lineBreakMode = .byWordWrapping
    vSpacer1View.boxType = .custom
    vSpacer1View.borderType = .noBorder
    vSpacer1View.contentViewMargins = .zero
    textView.lineBreakMode = .byWordWrapping
    vSpacer3View.boxType = .custom
    vSpacer3View.borderType = .noBorder
    vSpacer3View.contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    publishTextView.lineBreakMode = .byWordWrapping
    workspaceTitleView.lineBreakMode = .byWordWrapping
    vSpacer2View.boxType = .custom
    vSpacer2View.borderType = .noBorder
    vSpacer2View.contentViewMargins = .zero
    viewView.boxType = .custom
    viewView.borderType = .noBorder
    viewView.contentViewMargins = .zero

    addSubview(titleContainerView)
    addSubview(vSpacerView)
    addSubview(bodyTextView)
    addSubview(vSpacer1View)
    addSubview(textView)
    addSubview(vSpacer3View)
    addSubview(view1View)
    titleContainerView.addSubview(publishTextView)
    titleContainerView.addSubview(workspaceTitleView)
    view1View.addSubview(organizationNameInputView)
    view1View.addSubview(vSpacer2View)
    view1View.addSubview(viewView)
    viewView.addSubview(submitButtonView)

    publishTextView.attributedStringValue = publishTextViewTextStyle.apply(to: "Publish ")
    publishTextViewTextStyle = TextStyles.titleLight
    publishTextView.attributedStringValue = publishTextViewTextStyle.apply(to: publishTextView.attributedStringValue)
    workspaceTitleViewTextStyle = TextStyles.title
    workspaceTitleView.attributedStringValue =
      workspaceTitleViewTextStyle.apply(to: workspaceTitleView.attributedStringValue)
    vSpacerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    bodyTextView.attributedStringValue =
      bodyTextViewTextStyle
        .apply(to:
        """
First, you’ll need a Lona organization associated with your account.

If your team or company already has a Lona organization, an organization owner can add your account to it. Otherwise, create a new organization below.
""")
    bodyTextViewTextStyle = TextStyles.body
    bodyTextView.attributedStringValue = bodyTextViewTextStyle.apply(to: bodyTextView.attributedStringValue)
    vSpacer1View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    textView.attributedStringValue = textViewTextStyle.apply(to: "Create organization")
    textViewTextStyle = TextStyles.subtitle
    textView.attributedStringValue = textViewTextStyle.apply(to: textView.attributedStringValue)
    vSpacer3View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    organizationNameInputView.placeholderString = "Text"
    vSpacer2View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    submitButtonView.titleText = "Create"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    titleContainerView.translatesAutoresizingMaskIntoConstraints = false
    vSpacerView.translatesAutoresizingMaskIntoConstraints = false
    bodyTextView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer1View.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer3View.translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    publishTextView.translatesAutoresizingMaskIntoConstraints = false
    workspaceTitleView.translatesAutoresizingMaskIntoConstraints = false
    organizationNameInputView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer2View.translatesAutoresizingMaskIntoConstraints = false
    viewView.translatesAutoresizingMaskIntoConstraints = false
    submitButtonView.translatesAutoresizingMaskIntoConstraints = false

    let titleContainerViewTopAnchorConstraint = titleContainerView.topAnchor.constraint(equalTo: topAnchor)
    let titleContainerViewLeadingAnchorConstraint = titleContainerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let titleContainerViewTrailingAnchorConstraint = titleContainerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let vSpacerViewTopAnchorConstraint = vSpacerView.topAnchor.constraint(equalTo: titleContainerView.bottomAnchor)
    let vSpacerViewLeadingAnchorConstraint = vSpacerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let bodyTextViewTopAnchorConstraint = bodyTextView.topAnchor.constraint(equalTo: vSpacerView.bottomAnchor)
    let bodyTextViewLeadingAnchorConstraint = bodyTextView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let bodyTextViewTrailingAnchorConstraint = bodyTextView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let vSpacer1ViewTopAnchorConstraint = vSpacer1View.topAnchor.constraint(equalTo: bodyTextView.bottomAnchor)
    let vSpacer1ViewLeadingAnchorConstraint = vSpacer1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: vSpacer1View.bottomAnchor)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let textViewTrailingAnchorConstraint = textView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let vSpacer3ViewTopAnchorConstraint = vSpacer3View.topAnchor.constraint(equalTo: textView.bottomAnchor)
    let vSpacer3ViewLeadingAnchorConstraint = vSpacer3View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewBottomAnchorConstraint = view1View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: vSpacer3View.bottomAnchor)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewTrailingAnchorConstraint = view1View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let publishTextViewHeightAnchorParentConstraint = publishTextView
      .heightAnchor
      .constraint(lessThanOrEqualTo: titleContainerView.heightAnchor)
    let workspaceTitleViewHeightAnchorParentConstraint = workspaceTitleView
      .heightAnchor
      .constraint(lessThanOrEqualTo: titleContainerView.heightAnchor)
    let publishTextViewLeadingAnchorConstraint = publishTextView
      .leadingAnchor
      .constraint(equalTo: titleContainerView.leadingAnchor)
    let publishTextViewTopAnchorConstraint = publishTextView.topAnchor.constraint(equalTo: titleContainerView.topAnchor)
    let publishTextViewBottomAnchorConstraint = publishTextView
      .bottomAnchor
      .constraint(equalTo: titleContainerView.bottomAnchor)
    let workspaceTitleViewLeadingAnchorConstraint = workspaceTitleView
      .leadingAnchor
      .constraint(equalTo: publishTextView.trailingAnchor)
    let workspaceTitleViewTopAnchorConstraint = workspaceTitleView
      .topAnchor
      .constraint(equalTo: titleContainerView.topAnchor)
    let workspaceTitleViewBottomAnchorConstraint = workspaceTitleView
      .bottomAnchor
      .constraint(equalTo: titleContainerView.bottomAnchor)
    let vSpacerViewHeightAnchorConstraint = vSpacerView.heightAnchor.constraint(equalToConstant: 32)
    let vSpacerViewWidthAnchorConstraint = vSpacerView.widthAnchor.constraint(equalToConstant: 0)
    let vSpacer1ViewHeightAnchorConstraint = vSpacer1View.heightAnchor.constraint(equalToConstant: 72)
    let vSpacer1ViewWidthAnchorConstraint = vSpacer1View.widthAnchor.constraint(equalToConstant: 0)
    let vSpacer3ViewHeightAnchorConstraint = vSpacer3View.heightAnchor.constraint(equalToConstant: 20)
    let vSpacer3ViewWidthAnchorConstraint = vSpacer3View.widthAnchor.constraint(equalToConstant: 0)
    let organizationNameInputViewTopAnchorConstraint = organizationNameInputView
      .topAnchor
      .constraint(equalTo: view1View.topAnchor)
    let organizationNameInputViewLeadingAnchorConstraint = organizationNameInputView
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor)
    let organizationNameInputViewTrailingAnchorConstraint = organizationNameInputView
      .trailingAnchor
      .constraint(equalTo: view1View.trailingAnchor)
    let vSpacer2ViewTopAnchorConstraint = vSpacer2View
      .topAnchor
      .constraint(equalTo: organizationNameInputView.bottomAnchor)
    let vSpacer2ViewTrailingAnchorConstraint = vSpacer2View.trailingAnchor.constraint(equalTo: view1View.trailingAnchor)
    let viewViewBottomAnchorConstraint = viewView.bottomAnchor.constraint(equalTo: view1View.bottomAnchor)
    let viewViewTopAnchorConstraint = viewView.topAnchor.constraint(equalTo: vSpacer2View.bottomAnchor)
    let viewViewTrailingAnchorConstraint = viewView.trailingAnchor.constraint(equalTo: view1View.trailingAnchor)
    let vSpacer2ViewHeightAnchorConstraint = vSpacer2View.heightAnchor.constraint(equalToConstant: 8)
    let vSpacer2ViewWidthAnchorConstraint = vSpacer2View.widthAnchor.constraint(equalToConstant: 0)
    let viewViewWidthAnchorConstraint = viewView.widthAnchor.constraint(equalToConstant: 250)
    let submitButtonViewTopAnchorConstraint = submitButtonView.topAnchor.constraint(equalTo: viewView.topAnchor)
    let submitButtonViewBottomAnchorConstraint = submitButtonView
      .bottomAnchor
      .constraint(equalTo: viewView.bottomAnchor)
    let submitButtonViewLeadingAnchorConstraint = submitButtonView
      .leadingAnchor
      .constraint(equalTo: viewView.leadingAnchor)
    let submitButtonViewTrailingAnchorConstraint = submitButtonView
      .trailingAnchor
      .constraint(equalTo: viewView.trailingAnchor)

    publishTextViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    workspaceTitleViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      titleContainerViewTopAnchorConstraint,
      titleContainerViewLeadingAnchorConstraint,
      titleContainerViewTrailingAnchorConstraint,
      vSpacerViewTopAnchorConstraint,
      vSpacerViewLeadingAnchorConstraint,
      bodyTextViewTopAnchorConstraint,
      bodyTextViewLeadingAnchorConstraint,
      bodyTextViewTrailingAnchorConstraint,
      vSpacer1ViewTopAnchorConstraint,
      vSpacer1ViewLeadingAnchorConstraint,
      textViewTopAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint,
      vSpacer3ViewTopAnchorConstraint,
      vSpacer3ViewLeadingAnchorConstraint,
      view1ViewBottomAnchorConstraint,
      view1ViewTopAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewTrailingAnchorConstraint,
      publishTextViewHeightAnchorParentConstraint,
      workspaceTitleViewHeightAnchorParentConstraint,
      publishTextViewLeadingAnchorConstraint,
      publishTextViewTopAnchorConstraint,
      publishTextViewBottomAnchorConstraint,
      workspaceTitleViewLeadingAnchorConstraint,
      workspaceTitleViewTopAnchorConstraint,
      workspaceTitleViewBottomAnchorConstraint,
      vSpacerViewHeightAnchorConstraint,
      vSpacerViewWidthAnchorConstraint,
      vSpacer1ViewHeightAnchorConstraint,
      vSpacer1ViewWidthAnchorConstraint,
      vSpacer3ViewHeightAnchorConstraint,
      vSpacer3ViewWidthAnchorConstraint,
      organizationNameInputViewTopAnchorConstraint,
      organizationNameInputViewLeadingAnchorConstraint,
      organizationNameInputViewTrailingAnchorConstraint,
      vSpacer2ViewTopAnchorConstraint,
      vSpacer2ViewTrailingAnchorConstraint,
      viewViewBottomAnchorConstraint,
      viewViewTopAnchorConstraint,
      viewViewTrailingAnchorConstraint,
      vSpacer2ViewHeightAnchorConstraint,
      vSpacer2ViewWidthAnchorConstraint,
      viewViewWidthAnchorConstraint,
      submitButtonViewTopAnchorConstraint,
      submitButtonViewBottomAnchorConstraint,
      submitButtonViewLeadingAnchorConstraint,
      submitButtonViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    workspaceTitleView.attributedStringValue = workspaceTitleViewTextStyle.apply(to: workspaceName)
    organizationNameInputView.textValue = organizationName
    organizationNameInputView.onChangeTextValue = handleOnChangeTextValue
    submitButtonView.onClick = handleOnClickSubmit
  }

  private func handleOnClickSubmit() {
    onClickSubmit?()
  }

  private func handleOnChangeTextValue(_ arg0: String) {
    onChangeTextValue?(arg0)
  }
}

// MARK: - Parameters

extension PublishNeedsOrg {
  public struct Parameters: Equatable {
    public var workspaceName: String
    public var organizationName: String
    public var onClickSubmit: (() -> Void)?
    public var onChangeTextValue: StringHandler

    public init(
      workspaceName: String,
      organizationName: String,
      onClickSubmit: (() -> Void)? = nil,
      onChangeTextValue: StringHandler = nil)
    {
      self.workspaceName = workspaceName
      self.organizationName = organizationName
      self.onClickSubmit = onClickSubmit
      self.onChangeTextValue = onChangeTextValue
    }

    public init() {
      self.init(workspaceName: "", organizationName: "")
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.workspaceName == rhs.workspaceName && lhs.organizationName == rhs.organizationName
    }
  }
}

// MARK: - Model

extension PublishNeedsOrg {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "PublishNeedsOrg"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      workspaceName: String,
      organizationName: String,
      onClickSubmit: (() -> Void)? = nil,
      onChangeTextValue: StringHandler = nil)
    {
      self
        .init(
          Parameters(
            workspaceName: workspaceName,
            organizationName: organizationName,
            onClickSubmit: onClickSubmit,
            onChangeTextValue: onChangeTextValue))
    }

    public init() {
      self.init(workspaceName: "", organizationName: "")
    }
  }
}
