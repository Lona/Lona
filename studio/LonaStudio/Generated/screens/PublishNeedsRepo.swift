import AppKit
import Foundation

// MARK: - PublishNeedsRepo

public class PublishNeedsRepo: NSBox {

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

  public var onClickCreateRepository: (() -> Void)? {
    get { return parameters.onClickCreateRepository }
    set { parameters.onClickCreateRepository = newValue }
  }

  public var onClickUseExistingRepository: (() -> Void)? {
    get { return parameters.onClickUseExistingRepository }
    set { parameters.onClickUseExistingRepository = newValue }
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
  private var vSpacer1View = NSBox()
  private var viewView = NSBox()
  private var createButtonView = PrimaryButton()
  private var vSpacer2View = NSBox()
  private var useExistingButtonView = PrimaryButton()

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
    vSpacer1View.boxType = .custom
    vSpacer1View.borderType = .noBorder
    vSpacer1View.contentViewMargins = .zero
    viewView.boxType = .custom
    viewView.borderType = .noBorder
    viewView.contentViewMargins = .zero
    publishTextView.lineBreakMode = .byWordWrapping
    workspaceTitleView.lineBreakMode = .byWordWrapping
    publishText1View.lineBreakMode = .byWordWrapping
    orgTitleView.lineBreakMode = .byWordWrapping
    vSpacer2View.boxType = .custom
    vSpacer2View.borderType = .noBorder
    vSpacer2View.contentViewMargins = .zero

    addSubview(titleContainerView)
    addSubview(vSpacerView)
    addSubview(bodyTextView)
    addSubview(vSpacer1View)
    addSubview(viewView)
    titleContainerView.addSubview(publishTextView)
    titleContainerView.addSubview(workspaceTitleView)
    titleContainerView.addSubview(publishText1View)
    titleContainerView.addSubview(orgTitleView)
    viewView.addSubview(createButtonView)
    viewView.addSubview(vSpacer2View)
    viewView.addSubview(useExistingButtonView)

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
        """
Next, you’ll need to choose a git repository to store your workspace files. 

We can create a new one automatically for you on GitHub (we’ll need permission to access your GitHub repositories), or you can choose an existing Git repository.
""")
    bodyTextViewTextStyle = TextStyles.body
    bodyTextView.attributedStringValue = bodyTextViewTextStyle.apply(to: bodyTextView.attributedStringValue)
    vSpacer1View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    createButtonView.titleText = "Create new GitHub repository"
    vSpacer2View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    useExistingButtonView.titleText = "Use an existing git repository"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    titleContainerView.translatesAutoresizingMaskIntoConstraints = false
    vSpacerView.translatesAutoresizingMaskIntoConstraints = false
    bodyTextView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer1View.translatesAutoresizingMaskIntoConstraints = false
    viewView.translatesAutoresizingMaskIntoConstraints = false
    publishTextView.translatesAutoresizingMaskIntoConstraints = false
    workspaceTitleView.translatesAutoresizingMaskIntoConstraints = false
    publishText1View.translatesAutoresizingMaskIntoConstraints = false
    orgTitleView.translatesAutoresizingMaskIntoConstraints = false
    createButtonView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer2View.translatesAutoresizingMaskIntoConstraints = false
    useExistingButtonView.translatesAutoresizingMaskIntoConstraints = false

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
    let viewViewBottomAnchorConstraint = viewView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let viewViewTopAnchorConstraint = viewView.topAnchor.constraint(equalTo: vSpacer1View.bottomAnchor)
    let viewViewLeadingAnchorConstraint = viewView.leadingAnchor.constraint(equalTo: leadingAnchor)
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
    let vSpacer1ViewHeightAnchorConstraint = vSpacer1View.heightAnchor.constraint(equalToConstant: 72)
    let vSpacer1ViewWidthAnchorConstraint = vSpacer1View.widthAnchor.constraint(equalToConstant: 0)
    let viewViewWidthAnchorConstraint = viewView.widthAnchor.constraint(equalToConstant: 250)
    let createButtonViewTopAnchorConstraint = createButtonView.topAnchor.constraint(equalTo: viewView.topAnchor)
    let createButtonViewLeadingAnchorConstraint = createButtonView
      .leadingAnchor
      .constraint(equalTo: viewView.leadingAnchor)
    let createButtonViewTrailingAnchorConstraint = createButtonView
      .trailingAnchor
      .constraint(equalTo: viewView.trailingAnchor)
    let vSpacer2ViewTopAnchorConstraint = vSpacer2View.topAnchor.constraint(equalTo: createButtonView.bottomAnchor)
    let vSpacer2ViewLeadingAnchorConstraint = vSpacer2View.leadingAnchor.constraint(equalTo: viewView.leadingAnchor)
    let useExistingButtonViewBottomAnchorConstraint = useExistingButtonView
      .bottomAnchor
      .constraint(equalTo: viewView.bottomAnchor)
    let useExistingButtonViewTopAnchorConstraint = useExistingButtonView
      .topAnchor
      .constraint(equalTo: vSpacer2View.bottomAnchor)
    let useExistingButtonViewLeadingAnchorConstraint = useExistingButtonView
      .leadingAnchor
      .constraint(equalTo: viewView.leadingAnchor)
    let useExistingButtonViewTrailingAnchorConstraint = useExistingButtonView
      .trailingAnchor
      .constraint(equalTo: viewView.trailingAnchor)
    let vSpacer2ViewHeightAnchorConstraint = vSpacer2View.heightAnchor.constraint(equalToConstant: 8)
    let vSpacer2ViewWidthAnchorConstraint = vSpacer2View.widthAnchor.constraint(equalToConstant: 0)

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
      vSpacer1ViewTopAnchorConstraint,
      vSpacer1ViewLeadingAnchorConstraint,
      viewViewBottomAnchorConstraint,
      viewViewTopAnchorConstraint,
      viewViewLeadingAnchorConstraint,
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
      vSpacer1ViewHeightAnchorConstraint,
      vSpacer1ViewWidthAnchorConstraint,
      viewViewWidthAnchorConstraint,
      createButtonViewTopAnchorConstraint,
      createButtonViewLeadingAnchorConstraint,
      createButtonViewTrailingAnchorConstraint,
      vSpacer2ViewTopAnchorConstraint,
      vSpacer2ViewLeadingAnchorConstraint,
      useExistingButtonViewBottomAnchorConstraint,
      useExistingButtonViewTopAnchorConstraint,
      useExistingButtonViewLeadingAnchorConstraint,
      useExistingButtonViewTrailingAnchorConstraint,
      vSpacer2ViewHeightAnchorConstraint,
      vSpacer2ViewWidthAnchorConstraint
    ])
  }

  private func update() {
    workspaceTitleView.attributedStringValue = workspaceTitleViewTextStyle.apply(to: workspaceName)
    orgTitleView.attributedStringValue = orgTitleViewTextStyle.apply(to: organizationName)
    createButtonView.onClick = handleOnClickCreateRepository
    useExistingButtonView.onClick = handleOnClickUseExistingRepository
  }

  private func handleOnClickCreateRepository() {
    onClickCreateRepository?()
  }

  private func handleOnClickUseExistingRepository() {
    onClickUseExistingRepository?()
  }
}

// MARK: - Parameters

extension PublishNeedsRepo {
  public struct Parameters: Equatable {
    public var workspaceName: String
    public var organizationName: String
    public var onClickCreateRepository: (() -> Void)?
    public var onClickUseExistingRepository: (() -> Void)?

    public init(
      workspaceName: String,
      organizationName: String,
      onClickCreateRepository: (() -> Void)? = nil,
      onClickUseExistingRepository: (() -> Void)? = nil)
    {
      self.workspaceName = workspaceName
      self.organizationName = organizationName
      self.onClickCreateRepository = onClickCreateRepository
      self.onClickUseExistingRepository = onClickUseExistingRepository
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

extension PublishNeedsRepo {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "PublishNeedsRepo"
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
      onClickCreateRepository: (() -> Void)? = nil,
      onClickUseExistingRepository: (() -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            workspaceName: workspaceName,
            organizationName: organizationName,
            onClickCreateRepository: onClickCreateRepository,
            onClickUseExistingRepository: onClickUseExistingRepository))
    }

    public init() {
      self.init(workspaceName: "", organizationName: "")
    }
  }
}
