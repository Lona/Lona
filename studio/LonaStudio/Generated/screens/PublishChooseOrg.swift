import AppKit
import Foundation

// MARK: - PublishChooseOrg

public class PublishChooseOrg: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(
    titleText: String,
    bodyText: String,
    organizationName: String,
    organizationIds: [String],
    showsOrganizationsList: Bool,
    isSubmitting: Bool)
  {
    self
      .init(
        Parameters(
          titleText: titleText,
          bodyText: bodyText,
          organizationName: organizationName,
          organizationIds: organizationIds,
          showsOrganizationsList: showsOrganizationsList,
          isSubmitting: isSubmitting))
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

  public var titleText: String {
    get { return parameters.titleText }
    set {
      if parameters.titleText != newValue {
        parameters.titleText = newValue
      }
    }
  }

  public var bodyText: String {
    get { return parameters.bodyText }
    set {
      if parameters.bodyText != newValue {
        parameters.bodyText = newValue
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

  public var onChangeTextValue: StringHandler {
    get { return parameters.onChangeTextValue }
    set { parameters.onChangeTextValue = newValue }
  }

  public var organizationIds: [String] {
    get { return parameters.organizationIds }
    set {
      if parameters.organizationIds != newValue {
        parameters.organizationIds = newValue
      }
    }
  }

  public var showsOrganizationsList: Bool {
    get { return parameters.showsOrganizationsList }
    set {
      if parameters.showsOrganizationsList != newValue {
        parameters.showsOrganizationsList = newValue
      }
    }
  }

  public var isSubmitting: Bool {
    get { return parameters.isSubmitting }
    set {
      if parameters.isSubmitting != newValue {
        parameters.isSubmitting = newValue
      }
    }
  }

  public var onClickSubmit: (() -> Void)? {
    get { return parameters.onClickSubmit }
    set { parameters.onClickSubmit = newValue }
  }

  public var onSelectOrganizationId: ((String) -> Void)? {
    get { return parameters.onSelectOrganizationId }
    set { parameters.onSelectOrganizationId = newValue }
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
  private var vSpacerView = NSBox()
  private var bodyView = LNATextField(labelWithString: "")
  private var vSpacer4View = NSBox()
  private var organizationContainerView = NSBox()
  private var text1View = LNATextField(labelWithString: "")
  private var vSpacer5View = NSBox()
  private var organizationListView = OrganizationList()
  private var vSpacer1View = NSBox()
  private var textView = LNATextField(labelWithString: "")
  private var vSpacer3View = NSBox()
  private var view1View = NSBox()
  private var organizationNameInputView = TextInput()
  private var vSpacer2View = NSBox()
  private var viewView = NSBox()
  private var submitButtonView = PrimaryButton()

  private var titleViewTextStyle = TextStyles.title
  private var bodyViewTextStyle = TextStyles.body
  private var text1ViewTextStyle = TextStyles.subtitle
  private var textViewTextStyle = TextStyles.subtitle

  private var textViewTopAnchorVSpacer4ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var organizationContainerViewTopAnchorVSpacer4ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var organizationContainerViewLeadingAnchorLeadingAnchorConstraint: NSLayoutConstraint?
  private var organizationContainerViewTrailingAnchorTrailingAnchorConstraint: NSLayoutConstraint?
  private var textViewTopAnchorOrganizationContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var text1ViewTopAnchorOrganizationContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var text1ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text1ViewTrailingAnchorOrganizationContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var vSpacer5ViewTopAnchorText1ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var vSpacer5ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var organizationListViewTopAnchorVSpacer5ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var organizationListViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var organizationListViewTrailingAnchorOrganizationContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var vSpacer1ViewBottomAnchorOrganizationContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var vSpacer1ViewTopAnchorOrganizationListViewBottomAnchorConstraint: NSLayoutConstraint?
  private var vSpacer1ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var vSpacer5ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var vSpacer5ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var vSpacer1ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var vSpacer1ViewWidthAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    vSpacerView.boxType = .custom
    vSpacerView.borderType = .noBorder
    vSpacerView.contentViewMargins = .zero
    bodyView.lineBreakMode = .byWordWrapping
    vSpacer4View.boxType = .custom
    vSpacer4View.borderType = .noBorder
    vSpacer4View.contentViewMargins = .zero
    organizationContainerView.boxType = .custom
    organizationContainerView.borderType = .noBorder
    organizationContainerView.contentViewMargins = .zero
    textView.lineBreakMode = .byWordWrapping
    vSpacer3View.boxType = .custom
    vSpacer3View.borderType = .noBorder
    vSpacer3View.contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    text1View.lineBreakMode = .byWordWrapping
    vSpacer5View.boxType = .custom
    vSpacer5View.borderType = .noBorder
    vSpacer5View.contentViewMargins = .zero
    vSpacer1View.boxType = .custom
    vSpacer1View.borderType = .noBorder
    vSpacer1View.contentViewMargins = .zero
    vSpacer2View.boxType = .custom
    vSpacer2View.borderType = .noBorder
    vSpacer2View.contentViewMargins = .zero
    viewView.boxType = .custom
    viewView.borderType = .noBorder
    viewView.contentViewMargins = .zero

    addSubview(titleView)
    addSubview(vSpacerView)
    addSubview(bodyView)
    addSubview(vSpacer4View)
    addSubview(organizationContainerView)
    addSubview(textView)
    addSubview(vSpacer3View)
    addSubview(view1View)
    organizationContainerView.addSubview(text1View)
    organizationContainerView.addSubview(vSpacer5View)
    organizationContainerView.addSubview(organizationListView)
    organizationContainerView.addSubview(vSpacer1View)
    view1View.addSubview(organizationNameInputView)
    view1View.addSubview(vSpacer2View)
    view1View.addSubview(viewView)
    viewView.addSubview(submitButtonView)

    titleViewTextStyle = TextStyles.title
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    vSpacerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    bodyViewTextStyle = TextStyles.body
    bodyView.attributedStringValue = bodyViewTextStyle.apply(to: bodyView.attributedStringValue)
    vSpacer4View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    text1View.attributedStringValue = text1ViewTextStyle.apply(to: "Choose organization")
    text1ViewTextStyle = TextStyles.subtitle
    text1View.attributedStringValue = text1ViewTextStyle.apply(to: text1View.attributedStringValue)
    vSpacer5View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    vSpacer1View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    textView.attributedStringValue = textViewTextStyle.apply(to: "Create organization")
    textViewTextStyle = TextStyles.subtitle
    textView.attributedStringValue = textViewTextStyle.apply(to: textView.attributedStringValue)
    vSpacer3View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    vSpacer2View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    submitButtonView.titleText = "Create"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    vSpacerView.translatesAutoresizingMaskIntoConstraints = false
    bodyView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer4View.translatesAutoresizingMaskIntoConstraints = false
    organizationContainerView.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer3View.translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    text1View.translatesAutoresizingMaskIntoConstraints = false
    vSpacer5View.translatesAutoresizingMaskIntoConstraints = false
    organizationListView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer1View.translatesAutoresizingMaskIntoConstraints = false
    organizationNameInputView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer2View.translatesAutoresizingMaskIntoConstraints = false
    viewView.translatesAutoresizingMaskIntoConstraints = false
    submitButtonView.translatesAutoresizingMaskIntoConstraints = false

    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: topAnchor)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let titleViewTrailingAnchorConstraint = titleView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let vSpacerViewTopAnchorConstraint = vSpacerView.topAnchor.constraint(equalTo: titleView.bottomAnchor)
    let vSpacerViewLeadingAnchorConstraint = vSpacerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let bodyViewTopAnchorConstraint = bodyView.topAnchor.constraint(equalTo: vSpacerView.bottomAnchor)
    let bodyViewLeadingAnchorConstraint = bodyView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let bodyViewTrailingAnchorConstraint = bodyView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let vSpacer4ViewTopAnchorConstraint = vSpacer4View.topAnchor.constraint(equalTo: bodyView.bottomAnchor)
    let vSpacer4ViewLeadingAnchorConstraint = vSpacer4View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let textViewTrailingAnchorConstraint = textView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let vSpacer3ViewTopAnchorConstraint = vSpacer3View.topAnchor.constraint(equalTo: textView.bottomAnchor)
    let vSpacer3ViewLeadingAnchorConstraint = vSpacer3View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewBottomAnchorConstraint = view1View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: vSpacer3View.bottomAnchor)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewTrailingAnchorConstraint = view1View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let vSpacerViewHeightAnchorConstraint = vSpacerView.heightAnchor.constraint(equalToConstant: 32)
    let vSpacerViewWidthAnchorConstraint = vSpacerView.widthAnchor.constraint(equalToConstant: 0)
    let vSpacer4ViewHeightAnchorConstraint = vSpacer4View.heightAnchor.constraint(equalToConstant: 72)
    let vSpacer4ViewWidthAnchorConstraint = vSpacer4View.widthAnchor.constraint(equalToConstant: 0)
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
    let textViewTopAnchorVSpacer4ViewBottomAnchorConstraint = textView
      .topAnchor
      .constraint(equalTo: vSpacer4View.bottomAnchor)
    let organizationContainerViewTopAnchorVSpacer4ViewBottomAnchorConstraint = organizationContainerView
      .topAnchor
      .constraint(equalTo: vSpacer4View.bottomAnchor)
    let organizationContainerViewLeadingAnchorLeadingAnchorConstraint = organizationContainerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let organizationContainerViewTrailingAnchorTrailingAnchorConstraint = organizationContainerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let textViewTopAnchorOrganizationContainerViewBottomAnchorConstraint = textView
      .topAnchor
      .constraint(equalTo: organizationContainerView.bottomAnchor)
    let text1ViewTopAnchorOrganizationContainerViewTopAnchorConstraint = text1View
      .topAnchor
      .constraint(equalTo: organizationContainerView.topAnchor)
    let text1ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint = text1View
      .leadingAnchor
      .constraint(equalTo: organizationContainerView.leadingAnchor)
    let text1ViewTrailingAnchorOrganizationContainerViewTrailingAnchorConstraint = text1View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: organizationContainerView.trailingAnchor)
    let vSpacer5ViewTopAnchorText1ViewBottomAnchorConstraint = vSpacer5View
      .topAnchor
      .constraint(equalTo: text1View.bottomAnchor)
    let vSpacer5ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint = vSpacer5View
      .leadingAnchor
      .constraint(equalTo: organizationContainerView.leadingAnchor)
    let organizationListViewTopAnchorVSpacer5ViewBottomAnchorConstraint = organizationListView
      .topAnchor
      .constraint(equalTo: vSpacer5View.bottomAnchor)
    let organizationListViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint = organizationListView
      .leadingAnchor
      .constraint(equalTo: organizationContainerView.leadingAnchor)
    let organizationListViewTrailingAnchorOrganizationContainerViewTrailingAnchorConstraint = organizationListView
      .trailingAnchor
      .constraint(equalTo: organizationContainerView.trailingAnchor)
    let vSpacer1ViewBottomAnchorOrganizationContainerViewBottomAnchorConstraint = vSpacer1View
      .bottomAnchor
      .constraint(equalTo: organizationContainerView.bottomAnchor)
    let vSpacer1ViewTopAnchorOrganizationListViewBottomAnchorConstraint = vSpacer1View
      .topAnchor
      .constraint(equalTo: organizationListView.bottomAnchor)
    let vSpacer1ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint = vSpacer1View
      .leadingAnchor
      .constraint(equalTo: organizationContainerView.leadingAnchor)
    let vSpacer5ViewHeightAnchorConstraint = vSpacer5View.heightAnchor.constraint(equalToConstant: 20)
    let vSpacer5ViewWidthAnchorConstraint = vSpacer5View.widthAnchor.constraint(equalToConstant: 0)
    let vSpacer1ViewHeightAnchorConstraint = vSpacer1View.heightAnchor.constraint(equalToConstant: 72)
    let vSpacer1ViewWidthAnchorConstraint = vSpacer1View.widthAnchor.constraint(equalToConstant: 0)

    self.textViewTopAnchorVSpacer4ViewBottomAnchorConstraint = textViewTopAnchorVSpacer4ViewBottomAnchorConstraint
    self.organizationContainerViewTopAnchorVSpacer4ViewBottomAnchorConstraint =
      organizationContainerViewTopAnchorVSpacer4ViewBottomAnchorConstraint
    self.organizationContainerViewLeadingAnchorLeadingAnchorConstraint =
      organizationContainerViewLeadingAnchorLeadingAnchorConstraint
    self.organizationContainerViewTrailingAnchorTrailingAnchorConstraint =
      organizationContainerViewTrailingAnchorTrailingAnchorConstraint
    self.textViewTopAnchorOrganizationContainerViewBottomAnchorConstraint =
      textViewTopAnchorOrganizationContainerViewBottomAnchorConstraint
    self.text1ViewTopAnchorOrganizationContainerViewTopAnchorConstraint =
      text1ViewTopAnchorOrganizationContainerViewTopAnchorConstraint
    self.text1ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint =
      text1ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint
    self.text1ViewTrailingAnchorOrganizationContainerViewTrailingAnchorConstraint =
      text1ViewTrailingAnchorOrganizationContainerViewTrailingAnchorConstraint
    self.vSpacer5ViewTopAnchorText1ViewBottomAnchorConstraint = vSpacer5ViewTopAnchorText1ViewBottomAnchorConstraint
    self.vSpacer5ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint =
      vSpacer5ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint
    self.organizationListViewTopAnchorVSpacer5ViewBottomAnchorConstraint =
      organizationListViewTopAnchorVSpacer5ViewBottomAnchorConstraint
    self.organizationListViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint =
      organizationListViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint
    self.organizationListViewTrailingAnchorOrganizationContainerViewTrailingAnchorConstraint =
      organizationListViewTrailingAnchorOrganizationContainerViewTrailingAnchorConstraint
    self.vSpacer1ViewBottomAnchorOrganizationContainerViewBottomAnchorConstraint =
      vSpacer1ViewBottomAnchorOrganizationContainerViewBottomAnchorConstraint
    self.vSpacer1ViewTopAnchorOrganizationListViewBottomAnchorConstraint =
      vSpacer1ViewTopAnchorOrganizationListViewBottomAnchorConstraint
    self.vSpacer1ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint =
      vSpacer1ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint
    self.vSpacer5ViewHeightAnchorConstraint = vSpacer5ViewHeightAnchorConstraint
    self.vSpacer5ViewWidthAnchorConstraint = vSpacer5ViewWidthAnchorConstraint
    self.vSpacer1ViewHeightAnchorConstraint = vSpacer1ViewHeightAnchorConstraint
    self.vSpacer1ViewWidthAnchorConstraint = vSpacer1ViewWidthAnchorConstraint

    NSLayoutConstraint.activate(
      [
        titleViewTopAnchorConstraint,
        titleViewLeadingAnchorConstraint,
        titleViewTrailingAnchorConstraint,
        vSpacerViewTopAnchorConstraint,
        vSpacerViewLeadingAnchorConstraint,
        bodyViewTopAnchorConstraint,
        bodyViewLeadingAnchorConstraint,
        bodyViewTrailingAnchorConstraint,
        vSpacer4ViewTopAnchorConstraint,
        vSpacer4ViewLeadingAnchorConstraint,
        textViewLeadingAnchorConstraint,
        textViewTrailingAnchorConstraint,
        vSpacer3ViewTopAnchorConstraint,
        vSpacer3ViewLeadingAnchorConstraint,
        view1ViewBottomAnchorConstraint,
        view1ViewTopAnchorConstraint,
        view1ViewLeadingAnchorConstraint,
        view1ViewTrailingAnchorConstraint,
        vSpacerViewHeightAnchorConstraint,
        vSpacerViewWidthAnchorConstraint,
        vSpacer4ViewHeightAnchorConstraint,
        vSpacer4ViewWidthAnchorConstraint,
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
      ] +
        conditionalConstraints(organizationContainerViewIsHidden: organizationContainerView.isHidden))
  }

  private func conditionalConstraints(organizationContainerViewIsHidden: Bool) -> [NSLayoutConstraint] {
    var constraints: [NSLayoutConstraint?]

    switch (organizationContainerViewIsHidden) {
      case (true):
        constraints = [textViewTopAnchorVSpacer4ViewBottomAnchorConstraint]
      case (false):
        constraints = [
          organizationContainerViewTopAnchorVSpacer4ViewBottomAnchorConstraint,
          organizationContainerViewLeadingAnchorLeadingAnchorConstraint,
          organizationContainerViewTrailingAnchorTrailingAnchorConstraint,
          textViewTopAnchorOrganizationContainerViewBottomAnchorConstraint,
          text1ViewTopAnchorOrganizationContainerViewTopAnchorConstraint,
          text1ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint,
          text1ViewTrailingAnchorOrganizationContainerViewTrailingAnchorConstraint,
          vSpacer5ViewTopAnchorText1ViewBottomAnchorConstraint,
          vSpacer5ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint,
          organizationListViewTopAnchorVSpacer5ViewBottomAnchorConstraint,
          organizationListViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint,
          organizationListViewTrailingAnchorOrganizationContainerViewTrailingAnchorConstraint,
          vSpacer1ViewBottomAnchorOrganizationContainerViewBottomAnchorConstraint,
          vSpacer1ViewTopAnchorOrganizationListViewBottomAnchorConstraint,
          vSpacer1ViewLeadingAnchorOrganizationContainerViewLeadingAnchorConstraint,
          vSpacer5ViewHeightAnchorConstraint,
          vSpacer5ViewWidthAnchorConstraint,
          vSpacer1ViewHeightAnchorConstraint,
          vSpacer1ViewWidthAnchorConstraint
        ]
    }

    return constraints.compactMap({ $0 })
  }

  private func update() {
    let organizationContainerViewIsHidden = organizationContainerView.isHidden

    organizationContainerView.isHidden = !false
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleText)
    bodyView.attributedStringValue = bodyViewTextStyle.apply(to: bodyText)
    organizationNameInputView.textValue = organizationName
    organizationNameInputView.onChangeTextValue = handleOnChangeTextValue
    submitButtonView.onClick = handleOnClickSubmit
    organizationNameInputView.placeholderString = "Organization name"
    organizationListView.organizationIds = organizationIds
    organizationListView.onSelectOrganizationId = handleOnSelectOrganizationId
    submitButtonView.disabled = isSubmitting
    if showsOrganizationsList {
      organizationContainerView.isHidden = !true
    }

    if organizationContainerView.isHidden != organizationContainerViewIsHidden {
      NSLayoutConstraint.deactivate(
        conditionalConstraints(organizationContainerViewIsHidden: organizationContainerViewIsHidden))
      NSLayoutConstraint.activate(
        conditionalConstraints(organizationContainerViewIsHidden: organizationContainerView.isHidden))
    }
  }

  private func handleOnChangeTextValue(_ arg0: String) {
    onChangeTextValue?(arg0)
  }

  private func handleOnClickSubmit() {
    onClickSubmit?()
  }

  private func handleOnSelectOrganizationId(_ arg0: String) {
    onSelectOrganizationId?(arg0)
  }
}

