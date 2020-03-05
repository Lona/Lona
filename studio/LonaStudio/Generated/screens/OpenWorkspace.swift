import AppKit
import Foundation

// MARK: - OpenWorkspace

public class OpenWorkspace: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(isLoggedIn: Bool) {
    self.init(Parameters(isLoggedIn: isLoggedIn))
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

  public var onClickGithubButton: (() -> Void)? {
    get { return parameters.onClickGithubButton }
    set { parameters.onClickGithubButton = newValue }
  }

  public var onClickGoogleButton: (() -> Void)? {
    get { return parameters.onClickGoogleButton }
    set { parameters.onClickGoogleButton = newValue }
  }

  public var onClickLocalButton: (() -> Void)? {
    get { return parameters.onClickLocalButton }
    set { parameters.onClickLocalButton = newValue }
  }

  public var onClickRemoteButton: (() -> Void)? {
    get { return parameters.onClickRemoteButton }
    set { parameters.onClickRemoteButton = newValue }
  }

  public var isLoggedIn: Bool {
    get { return parameters.isLoggedIn }
    set {
      if parameters.isLoggedIn != newValue {
        parameters.isLoggedIn = newValue
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

  private var view2View = NSBox()
  private var titleView = LNATextField(labelWithString: "")
  private var vSpacerView = NSBox()
  private var bodyTextView = LNATextField(labelWithString: "")
  private var vSpacer1View = NSBox()
  private var loggedOutView = NSBox()
  private var gitHubButtonView = PrimaryButton()
  private var vSpacer2View = NSBox()
  private var googleButtonView = PrimaryButton()
  private var loggedInView = NSBox()
  private var remoteButtonView = PrimaryButton()
  private var vSpacer3View = NSBox()
  private var bodyText1View = LNATextField(labelWithString: "")
  private var vSpacer4View = NSBox()
  private var view1View = NSBox()
  private var localButtonView = PrimaryButton()

  private var titleViewTextStyle = TextStyles.title
  private var bodyTextViewTextStyle = TextStyles.body
  private var bodyText1ViewTextStyle = TextStyles.body

  private var vSpacer3ViewTopAnchorVSpacer1ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var loggedOutViewTopAnchorVSpacer1ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var loggedOutViewLeadingAnchorLeadingAnchorConstraint: NSLayoutConstraint?
  private var vSpacer3ViewTopAnchorLoggedOutViewBottomAnchorConstraint: NSLayoutConstraint?
  private var loggedOutViewWidthAnchorConstraint: NSLayoutConstraint?
  private var gitHubButtonViewTopAnchorLoggedOutViewTopAnchorConstraint: NSLayoutConstraint?
  private var gitHubButtonViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var gitHubButtonViewTrailingAnchorLoggedOutViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var vSpacer2ViewTopAnchorGitHubButtonViewBottomAnchorConstraint: NSLayoutConstraint?
  private var vSpacer2ViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var googleButtonViewBottomAnchorLoggedOutViewBottomAnchorConstraint: NSLayoutConstraint?
  private var googleButtonViewTopAnchorVSpacer2ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var googleButtonViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var googleButtonViewTrailingAnchorLoggedOutViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var vSpacer2ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var vSpacer2ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var loggedInViewTopAnchorVSpacer1ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var loggedInViewLeadingAnchorLeadingAnchorConstraint: NSLayoutConstraint?
  private var vSpacer3ViewTopAnchorLoggedInViewBottomAnchorConstraint: NSLayoutConstraint?
  private var loggedInViewWidthAnchorConstraint: NSLayoutConstraint?
  private var remoteButtonViewTopAnchorLoggedInViewTopAnchorConstraint: NSLayoutConstraint?
  private var remoteButtonViewBottomAnchorLoggedInViewBottomAnchorConstraint: NSLayoutConstraint?
  private var remoteButtonViewLeadingAnchorLoggedInViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var remoteButtonViewTrailingAnchorLoggedInViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var loggedInViewTopAnchorLoggedOutViewBottomAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    view2View.boxType = .custom
    view2View.borderType = .noBorder
    view2View.contentViewMargins = .zero
    vSpacerView.boxType = .custom
    vSpacerView.borderType = .noBorder
    vSpacerView.contentViewMargins = .zero
    bodyTextView.lineBreakMode = .byWordWrapping
    vSpacer1View.boxType = .custom
    vSpacer1View.borderType = .noBorder
    vSpacer1View.contentViewMargins = .zero
    loggedOutView.boxType = .custom
    loggedOutView.borderType = .noBorder
    loggedOutView.contentViewMargins = .zero
    loggedInView.boxType = .custom
    loggedInView.borderType = .noBorder
    loggedInView.contentViewMargins = .zero
    vSpacer3View.boxType = .custom
    vSpacer3View.borderType = .noBorder
    vSpacer3View.contentViewMargins = .zero
    bodyText1View.lineBreakMode = .byWordWrapping
    vSpacer4View.boxType = .custom
    vSpacer4View.borderType = .noBorder
    vSpacer4View.contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    vSpacer2View.boxType = .custom
    vSpacer2View.borderType = .noBorder
    vSpacer2View.contentViewMargins = .zero

    addSubview(view2View)
    addSubview(vSpacerView)
    addSubview(bodyTextView)
    addSubview(vSpacer1View)
    addSubview(loggedOutView)
    addSubview(loggedInView)
    addSubview(vSpacer3View)
    addSubview(bodyText1View)
    addSubview(vSpacer4View)
    addSubview(view1View)
    view2View.addSubview(titleView)
    loggedOutView.addSubview(gitHubButtonView)
    loggedOutView.addSubview(vSpacer2View)
    loggedOutView.addSubview(googleButtonView)
    loggedInView.addSubview(remoteButtonView)
    view1View.addSubview(localButtonView)

    titleView.attributedStringValue = titleViewTextStyle.apply(to: "Open workspace")
    titleViewTextStyle = TextStyles.title
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    vSpacerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    bodyTextViewTextStyle = TextStyles.body
    bodyTextView.attributedStringValue = bodyTextViewTextStyle.apply(to: bodyTextView.attributedStringValue)
    vSpacer1View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    gitHubButtonView.titleText = "Sign in with GitHub"
    vSpacer2View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    googleButtonView.titleText = "Sign in with Google"
    remoteButtonView.titleText = "Sync a Lona workspace"
    vSpacer3View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    bodyText1View.attributedStringValue =
      bodyText1ViewTextStyle.apply(to: "Or choose a workspace that’s already on your hard drive:")
    bodyText1ViewTextStyle = TextStyles.body
    bodyText1View.attributedStringValue = bodyText1ViewTextStyle.apply(to: bodyText1View.attributedStringValue)
    vSpacer4View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    localButtonView.titleText = "Open workspace folder..."
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    view2View.translatesAutoresizingMaskIntoConstraints = false
    vSpacerView.translatesAutoresizingMaskIntoConstraints = false
    bodyTextView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer1View.translatesAutoresizingMaskIntoConstraints = false
    loggedOutView.translatesAutoresizingMaskIntoConstraints = false
    loggedInView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer3View.translatesAutoresizingMaskIntoConstraints = false
    bodyText1View.translatesAutoresizingMaskIntoConstraints = false
    vSpacer4View.translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    gitHubButtonView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer2View.translatesAutoresizingMaskIntoConstraints = false
    googleButtonView.translatesAutoresizingMaskIntoConstraints = false
    remoteButtonView.translatesAutoresizingMaskIntoConstraints = false
    localButtonView.translatesAutoresizingMaskIntoConstraints = false

    let view2ViewTopAnchorConstraint = view2View.topAnchor.constraint(equalTo: topAnchor)
    let view2ViewLeadingAnchorConstraint = view2View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view2ViewTrailingAnchorConstraint = view2View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let vSpacerViewTopAnchorConstraint = vSpacerView.topAnchor.constraint(equalTo: view2View.bottomAnchor)
    let vSpacerViewLeadingAnchorConstraint = vSpacerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let bodyTextViewTopAnchorConstraint = bodyTextView.topAnchor.constraint(equalTo: vSpacerView.bottomAnchor)
    let bodyTextViewLeadingAnchorConstraint = bodyTextView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let bodyTextViewTrailingAnchorConstraint = bodyTextView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let vSpacer1ViewTopAnchorConstraint = vSpacer1View.topAnchor.constraint(equalTo: bodyTextView.bottomAnchor)
    let vSpacer1ViewLeadingAnchorConstraint = vSpacer1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let vSpacer3ViewLeadingAnchorConstraint = vSpacer3View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let bodyText1ViewTopAnchorConstraint = bodyText1View.topAnchor.constraint(equalTo: vSpacer3View.bottomAnchor)
    let bodyText1ViewLeadingAnchorConstraint = bodyText1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let bodyText1ViewTrailingAnchorConstraint = bodyText1View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let vSpacer4ViewTopAnchorConstraint = vSpacer4View.topAnchor.constraint(equalTo: bodyText1View.bottomAnchor)
    let vSpacer4ViewLeadingAnchorConstraint = vSpacer4View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewBottomAnchorConstraint = view1View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: vSpacer4View.bottomAnchor)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: view2View.topAnchor)
    let titleViewBottomAnchorConstraint = titleView.bottomAnchor.constraint(equalTo: view2View.bottomAnchor)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: view2View.leadingAnchor)
    let titleViewTrailingAnchorConstraint = titleView.trailingAnchor.constraint(equalTo: view2View.trailingAnchor)
    let vSpacerViewHeightAnchorConstraint = vSpacerView.heightAnchor.constraint(equalToConstant: 32)
    let vSpacerViewWidthAnchorConstraint = vSpacerView.widthAnchor.constraint(equalToConstant: 0)
    let vSpacer1ViewHeightAnchorConstraint = vSpacer1View.heightAnchor.constraint(equalToConstant: 16)
    let vSpacer1ViewWidthAnchorConstraint = vSpacer1View.widthAnchor.constraint(equalToConstant: 0)
    let vSpacer3ViewHeightAnchorConstraint = vSpacer3View.heightAnchor.constraint(equalToConstant: 40)
    let vSpacer3ViewWidthAnchorConstraint = vSpacer3View.widthAnchor.constraint(equalToConstant: 0)
    let vSpacer4ViewHeightAnchorConstraint = vSpacer4View.heightAnchor.constraint(equalToConstant: 16)
    let vSpacer4ViewWidthAnchorConstraint = vSpacer4View.widthAnchor.constraint(equalToConstant: 0)
    let view1ViewWidthAnchorConstraint = view1View.widthAnchor.constraint(equalToConstant: 250)
    let localButtonViewTopAnchorConstraint = localButtonView.topAnchor.constraint(equalTo: view1View.topAnchor)
    let localButtonViewBottomAnchorConstraint = localButtonView.bottomAnchor.constraint(equalTo: view1View.bottomAnchor)
    let localButtonViewLeadingAnchorConstraint = localButtonView
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor)
    let localButtonViewTrailingAnchorConstraint = localButtonView
      .trailingAnchor
      .constraint(equalTo: view1View.trailingAnchor)
    let vSpacer3ViewTopAnchorVSpacer1ViewBottomAnchorConstraint = vSpacer3View
      .topAnchor
      .constraint(equalTo: vSpacer1View.bottomAnchor)
    let loggedOutViewTopAnchorVSpacer1ViewBottomAnchorConstraint = loggedOutView
      .topAnchor
      .constraint(equalTo: vSpacer1View.bottomAnchor)
    let loggedOutViewLeadingAnchorLeadingAnchorConstraint = loggedOutView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let vSpacer3ViewTopAnchorLoggedOutViewBottomAnchorConstraint = vSpacer3View
      .topAnchor
      .constraint(equalTo: loggedOutView.bottomAnchor)
    let loggedOutViewWidthAnchorConstraint = loggedOutView.widthAnchor.constraint(equalToConstant: 250)
    let gitHubButtonViewTopAnchorLoggedOutViewTopAnchorConstraint = gitHubButtonView
      .topAnchor
      .constraint(equalTo: loggedOutView.topAnchor)
    let gitHubButtonViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint = gitHubButtonView
      .leadingAnchor
      .constraint(equalTo: loggedOutView.leadingAnchor)
    let gitHubButtonViewTrailingAnchorLoggedOutViewTrailingAnchorConstraint = gitHubButtonView
      .trailingAnchor
      .constraint(equalTo: loggedOutView.trailingAnchor)
    let vSpacer2ViewTopAnchorGitHubButtonViewBottomAnchorConstraint = vSpacer2View
      .topAnchor
      .constraint(equalTo: gitHubButtonView.bottomAnchor)
    let vSpacer2ViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint = vSpacer2View
      .leadingAnchor
      .constraint(equalTo: loggedOutView.leadingAnchor)
    let googleButtonViewBottomAnchorLoggedOutViewBottomAnchorConstraint = googleButtonView
      .bottomAnchor
      .constraint(equalTo: loggedOutView.bottomAnchor)
    let googleButtonViewTopAnchorVSpacer2ViewBottomAnchorConstraint = googleButtonView
      .topAnchor
      .constraint(equalTo: vSpacer2View.bottomAnchor)
    let googleButtonViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint = googleButtonView
      .leadingAnchor
      .constraint(equalTo: loggedOutView.leadingAnchor)
    let googleButtonViewTrailingAnchorLoggedOutViewTrailingAnchorConstraint = googleButtonView
      .trailingAnchor
      .constraint(equalTo: loggedOutView.trailingAnchor)
    let vSpacer2ViewHeightAnchorConstraint = vSpacer2View.heightAnchor.constraint(equalToConstant: 8)
    let vSpacer2ViewWidthAnchorConstraint = vSpacer2View.widthAnchor.constraint(equalToConstant: 0)
    let loggedInViewTopAnchorVSpacer1ViewBottomAnchorConstraint = loggedInView
      .topAnchor
      .constraint(equalTo: vSpacer1View.bottomAnchor)
    let loggedInViewLeadingAnchorLeadingAnchorConstraint = loggedInView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let vSpacer3ViewTopAnchorLoggedInViewBottomAnchorConstraint = vSpacer3View
      .topAnchor
      .constraint(equalTo: loggedInView.bottomAnchor)
    let loggedInViewWidthAnchorConstraint = loggedInView.widthAnchor.constraint(equalToConstant: 250)
    let remoteButtonViewTopAnchorLoggedInViewTopAnchorConstraint = remoteButtonView
      .topAnchor
      .constraint(equalTo: loggedInView.topAnchor)
    let remoteButtonViewBottomAnchorLoggedInViewBottomAnchorConstraint = remoteButtonView
      .bottomAnchor
      .constraint(equalTo: loggedInView.bottomAnchor)
    let remoteButtonViewLeadingAnchorLoggedInViewLeadingAnchorConstraint = remoteButtonView
      .leadingAnchor
      .constraint(equalTo: loggedInView.leadingAnchor)
    let remoteButtonViewTrailingAnchorLoggedInViewTrailingAnchorConstraint = remoteButtonView
      .trailingAnchor
      .constraint(equalTo: loggedInView.trailingAnchor)
    let loggedInViewTopAnchorLoggedOutViewBottomAnchorConstraint = loggedInView
      .topAnchor
      .constraint(equalTo: loggedOutView.bottomAnchor)

    self.vSpacer3ViewTopAnchorVSpacer1ViewBottomAnchorConstraint =
      vSpacer3ViewTopAnchorVSpacer1ViewBottomAnchorConstraint
    self.loggedOutViewTopAnchorVSpacer1ViewBottomAnchorConstraint =
      loggedOutViewTopAnchorVSpacer1ViewBottomAnchorConstraint
    self.loggedOutViewLeadingAnchorLeadingAnchorConstraint = loggedOutViewLeadingAnchorLeadingAnchorConstraint
    self.vSpacer3ViewTopAnchorLoggedOutViewBottomAnchorConstraint =
      vSpacer3ViewTopAnchorLoggedOutViewBottomAnchorConstraint
    self.loggedOutViewWidthAnchorConstraint = loggedOutViewWidthAnchorConstraint
    self.gitHubButtonViewTopAnchorLoggedOutViewTopAnchorConstraint =
      gitHubButtonViewTopAnchorLoggedOutViewTopAnchorConstraint
    self.gitHubButtonViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint =
      gitHubButtonViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint
    self.gitHubButtonViewTrailingAnchorLoggedOutViewTrailingAnchorConstraint =
      gitHubButtonViewTrailingAnchorLoggedOutViewTrailingAnchorConstraint
    self.vSpacer2ViewTopAnchorGitHubButtonViewBottomAnchorConstraint =
      vSpacer2ViewTopAnchorGitHubButtonViewBottomAnchorConstraint
    self.vSpacer2ViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint =
      vSpacer2ViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint
    self.googleButtonViewBottomAnchorLoggedOutViewBottomAnchorConstraint =
      googleButtonViewBottomAnchorLoggedOutViewBottomAnchorConstraint
    self.googleButtonViewTopAnchorVSpacer2ViewBottomAnchorConstraint =
      googleButtonViewTopAnchorVSpacer2ViewBottomAnchorConstraint
    self.googleButtonViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint =
      googleButtonViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint
    self.googleButtonViewTrailingAnchorLoggedOutViewTrailingAnchorConstraint =
      googleButtonViewTrailingAnchorLoggedOutViewTrailingAnchorConstraint
    self.vSpacer2ViewHeightAnchorConstraint = vSpacer2ViewHeightAnchorConstraint
    self.vSpacer2ViewWidthAnchorConstraint = vSpacer2ViewWidthAnchorConstraint
    self.loggedInViewTopAnchorVSpacer1ViewBottomAnchorConstraint =
      loggedInViewTopAnchorVSpacer1ViewBottomAnchorConstraint
    self.loggedInViewLeadingAnchorLeadingAnchorConstraint = loggedInViewLeadingAnchorLeadingAnchorConstraint
    self.vSpacer3ViewTopAnchorLoggedInViewBottomAnchorConstraint =
      vSpacer3ViewTopAnchorLoggedInViewBottomAnchorConstraint
    self.loggedInViewWidthAnchorConstraint = loggedInViewWidthAnchorConstraint
    self.remoteButtonViewTopAnchorLoggedInViewTopAnchorConstraint =
      remoteButtonViewTopAnchorLoggedInViewTopAnchorConstraint
    self.remoteButtonViewBottomAnchorLoggedInViewBottomAnchorConstraint =
      remoteButtonViewBottomAnchorLoggedInViewBottomAnchorConstraint
    self.remoteButtonViewLeadingAnchorLoggedInViewLeadingAnchorConstraint =
      remoteButtonViewLeadingAnchorLoggedInViewLeadingAnchorConstraint
    self.remoteButtonViewTrailingAnchorLoggedInViewTrailingAnchorConstraint =
      remoteButtonViewTrailingAnchorLoggedInViewTrailingAnchorConstraint
    self.loggedInViewTopAnchorLoggedOutViewBottomAnchorConstraint =
      loggedInViewTopAnchorLoggedOutViewBottomAnchorConstraint

    NSLayoutConstraint.activate(
      [
        view2ViewTopAnchorConstraint,
        view2ViewLeadingAnchorConstraint,
        view2ViewTrailingAnchorConstraint,
        vSpacerViewTopAnchorConstraint,
        vSpacerViewLeadingAnchorConstraint,
        bodyTextViewTopAnchorConstraint,
        bodyTextViewLeadingAnchorConstraint,
        bodyTextViewTrailingAnchorConstraint,
        vSpacer1ViewTopAnchorConstraint,
        vSpacer1ViewLeadingAnchorConstraint,
        vSpacer3ViewLeadingAnchorConstraint,
        bodyText1ViewTopAnchorConstraint,
        bodyText1ViewLeadingAnchorConstraint,
        bodyText1ViewTrailingAnchorConstraint,
        vSpacer4ViewTopAnchorConstraint,
        vSpacer4ViewLeadingAnchorConstraint,
        view1ViewBottomAnchorConstraint,
        view1ViewTopAnchorConstraint,
        view1ViewLeadingAnchorConstraint,
        titleViewTopAnchorConstraint,
        titleViewBottomAnchorConstraint,
        titleViewLeadingAnchorConstraint,
        titleViewTrailingAnchorConstraint,
        vSpacerViewHeightAnchorConstraint,
        vSpacerViewWidthAnchorConstraint,
        vSpacer1ViewHeightAnchorConstraint,
        vSpacer1ViewWidthAnchorConstraint,
        vSpacer3ViewHeightAnchorConstraint,
        vSpacer3ViewWidthAnchorConstraint,
        vSpacer4ViewHeightAnchorConstraint,
        vSpacer4ViewWidthAnchorConstraint,
        view1ViewWidthAnchorConstraint,
        localButtonViewTopAnchorConstraint,
        localButtonViewBottomAnchorConstraint,
        localButtonViewLeadingAnchorConstraint,
        localButtonViewTrailingAnchorConstraint
      ] +
        conditionalConstraints(
          loggedInViewIsHidden: loggedInView.isHidden,
          loggedOutViewIsHidden: loggedOutView.isHidden))
  }

  private func conditionalConstraints(loggedInViewIsHidden: Bool, loggedOutViewIsHidden: Bool) -> [NSLayoutConstraint] {
    var constraints: [NSLayoutConstraint?]

    switch (loggedInViewIsHidden, loggedOutViewIsHidden) {
      case (true, true):
        constraints = [vSpacer3ViewTopAnchorVSpacer1ViewBottomAnchorConstraint]
      case (true, false):
        constraints = [
          loggedOutViewTopAnchorVSpacer1ViewBottomAnchorConstraint,
          loggedOutViewLeadingAnchorLeadingAnchorConstraint,
          vSpacer3ViewTopAnchorLoggedOutViewBottomAnchorConstraint,
          loggedOutViewWidthAnchorConstraint,
          gitHubButtonViewTopAnchorLoggedOutViewTopAnchorConstraint,
          gitHubButtonViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint,
          gitHubButtonViewTrailingAnchorLoggedOutViewTrailingAnchorConstraint,
          vSpacer2ViewTopAnchorGitHubButtonViewBottomAnchorConstraint,
          vSpacer2ViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint,
          googleButtonViewBottomAnchorLoggedOutViewBottomAnchorConstraint,
          googleButtonViewTopAnchorVSpacer2ViewBottomAnchorConstraint,
          googleButtonViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint,
          googleButtonViewTrailingAnchorLoggedOutViewTrailingAnchorConstraint,
          vSpacer2ViewHeightAnchorConstraint,
          vSpacer2ViewWidthAnchorConstraint
        ]
      case (false, true):
        constraints = [
          loggedInViewTopAnchorVSpacer1ViewBottomAnchorConstraint,
          loggedInViewLeadingAnchorLeadingAnchorConstraint,
          vSpacer3ViewTopAnchorLoggedInViewBottomAnchorConstraint,
          loggedInViewWidthAnchorConstraint,
          remoteButtonViewTopAnchorLoggedInViewTopAnchorConstraint,
          remoteButtonViewBottomAnchorLoggedInViewBottomAnchorConstraint,
          remoteButtonViewLeadingAnchorLoggedInViewLeadingAnchorConstraint,
          remoteButtonViewTrailingAnchorLoggedInViewTrailingAnchorConstraint
        ]
      case (false, false):
        constraints = [
          loggedOutViewTopAnchorVSpacer1ViewBottomAnchorConstraint,
          loggedOutViewLeadingAnchorLeadingAnchorConstraint,
          loggedInViewTopAnchorLoggedOutViewBottomAnchorConstraint,
          loggedInViewLeadingAnchorLeadingAnchorConstraint,
          vSpacer3ViewTopAnchorLoggedInViewBottomAnchorConstraint,
          loggedOutViewWidthAnchorConstraint,
          gitHubButtonViewTopAnchorLoggedOutViewTopAnchorConstraint,
          gitHubButtonViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint,
          gitHubButtonViewTrailingAnchorLoggedOutViewTrailingAnchorConstraint,
          vSpacer2ViewTopAnchorGitHubButtonViewBottomAnchorConstraint,
          vSpacer2ViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint,
          googleButtonViewBottomAnchorLoggedOutViewBottomAnchorConstraint,
          googleButtonViewTopAnchorVSpacer2ViewBottomAnchorConstraint,
          googleButtonViewLeadingAnchorLoggedOutViewLeadingAnchorConstraint,
          googleButtonViewTrailingAnchorLoggedOutViewTrailingAnchorConstraint,
          loggedInViewWidthAnchorConstraint,
          remoteButtonViewTopAnchorLoggedInViewTopAnchorConstraint,
          remoteButtonViewBottomAnchorLoggedInViewBottomAnchorConstraint,
          remoteButtonViewLeadingAnchorLoggedInViewLeadingAnchorConstraint,
          remoteButtonViewTrailingAnchorLoggedInViewTrailingAnchorConstraint,
          vSpacer2ViewHeightAnchorConstraint,
          vSpacer2ViewWidthAnchorConstraint
        ]
    }

    return constraints.compactMap({ $0 })
  }

  private func update() {
    let loggedInViewIsHidden = loggedInView.isHidden
    let loggedOutViewIsHidden = loggedOutView.isHidden

    bodyTextView.attributedStringValue =
      bodyTextViewTextStyle.apply(to: "Sign in to sync a Lona workspace from your account to your hard drive.")
    loggedInView.isHidden = !true
    loggedOutView.isHidden = !true
    gitHubButtonView.onClick = handleOnClickGithubButton
    googleButtonView.onClick = handleOnClickGoogleButton
    localButtonView.onClick = handleOnClickLocalButton
    remoteButtonView.onClick = handleOnClickRemoteButton
    if isLoggedIn {
      bodyTextView.attributedStringValue =
        bodyTextViewTextStyle.apply(to: "Sync a workspace from your Lona account to your hard drive:")
      loggedInView.isHidden = !true
      loggedOutView.isHidden = !false
    }
    if isLoggedIn == false {
      bodyTextView.attributedStringValue =
        bodyTextViewTextStyle.apply(to: "Sign in to sync a Lona workspace from your account to your hard drive:")
      loggedInView.isHidden = !false
      loggedOutView.isHidden = !true
    }

    if loggedInView.isHidden != loggedInViewIsHidden || loggedOutView.isHidden != loggedOutViewIsHidden {
      NSLayoutConstraint.deactivate(
        conditionalConstraints(
          loggedInViewIsHidden: loggedInViewIsHidden,
          loggedOutViewIsHidden: loggedOutViewIsHidden))
      NSLayoutConstraint.activate(
        conditionalConstraints(
          loggedInViewIsHidden: loggedInView.isHidden,
          loggedOutViewIsHidden: loggedOutView.isHidden))
    }
  }

  private func handleOnClickGithubButton() {
    onClickGithubButton?()
  }

  private func handleOnClickGoogleButton() {
    onClickGoogleButton?()
  }

  private func handleOnClickLocalButton() {
    onClickLocalButton?()
  }

  private func handleOnClickRemoteButton() {
    onClickRemoteButton?()
  }
}

