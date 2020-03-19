import AppKit
import Foundation

// MARK: - PublishInfo

public class PublishInfo: NSBox {

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
    showsCancelButton: Bool,
    doneButtonTitle: String,
    cancelButtonTitle: String)
  {
    self
      .init(
        Parameters(
          titleText: titleText,
          bodyText: bodyText,
          showsCancelButton: showsCancelButton,
          doneButtonTitle: doneButtonTitle,
          cancelButtonTitle: cancelButtonTitle))
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

  public var onClickDoneButton: (() -> Void)? {
    get { return parameters.onClickDoneButton }
    set { parameters.onClickDoneButton = newValue }
  }

  public var showsCancelButton: Bool {
    get { return parameters.showsCancelButton }
    set {
      if parameters.showsCancelButton != newValue {
        parameters.showsCancelButton = newValue
      }
    }
  }

  public var doneButtonTitle: String {
    get { return parameters.doneButtonTitle }
    set {
      if parameters.doneButtonTitle != newValue {
        parameters.doneButtonTitle = newValue
      }
    }
  }

  public var cancelButtonTitle: String {
    get { return parameters.cancelButtonTitle }
    set {
      if parameters.cancelButtonTitle != newValue {
        parameters.cancelButtonTitle = newValue
      }
    }
  }

  public var onClickCancelButton: (() -> Void)? {
    get { return parameters.onClickCancelButton }
    set { parameters.onClickCancelButton = newValue }
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
  private var vSpacerView = NSBox()
  private var bodyTextView = LNATextField(labelWithString: "")
  private var vSpacer1View = NSBox()
  private var view1View = NSBox()
  private var cancelContainerView = NSBox()
  private var cancelButtonView = PrimaryButton()
  private var view3View = NSBox()
  private var viewView = NSBox()
  private var doneButtonView = PrimaryButton()

  private var publishTextViewTextStyle = TextStyles.titleLight
  private var bodyTextViewTextStyle = TextStyles.body

  private var view3ViewLeadingAnchorView1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var cancelContainerViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var cancelContainerViewLeadingAnchorView1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var cancelContainerViewTopAnchorView1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var cancelContainerViewBottomAnchorView1ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var view3ViewLeadingAnchorCancelContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var cancelContainerViewWidthAnchorConstraint: NSLayoutConstraint?
  private var cancelButtonViewTopAnchorCancelContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var cancelButtonViewBottomAnchorCancelContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var cancelButtonViewLeadingAnchorCancelContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var cancelButtonViewTrailingAnchorCancelContainerViewTrailingAnchorConstraint: NSLayoutConstraint?

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
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    publishTextView.lineBreakMode = .byWordWrapping
    cancelContainerView.boxType = .custom
    cancelContainerView.borderType = .noBorder
    cancelContainerView.contentViewMargins = .zero
    view3View.boxType = .custom
    view3View.borderType = .noBorder
    view3View.contentViewMargins = .zero
    viewView.boxType = .custom
    viewView.borderType = .noBorder
    viewView.contentViewMargins = .zero

    addSubview(titleContainerView)
    addSubview(vSpacerView)
    addSubview(bodyTextView)
    addSubview(vSpacer1View)
    addSubview(view1View)
    titleContainerView.addSubview(publishTextView)
    view1View.addSubview(cancelContainerView)
    view1View.addSubview(view3View)
    view1View.addSubview(viewView)
    cancelContainerView.addSubview(cancelButtonView)
    viewView.addSubview(doneButtonView)

    publishTextViewTextStyle = TextStyles.titleLight
    publishTextView.attributedStringValue = publishTextViewTextStyle.apply(to: publishTextView.attributedStringValue)
    vSpacerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    bodyTextViewTextStyle = TextStyles.body
    bodyTextView.attributedStringValue = bodyTextViewTextStyle.apply(to: bodyTextView.attributedStringValue)
    vSpacer1View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    titleContainerView.translatesAutoresizingMaskIntoConstraints = false
    vSpacerView.translatesAutoresizingMaskIntoConstraints = false
    bodyTextView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer1View.translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    publishTextView.translatesAutoresizingMaskIntoConstraints = false
    cancelContainerView.translatesAutoresizingMaskIntoConstraints = false
    view3View.translatesAutoresizingMaskIntoConstraints = false
    viewView.translatesAutoresizingMaskIntoConstraints = false
    cancelButtonView.translatesAutoresizingMaskIntoConstraints = false
    doneButtonView.translatesAutoresizingMaskIntoConstraints = false

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
    let view1ViewBottomAnchorConstraint = view1View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: vSpacer1View.bottomAnchor)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewTrailingAnchorConstraint = view1View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let publishTextViewHeightAnchorParentConstraint = publishTextView
      .heightAnchor
      .constraint(lessThanOrEqualTo: titleContainerView.heightAnchor)
    let publishTextViewLeadingAnchorConstraint = publishTextView
      .leadingAnchor
      .constraint(equalTo: titleContainerView.leadingAnchor)
    let publishTextViewTopAnchorConstraint = publishTextView.topAnchor.constraint(equalTo: titleContainerView.topAnchor)
    let publishTextViewBottomAnchorConstraint = publishTextView
      .bottomAnchor
      .constraint(equalTo: titleContainerView.bottomAnchor)
    let vSpacerViewHeightAnchorConstraint = vSpacerView.heightAnchor.constraint(equalToConstant: 32)
    let vSpacerViewWidthAnchorConstraint = vSpacerView.widthAnchor.constraint(equalToConstant: 0)
    let vSpacer1ViewHeightAnchorConstraint = vSpacer1View.heightAnchor.constraint(equalToConstant: 72)
    let vSpacer1ViewWidthAnchorConstraint = vSpacer1View.widthAnchor.constraint(equalToConstant: 0)
    let view3ViewHeightAnchorParentConstraint = view3View
      .heightAnchor
      .constraint(lessThanOrEqualTo: view1View.heightAnchor)
    let viewViewHeightAnchorParentConstraint = viewView
      .heightAnchor
      .constraint(lessThanOrEqualTo: view1View.heightAnchor)
    let view3ViewTopAnchorConstraint = view3View.topAnchor.constraint(equalTo: view1View.topAnchor)
    let view3ViewBottomAnchorConstraint = view3View.bottomAnchor.constraint(equalTo: view1View.bottomAnchor)
    let viewViewTrailingAnchorConstraint = viewView.trailingAnchor.constraint(equalTo: view1View.trailingAnchor)
    let viewViewLeadingAnchorConstraint = viewView.leadingAnchor.constraint(equalTo: view3View.trailingAnchor)
    let viewViewTopAnchorConstraint = viewView.topAnchor.constraint(equalTo: view1View.topAnchor)
    let viewViewBottomAnchorConstraint = viewView.bottomAnchor.constraint(equalTo: view1View.bottomAnchor)
    let viewViewWidthAnchorConstraint = viewView.widthAnchor.constraint(equalToConstant: 250)
    let doneButtonViewTopAnchorConstraint = doneButtonView.topAnchor.constraint(equalTo: viewView.topAnchor)
    let doneButtonViewBottomAnchorConstraint = doneButtonView.bottomAnchor.constraint(equalTo: viewView.bottomAnchor)
    let doneButtonViewLeadingAnchorConstraint = doneButtonView.leadingAnchor.constraint(equalTo: viewView.leadingAnchor)
    let doneButtonViewTrailingAnchorConstraint = doneButtonView
      .trailingAnchor
      .constraint(equalTo: viewView.trailingAnchor)
    let view3ViewLeadingAnchorView1ViewLeadingAnchorConstraint = view3View
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor)
    let cancelContainerViewHeightAnchorParentConstraint = cancelContainerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: view1View.heightAnchor)
    let cancelContainerViewLeadingAnchorView1ViewLeadingAnchorConstraint = cancelContainerView
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor)
    let cancelContainerViewTopAnchorView1ViewTopAnchorConstraint = cancelContainerView
      .topAnchor
      .constraint(equalTo: view1View.topAnchor)
    let cancelContainerViewBottomAnchorView1ViewBottomAnchorConstraint = cancelContainerView
      .bottomAnchor
      .constraint(equalTo: view1View.bottomAnchor)
    let view3ViewLeadingAnchorCancelContainerViewTrailingAnchorConstraint = view3View
      .leadingAnchor
      .constraint(equalTo: cancelContainerView.trailingAnchor)
    let cancelContainerViewWidthAnchorConstraint = cancelContainerView.widthAnchor.constraint(equalToConstant: 250)
    let cancelButtonViewTopAnchorCancelContainerViewTopAnchorConstraint = cancelButtonView
      .topAnchor
      .constraint(equalTo: cancelContainerView.topAnchor)
    let cancelButtonViewBottomAnchorCancelContainerViewBottomAnchorConstraint = cancelButtonView
      .bottomAnchor
      .constraint(equalTo: cancelContainerView.bottomAnchor)
    let cancelButtonViewLeadingAnchorCancelContainerViewLeadingAnchorConstraint = cancelButtonView
      .leadingAnchor
      .constraint(equalTo: cancelContainerView.leadingAnchor)
    let cancelButtonViewTrailingAnchorCancelContainerViewTrailingAnchorConstraint = cancelButtonView
      .trailingAnchor
      .constraint(equalTo: cancelContainerView.trailingAnchor)

    publishTextViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    view3ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    viewViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    cancelContainerViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    self.view3ViewLeadingAnchorView1ViewLeadingAnchorConstraint = view3ViewLeadingAnchorView1ViewLeadingAnchorConstraint
    self.cancelContainerViewHeightAnchorParentConstraint = cancelContainerViewHeightAnchorParentConstraint
    self.cancelContainerViewLeadingAnchorView1ViewLeadingAnchorConstraint =
      cancelContainerViewLeadingAnchorView1ViewLeadingAnchorConstraint
    self.cancelContainerViewTopAnchorView1ViewTopAnchorConstraint =
      cancelContainerViewTopAnchorView1ViewTopAnchorConstraint
    self.cancelContainerViewBottomAnchorView1ViewBottomAnchorConstraint =
      cancelContainerViewBottomAnchorView1ViewBottomAnchorConstraint
    self.view3ViewLeadingAnchorCancelContainerViewTrailingAnchorConstraint =
      view3ViewLeadingAnchorCancelContainerViewTrailingAnchorConstraint
    self.cancelContainerViewWidthAnchorConstraint = cancelContainerViewWidthAnchorConstraint
    self.cancelButtonViewTopAnchorCancelContainerViewTopAnchorConstraint =
      cancelButtonViewTopAnchorCancelContainerViewTopAnchorConstraint
    self.cancelButtonViewBottomAnchorCancelContainerViewBottomAnchorConstraint =
      cancelButtonViewBottomAnchorCancelContainerViewBottomAnchorConstraint
    self.cancelButtonViewLeadingAnchorCancelContainerViewLeadingAnchorConstraint =
      cancelButtonViewLeadingAnchorCancelContainerViewLeadingAnchorConstraint
    self.cancelButtonViewTrailingAnchorCancelContainerViewTrailingAnchorConstraint =
      cancelButtonViewTrailingAnchorCancelContainerViewTrailingAnchorConstraint

    NSLayoutConstraint.activate(
      [
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
        view1ViewBottomAnchorConstraint,
        view1ViewTopAnchorConstraint,
        view1ViewLeadingAnchorConstraint,
        view1ViewTrailingAnchorConstraint,
        publishTextViewHeightAnchorParentConstraint,
        publishTextViewLeadingAnchorConstraint,
        publishTextViewTopAnchorConstraint,
        publishTextViewBottomAnchorConstraint,
        vSpacerViewHeightAnchorConstraint,
        vSpacerViewWidthAnchorConstraint,
        vSpacer1ViewHeightAnchorConstraint,
        vSpacer1ViewWidthAnchorConstraint,
        view3ViewHeightAnchorParentConstraint,
        viewViewHeightAnchorParentConstraint,
        view3ViewTopAnchorConstraint,
        view3ViewBottomAnchorConstraint,
        viewViewTrailingAnchorConstraint,
        viewViewLeadingAnchorConstraint,
        viewViewTopAnchorConstraint,
        viewViewBottomAnchorConstraint,
        viewViewWidthAnchorConstraint,
        doneButtonViewTopAnchorConstraint,
        doneButtonViewBottomAnchorConstraint,
        doneButtonViewLeadingAnchorConstraint,
        doneButtonViewTrailingAnchorConstraint
      ] +
        conditionalConstraints(cancelContainerViewIsHidden: cancelContainerView.isHidden))
  }

  private func conditionalConstraints(cancelContainerViewIsHidden: Bool) -> [NSLayoutConstraint] {
    var constraints: [NSLayoutConstraint?]

    switch (cancelContainerViewIsHidden) {
      case (true):
        constraints = [view3ViewLeadingAnchorView1ViewLeadingAnchorConstraint]
      case (false):
        constraints = [
          cancelContainerViewHeightAnchorParentConstraint,
          cancelContainerViewLeadingAnchorView1ViewLeadingAnchorConstraint,
          cancelContainerViewTopAnchorView1ViewTopAnchorConstraint,
          cancelContainerViewBottomAnchorView1ViewBottomAnchorConstraint,
          view3ViewLeadingAnchorCancelContainerViewTrailingAnchorConstraint,
          cancelContainerViewWidthAnchorConstraint,
          cancelButtonViewTopAnchorCancelContainerViewTopAnchorConstraint,
          cancelButtonViewBottomAnchorCancelContainerViewBottomAnchorConstraint,
          cancelButtonViewLeadingAnchorCancelContainerViewLeadingAnchorConstraint,
          cancelButtonViewTrailingAnchorCancelContainerViewTrailingAnchorConstraint
        ]
    }

    return constraints.compactMap({ $0 })
  }

  private func update() {
    let cancelContainerViewIsHidden = cancelContainerView.isHidden

    publishTextView.attributedStringValue = publishTextViewTextStyle.apply(to: titleText)
    bodyTextView.attributedStringValue = bodyTextViewTextStyle.apply(to: bodyText)
    doneButtonView.onClick = handleOnClickDoneButton
    cancelButtonView.onClick = handleOnClickDoneButton
    doneButtonView.titleText = doneButtonTitle
    cancelButtonView.titleText = cancelButtonTitle
    cancelContainerView.isHidden = !showsCancelButton

    if cancelContainerView.isHidden != cancelContainerViewIsHidden {
      NSLayoutConstraint.deactivate(conditionalConstraints(cancelContainerViewIsHidden: cancelContainerViewIsHidden))
      NSLayoutConstraint.activate(conditionalConstraints(cancelContainerViewIsHidden: cancelContainerView.isHidden))
    }
  }

  private func handleOnClickDoneButton() {
    onClickDoneButton?()
  }

  private func handleOnClickCancelButton() {
    onClickCancelButton?()
  }
}

