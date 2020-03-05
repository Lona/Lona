import AppKit
import Foundation

// MARK: - OpenSyncLocation

public class OpenSyncLocation: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(workspaceName: String, localPath: String, submitButtonTitle: String) {
    self.init(Parameters(workspaceName: workspaceName, localPath: localPath, submitButtonTitle: submitButtonTitle))
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

  public var localPath: String {
    get { return parameters.localPath }
    set {
      if parameters.localPath != newValue {
        parameters.localPath = newValue
      }
    }
  }

  public var onChangeLocalPath: StringHandler {
    get { return parameters.onChangeLocalPath }
    set { parameters.onChangeLocalPath = newValue }
  }

  public var submitButtonTitle: String {
    get { return parameters.submitButtonTitle }
    set {
      if parameters.submitButtonTitle != newValue {
        parameters.submitButtonTitle = newValue
      }
    }
  }

  public var onClickSubmitButton: (() -> Void)? {
    get { return parameters.onClickSubmitButton }
    set { parameters.onClickSubmitButton = newValue }
  }

  public var onClickChooseDirectory: (() -> Void)? {
    get { return parameters.onClickChooseDirectory }
    set { parameters.onClickChooseDirectory = newValue }
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
  private var vSpacer3View = NSBox()
  private var view1View = NSBox()
  private var view2View = NSBox()
  private var localPathInputView = TextInput()
  private var view3View = NSBox()
  private var choosePathButtonView = Button()
  private var vSpacer2View = NSBox()
  private var viewView = NSBox()
  private var submitButtonView = PrimaryButton()

  private var publishTextViewTextStyle = TextStyles.titleLight
  private var workspaceTitleViewTextStyle = TextStyles.title
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
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    publishTextView.lineBreakMode = .byWordWrapping
    workspaceTitleView.lineBreakMode = .byWordWrapping
    view2View.boxType = .custom
    view2View.borderType = .noBorder
    view2View.contentViewMargins = .zero
    vSpacer2View.boxType = .custom
    vSpacer2View.borderType = .noBorder
    vSpacer2View.contentViewMargins = .zero
    viewView.boxType = .custom
    viewView.borderType = .noBorder
    viewView.contentViewMargins = .zero
    view3View.boxType = .custom
    view3View.borderType = .noBorder
    view3View.contentViewMargins = .zero

    addSubview(titleContainerView)
    addSubview(vSpacerView)
    addSubview(bodyTextView)
    addSubview(vSpacer3View)
    addSubview(view1View)
    titleContainerView.addSubview(publishTextView)
    titleContainerView.addSubview(workspaceTitleView)
    view1View.addSubview(view2View)
    view1View.addSubview(vSpacer2View)
    view1View.addSubview(viewView)
    view2View.addSubview(localPathInputView)
    view2View.addSubview(view3View)
    view3View.addSubview(choosePathButtonView)
    viewView.addSubview(submitButtonView)

    publishTextView.attributedStringValue = publishTextViewTextStyle.apply(to: "Sync ")
    publishTextViewTextStyle = TextStyles.titleLight
    publishTextView.attributedStringValue = publishTextViewTextStyle.apply(to: publishTextView.attributedStringValue)
    workspaceTitleViewTextStyle = TextStyles.title
    workspaceTitleView.attributedStringValue =
      workspaceTitleViewTextStyle.apply(to: workspaceTitleView.attributedStringValue)
    vSpacerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    bodyTextView.attributedStringValue =
      bodyTextViewTextStyle.apply(to: "Where do you want to sync this workspace on your hard drive?")
    bodyTextViewTextStyle = TextStyles.body
    bodyTextView.attributedStringValue = bodyTextViewTextStyle.apply(to: bodyTextView.attributedStringValue)
    vSpacer3View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    choosePathButtonView.titleText = "Choose directory..."
    vSpacer2View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    titleContainerView.translatesAutoresizingMaskIntoConstraints = false
    vSpacerView.translatesAutoresizingMaskIntoConstraints = false
    bodyTextView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer3View.translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    publishTextView.translatesAutoresizingMaskIntoConstraints = false
    workspaceTitleView.translatesAutoresizingMaskIntoConstraints = false
    view2View.translatesAutoresizingMaskIntoConstraints = false
    vSpacer2View.translatesAutoresizingMaskIntoConstraints = false
    viewView.translatesAutoresizingMaskIntoConstraints = false
    localPathInputView.translatesAutoresizingMaskIntoConstraints = false
    view3View.translatesAutoresizingMaskIntoConstraints = false
    choosePathButtonView.translatesAutoresizingMaskIntoConstraints = false
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
    let vSpacer3ViewHeightAnchorConstraint = vSpacer3View.heightAnchor.constraint(equalToConstant: 16)
    let vSpacer3ViewWidthAnchorConstraint = vSpacer3View.widthAnchor.constraint(equalToConstant: 0)
    let view2ViewTopAnchorConstraint = view2View.topAnchor.constraint(equalTo: view1View.topAnchor)
    let view2ViewLeadingAnchorConstraint = view2View.leadingAnchor.constraint(equalTo: view1View.leadingAnchor)
    let view2ViewTrailingAnchorConstraint = view2View.trailingAnchor.constraint(equalTo: view1View.trailingAnchor)
    let vSpacer2ViewTopAnchorConstraint = vSpacer2View.topAnchor.constraint(equalTo: view2View.bottomAnchor)
    let vSpacer2ViewTrailingAnchorConstraint = vSpacer2View.trailingAnchor.constraint(equalTo: view1View.trailingAnchor)
    let viewViewBottomAnchorConstraint = viewView.bottomAnchor.constraint(equalTo: view1View.bottomAnchor)
    let viewViewTopAnchorConstraint = viewView.topAnchor.constraint(equalTo: vSpacer2View.bottomAnchor)
    let viewViewTrailingAnchorConstraint = viewView.trailingAnchor.constraint(equalTo: view1View.trailingAnchor)
    let localPathInputViewHeightAnchorParentConstraint = localPathInputView
      .heightAnchor
      .constraint(lessThanOrEqualTo: view2View.heightAnchor)
    let view3ViewHeightAnchorParentConstraint = view3View
      .heightAnchor
      .constraint(lessThanOrEqualTo: view2View.heightAnchor)
    let localPathInputViewLeadingAnchorConstraint = localPathInputView
      .leadingAnchor
      .constraint(equalTo: view2View.leadingAnchor)
    let localPathInputViewTopAnchorConstraint = localPathInputView.topAnchor.constraint(equalTo: view2View.topAnchor)
    let localPathInputViewBottomAnchorConstraint = localPathInputView
      .bottomAnchor
      .constraint(equalTo: view2View.bottomAnchor)
    let view3ViewTrailingAnchorConstraint = view3View.trailingAnchor.constraint(equalTo: view2View.trailingAnchor)
    let view3ViewLeadingAnchorConstraint = view3View
      .leadingAnchor
      .constraint(equalTo: localPathInputView.trailingAnchor, constant: 8)
    let view3ViewTopAnchorConstraint = view3View.topAnchor.constraint(equalTo: view2View.topAnchor)
    let view3ViewBottomAnchorConstraint = view3View.bottomAnchor.constraint(equalTo: view2View.bottomAnchor)
    let vSpacer2ViewHeightAnchorConstraint = vSpacer2View.heightAnchor.constraint(equalToConstant: 32)
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
    let choosePathButtonViewWidthAnchorParentConstraint = choosePathButtonView
      .widthAnchor
      .constraint(lessThanOrEqualTo: view3View.widthAnchor)
    let choosePathButtonViewTopAnchorConstraint = choosePathButtonView
      .topAnchor
      .constraint(equalTo: view3View.topAnchor)
    let choosePathButtonViewBottomAnchorConstraint = choosePathButtonView
      .bottomAnchor
      .constraint(equalTo: view3View.bottomAnchor)
    let choosePathButtonViewLeadingAnchorConstraint = choosePathButtonView
      .leadingAnchor
      .constraint(equalTo: view3View.leadingAnchor)
    let choosePathButtonViewTrailingAnchorConstraint = choosePathButtonView
      .trailingAnchor
      .constraint(equalTo: view3View.trailingAnchor)

    publishTextViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    workspaceTitleViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    localPathInputViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    view3ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    choosePathButtonViewWidthAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

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
      vSpacer3ViewHeightAnchorConstraint,
      vSpacer3ViewWidthAnchorConstraint,
      view2ViewTopAnchorConstraint,
      view2ViewLeadingAnchorConstraint,
      view2ViewTrailingAnchorConstraint,
      vSpacer2ViewTopAnchorConstraint,
      vSpacer2ViewTrailingAnchorConstraint,
      viewViewBottomAnchorConstraint,
      viewViewTopAnchorConstraint,
      viewViewTrailingAnchorConstraint,
      localPathInputViewHeightAnchorParentConstraint,
      view3ViewHeightAnchorParentConstraint,
      localPathInputViewLeadingAnchorConstraint,
      localPathInputViewTopAnchorConstraint,
      localPathInputViewBottomAnchorConstraint,
      view3ViewTrailingAnchorConstraint,
      view3ViewLeadingAnchorConstraint,
      view3ViewTopAnchorConstraint,
      view3ViewBottomAnchorConstraint,
      vSpacer2ViewHeightAnchorConstraint,
      vSpacer2ViewWidthAnchorConstraint,
      viewViewWidthAnchorConstraint,
      submitButtonViewTopAnchorConstraint,
      submitButtonViewBottomAnchorConstraint,
      submitButtonViewLeadingAnchorConstraint,
      submitButtonViewTrailingAnchorConstraint,
      choosePathButtonViewWidthAnchorParentConstraint,
      choosePathButtonViewTopAnchorConstraint,
      choosePathButtonViewBottomAnchorConstraint,
      choosePathButtonViewLeadingAnchorConstraint,
      choosePathButtonViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    workspaceTitleView.attributedStringValue = workspaceTitleViewTextStyle.apply(to: workspaceName)
    localPathInputView.textValue = localPath
    localPathInputView.onChangeTextValue = handleOnChangeLocalPath
    submitButtonView.titleText = submitButtonTitle
    submitButtonView.onClick = handleOnClickSubmitButton
    choosePathButtonView.onClick = handleOnClickChooseDirectory
    localPathInputView.placeholderString = "Directory location"
  }

