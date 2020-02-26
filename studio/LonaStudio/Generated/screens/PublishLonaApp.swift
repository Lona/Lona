import AppKit
import Foundation

// MARK: - PublishLonaApp

public class PublishLonaApp: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(isSubmitting: Bool) {
    self.init(Parameters(isSubmitting: isSubmitting))
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

  public var onClickOpenGithub: (() -> Void)? {
    get { return parameters.onClickOpenGithub }
    set { parameters.onClickOpenGithub = newValue }
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
  private var viewView = NSBox()
  private var openGithubButtonView = PrimaryButton()
  private var vSpacer4View = NSBox()
  private var instructionsView = LNATextField(labelWithString: "")
  private var vSpacer2View = NSBox()
  private var view2View = NSBox()
  private var view3View = NSBox()
  private var textView = LNATextField(labelWithString: "")
  private var imageView = LNAImageView()
  private var hSpacerView = NSBox()
  private var view4View = NSBox()
  private var text2View = LNATextField(labelWithString: "")
  private var image1View = LNAImageView()
  private var vSpacer1View = NSBox()
  private var text1View = LNATextField(labelWithString: "")
  private var vSpacer3View = NSBox()
  private var view1View = NSBox()
  private var submitButtonView = PrimaryButton()

  private var titleViewTextStyle = TextStyles.title
  private var bodyViewTextStyle = TextStyles.body
  private var instructionsViewTextStyle = TextStyles.largeSemibold
  private var textViewTextStyle = TextStyles.regular
  private var text2ViewTextStyle = TextStyles.regular
  private var text1ViewTextStyle = TextStyles.subtitle

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    vSpacerView.boxType = .custom
    vSpacerView.borderType = .noBorder
    vSpacerView.contentViewMargins = .zero
    bodyView.lineBreakMode = .byWordWrapping
    viewView.boxType = .custom
    viewView.borderType = .noBorder
    viewView.contentViewMargins = .zero
    vSpacer4View.boxType = .custom
    vSpacer4View.borderType = .noBorder
    vSpacer4View.contentViewMargins = .zero
    instructionsView.lineBreakMode = .byWordWrapping
    vSpacer2View.boxType = .custom
    vSpacer2View.borderType = .noBorder
    vSpacer2View.contentViewMargins = .zero
    view2View.boxType = .custom
    view2View.borderType = .noBorder
    view2View.contentViewMargins = .zero
    vSpacer1View.boxType = .custom
    vSpacer1View.borderType = .noBorder
    vSpacer1View.contentViewMargins = .zero
    text1View.lineBreakMode = .byWordWrapping
    vSpacer3View.boxType = .custom
    vSpacer3View.borderType = .noBorder
    vSpacer3View.contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    view3View.boxType = .custom
    view3View.borderType = .noBorder
    view3View.contentViewMargins = .zero
    hSpacerView.boxType = .custom
    hSpacerView.borderType = .noBorder
    hSpacerView.contentViewMargins = .zero
    view4View.boxType = .custom
    view4View.borderType = .noBorder
    view4View.contentViewMargins = .zero
    textView.lineBreakMode = .byWordWrapping
    text2View.lineBreakMode = .byWordWrapping

    addSubview(titleView)
    addSubview(vSpacerView)
    addSubview(bodyView)
    addSubview(viewView)
    addSubview(vSpacer4View)
    addSubview(instructionsView)
    addSubview(vSpacer2View)
    addSubview(view2View)
    addSubview(vSpacer1View)
    addSubview(text1View)
    addSubview(vSpacer3View)
    addSubview(view1View)
    viewView.addSubview(openGithubButtonView)
    view2View.addSubview(view3View)
    view2View.addSubview(hSpacerView)
    view2View.addSubview(view4View)
    view3View.addSubview(textView)
    view3View.addSubview(imageView)
    view4View.addSubview(text2View)
    view4View.addSubview(image1View)
    view1View.addSubview(submitButtonView)

    titleView.attributedStringValue = titleViewTextStyle.apply(to: "Install Lona's GitHub plugin")
    titleViewTextStyle = TextStyles.title
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    vSpacerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    bodyView.attributedStringValue =
      bodyViewTextStyle
        .apply(to:
        "In order to generate a documentation website automatically, you’ll need to install the Lona plugin on your GitHub repository.")
    bodyViewTextStyle = TextStyles.body
    bodyView.attributedStringValue = bodyViewTextStyle.apply(to: bodyView.attributedStringValue)
    openGithubButtonView.titleText = "Open GitHub and install Lona plugin"
    vSpacer4View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    instructionsView.attributedStringValue = instructionsViewTextStyle.apply(to: "Instructions")
    instructionsViewTextStyle = TextStyles.largeSemibold
    instructionsView.attributedStringValue = instructionsViewTextStyle.apply(to: instructionsView.attributedStringValue)
    vSpacer2View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    textView.attributedStringValue =
      textViewTextStyle.apply(to: "1. Choose the GitHub organization your repository belongs to.")
    imageView.image = #imageLiteral(resourceName: "lona-app-install-step1")
    text2View.attributedStringValue =
      text2ViewTextStyle.apply(to: "2. Choose which repositories the Lona plugin has access to.")
    image1View.image = #imageLiteral(resourceName: "lona-app-install-step2")
    vSpacer1View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    text1View.attributedStringValue = text1ViewTextStyle.apply(to: "All done?")
    text1ViewTextStyle = TextStyles.subtitle
    text1View.attributedStringValue = text1ViewTextStyle.apply(to: text1View.attributedStringValue)
    vSpacer3View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    submitButtonView.titleText = "OK, I installed the Lona GitHub plugin"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    vSpacerView.translatesAutoresizingMaskIntoConstraints = false
    bodyView.translatesAutoresizingMaskIntoConstraints = false
    viewView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer4View.translatesAutoresizingMaskIntoConstraints = false
    instructionsView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer2View.translatesAutoresizingMaskIntoConstraints = false
    view2View.translatesAutoresizingMaskIntoConstraints = false
    vSpacer1View.translatesAutoresizingMaskIntoConstraints = false
    text1View.translatesAutoresizingMaskIntoConstraints = false
    vSpacer3View.translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    openGithubButtonView.translatesAutoresizingMaskIntoConstraints = false
    view3View.translatesAutoresizingMaskIntoConstraints = false
    hSpacerView.translatesAutoresizingMaskIntoConstraints = false
    view4View.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    text2View.translatesAutoresizingMaskIntoConstraints = false
    image1View.translatesAutoresizingMaskIntoConstraints = false
    submitButtonView.translatesAutoresizingMaskIntoConstraints = false

    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: topAnchor)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let titleViewTrailingAnchorConstraint = titleView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let vSpacerViewTopAnchorConstraint = vSpacerView.topAnchor.constraint(equalTo: titleView.bottomAnchor)
    let vSpacerViewLeadingAnchorConstraint = vSpacerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let bodyViewTopAnchorConstraint = bodyView.topAnchor.constraint(equalTo: vSpacerView.bottomAnchor)
    let bodyViewLeadingAnchorConstraint = bodyView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let bodyViewTrailingAnchorConstraint = bodyView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let viewViewTopAnchorConstraint = viewView.topAnchor.constraint(equalTo: bodyView.bottomAnchor, constant: 20)
    let viewViewLeadingAnchorConstraint = viewView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let vSpacer4ViewTopAnchorConstraint = vSpacer4View.topAnchor.constraint(equalTo: viewView.bottomAnchor)
    let vSpacer4ViewLeadingAnchorConstraint = vSpacer4View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let instructionsViewTopAnchorConstraint = instructionsView.topAnchor.constraint(equalTo: vSpacer4View.bottomAnchor)
    let instructionsViewLeadingAnchorConstraint = instructionsView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let instructionsViewTrailingAnchorConstraint = instructionsView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let vSpacer2ViewTopAnchorConstraint = vSpacer2View.topAnchor.constraint(equalTo: instructionsView.bottomAnchor)
    let vSpacer2ViewLeadingAnchorConstraint = vSpacer2View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view2ViewTopAnchorConstraint = view2View.topAnchor.constraint(equalTo: vSpacer2View.bottomAnchor)
    let view2ViewLeadingAnchorConstraint = view2View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view2ViewTrailingAnchorConstraint = view2View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let vSpacer1ViewTopAnchorConstraint = vSpacer1View.topAnchor.constraint(equalTo: view2View.bottomAnchor)
    let vSpacer1ViewLeadingAnchorConstraint = vSpacer1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text1ViewTopAnchorConstraint = text1View.topAnchor.constraint(equalTo: vSpacer1View.bottomAnchor)
    let text1ViewLeadingAnchorConstraint = text1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text1ViewTrailingAnchorConstraint = text1View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let vSpacer3ViewTopAnchorConstraint = vSpacer3View.topAnchor.constraint(equalTo: text1View.bottomAnchor)
    let vSpacer3ViewLeadingAnchorConstraint = vSpacer3View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewBottomAnchorConstraint = view1View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: vSpacer3View.bottomAnchor)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let vSpacerViewHeightAnchorConstraint = vSpacerView.heightAnchor.constraint(equalToConstant: 32)
    let vSpacerViewWidthAnchorConstraint = vSpacerView.widthAnchor.constraint(equalToConstant: 0)
    let viewViewWidthAnchorConstraint = viewView.widthAnchor.constraint(equalToConstant: 300)
    let openGithubButtonViewTopAnchorConstraint = openGithubButtonView.topAnchor.constraint(equalTo: viewView.topAnchor)
    let openGithubButtonViewBottomAnchorConstraint = openGithubButtonView
      .bottomAnchor
      .constraint(equalTo: viewView.bottomAnchor)
    let openGithubButtonViewLeadingAnchorConstraint = openGithubButtonView
      .leadingAnchor
      .constraint(equalTo: viewView.leadingAnchor)
    let openGithubButtonViewTrailingAnchorConstraint = openGithubButtonView
      .trailingAnchor
      .constraint(equalTo: viewView.trailingAnchor)
    let vSpacer4ViewHeightAnchorConstraint = vSpacer4View.heightAnchor.constraint(equalToConstant: 36)
    let vSpacer4ViewWidthAnchorConstraint = vSpacer4View.widthAnchor.constraint(equalToConstant: 0)
    let vSpacer2ViewHeightAnchorConstraint = vSpacer2View.heightAnchor.constraint(equalToConstant: 20)
    let vSpacer2ViewWidthAnchorConstraint = vSpacer2View.widthAnchor.constraint(equalToConstant: 0)
    let view2ViewHeightAnchorConstraint = view2View.heightAnchor.constraint(equalToConstant: 415)
    let view3ViewView4ViewWidthAnchorSiblingConstraint = view3View
      .widthAnchor
      .constraint(equalTo: view4View.widthAnchor)
    let view3ViewLeadingAnchorConstraint = view3View.leadingAnchor.constraint(equalTo: view2View.leadingAnchor)
    let view3ViewTopAnchorConstraint = view3View.topAnchor.constraint(equalTo: view2View.topAnchor)
    let view3ViewBottomAnchorConstraint = view3View.bottomAnchor.constraint(equalTo: view2View.bottomAnchor)
    let hSpacerViewLeadingAnchorConstraint = hSpacerView.leadingAnchor.constraint(equalTo: view3View.trailingAnchor)
    let hSpacerViewTopAnchorConstraint = hSpacerView.topAnchor.constraint(equalTo: view2View.topAnchor)
    let hSpacerViewBottomAnchorConstraint = hSpacerView.bottomAnchor.constraint(equalTo: view2View.bottomAnchor)
    let view4ViewTrailingAnchorConstraint = view4View.trailingAnchor.constraint(equalTo: view2View.trailingAnchor)
    let view4ViewLeadingAnchorConstraint = view4View.leadingAnchor.constraint(equalTo: hSpacerView.trailingAnchor)
    let view4ViewTopAnchorConstraint = view4View.topAnchor.constraint(equalTo: view2View.topAnchor)
    let view4ViewBottomAnchorConstraint = view4View.bottomAnchor.constraint(equalTo: view2View.bottomAnchor)
    let vSpacer1ViewHeightAnchorConstraint = vSpacer1View.heightAnchor.constraint(equalToConstant: 72)
    let vSpacer1ViewWidthAnchorConstraint = vSpacer1View.widthAnchor.constraint(equalToConstant: 0)
    let vSpacer3ViewHeightAnchorConstraint = vSpacer3View.heightAnchor.constraint(equalToConstant: 20)
    let vSpacer3ViewWidthAnchorConstraint = vSpacer3View.widthAnchor.constraint(equalToConstant: 0)
    let view1ViewWidthAnchorConstraint = view1View.widthAnchor.constraint(equalToConstant: 300)
    let submitButtonViewTopAnchorConstraint = submitButtonView.topAnchor.constraint(equalTo: view1View.topAnchor)
    let submitButtonViewBottomAnchorConstraint = submitButtonView
      .bottomAnchor
      .constraint(equalTo: view1View.bottomAnchor)
    let submitButtonViewLeadingAnchorConstraint = submitButtonView
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor)
    let submitButtonViewTrailingAnchorConstraint = submitButtonView
      .trailingAnchor
      .constraint(equalTo: view1View.trailingAnchor)
    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: view3View.topAnchor)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: view3View.leadingAnchor)
    let textViewTrailingAnchorConstraint = textView.trailingAnchor.constraint(equalTo: view3View.trailingAnchor)
    let imageViewTopAnchorConstraint = imageView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 12)
    let imageViewLeadingAnchorConstraint = imageView.leadingAnchor.constraint(equalTo: view3View.leadingAnchor)
    let imageViewTrailingAnchorConstraint = imageView.trailingAnchor.constraint(equalTo: view3View.trailingAnchor)
    let hSpacerViewWidthAnchorConstraint = hSpacerView.widthAnchor.constraint(equalToConstant: 24)
    let text2ViewTopAnchorConstraint = text2View.topAnchor.constraint(equalTo: view4View.topAnchor)
    let text2ViewLeadingAnchorConstraint = text2View.leadingAnchor.constraint(equalTo: view4View.leadingAnchor)
    let text2ViewTrailingAnchorConstraint = text2View.trailingAnchor.constraint(equalTo: view4View.trailingAnchor)
    let image1ViewTopAnchorConstraint = image1View.topAnchor.constraint(equalTo: text2View.bottomAnchor, constant: 12)
    let image1ViewLeadingAnchorConstraint = image1View.leadingAnchor.constraint(equalTo: view4View.leadingAnchor)
    let image1ViewTrailingAnchorConstraint = image1View.trailingAnchor.constraint(equalTo: view4View.trailingAnchor)
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 196)
    let image1ViewHeightAnchorConstraint = image1View.heightAnchor.constraint(equalToConstant: 371)

    NSLayoutConstraint.activate([
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      vSpacerViewTopAnchorConstraint,
      vSpacerViewLeadingAnchorConstraint,
      bodyViewTopAnchorConstraint,
      bodyViewLeadingAnchorConstraint,
      bodyViewTrailingAnchorConstraint,
      viewViewTopAnchorConstraint,
      viewViewLeadingAnchorConstraint,
      vSpacer4ViewTopAnchorConstraint,
      vSpacer4ViewLeadingAnchorConstraint,
      instructionsViewTopAnchorConstraint,
      instructionsViewLeadingAnchorConstraint,
      instructionsViewTrailingAnchorConstraint,
      vSpacer2ViewTopAnchorConstraint,
      vSpacer2ViewLeadingAnchorConstraint,
      view2ViewTopAnchorConstraint,
      view2ViewLeadingAnchorConstraint,
      view2ViewTrailingAnchorConstraint,
      vSpacer1ViewTopAnchorConstraint,
      vSpacer1ViewLeadingAnchorConstraint,
      text1ViewTopAnchorConstraint,
      text1ViewLeadingAnchorConstraint,
      text1ViewTrailingAnchorConstraint,
      vSpacer3ViewTopAnchorConstraint,
      vSpacer3ViewLeadingAnchorConstraint,
      view1ViewBottomAnchorConstraint,
      view1ViewTopAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      vSpacerViewHeightAnchorConstraint,
      vSpacerViewWidthAnchorConstraint,
      viewViewWidthAnchorConstraint,
      openGithubButtonViewTopAnchorConstraint,
      openGithubButtonViewBottomAnchorConstraint,
      openGithubButtonViewLeadingAnchorConstraint,
      openGithubButtonViewTrailingAnchorConstraint,
      vSpacer4ViewHeightAnchorConstraint,
      vSpacer4ViewWidthAnchorConstraint,
      vSpacer2ViewHeightAnchorConstraint,
      vSpacer2ViewWidthAnchorConstraint,
      view2ViewHeightAnchorConstraint,
      view3ViewView4ViewWidthAnchorSiblingConstraint,
      view3ViewLeadingAnchorConstraint,
      view3ViewTopAnchorConstraint,
      view3ViewBottomAnchorConstraint,
      hSpacerViewLeadingAnchorConstraint,
      hSpacerViewTopAnchorConstraint,
      hSpacerViewBottomAnchorConstraint,
      view4ViewTrailingAnchorConstraint,
      view4ViewLeadingAnchorConstraint,
      view4ViewTopAnchorConstraint,
      view4ViewBottomAnchorConstraint,
      vSpacer1ViewHeightAnchorConstraint,
      vSpacer1ViewWidthAnchorConstraint,
      vSpacer3ViewHeightAnchorConstraint,
      vSpacer3ViewWidthAnchorConstraint,
      view1ViewWidthAnchorConstraint,
      submitButtonViewTopAnchorConstraint,
      submitButtonViewBottomAnchorConstraint,
      submitButtonViewLeadingAnchorConstraint,
      submitButtonViewTrailingAnchorConstraint,
      textViewTopAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint,
      imageViewTopAnchorConstraint,
      imageViewLeadingAnchorConstraint,
      imageViewTrailingAnchorConstraint,
      hSpacerViewWidthAnchorConstraint,
      text2ViewTopAnchorConstraint,
      text2ViewLeadingAnchorConstraint,
      text2ViewTrailingAnchorConstraint,
      image1ViewTopAnchorConstraint,
      image1ViewLeadingAnchorConstraint,
      image1ViewTrailingAnchorConstraint,
      imageViewHeightAnchorConstraint,
      image1ViewHeightAnchorConstraint
    ])
  }

  private func update() {
    submitButtonView.onClick = handleOnClickSubmit
    openGithubButtonView.onClick = handleOnClickOpenGithub
    submitButtonView.disabled = isSubmitting
    openGithubButtonView.disabled = isSubmitting
  }

  private func handleOnClickSubmit() {
    onClickSubmit?()
  }

  private func handleOnClickOpenGithub() {
    onClickOpenGithub?()
  }
}

// MARK: - Parameters

extension PublishLonaApp {
  public struct Parameters: Equatable {
    public var isSubmitting: Bool
    public var onClickSubmit: (() -> Void)?
    public var onClickOpenGithub: (() -> Void)?

    public init(isSubmitting: Bool, onClickSubmit: (() -> Void)? = nil, onClickOpenGithub: (() -> Void)? = nil) {
      self.isSubmitting = isSubmitting
      self.onClickSubmit = onClickSubmit
      self.onClickOpenGithub = onClickOpenGithub
    }

    public init() {
      self.init(isSubmitting: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.isSubmitting == rhs.isSubmitting
    }
  }
}

// MARK: - Model

extension PublishLonaApp {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "PublishLonaApp"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(isSubmitting: Bool, onClickSubmit: (() -> Void)? = nil, onClickOpenGithub: (() -> Void)? = nil) {
      self
        .init(
          Parameters(isSubmitting: isSubmitting, onClickSubmit: onClickSubmit, onClickOpenGithub: onClickOpenGithub))
    }

    public init() {
      self.init(isSubmitting: false)
    }
  }
}