// MARK: - Parameters

extension OpenWorkspace {
  public struct Parameters: Equatable {
    public var isLoggedIn: Bool
    public var onClickGithubButton: (() -> Void)?
    public var onClickGoogleButton: (() -> Void)?
    public var onClickLocalButton: (() -> Void)?
    public var onClickRemoteButton: (() -> Void)?

    public init(
      isLoggedIn: Bool,
      onClickGithubButton: (() -> Void)? = nil,
      onClickGoogleButton: (() -> Void)? = nil,
      onClickLocalButton: (() -> Void)? = nil,
      onClickRemoteButton: (() -> Void)? = nil)
    {
      self.isLoggedIn = isLoggedIn
      self.onClickGithubButton = onClickGithubButton
      self.onClickGoogleButton = onClickGoogleButton
      self.onClickLocalButton = onClickLocalButton
      self.onClickRemoteButton = onClickRemoteButton
    }

    public init() {
      self.init(isLoggedIn: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.isLoggedIn == rhs.isLoggedIn
    }
  }
}

// MARK: - Model

extension OpenWorkspace {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "OpenWorkspace"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      isLoggedIn: Bool,
      onClickGithubButton: (() -> Void)? = nil,
      onClickGoogleButton: (() -> Void)? = nil,
      onClickLocalButton: (() -> Void)? = nil,
      onClickRemoteButton: (() -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            isLoggedIn: isLoggedIn,
            onClickGithubButton: onClickGithubButton,
            onClickGoogleButton: onClickGoogleButton,
            onClickLocalButton: onClickLocalButton,
            onClickRemoteButton: onClickRemoteButton))
    }

    public init() {
      self.init(isLoggedIn: false)
    }
  }
}