// MARK: - Parameters

extension PublishInfo {
  public struct Parameters: Equatable {
    public var titleText: String
    public var bodyText: String
    public var showsCancelButton: Bool
    public var doneButtonTitle: String
    public var cancelButtonTitle: String
    public var onClickDoneButton: (() -> Void)?
    public var onClickCancelButton: (() -> Void)?

    public init(
      titleText: String,
      bodyText: String,
      showsCancelButton: Bool,
      doneButtonTitle: String,
      cancelButtonTitle: String,
      onClickDoneButton: (() -> Void)? = nil,
      onClickCancelButton: (() -> Void)? = nil)
    {
      self.titleText = titleText
      self.bodyText = bodyText
      self.showsCancelButton = showsCancelButton
      self.doneButtonTitle = doneButtonTitle
      self.cancelButtonTitle = cancelButtonTitle
      self.onClickDoneButton = onClickDoneButton
      self.onClickCancelButton = onClickCancelButton
    }

    public init() {
      self.init(titleText: "", bodyText: "", showsCancelButton: false, doneButtonTitle: "", cancelButtonTitle: "")
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.titleText == rhs.titleText &&
        lhs.bodyText == rhs.bodyText &&
          lhs.showsCancelButton == rhs.showsCancelButton &&
            lhs.doneButtonTitle == rhs.doneButtonTitle && lhs.cancelButtonTitle == rhs.cancelButtonTitle
    }
  }
}

// MARK: - Model

extension PublishInfo {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "PublishInfo"
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
      showsCancelButton: Bool,
      doneButtonTitle: String,
      cancelButtonTitle: String,
      onClickDoneButton: (() -> Void)? = nil,
      onClickCancelButton: (() -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            titleText: titleText,
            bodyText: bodyText,
            showsCancelButton: showsCancelButton,
            doneButtonTitle: doneButtonTitle,
            cancelButtonTitle: cancelButtonTitle,
            onClickDoneButton: onClickDoneButton,
            onClickCancelButton: onClickCancelButton))
    }

    public init() {
      self.init(titleText: "", bodyText: "", showsCancelButton: false, doneButtonTitle: "", cancelButtonTitle: "")
    }
  }
}
