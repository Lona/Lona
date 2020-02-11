import AppKit
import Foundation

// MARK: - TemplateBrowser

public class TemplateBrowser: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
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

  public var onSelectTokens: (() -> Void)? {
    get { return parameters.onSelectTokens }
    set { parameters.onSelectTokens = newValue }
  }

  public var onSelectThemedTokens: (() -> Void)? {
    get { return parameters.onSelectThemedTokens }
    set { parameters.onSelectThemedTokens = newValue }
  }

  public var onClickDone: (() -> Void)? {
    get { return parameters.onClickDone }
    set { parameters.onClickDone = newValue }
  }

  public var onClickCancel: (() -> Void)? {
    get { return parameters.onClickCancel }
    set { parameters.onClickCancel = newValue }
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
  private var dividerView = NSBox()
  private var contentAreaView = NSBox()
  private var templateListContainerView = NSBox()
  private var templateListTitleView = LNATextField(labelWithString: "")
  private var templateListContentView = NSBox()
  private var tokensListTemplateView = WorkspaceTemplateCard()
  private var view2View = NSBox()
  private var view1View = NSBox()
  private var themedTokensListTemplateView = WorkspaceTemplateCard()
  private var vDividerView = NSBox()
  private var fileListContainerView = NSBox()
  private var templateListTitle1View = LNATextField(labelWithString: "")
  private var templateFileCardView = TemplateFileCard()
  private var cardSpacerView = NSBox()
  private var templateFileCard1View = TemplateFileCard()
  private var cardSpacer1View = NSBox()
  private var templateFileCard2View = TemplateFileCard()
  private var divider5View = NSBox()
  private var view4View = NSBox()
  private var cancelButtonView = Button()
  private var view5View = NSBox()
  private var doneButtonView = Button()

  private var titleViewTextStyle = TextStyles.subtitle
  private var templateListTitleViewTextStyle = TextStyles.sectionTitle
  private var templateListTitle1ViewTextStyle = TextStyles.sectionTitle

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    dividerView.boxType = .custom
    dividerView.borderType = .noBorder
    dividerView.contentViewMargins = .zero
    contentAreaView.boxType = .custom
    contentAreaView.borderType = .noBorder
    contentAreaView.contentViewMargins = .zero
    divider5View.boxType = .custom
    divider5View.borderType = .noBorder
    divider5View.contentViewMargins = .zero
    view4View.boxType = .custom
    view4View.borderType = .noBorder
    view4View.contentViewMargins = .zero
    templateListContainerView.boxType = .custom
    templateListContainerView.borderType = .noBorder
    templateListContainerView.contentViewMargins = .zero
    vDividerView.boxType = .custom
    vDividerView.borderType = .noBorder
    vDividerView.contentViewMargins = .zero
    fileListContainerView.boxType = .custom
    fileListContainerView.borderType = .noBorder
    fileListContainerView.contentViewMargins = .zero
    templateListTitleView.lineBreakMode = .byWordWrapping
    templateListContentView.boxType = .custom
    templateListContentView.borderType = .noBorder
    templateListContentView.contentViewMargins = .zero
    view2View.boxType = .custom
    view2View.borderType = .noBorder
    view2View.contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    templateListTitle1View.lineBreakMode = .byWordWrapping
    cardSpacerView.boxType = .custom
    cardSpacerView.borderType = .noBorder
    cardSpacerView.contentViewMargins = .zero
    cardSpacer1View.boxType = .custom
    cardSpacer1View.borderType = .noBorder
    cardSpacer1View.contentViewMargins = .zero
    view5View.boxType = .custom
    view5View.borderType = .noBorder
    view5View.contentViewMargins = .zero

    addSubview(titleView)
    addSubview(dividerView)
    addSubview(contentAreaView)
    addSubview(divider5View)
    addSubview(view4View)
    contentAreaView.addSubview(templateListContainerView)
    contentAreaView.addSubview(vDividerView)
    contentAreaView.addSubview(fileListContainerView)
    templateListContainerView.addSubview(templateListTitleView)
    templateListContainerView.addSubview(templateListContentView)
    templateListContentView.addSubview(tokensListTemplateView)
    templateListContentView.addSubview(view2View)
    templateListContentView.addSubview(view1View)
    view1View.addSubview(themedTokensListTemplateView)
    fileListContainerView.addSubview(templateListTitle1View)
    fileListContainerView.addSubview(templateFileCardView)
    fileListContainerView.addSubview(cardSpacerView)
    fileListContainerView.addSubview(templateFileCard1View)
    fileListContainerView.addSubview(cardSpacer1View)
    fileListContainerView.addSubview(templateFileCard2View)
    view4View.addSubview(cancelButtonView)
    view4View.addSubview(view5View)
    view4View.addSubview(doneButtonView)

    fillColor = Colors.white
    titleView.attributedStringValue = titleViewTextStyle.apply(to: "Choose a template")
    titleViewTextStyle = TextStyles.subtitle
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    dividerView.fillColor = Colors.grey300
    contentAreaView.fillColor = Colors.grey50
    templateListTitleView.attributedStringValue = templateListTitleViewTextStyle.apply(to: "TEMPLATES")
    templateListTitleViewTextStyle = TextStyles.sectionTitle
    templateListTitleView.attributedStringValue =
      templateListTitleViewTextStyle.apply(to: templateListTitleView.attributedStringValue)
    tokensListTemplateView.image = #imageLiteral(resourceName: "tokens-list")
    tokensListTemplateView.descriptionText =
      "Simple lists of tokens (colors, text styles, etc). Great for new design systems."
    tokensListTemplateView.isSelected = true
    tokensListTemplateView.titleText = "Design Tokens"
    view1View.alphaValue = 0.6
    themedTokensListTemplateView.image = #imageLiteral(resourceName: "themed-tokens-list")
    themedTokensListTemplateView.descriptionText = "There's only one template at the moment..."
    themedTokensListTemplateView.titleText = "More coming soon!"
    vDividerView.fillColor = Colors.grey200
    templateListTitle1View.attributedStringValue = templateListTitle1ViewTextStyle.apply(to: "FILES IN THIS TEMPLATE")
    templateListTitle1ViewTextStyle = TextStyles.sectionTitle
    templateListTitle1View.attributedStringValue =
      templateListTitle1ViewTextStyle.apply(to: templateListTitle1View.attributedStringValue)
    templateFileCardView.subtitleText = "A list of color tokens"
    templateFileCardView.titleText = "Colors.tokens"
    cardSpacerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    templateFileCard1View.subtitleText = "A list of text style tokens"
    templateFileCard1View.titleText = "TextStyles.tokens"
    cardSpacer1View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    templateFileCard2View.subtitleText = "A list of shadow tokens"
    templateFileCard2View.titleText = "Shadows.tokens"
    divider5View.fillColor = Colors.grey300
    cancelButtonView.titleText = "Cancel"
    doneButtonView.titleText = "OK"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    contentAreaView.translatesAutoresizingMaskIntoConstraints = false
    divider5View.translatesAutoresizingMaskIntoConstraints = false
    view4View.translatesAutoresizingMaskIntoConstraints = false
    templateListContainerView.translatesAutoresizingMaskIntoConstraints = false
    vDividerView.translatesAutoresizingMaskIntoConstraints = false
    fileListContainerView.translatesAutoresizingMaskIntoConstraints = false
    templateListTitleView.translatesAutoresizingMaskIntoConstraints = false
    templateListContentView.translatesAutoresizingMaskIntoConstraints = false
    tokensListTemplateView.translatesAutoresizingMaskIntoConstraints = false
    view2View.translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    themedTokensListTemplateView.translatesAutoresizingMaskIntoConstraints = false
    templateListTitle1View.translatesAutoresizingMaskIntoConstraints = false
    templateFileCardView.translatesAutoresizingMaskIntoConstraints = false
    cardSpacerView.translatesAutoresizingMaskIntoConstraints = false
    templateFileCard1View.translatesAutoresizingMaskIntoConstraints = false
    cardSpacer1View.translatesAutoresizingMaskIntoConstraints = false
    templateFileCard2View.translatesAutoresizingMaskIntoConstraints = false
    cancelButtonView.translatesAutoresizingMaskIntoConstraints = false
    view5View.translatesAutoresizingMaskIntoConstraints = false
    doneButtonView.translatesAutoresizingMaskIntoConstraints = false

    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: topAnchor, constant: 58)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40)
    let titleViewTrailingAnchorConstraint = titleView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
    let dividerViewTopAnchorConstraint = dividerView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 24)
    let dividerViewLeadingAnchorConstraint = dividerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let dividerViewTrailingAnchorConstraint = dividerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let contentAreaViewTopAnchorConstraint = contentAreaView.topAnchor.constraint(equalTo: dividerView.bottomAnchor)
    let contentAreaViewLeadingAnchorConstraint = contentAreaView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let contentAreaViewTrailingAnchorConstraint = contentAreaView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let divider5ViewTopAnchorConstraint = divider5View.topAnchor.constraint(equalTo: contentAreaView.bottomAnchor)
    let divider5ViewLeadingAnchorConstraint = divider5View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let divider5ViewTrailingAnchorConstraint = divider5View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let view4ViewBottomAnchorConstraint = view4View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let view4ViewTopAnchorConstraint = view4View.topAnchor.constraint(equalTo: divider5View.bottomAnchor)
    let view4ViewLeadingAnchorConstraint = view4View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view4ViewTrailingAnchorConstraint = view4View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let dividerViewHeightAnchorConstraint = dividerView.heightAnchor.constraint(equalToConstant: 1)
    let contentAreaViewHeightAnchorConstraint = contentAreaView.heightAnchor.constraint(equalToConstant: 460)
    let templateListContainerViewLeadingAnchorConstraint = templateListContainerView
      .leadingAnchor
      .constraint(equalTo: contentAreaView.leadingAnchor, constant: 28)
    let templateListContainerViewTopAnchorConstraint = templateListContainerView
      .topAnchor
      .constraint(equalTo: contentAreaView.topAnchor, constant: 16)
    let templateListContainerViewBottomAnchorConstraint = templateListContainerView
      .bottomAnchor
      .constraint(equalTo: contentAreaView.bottomAnchor, constant: -16)
    let vDividerViewLeadingAnchorConstraint = vDividerView
      .leadingAnchor
      .constraint(equalTo: templateListContainerView.trailingAnchor, constant: 40)
    let vDividerViewTopAnchorConstraint = vDividerView
      .topAnchor
      .constraint(equalTo: contentAreaView.topAnchor, constant: 16)
    let vDividerViewBottomAnchorConstraint = vDividerView
      .bottomAnchor
      .constraint(equalTo: contentAreaView.bottomAnchor, constant: -16)
    let fileListContainerViewTrailingAnchorConstraint = fileListContainerView
      .trailingAnchor
      .constraint(equalTo: contentAreaView.trailingAnchor, constant: -40)
    let fileListContainerViewLeadingAnchorConstraint = fileListContainerView
      .leadingAnchor
      .constraint(equalTo: vDividerView.trailingAnchor, constant: 40)
    let fileListContainerViewTopAnchorConstraint = fileListContainerView
      .topAnchor
      .constraint(equalTo: contentAreaView.topAnchor, constant: 16)
    let fileListContainerViewBottomAnchorConstraint = fileListContainerView
      .bottomAnchor
      .constraint(equalTo: contentAreaView.bottomAnchor, constant: -16)
    let divider5ViewHeightAnchorConstraint = divider5View.heightAnchor.constraint(equalToConstant: 1)
    let cancelButtonViewHeightAnchorParentConstraint = cancelButtonView
      .heightAnchor
      .constraint(lessThanOrEqualTo: view4View.heightAnchor, constant: -24)
    let view5ViewHeightAnchorParentConstraint = view5View
      .heightAnchor
      .constraint(lessThanOrEqualTo: view4View.heightAnchor, constant: -24)
    let doneButtonViewHeightAnchorParentConstraint = doneButtonView
      .heightAnchor
      .constraint(lessThanOrEqualTo: view4View.heightAnchor, constant: -24)
    let cancelButtonViewLeadingAnchorConstraint = cancelButtonView
      .leadingAnchor
      .constraint(equalTo: view4View.leadingAnchor, constant: 24)
    let cancelButtonViewTopAnchorConstraint = cancelButtonView
      .topAnchor
      .constraint(equalTo: view4View.topAnchor, constant: 12)
    let cancelButtonViewBottomAnchorConstraint = cancelButtonView
      .bottomAnchor
      .constraint(equalTo: view4View.bottomAnchor, constant: -12)
    let view5ViewLeadingAnchorConstraint = view5View.leadingAnchor.constraint(equalTo: cancelButtonView.trailingAnchor)
    let view5ViewTopAnchorConstraint = view5View.topAnchor.constraint(equalTo: view4View.topAnchor, constant: 12)
    let view5ViewBottomAnchorConstraint = view5View
      .bottomAnchor
      .constraint(equalTo: view4View.bottomAnchor, constant: -12)
    let doneButtonViewTrailingAnchorConstraint = doneButtonView
      .trailingAnchor
      .constraint(equalTo: view4View.trailingAnchor, constant: -24)
    let doneButtonViewLeadingAnchorConstraint = doneButtonView
      .leadingAnchor
      .constraint(equalTo: view5View.trailingAnchor)
    let doneButtonViewTopAnchorConstraint = doneButtonView
      .topAnchor
      .constraint(equalTo: view4View.topAnchor, constant: 12)
    let doneButtonViewBottomAnchorConstraint = doneButtonView
      .bottomAnchor
      .constraint(equalTo: view4View.bottomAnchor, constant: -12)
    let templateListTitleViewTopAnchorConstraint = templateListTitleView
      .topAnchor
      .constraint(equalTo: templateListContainerView.topAnchor, constant: 12)
    let templateListTitleViewLeadingAnchorConstraint = templateListTitleView
      .leadingAnchor
      .constraint(equalTo: templateListContainerView.leadingAnchor, constant: 12)
    let templateListTitleViewTrailingAnchorConstraint = templateListTitleView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: templateListContainerView.trailingAnchor)
    let templateListContentViewBottomAnchorConstraint = templateListContentView
      .bottomAnchor
      .constraint(equalTo: templateListContainerView.bottomAnchor)
    let templateListContentViewTopAnchorConstraint = templateListContentView
      .topAnchor
      .constraint(equalTo: templateListTitleView.bottomAnchor, constant: 20)
    let templateListContentViewLeadingAnchorConstraint = templateListContentView
      .leadingAnchor
      .constraint(equalTo: templateListContainerView.leadingAnchor)
    let templateListContentViewTrailingAnchorConstraint = templateListContentView
      .trailingAnchor
      .constraint(equalTo: templateListContainerView.trailingAnchor)
    let vDividerViewWidthAnchorConstraint = vDividerView.widthAnchor.constraint(equalToConstant: 1)
    let fileListContainerViewWidthAnchorConstraint = fileListContainerView.widthAnchor.constraint(equalToConstant: 321)
    let templateListTitle1ViewTopAnchorConstraint = templateListTitle1View
      .topAnchor
      .constraint(equalTo: fileListContainerView.topAnchor, constant: 12)
    let templateListTitle1ViewLeadingAnchorConstraint = templateListTitle1View
      .leadingAnchor
      .constraint(equalTo: fileListContainerView.leadingAnchor)
    let templateListTitle1ViewTrailingAnchorConstraint = templateListTitle1View
      .trailingAnchor
      .constraint(equalTo: fileListContainerView.trailingAnchor)
    let templateFileCardViewTopAnchorConstraint = templateFileCardView
      .topAnchor
      .constraint(equalTo: templateListTitle1View.bottomAnchor, constant: 20)
    let templateFileCardViewLeadingAnchorConstraint = templateFileCardView
      .leadingAnchor
      .constraint(equalTo: fileListContainerView.leadingAnchor)
    let templateFileCardViewTrailingAnchorConstraint = templateFileCardView
      .trailingAnchor
      .constraint(equalTo: fileListContainerView.trailingAnchor)
    let cardSpacerViewTopAnchorConstraint = cardSpacerView
      .topAnchor
      .constraint(equalTo: templateFileCardView.bottomAnchor)
    let cardSpacerViewLeadingAnchorConstraint = cardSpacerView
      .leadingAnchor
      .constraint(equalTo: fileListContainerView.leadingAnchor)
    let templateFileCard1ViewTopAnchorConstraint = templateFileCard1View
      .topAnchor
      .constraint(equalTo: cardSpacerView.bottomAnchor)
    let templateFileCard1ViewLeadingAnchorConstraint = templateFileCard1View
      .leadingAnchor
      .constraint(equalTo: fileListContainerView.leadingAnchor)
    let templateFileCard1ViewTrailingAnchorConstraint = templateFileCard1View
      .trailingAnchor
      .constraint(equalTo: fileListContainerView.trailingAnchor)
    let cardSpacer1ViewTopAnchorConstraint = cardSpacer1View
      .topAnchor
      .constraint(equalTo: templateFileCard1View.bottomAnchor)
    let cardSpacer1ViewLeadingAnchorConstraint = cardSpacer1View
      .leadingAnchor
      .constraint(equalTo: fileListContainerView.leadingAnchor)
    let templateFileCard2ViewTopAnchorConstraint = templateFileCard2View
      .topAnchor
      .constraint(equalTo: cardSpacer1View.bottomAnchor)
    let templateFileCard2ViewLeadingAnchorConstraint = templateFileCard2View
      .leadingAnchor
      .constraint(equalTo: fileListContainerView.leadingAnchor)
    let templateFileCard2ViewTrailingAnchorConstraint = templateFileCard2View
      .trailingAnchor
      .constraint(equalTo: fileListContainerView.trailingAnchor)
    let tokensListTemplateViewLeadingAnchorConstraint = tokensListTemplateView
      .leadingAnchor
      .constraint(equalTo: templateListContentView.leadingAnchor)
    let tokensListTemplateViewTopAnchorConstraint = tokensListTemplateView
      .topAnchor
      .constraint(equalTo: templateListContentView.topAnchor)
    let tokensListTemplateViewBottomAnchorConstraint = tokensListTemplateView
      .bottomAnchor
      .constraint(lessThanOrEqualTo: templateListContentView.bottomAnchor)
    let view2ViewLeadingAnchorConstraint = view2View
      .leadingAnchor
      .constraint(equalTo: tokensListTemplateView.trailingAnchor)
    let view2ViewTopAnchorConstraint = view2View.topAnchor.constraint(equalTo: templateListContentView.topAnchor)
    let view2ViewBottomAnchorConstraint = view2View
      .bottomAnchor
      .constraint(lessThanOrEqualTo: templateListContentView.bottomAnchor)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: view2View.trailingAnchor)
    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: templateListContentView.topAnchor)
    let view1ViewBottomAnchorConstraint = view1View
      .bottomAnchor
      .constraint(lessThanOrEqualTo: templateListContentView.bottomAnchor)
    let tokensListTemplateViewWidthAnchorConstraint = tokensListTemplateView
      .widthAnchor
      .constraint(equalToConstant: 230)
    let view2ViewWidthAnchorConstraint = view2View.widthAnchor.constraint(equalToConstant: 8)
    let themedTokensListTemplateViewWidthAnchorParentConstraint = themedTokensListTemplateView
      .widthAnchor
      .constraint(lessThanOrEqualTo: view1View.widthAnchor)
    let themedTokensListTemplateViewTopAnchorConstraint = themedTokensListTemplateView
      .topAnchor
      .constraint(equalTo: view1View.topAnchor)
    let themedTokensListTemplateViewBottomAnchorConstraint = themedTokensListTemplateView
      .bottomAnchor
      .constraint(equalTo: view1View.bottomAnchor)
    let themedTokensListTemplateViewLeadingAnchorConstraint = themedTokensListTemplateView
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor)
    let themedTokensListTemplateViewWidthAnchorConstraint = themedTokensListTemplateView
      .widthAnchor
      .constraint(equalToConstant: 230)
    let cardSpacerViewHeightAnchorConstraint = cardSpacerView.heightAnchor.constraint(equalToConstant: 8)
    let cardSpacerViewWidthAnchorConstraint = cardSpacerView.widthAnchor.constraint(equalToConstant: 0)
    let cardSpacer1ViewHeightAnchorConstraint = cardSpacer1View.heightAnchor.constraint(equalToConstant: 8)
    let cardSpacer1ViewWidthAnchorConstraint = cardSpacer1View.widthAnchor.constraint(equalToConstant: 0)

    cancelButtonViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    view5ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    doneButtonViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    themedTokensListTemplateViewWidthAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      dividerViewTopAnchorConstraint,
      dividerViewLeadingAnchorConstraint,
      dividerViewTrailingAnchorConstraint,
      contentAreaViewTopAnchorConstraint,
      contentAreaViewLeadingAnchorConstraint,
      contentAreaViewTrailingAnchorConstraint,
      divider5ViewTopAnchorConstraint,
      divider5ViewLeadingAnchorConstraint,
      divider5ViewTrailingAnchorConstraint,
      view4ViewBottomAnchorConstraint,
      view4ViewTopAnchorConstraint,
      view4ViewLeadingAnchorConstraint,
      view4ViewTrailingAnchorConstraint,
      dividerViewHeightAnchorConstraint,
      contentAreaViewHeightAnchorConstraint,
      templateListContainerViewLeadingAnchorConstraint,
      templateListContainerViewTopAnchorConstraint,
      templateListContainerViewBottomAnchorConstraint,
      vDividerViewLeadingAnchorConstraint,
      vDividerViewTopAnchorConstraint,
      vDividerViewBottomAnchorConstraint,
      fileListContainerViewTrailingAnchorConstraint,
      fileListContainerViewLeadingAnchorConstraint,
      fileListContainerViewTopAnchorConstraint,
      fileListContainerViewBottomAnchorConstraint,
      divider5ViewHeightAnchorConstraint,
      cancelButtonViewHeightAnchorParentConstraint,
      view5ViewHeightAnchorParentConstraint,
      doneButtonViewHeightAnchorParentConstraint,
      cancelButtonViewLeadingAnchorConstraint,
      cancelButtonViewTopAnchorConstraint,
      cancelButtonViewBottomAnchorConstraint,
      view5ViewLeadingAnchorConstraint,
      view5ViewTopAnchorConstraint,
      view5ViewBottomAnchorConstraint,
      doneButtonViewTrailingAnchorConstraint,
      doneButtonViewLeadingAnchorConstraint,
      doneButtonViewTopAnchorConstraint,
      doneButtonViewBottomAnchorConstraint,
      templateListTitleViewTopAnchorConstraint,
      templateListTitleViewLeadingAnchorConstraint,
      templateListTitleViewTrailingAnchorConstraint,
      templateListContentViewBottomAnchorConstraint,
      templateListContentViewTopAnchorConstraint,
      templateListContentViewLeadingAnchorConstraint,
      templateListContentViewTrailingAnchorConstraint,
      vDividerViewWidthAnchorConstraint,
      fileListContainerViewWidthAnchorConstraint,
      templateListTitle1ViewTopAnchorConstraint,
      templateListTitle1ViewLeadingAnchorConstraint,
      templateListTitle1ViewTrailingAnchorConstraint,
      templateFileCardViewTopAnchorConstraint,
      templateFileCardViewLeadingAnchorConstraint,
      templateFileCardViewTrailingAnchorConstraint,
      cardSpacerViewTopAnchorConstraint,
      cardSpacerViewLeadingAnchorConstraint,
      templateFileCard1ViewTopAnchorConstraint,
      templateFileCard1ViewLeadingAnchorConstraint,
      templateFileCard1ViewTrailingAnchorConstraint,
      cardSpacer1ViewTopAnchorConstraint,
      cardSpacer1ViewLeadingAnchorConstraint,
      templateFileCard2ViewTopAnchorConstraint,
      templateFileCard2ViewLeadingAnchorConstraint,
      templateFileCard2ViewTrailingAnchorConstraint,
      tokensListTemplateViewLeadingAnchorConstraint,
      tokensListTemplateViewTopAnchorConstraint,
      tokensListTemplateViewBottomAnchorConstraint,
      view2ViewLeadingAnchorConstraint,
      view2ViewTopAnchorConstraint,
      view2ViewBottomAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewTopAnchorConstraint,
      view1ViewBottomAnchorConstraint,
      tokensListTemplateViewWidthAnchorConstraint,
      view2ViewWidthAnchorConstraint,
      themedTokensListTemplateViewWidthAnchorParentConstraint,
      themedTokensListTemplateViewTopAnchorConstraint,
      themedTokensListTemplateViewBottomAnchorConstraint,
      themedTokensListTemplateViewLeadingAnchorConstraint,
      themedTokensListTemplateViewWidthAnchorConstraint,
      cardSpacerViewHeightAnchorConstraint,
      cardSpacerViewWidthAnchorConstraint,
      cardSpacer1ViewHeightAnchorConstraint,
      cardSpacer1ViewWidthAnchorConstraint
    ])
  }

  private func update() {
    tokensListTemplateView.onPressCard = handleOnSelectTokens
    themedTokensListTemplateView.onPressCard = handleOnSelectThemedTokens
    doneButtonView.onClick = handleOnClickDone
    cancelButtonView.onClick = handleOnClickCancel
  }

  private func handleOnSelectTokens() {
    onSelectTokens?()
  }

  private func handleOnSelectThemedTokens() {
    onSelectThemedTokens?()
  }

  private func handleOnClickDone() {
    onClickDone?()
  }

  private func handleOnClickCancel() {
    onClickCancel?()
  }
}

// MARK: - Parameters

extension TemplateBrowser {
  public struct Parameters: Equatable {
    public var onSelectTokens: (() -> Void)?
    public var onSelectThemedTokens: (() -> Void)?
    public var onClickDone: (() -> Void)?
    public var onClickCancel: (() -> Void)?

    public init(
      onSelectTokens: (() -> Void)? = nil,
      onSelectThemedTokens: (() -> Void)? = nil,
      onClickDone: (() -> Void)? = nil,
      onClickCancel: (() -> Void)? = nil)
    {
      self.onSelectTokens = onSelectTokens
      self.onSelectThemedTokens = onSelectThemedTokens
      self.onClickDone = onClickDone
      self.onClickCancel = onClickCancel
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return true
    }
  }
}

// MARK: - Model

extension TemplateBrowser {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "TemplateBrowser"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      onSelectTokens: (() -> Void)? = nil,
      onSelectThemedTokens: (() -> Void)? = nil,
      onClickDone: (() -> Void)? = nil,
      onClickCancel: (() -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            onSelectTokens: onSelectTokens,
            onSelectThemedTokens: onSelectThemedTokens,
            onClickDone: onClickDone,
            onClickCancel: onClickCancel))
    }
  }
}