// MARK: - Parameters

extension PublishChooseOrg {
  public struct Parameters: Equatable {
    public var titleText: String
    public var bodyText: String
    public var organizationName: String
    public var organizationIds: [String]
    public var showsOrganizationsList: Bool
    public var isSubmitting: Bool
    public var onChangeTextValue: StringHandler
    public var onClickSubmit: (() -> Void)?
    public var onSelectOrganizationId: ((String) -> Void)?

    public init(
      titleText: String,
      bodyText: String,
      organizationName: String,
      organizationIds: [String],
      showsOrganizationsList: Bool,
      isSubmitting: Bool,
      onChangeTextValue: StringHandler = nil,
      onClickSubmit: (() -> Void)? = nil,
      onSelectOrganizationId: ((String) -> Void)? = nil)
    {
      self.titleText = titleText
      self.bodyText = bodyText
      self.organizationName = organizationName
      self.organizationIds = organizationIds
      self.showsOrganizationsList = showsOrganizationsList
      self.isSubmitting = isSubmitting
      self.onChangeTextValue = onChangeTextValue
      self.onClickSubmit = onClickSubmit
      self.onSelectOrganizationId = onSelectOrganizationId
    }

    public init() {
      self
        .init(
          titleText: "",
          bodyText: "",
          organizationName: "",
          organizationIds: [],
          showsOrganizationsList: false,
          isSubmitting: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.titleText == rhs.titleText &&
        lhs.bodyText == rhs.bodyText &&
          lhs.organizationName == rhs.organizationName &&
            lhs.organizationIds == rhs.organizationIds &&
              lhs.showsOrganizationsList == rhs.showsOrganizationsList && lhs.isSubmitting == rhs.isSubmitting
    }
  }
}

// MARK: - Model

extension PublishChooseOrg {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "PublishChooseOrg"
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
      bodyText: String,
      organizationName: String,
      organizationIds: [String],
      showsOrganizationsList: Bool,
      isSubmitting: Bool,
      onChangeTextValue: StringHandler = nil,
      onClickSubmit: (() -> Void)? = nil,
      onSelectOrganizationId: ((String) -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            titleText: titleText,
            bodyText: bodyText,
            organizationName: organizationName,
            organizationIds: organizationIds,
            showsOrganizationsList: showsOrganizationsList,
            isSubmitting: isSubmitting,
            onChangeTextValue: onChangeTextValue,
            onClickSubmit: onClickSubmit,
            onSelectOrganizationId: onSelectOrganizationId))
    }

    public init() {
      self
        .init(
          titleText: "",
          bodyText: "",
          organizationName: "",
          organizationIds: [],
          showsOrganizationsList: false,
          isSubmitting: false)
    }
  }
}
