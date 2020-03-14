import AppKit
import Foundation

// MARK: - PublishExistingRepo

public class PublishExistingRepo: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(workspaceName: String, organizationName: String, repositoryName: String) {
    self
      .init(
        Parameters(workspaceName: workspaceName, organizationName: organizationName, repositoryName: repositoryName))
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

  public var repositoryName: String {
    get { return parameters.repositoryName }
    set {
      if parameters.repositoryName != newValue {
        parameters.repositoryName = newValue
      }
    }
  }

  public var onChangeRepositoryName: StringHandler {
    get { return parameters.onChangeRepositoryName }
    set { parameters.onChangeRepositoryName = newValue }
  }

  public var onClickSubmitButton: (() -> Void)? {
    get { return parameters.onClickSubmitButton }
    set { parameters.onClickSubmitButton = newValue }
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
  private var publishText1View = LNATextField(labelWithString: "")
  private var orgTitleView = LNATextField(labelWithString: "")
  private var vSpacerView = NSBox()
  private var bodyTextView = LNATextField(labelWithString: "")
  private var vSpacer3View = NSBox()
  private var repositoryNameInputView = TextInput()
  private var view2View = NSBox()
  private var vSpacer4View = NSBox()
  private var view1View = NSBox()
  private var viewView = NSBox()
  private var submitButtonView = PrimaryButton()

  private var publishTextViewTextStyle = TextStyles.titleLight
  private var workspaceTitleViewTextStyle = TextStyles.title
  private var publishText1ViewTextStyle = TextStyles.titleLight
  private var orgTitleViewTextStyle = TextStyles.title
  private var bodyTextViewTextStyle = TextStyles.body

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
    vSpacer3View.boxType = .custom
    vSpacer3View.borderType = .noBorder
    vSpacer3View.contentViewMargins = .zero
    view2View.boxType = .custom
    view2View.borderType = .noBorder
    view2View.contentViewMargins = .zero
    vSpacer4View.boxType = .custom
    vSpacer4View.borderType = .noBorder
    vSpacer4View.contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    publishTextView.lineBreakMode = .byWordWrapping
    workspaceTitleView.lineBreakMode = .byWordWrapping
    publishText1View.lineBreakMode = .byWordWrapping
    orgTitleView.lineBreakMode = .byWordWrapping
    viewView.boxType = .custom
    viewView.borderType = .noBorder
    viewView.contentViewMargins = .zero

    addSubview(titleContainerView)
    addSubview(vSpacerView)
    addSubview(bodyTextView)
    addSubview(vSpacer3View)
    addSubview(repositoryNameInputView)
    addSubview(view2View)
    addSubview(vSpacer4View)
    addSubview(view1View)
    titleContainerView.addSubview(publishTextView)
    titleContainerView.addSubview(workspaceTitleView)
    titleContainerView.addSubview(publishText1View)
    titleContainerView.addSubview(orgTitleView)
    view1View.addSubview(viewView)
    viewView.addSubview(submitButtonView)

    publishTextView.attributedStringValue = publishTextViewTextStyle.apply(to: "Publish ")
    publishTextViewTextStyle = TextStyles.titleLight
    publishTextView.attributedStringValue = publishTextViewTextStyle.apply(to: publishTextView.attributedStringValue)
    workspaceTitleViewTextStyle = TextStyles.title
    workspaceTitleView.attributedStringValue =
      workspaceTitleViewTextStyle.apply(to: workspaceTitleView.attributedStringValue)
    publishText1View.attributedStringValue = publishText1ViewTextStyle.apply(to: " to ")
    publishText1ViewTextStyle = TextStyles.titleLight
    publishText1View.attributedStringValue = publishText1ViewTextStyle.apply(to: publishText1View.attributedStringValue)
    orgTitleViewTextStyle = TextStyles.title
    orgTitleView.attributedStringValue = orgTitleViewTextStyle.apply(to: orgTitleView.attributedStringValue)
    vSpacerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    bodyTextView.attributedStringValue =
      bodyTextViewTextStyle
        .apply(to:
        "Paste the URL of the repository you'd like to sync this Lona workspace to. The repository must be empty.")
    bodyTextViewTextStyle = TextStyles.body
    bodyTextView.attributedStringValue = bodyTextViewTextStyle.apply(to: bodyTextView.attributedStringValue)
    vSpacer3View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    vSpacer4View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    submitButtonView.titleText = "Sync to repository"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    titleContainerView.translatesAutoresizingMaskIntoConstraints = false
    vSpacerView.translatesAutoresizingMaskIntoConstraints = false
    bodyTextView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer3View.translatesAutoresizingMaskIntoConstraints = false
    repositoryNameInputView.translatesAutoresizingMaskIntoConstraints = false
    view2View.translatesAutoresizingMaskIntoConstraints = false
    vSpacer4View.translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    publishTextView.translatesAutoresizingMaskIntoConstraints = false
    workspaceTitleView.translatesAutoresizingMaskIntoConstraints = false
    publishText1View.translatesAutoresizingMaskIntoConstraints = false
    orgTitleView.translatesAutoresizingMaskIntoConstraints = false
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
    let vSpacer3ViewTopAnchorConstraint = vSpacer3View.topAnchor.constraint(equalTo: bodyTextView.bottomAnchor)
    let vSpacer3ViewLeadingAnchorConstraint = vSpacer3View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let repositoryNameInputViewTopAnchorConstraint = repositoryNameInputView
      .topAnchor
      .constraint(equalTo: vSpacer3View.bottomAnchor)
    let repositoryNameInputViewLeadingAnchorConstraint = repositoryNameInputView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let repositoryNameInputViewTrailingAnchorConstraint = repositoryNameInputView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let view2ViewTopAnchorConstraint = view2View.topAnchor.constraint(equalTo: repositoryNameInputView.bottomAnchor)
    let view2ViewLeadingAnchorConstraint = view2View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view2ViewTrailingAnchorConstraint = view2View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let vSpacer4ViewTopAnchorConstraint = vSpacer4View.topAnchor.constraint(equalTo: view2View.bottomAnchor)
    let vSpacer4ViewLeadingAnchorConstraint = vSpacer4View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewBottomAnchorConstraint = view1View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: vSpacer4View.bottomAnchor)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewTrailingAnchorConstraint = view1View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let publishTextViewHeightAnchorParentConstraint = publishTextView
      .heightAnchor
      .constraint(lessThanOrEqualTo: titleContainerView.heightAnchor)
    let workspaceTitleViewHeightAnchorParentConstraint = workspaceTitleView
      .heightAnchor
      .constraint(lessThanOrEqualTo: titleContainerView.heightAnchor)
    let publishText1ViewHeightAnchorParentConstraint = publishText1View
      .heightAnchor
      .constraint(lessThanOrEqualTo: titleContainerView.heightAnchor)
    let orgTitleViewHeightAnchorParentConstraint = orgTitleView
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
    let publishText1ViewLeadingAnchorConstraint = publishText1View
      .leadingAnchor
      .constraint(equalTo: workspaceTitleView.trailingAnchor)
    let publishText1ViewTopAnchorConstraint = publishText1View
      .topAnchor
      .constraint(equalTo: titleContainerView.topAnchor)
    let publishText1ViewBottomAnchorConstraint = publishText1View
      .bottomAnchor
      .constraint(equalTo: titleContainerView.bottomAnchor)
    let orgTitleViewLeadingAnchorConstraint = orgTitleView
      .leadingAnchor
      .constraint(equalTo: publishText1View.trailingAnchor)
    let orgTitleViewTopAnchorConstraint = orgTitleView.topAnchor.constraint(equalTo: titleContainerView.topAnchor)
    let orgTitleViewBottomAnchorConstraint = orgTitleView
      .bottomAnchor
      .constraint(equalTo: titleContainerView.bottomAnchor)
    let vSpacerViewHeightAnchorConstraint = vSpacerView.heightAnchor.constraint(equalToConstant: 32)
    let vSpacerViewWidthAnchorConstraint = vSpacerView.widthAnchor.constraint(equalToConstant: 0)
    let vSpacer3ViewHeightAnchorConstraint = vSpacer3View.heightAnchor.constraint(equalToConstant: 32)
    let vSpacer3ViewWidthAnchorConstraint = vSpacer3View.widthAnchor.constraint(equalToConstant: 0)
    let vSpacer4ViewHeightAnchorConstraint = vSpacer4View.heightAnchor.constraint(equalToConstant: 24)
    let vSpacer4ViewWidthAnchorConstraint = vSpacer4View.widthAnchor.constraint(equalToConstant: 0)
    let viewViewTopAnchorConstraint = viewView.topAnchor.constraint(equalTo: view1View.topAnchor)
    let viewViewBottomAnchorConstraint = viewView.bottomAnchor.constraint(equalTo: view1View.bottomAnchor)
    let viewViewTrailingAnchorConstraint = viewView.trailingAnchor.constraint(equalTo: view1View.trailingAnchor)
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
    publishText1ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    orgTitleViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      titleContainerViewTopAnchorConstraint,
      titleContainerViewLeadingAnchorConstraint,
      titleContainerViewTrailingAnchorConstraint,
      vSpacerViewTopAnchorConstraint,
      vSpacerViewLeadingAnchorConstraint,
      bodyTextViewTopAnchorConstraint,
      bodyTextViewLeadingAnchorConstraint,
      bodyTextViewTrailingAnchorConstraint,
      vSpacer3ViewTopAnchorConstraint,
      vSpacer3ViewLeadingAnchorConstraint,
      repositoryNameInputViewTopAnchorConstraint,
      repositoryNameInputViewLeadingAnchorConstraint,
      repositoryNameInputViewTrailingAnchorConstraint,
      view2ViewTopAnchorConstraint,
      view2ViewLeadingAnchorConstraint,
      view2ViewTrailingAnchorConstraint,
      vSpacer4ViewTopAnchorConstraint,
      vSpacer4ViewLeadingAnchorConstraint,
      view1ViewBottomAnchorConstraint,
      view1ViewTopAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewTrailingAnchorConstraint,
      publishTextViewHeightAnchorParentConstraint,
      workspaceTitleViewHeightAnchorParentConstraint,
      publishText1ViewHeightAnchorParentConstraint,
      orgTitleViewHeightAnchorParentConstraint,
      publishTextViewLeadingAnchorConstraint,
      publishTextViewTopAnchorConstraint,
      publishTextViewBottomAnchorConstraint,
      workspaceTitleViewLeadingAnchorConstraint,
      workspaceTitleViewTopAnchorConstraint,
      workspaceTitleViewBottomAnchorConstraint,
      publishText1ViewLeadingAnchorConstraint,
      publishText1ViewTopAnchorConstraint,
      publishText1ViewBottomAnchorConstraint,
      orgTitleViewLeadingAnchorConstraint,
      orgTitleViewTopAnchorConstraint,
      orgTitleViewBottomAnchorConstraint,
      vSpacerViewHeightAnchorConstraint,
      vSpacerViewWidthAnchorConstraint,
      vSpacer3ViewHeightAnchorConstraint,
      vSpacer3ViewWidthAnchorConstraint,
      vSpacer4ViewHeightAnchorConstraint,
      vSpacer4ViewWidthAnchorConstraint,
      viewViewTopAnchorConstraint,
      viewViewBottomAnchorConstraint,
      viewViewTrailingAnchorConstraint,
      viewViewWidthAnchorConstraint,
      submitButtonViewTopAnchorConstraint,
      submitButtonViewBottomAnchorConstraint,
      submitButtonViewLeadingAnchorConstraint,
      submitButtonViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    workspaceTitleView.attributedStringValue = workspaceTitleViewTextStyle.apply(to: workspaceName)
    orgTitleView.attributedStringValue = orgTitleViewTextStyle.apply(to: organizationName)
    repositoryNameInputView.textValue = repositoryName
    repositoryNameInputView.onChangeTextValue = handleOnChangeRepositoryName
    submitButtonView.onClick = handleOnClickSubmitButton
    repositoryNameInputView.placeholderString = "Repository URL"
  }

  private func handleOnChangeRepositoryName(_ arg0: String) {
    onChangeRepositoryName?(arg0)
  }

  private func handleOnClickSubmitButton() {
    onClickSubmitButton?()
  }
}

