import AppKit
import Foundation

// MARK: - Welcome

public class Welcome: NSBox {

  // MARK: Lifecycle

  public init() {
    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var onCreateProject: (() -> Void)? { didSet { update() } }
  public var onOpenExample: (() -> Void)? { didSet { update() } }
  public var onOpenDocumentation: (() -> Void)? { didSet { update() } }

  // MARK: Private

  private var bannerView = NSBox()
  private var imageView = NSImageView()
  private var titleView = NSTextField(labelWithString: "")
  private var versionView = NSTextField(labelWithString: "")
  private var rowsView = NSBox()
  private var newButtonView = IconRow()
  private var spacerView = NSBox()
  private var exampleButtonView = IconRow()
  private var spacer2View = NSBox()
  private var documentationButtonView = IconRow()

  private var titleViewTextStyle = TextStyles.title
  private var versionViewTextStyle = TextStyles.versionInfo

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var bannerViewTopMargin: CGFloat = 0
  private var bannerViewTrailingMargin: CGFloat = 0
  private var bannerViewBottomMargin: CGFloat = 0
  private var bannerViewLeadingMargin: CGFloat = 0
  private var bannerViewTopPadding: CGFloat = 40
  private var bannerViewTrailingPadding: CGFloat = 0
  private var bannerViewBottomPadding: CGFloat = 60
  private var bannerViewLeadingPadding: CGFloat = 0
  private var rowsViewTopMargin: CGFloat = 0
  private var rowsViewTrailingMargin: CGFloat = 0
  private var rowsViewBottomMargin: CGFloat = 0
  private var rowsViewLeadingMargin: CGFloat = 0
  private var rowsViewTopPadding: CGFloat = 0
  private var rowsViewTrailingPadding: CGFloat = 24
  private var rowsViewBottomPadding: CGFloat = 0
  private var rowsViewLeadingPadding: CGFloat = 24
  private var imageViewTopMargin: CGFloat = 0
  private var imageViewTrailingMargin: CGFloat = 0
  private var imageViewBottomMargin: CGFloat = 0
  private var imageViewLeadingMargin: CGFloat = 0
  private var titleViewTopMargin: CGFloat = 0
  private var titleViewTrailingMargin: CGFloat = 0
  private var titleViewBottomMargin: CGFloat = 0
  private var titleViewLeadingMargin: CGFloat = 0
  private var versionViewTopMargin: CGFloat = 0
  private var versionViewTrailingMargin: CGFloat = 0
  private var versionViewBottomMargin: CGFloat = 0
  private var versionViewLeadingMargin: CGFloat = 0
  private var newButtonViewTopMargin: CGFloat = 0
  private var newButtonViewTrailingMargin: CGFloat = 0
  private var newButtonViewBottomMargin: CGFloat = 0
  private var newButtonViewLeadingMargin: CGFloat = 0
  private var spacerViewTopMargin: CGFloat = 0
  private var spacerViewTrailingMargin: CGFloat = 0
  private var spacerViewBottomMargin: CGFloat = 0
  private var spacerViewLeadingMargin: CGFloat = 0
  private var exampleButtonViewTopMargin: CGFloat = 0
  private var exampleButtonViewTrailingMargin: CGFloat = 0
  private var exampleButtonViewBottomMargin: CGFloat = 0
  private var exampleButtonViewLeadingMargin: CGFloat = 0
  private var spacer2ViewTopMargin: CGFloat = 0
  private var spacer2ViewTrailingMargin: CGFloat = 0
  private var spacer2ViewBottomMargin: CGFloat = 0
  private var spacer2ViewLeadingMargin: CGFloat = 0
  private var documentationButtonViewTopMargin: CGFloat = 0
  private var documentationButtonViewTrailingMargin: CGFloat = 0
  private var documentationButtonViewBottomMargin: CGFloat = 0
  private var documentationButtonViewLeadingMargin: CGFloat = 0

  private var bannerViewTopAnchorConstraint: NSLayoutConstraint?
  private var bannerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var bannerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var rowsViewBottomAnchorConstraint: NSLayoutConstraint?
  private var rowsViewTopAnchorConstraint: NSLayoutConstraint?
  private var rowsViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var rowsViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var imageViewTopAnchorConstraint: NSLayoutConstraint?
  private var imageViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var titleViewTopAnchorConstraint: NSLayoutConstraint?
  private var titleViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var titleViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var titleViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var versionViewBottomAnchorConstraint: NSLayoutConstraint?
  private var versionViewTopAnchorConstraint: NSLayoutConstraint?
  private var versionViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var versionViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var versionViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var newButtonViewTopAnchorConstraint: NSLayoutConstraint?
  private var newButtonViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var newButtonViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var spacerViewTopAnchorConstraint: NSLayoutConstraint?
  private var spacerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var spacerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var exampleButtonViewTopAnchorConstraint: NSLayoutConstraint?
  private var exampleButtonViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var exampleButtonViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var spacer2ViewTopAnchorConstraint: NSLayoutConstraint?
  private var spacer2ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var spacer2ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var documentationButtonViewBottomAnchorConstraint: NSLayoutConstraint?
  private var documentationButtonViewTopAnchorConstraint: NSLayoutConstraint?
  private var documentationButtonViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var documentationButtonViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var imageViewHeightAnchorConstraint: NSLayoutConstraint?
  private var imageViewWidthAnchorConstraint: NSLayoutConstraint?
  private var spacerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var spacer2ViewHeightAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    bannerView.boxType = .custom
    bannerView.borderType = .noBorder
    bannerView.contentViewMargins = .zero
    rowsView.boxType = .custom
    rowsView.borderType = .noBorder
    rowsView.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    versionView.lineBreakMode = .byWordWrapping
    spacerView.boxType = .custom
    spacerView.borderType = .noBorder
    spacerView.contentViewMargins = .zero
    spacer2View.boxType = .custom
    spacer2View.borderType = .noBorder
    spacer2View.contentViewMargins = .zero

    addSubview(bannerView)
    addSubview(rowsView)
    bannerView.addSubview(imageView)
    bannerView.addSubview(titleView)
    bannerView.addSubview(versionView)
    rowsView.addSubview(newButtonView)
    rowsView.addSubview(spacerView)
    rowsView.addSubview(exampleButtonView)
    rowsView.addSubview(spacer2View)
    rowsView.addSubview(documentationButtonView)

    imageView.image = #imageLiteral(resourceName: "LonaIcon_128x128")
    titleViewTextStyle = TextStyles.title
    titleView.attributedStringValue = titleViewTextStyle.apply(to: "Welcome to Lona")
    versionViewTextStyle = TextStyles.versionInfo
    versionView.attributedStringValue = versionViewTextStyle.apply(to: "Developer Preview")
    newButtonView.icon = #imageLiteral(resourceName: "icon-blank-document")
    newButtonView.subtitleText = "Set up a new design system"
    newButtonView.titleText = "Create a new Lona project"
    exampleButtonView.icon = #imageLiteral(resourceName: "icon-material-design-example")
    exampleButtonView.subtitleText = "Explore the material design example project"
    exampleButtonView.titleText = "Open an example project"
    documentationButtonView.icon = #imageLiteral(resourceName: "icon-documentation")
    documentationButtonView.subtitleText = "Check out the documentation to learn how Lona works"
    documentationButtonView.titleText = "Explore documentation"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    rowsView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    versionView.translatesAutoresizingMaskIntoConstraints = false
    newButtonView.translatesAutoresizingMaskIntoConstraints = false
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    exampleButtonView.translatesAutoresizingMaskIntoConstraints = false
    spacer2View.translatesAutoresizingMaskIntoConstraints = false
    documentationButtonView.translatesAutoresizingMaskIntoConstraints = false

    let bannerViewTopAnchorConstraint = bannerView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + bannerViewTopMargin)
    let bannerViewLeadingAnchorConstraint = bannerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + bannerViewLeadingMargin)
    let bannerViewTrailingAnchorConstraint = bannerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + bannerViewTrailingMargin))
    let rowsViewBottomAnchorConstraint = rowsView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + rowsViewBottomMargin))
    let rowsViewTopAnchorConstraint = rowsView
      .topAnchor
      .constraint(equalTo: bannerView.bottomAnchor, constant: bannerViewBottomMargin + rowsViewTopMargin)
    let rowsViewLeadingAnchorConstraint = rowsView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + rowsViewLeadingMargin)
    let rowsViewTrailingAnchorConstraint = rowsView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + rowsViewTrailingMargin))
    let imageViewTopAnchorConstraint = imageView
      .topAnchor
      .constraint(equalTo: bannerView.topAnchor, constant: bannerViewTopPadding + imageViewTopMargin)
    let imageViewCenterXAnchorConstraint = imageView
      .centerXAnchor
      .constraint(equalTo: bannerView.centerXAnchor, constant: 0)
    let titleViewTopAnchorConstraint = titleView
      .topAnchor
      .constraint(equalTo: imageView.bottomAnchor, constant: imageViewBottomMargin + titleViewTopMargin)
    let titleViewLeadingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(
        greaterThanOrEqualTo: bannerView.leadingAnchor,
        constant: bannerViewLeadingPadding + titleViewLeadingMargin)
    let titleViewCenterXAnchorConstraint = titleView
      .centerXAnchor
      .constraint(equalTo: bannerView.centerXAnchor, constant: 0)
    let titleViewTrailingAnchorConstraint = titleView
      .trailingAnchor
      .constraint(
        lessThanOrEqualTo: bannerView.trailingAnchor,
        constant: -(bannerViewTrailingPadding + titleViewTrailingMargin))
    let versionViewBottomAnchorConstraint = versionView
      .bottomAnchor
      .constraint(equalTo: bannerView.bottomAnchor, constant: -(bannerViewBottomPadding + versionViewBottomMargin))
    let versionViewTopAnchorConstraint = versionView
      .topAnchor
      .constraint(equalTo: titleView.bottomAnchor, constant: titleViewBottomMargin + versionViewTopMargin)
    let versionViewLeadingAnchorConstraint = versionView
      .leadingAnchor
      .constraint(
        greaterThanOrEqualTo: bannerView.leadingAnchor,
        constant: bannerViewLeadingPadding + versionViewLeadingMargin)
    let versionViewCenterXAnchorConstraint = versionView
      .centerXAnchor
      .constraint(equalTo: bannerView.centerXAnchor, constant: 0)
    let versionViewTrailingAnchorConstraint = versionView
      .trailingAnchor
      .constraint(
        lessThanOrEqualTo: bannerView.trailingAnchor,
        constant: -(bannerViewTrailingPadding + versionViewTrailingMargin))
    let newButtonViewTopAnchorConstraint = newButtonView
      .topAnchor
      .constraint(equalTo: rowsView.topAnchor, constant: rowsViewTopPadding + newButtonViewTopMargin)
    let newButtonViewLeadingAnchorConstraint = newButtonView
      .leadingAnchor
      .constraint(equalTo: rowsView.leadingAnchor, constant: rowsViewLeadingPadding + newButtonViewLeadingMargin)
    let newButtonViewTrailingAnchorConstraint = newButtonView
      .trailingAnchor
      .constraint(equalTo: rowsView.trailingAnchor, constant: -(rowsViewTrailingPadding + newButtonViewTrailingMargin))
    let spacerViewTopAnchorConstraint = spacerView
      .topAnchor
      .constraint(equalTo: newButtonView.bottomAnchor, constant: newButtonViewBottomMargin + spacerViewTopMargin)
    let spacerViewLeadingAnchorConstraint = spacerView
      .leadingAnchor
      .constraint(equalTo: rowsView.leadingAnchor, constant: rowsViewLeadingPadding + spacerViewLeadingMargin)
    let spacerViewTrailingAnchorConstraint = spacerView
      .trailingAnchor
      .constraint(equalTo: rowsView.trailingAnchor, constant: -(rowsViewTrailingPadding + spacerViewTrailingMargin))
    let exampleButtonViewTopAnchorConstraint = exampleButtonView
      .topAnchor
      .constraint(equalTo: spacerView.bottomAnchor, constant: spacerViewBottomMargin + exampleButtonViewTopMargin)
    let exampleButtonViewLeadingAnchorConstraint = exampleButtonView
      .leadingAnchor
      .constraint(equalTo: rowsView.leadingAnchor, constant: rowsViewLeadingPadding + exampleButtonViewLeadingMargin)
    let exampleButtonViewTrailingAnchorConstraint = exampleButtonView
      .trailingAnchor
      .constraint(
        equalTo: rowsView.trailingAnchor,
        constant: -(rowsViewTrailingPadding + exampleButtonViewTrailingMargin))
    let spacer2ViewTopAnchorConstraint = spacer2View
      .topAnchor
      .constraint(
        equalTo: exampleButtonView.bottomAnchor,
        constant: exampleButtonViewBottomMargin + spacer2ViewTopMargin)
    let spacer2ViewLeadingAnchorConstraint = spacer2View
      .leadingAnchor
      .constraint(equalTo: rowsView.leadingAnchor, constant: rowsViewLeadingPadding + spacer2ViewLeadingMargin)
    let spacer2ViewTrailingAnchorConstraint = spacer2View
      .trailingAnchor
      .constraint(equalTo: rowsView.trailingAnchor, constant: -(rowsViewTrailingPadding + spacer2ViewTrailingMargin))
    let documentationButtonViewBottomAnchorConstraint = documentationButtonView
      .bottomAnchor
      .constraint(
        equalTo: rowsView.bottomAnchor,
        constant: -(rowsViewBottomPadding + documentationButtonViewBottomMargin))
    let documentationButtonViewTopAnchorConstraint = documentationButtonView
      .topAnchor
      .constraint(
        equalTo: spacer2View.bottomAnchor,
        constant: spacer2ViewBottomMargin + documentationButtonViewTopMargin)
    let documentationButtonViewLeadingAnchorConstraint = documentationButtonView
      .leadingAnchor
      .constraint(
        equalTo: rowsView.leadingAnchor,
        constant: rowsViewLeadingPadding + documentationButtonViewLeadingMargin)
    let documentationButtonViewTrailingAnchorConstraint = documentationButtonView
      .trailingAnchor
      .constraint(
        equalTo: rowsView.trailingAnchor,
        constant: -(rowsViewTrailingPadding + documentationButtonViewTrailingMargin))
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 128)
    let imageViewWidthAnchorConstraint = imageView.widthAnchor.constraint(equalToConstant: 128)
    let spacerViewHeightAnchorConstraint = spacerView.heightAnchor.constraint(equalToConstant: 4)
    let spacer2ViewHeightAnchorConstraint = spacer2View.heightAnchor.constraint(equalToConstant: 4)

    NSLayoutConstraint.activate([
      bannerViewTopAnchorConstraint,
      bannerViewLeadingAnchorConstraint,
      bannerViewTrailingAnchorConstraint,
      rowsViewBottomAnchorConstraint,
      rowsViewTopAnchorConstraint,
      rowsViewLeadingAnchorConstraint,
      rowsViewTrailingAnchorConstraint,
      imageViewTopAnchorConstraint,
      imageViewCenterXAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewCenterXAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      versionViewBottomAnchorConstraint,
      versionViewTopAnchorConstraint,
      versionViewLeadingAnchorConstraint,
      versionViewCenterXAnchorConstraint,
      versionViewTrailingAnchorConstraint,
      newButtonViewTopAnchorConstraint,
      newButtonViewLeadingAnchorConstraint,
      newButtonViewTrailingAnchorConstraint,
      spacerViewTopAnchorConstraint,
      spacerViewLeadingAnchorConstraint,
      spacerViewTrailingAnchorConstraint,
      exampleButtonViewTopAnchorConstraint,
      exampleButtonViewLeadingAnchorConstraint,
      exampleButtonViewTrailingAnchorConstraint,
      spacer2ViewTopAnchorConstraint,
      spacer2ViewLeadingAnchorConstraint,
      spacer2ViewTrailingAnchorConstraint,
      documentationButtonViewBottomAnchorConstraint,
      documentationButtonViewTopAnchorConstraint,
      documentationButtonViewLeadingAnchorConstraint,
      documentationButtonViewTrailingAnchorConstraint,
      imageViewHeightAnchorConstraint,
      imageViewWidthAnchorConstraint,
      spacerViewHeightAnchorConstraint,
      spacer2ViewHeightAnchorConstraint
    ])

    self.bannerViewTopAnchorConstraint = bannerViewTopAnchorConstraint
    self.bannerViewLeadingAnchorConstraint = bannerViewLeadingAnchorConstraint
    self.bannerViewTrailingAnchorConstraint = bannerViewTrailingAnchorConstraint
    self.rowsViewBottomAnchorConstraint = rowsViewBottomAnchorConstraint
    self.rowsViewTopAnchorConstraint = rowsViewTopAnchorConstraint
    self.rowsViewLeadingAnchorConstraint = rowsViewLeadingAnchorConstraint
    self.rowsViewTrailingAnchorConstraint = rowsViewTrailingAnchorConstraint
    self.imageViewTopAnchorConstraint = imageViewTopAnchorConstraint
    self.imageViewCenterXAnchorConstraint = imageViewCenterXAnchorConstraint
    self.titleViewTopAnchorConstraint = titleViewTopAnchorConstraint
    self.titleViewLeadingAnchorConstraint = titleViewLeadingAnchorConstraint
    self.titleViewCenterXAnchorConstraint = titleViewCenterXAnchorConstraint
    self.titleViewTrailingAnchorConstraint = titleViewTrailingAnchorConstraint
    self.versionViewBottomAnchorConstraint = versionViewBottomAnchorConstraint
    self.versionViewTopAnchorConstraint = versionViewTopAnchorConstraint
    self.versionViewLeadingAnchorConstraint = versionViewLeadingAnchorConstraint
    self.versionViewCenterXAnchorConstraint = versionViewCenterXAnchorConstraint
    self.versionViewTrailingAnchorConstraint = versionViewTrailingAnchorConstraint
    self.newButtonViewTopAnchorConstraint = newButtonViewTopAnchorConstraint
    self.newButtonViewLeadingAnchorConstraint = newButtonViewLeadingAnchorConstraint
    self.newButtonViewTrailingAnchorConstraint = newButtonViewTrailingAnchorConstraint
    self.spacerViewTopAnchorConstraint = spacerViewTopAnchorConstraint
    self.spacerViewLeadingAnchorConstraint = spacerViewLeadingAnchorConstraint
    self.spacerViewTrailingAnchorConstraint = spacerViewTrailingAnchorConstraint
    self.exampleButtonViewTopAnchorConstraint = exampleButtonViewTopAnchorConstraint
    self.exampleButtonViewLeadingAnchorConstraint = exampleButtonViewLeadingAnchorConstraint
    self.exampleButtonViewTrailingAnchorConstraint = exampleButtonViewTrailingAnchorConstraint
    self.spacer2ViewTopAnchorConstraint = spacer2ViewTopAnchorConstraint
    self.spacer2ViewLeadingAnchorConstraint = spacer2ViewLeadingAnchorConstraint
    self.spacer2ViewTrailingAnchorConstraint = spacer2ViewTrailingAnchorConstraint
    self.documentationButtonViewBottomAnchorConstraint = documentationButtonViewBottomAnchorConstraint
    self.documentationButtonViewTopAnchorConstraint = documentationButtonViewTopAnchorConstraint
    self.documentationButtonViewLeadingAnchorConstraint = documentationButtonViewLeadingAnchorConstraint
    self.documentationButtonViewTrailingAnchorConstraint = documentationButtonViewTrailingAnchorConstraint
    self.imageViewHeightAnchorConstraint = imageViewHeightAnchorConstraint
    self.imageViewWidthAnchorConstraint = imageViewWidthAnchorConstraint
    self.spacerViewHeightAnchorConstraint = spacerViewHeightAnchorConstraint
    self.spacer2ViewHeightAnchorConstraint = spacer2ViewHeightAnchorConstraint

    // For debugging
    bannerViewTopAnchorConstraint.identifier = "bannerViewTopAnchorConstraint"
    bannerViewLeadingAnchorConstraint.identifier = "bannerViewLeadingAnchorConstraint"
    bannerViewTrailingAnchorConstraint.identifier = "bannerViewTrailingAnchorConstraint"
    rowsViewBottomAnchorConstraint.identifier = "rowsViewBottomAnchorConstraint"
    rowsViewTopAnchorConstraint.identifier = "rowsViewTopAnchorConstraint"
    rowsViewLeadingAnchorConstraint.identifier = "rowsViewLeadingAnchorConstraint"
    rowsViewTrailingAnchorConstraint.identifier = "rowsViewTrailingAnchorConstraint"
    imageViewTopAnchorConstraint.identifier = "imageViewTopAnchorConstraint"
    imageViewCenterXAnchorConstraint.identifier = "imageViewCenterXAnchorConstraint"
    titleViewTopAnchorConstraint.identifier = "titleViewTopAnchorConstraint"
    titleViewLeadingAnchorConstraint.identifier = "titleViewLeadingAnchorConstraint"
    titleViewCenterXAnchorConstraint.identifier = "titleViewCenterXAnchorConstraint"
    titleViewTrailingAnchorConstraint.identifier = "titleViewTrailingAnchorConstraint"
    versionViewBottomAnchorConstraint.identifier = "versionViewBottomAnchorConstraint"
    versionViewTopAnchorConstraint.identifier = "versionViewTopAnchorConstraint"
    versionViewLeadingAnchorConstraint.identifier = "versionViewLeadingAnchorConstraint"
    versionViewCenterXAnchorConstraint.identifier = "versionViewCenterXAnchorConstraint"
    versionViewTrailingAnchorConstraint.identifier = "versionViewTrailingAnchorConstraint"
    newButtonViewTopAnchorConstraint.identifier = "newButtonViewTopAnchorConstraint"
    newButtonViewLeadingAnchorConstraint.identifier = "newButtonViewLeadingAnchorConstraint"
    newButtonViewTrailingAnchorConstraint.identifier = "newButtonViewTrailingAnchorConstraint"
    spacerViewTopAnchorConstraint.identifier = "spacerViewTopAnchorConstraint"
    spacerViewLeadingAnchorConstraint.identifier = "spacerViewLeadingAnchorConstraint"
    spacerViewTrailingAnchorConstraint.identifier = "spacerViewTrailingAnchorConstraint"
    exampleButtonViewTopAnchorConstraint.identifier = "exampleButtonViewTopAnchorConstraint"
    exampleButtonViewLeadingAnchorConstraint.identifier = "exampleButtonViewLeadingAnchorConstraint"
    exampleButtonViewTrailingAnchorConstraint.identifier = "exampleButtonViewTrailingAnchorConstraint"
    spacer2ViewTopAnchorConstraint.identifier = "spacer2ViewTopAnchorConstraint"
    spacer2ViewLeadingAnchorConstraint.identifier = "spacer2ViewLeadingAnchorConstraint"
    spacer2ViewTrailingAnchorConstraint.identifier = "spacer2ViewTrailingAnchorConstraint"
    documentationButtonViewBottomAnchorConstraint.identifier = "documentationButtonViewBottomAnchorConstraint"
    documentationButtonViewTopAnchorConstraint.identifier = "documentationButtonViewTopAnchorConstraint"
    documentationButtonViewLeadingAnchorConstraint.identifier = "documentationButtonViewLeadingAnchorConstraint"
    documentationButtonViewTrailingAnchorConstraint.identifier = "documentationButtonViewTrailingAnchorConstraint"
    imageViewHeightAnchorConstraint.identifier = "imageViewHeightAnchorConstraint"
    imageViewWidthAnchorConstraint.identifier = "imageViewWidthAnchorConstraint"
    spacerViewHeightAnchorConstraint.identifier = "spacerViewHeightAnchorConstraint"
    spacer2ViewHeightAnchorConstraint.identifier = "spacer2ViewHeightAnchorConstraint"
  }

  private func update() {
    newButtonView.onClick = onCreateProject
    exampleButtonView.onClick = onOpenExample
    documentationButtonView.onClick = onOpenDocumentation
  }
}