  private func handleOnChangeLocalPath(_ arg0: String) {
    onChangeLocalPath?(arg0)
  }

  private func handleOnClickSubmitButton() {
    onClickSubmitButton?()
  }

  private func handleOnClickChooseDirectory() {
    onClickChooseDirectory?()
  }
}

// MARK: - Parameters

extension OpenSyncLocation {
  public struct Parameters: Equatable {
    public var workspaceName: String
    public var localPath: String
    public var submitButtonTitle: String
    public var onChangeLocalPath: StringHandler
    public var onClickSubmitButton: (() -> Void)?
    public var onClickChooseDirectory: (() -> Void)?

    public init(
      workspaceName: String,
      localPath: String,
      submitButtonTitle: String,
      onChangeLocalPath: StringHandler = nil,
      onClickSubmitButton: (() -> Void)? = nil,
      onClickChooseDirectory: (() -> Void)? = nil)
    {
      self.workspaceName = workspaceName
      self.localPath = localPath
      self.submitButtonTitle = submitButtonTitle
      self.onChangeLocalPath = onChangeLocalPath
      self.onClickSubmitButton = onClickSubmitButton
      self.onClickChooseDirectory = onClickChooseDirectory
    }

    public init() {
      self.init(workspaceName: "", localPath: "", submitButtonTitle: "")
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.workspaceName == rhs.workspaceName &&
        lhs.localPath == rhs.localPath && lhs.submitButtonTitle == rhs.submitButtonTitle
    }
  }
}

// MARK: - Model

extension OpenSyncLocation {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "OpenSyncLocation"
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
      localPath: String,
      submitButtonTitle: String,
      onChangeLocalPath: StringHandler = nil,
      onClickSubmitButton: (() -> Void)? = nil,
      onClickChooseDirectory: (() -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            workspaceName: workspaceName,
            localPath: localPath,
            submitButtonTitle: submitButtonTitle,
            onChangeLocalPath: onChangeLocalPath,
            onClickSubmitButton: onClickSubmitButton,
            onClickChooseDirectory: onClickChooseDirectory))
    }

    public init() {
      self.init(workspaceName: "", localPath: "", submitButtonTitle: "")
    }
  }
}