// MARK: - Parameters

extension PublishExistingRepo {
  public struct Parameters: Equatable {
    public var workspaceName: String
    public var organizationName: String
    public var repositoryName: String
    public var onChangeRepositoryName: StringHandler
    public var onClickSubmitButton: (() -> Void)?

    public init(
      workspaceName: String,
      organizationName: String,
      repositoryName: String,
      onChangeRepositoryName: StringHandler = nil,
      onClickSubmitButton: (() -> Void)? = nil)
    {
      self.workspaceName = workspaceName
      self.organizationName = organizationName
      self.repositoryName = repositoryName
      self.onChangeRepositoryName = onChangeRepositoryName
      self.onClickSubmitButton = onClickSubmitButton
    }

    public init() {
      self.init(workspaceName: "", organizationName: "", repositoryName: "")
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.workspaceName == rhs.workspaceName &&
        lhs.organizationName == rhs.organizationName && lhs.repositoryName == rhs.repositoryName
    }
  }
}

// MARK: - Model

extension PublishExistingRepo {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "PublishExistingRepo"
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
      repositoryName: String,
      onChangeRepositoryName: StringHandler = nil,
      onClickSubmitButton: (() -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            workspaceName: workspaceName,
            organizationName: organizationName,
            repositoryName: repositoryName,
            onChangeRepositoryName: onChangeRepositoryName,
            onClickSubmitButton: onClickSubmitButton))
    }

    public init() {
      self.init(workspaceName: "", organizationName: "", repositoryName: "")
    }
  }
}
