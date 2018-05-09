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
  public var onOpenProject: (() -> Void)? { didSet { update() } }
  public var onOpenExample: (() -> Void)? { didSet { update() } }
  public var onOpenDocumentation: (() -> Void)? { didSet { update() } }

  // MARK: Private

  private var splashView = NSBox()
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
  private var dividerView = NSBox()
  private var projectsView = NSBox()
  private var recentProjectsListView = RecentProjectsList()
  private var openProjectButtonView = OpenProjectButton()

  private var titleViewTextStyle = TextStyles.title
  private var versionViewTextStyle = TextStyles.versionInfo

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var splashViewTopMargin: CGFloat = 0
  private var splashViewTrailingMargin: CGFloat = 0
  private var splashViewBottomMargin: CGFloat = 20
  private var splashViewLeadingMargin: CGFloat = 0
  private var splashViewTopPadding: CGFloat = 0
  private var splashViewTrailingPadding: CGFloat = 0
  private var splashViewBottomPadding: CGFloat = 0
  private var splashViewLeadingPadding: CGFloat = 0
  private var dividerViewTopMargin: CGFloat = 0
  private var dividerViewTrailingMargin: CGFloat = 0
  private var dividerViewBottomMargin: CGFloat = 0
  private var dividerViewLeadingMargin: CGFloat = 0
  private var projectsViewTopMargin: CGFloat = 0
  private var projectsViewTrailingMargin: CGFloat = 0
  private var projectsViewBottomMargin: CGFloat = 0
  private var projectsViewLeadingMargin: CGFloat = 0
  private var projectsViewTopPadding: CGFloat = 0
  private var projectsViewTrailingPadding: CGFloat = 0
  private var projectsViewBottomPadding: CGFloat = 0
  private var projectsViewLeadingPadding: CGFloat = 0
  private var bannerViewTopMargin: CGFloat = 0
  private var bannerViewTrailingMargin: CGFloat = 0
  private var bannerViewBottomMargin: CGFloat = 0
  private var bannerViewLeadingMargin: CGFloat = 0
  private var bannerViewTopPadding: CGFloat = 60
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
  private var recentProjectsListViewTopMargin: CGFloat = 0
  private var recentProjectsListViewTrailingMargin: CGFloat = 0
  private var recentProjectsListViewBottomMargin: CGFloat = 0
  private var recentProjectsListViewLeadingMargin: CGFloat = 0
  private var openProjectButtonViewTopMargin: CGFloat = 0
  private var openProjectButtonViewTrailingMargin: CGFloat = 0
  private var openProjectButtonViewBottomMargin: CGFloat = 0
  private var openProjectButtonViewLeadingMargin: CGFloat = 0

  private var splashViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var splashViewTopAnchorConstraint: NSLayoutConstraint?
  private var splashViewBottomAnchorConstraint: NSLayoutConstraint?
  private var dividerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewTopAnchorConstraint: NSLayoutConstraint?
  private var dividerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var projectsViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var projectsViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var projectsViewTopAnchorConstraint: NSLayoutConstraint?
  private var projectsViewBottomAnchorConstraint: NSLayoutConstraint?
  private var splashViewWidthAnchorConstraint: NSLayoutConstraint?
  private var bannerViewTopAnchorConstraint: NSLayoutConstraint?
  private var bannerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var bannerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var rowsViewBottomAnchorConstraint: NSLayoutConstraint?
  private var rowsViewTopAnchorConstraint: NSLayoutConstraint?
  private var rowsViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var rowsViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewWidthAnchorConstraint: NSLayoutConstraint?
  private var recentProjectsListViewTopAnchorConstraint: NSLayoutConstraint?
  private var recentProjectsListViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var recentProjectsListViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var openProjectButtonViewBottomAnchorConstraint: NSLayoutConstraint?
  private var openProjectButtonViewTopAnchorConstraint: NSLayoutConstraint?
  private var openProjectButtonViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var openProjectButtonViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var imageViewTopAnchorConstraint: NSLayoutConstraint?
  private var imageViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var titleViewTopAnchorConstraint: NSLayoutConstraint?
  private var titleViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var titleViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var titleViewTrailingAnchorConstraint: NSLayoutConstraint?
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
  private var openProjectButtonViewHeightAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    splashView.boxType = .custom
    splashView.borderType = .noBorder
    splashView.contentViewMargins = .zero
    dividerView.boxType = .custom
    dividerView.borderType = .noBorder
    dividerView.contentViewMargins = .zero
    projectsView.boxType = .custom
    projectsView.borderType = .noBorder
    projectsView.contentViewMargins = .zero
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

    addSubview(splashView)
    addSubview(dividerView)
    addSubview(projectsView)
    splashView.addSubview(bannerView)
    splashView.addSubview(rowsView)
    bannerView.addSubview(imageView)
    bannerView.addSubview(titleView)
    bannerView.addSubview(versionView)
    rowsView.addSubview(newButtonView)
    rowsView.addSubview(spacerView)
    rowsView.addSubview(exampleButtonView)
    rowsView.addSubview(spacer2View)
    rowsView.addSubview(documentationButtonView)
    projectsView.addSubview(recentProjectsListView)
    projectsView.addSubview(openProjectButtonView)

    imageView.image = #imageLiteral(resourceName: "LonaIcon_128x128")
    titleViewTextStyle = TextStyles.title
    titleView.attributedStringValue = titleViewTextStyle.apply(to: "Welcome to Lona")
    versionViewTextStyle = TextStyles.versionInfo
    versionView.attributedStringValue = versionViewTextStyle.apply(to: "Developer Preview")
    newButtonView.icon = #imageLiteral(resourceName: "icon-blank-document")
    newButtonView.subtitleText = "Set up a new design system"
    newButtonView.titleText = "Create a new Lona workspace"
    exampleButtonView.icon = #imageLiteral(resourceName: "icon-material-design-example")
    exampleButtonView.subtitleText = "Explore the material design example workspace"
    exampleButtonView.titleText = "Open an example workspace"
    documentationButtonView.icon = #imageLiteral(resourceName: "icon-documentation")
    documentationButtonView.subtitleText = "Check out the documentation to learn how Lona works"
    documentationButtonView.titleText = "Explore documentation"
    dividerView.fillColor = Colors.grey200
    projectsView.fillColor = Colors.grey50
    openProjectButtonView.titleText = "Open workspace..."
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    splashView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    projectsView.translatesAutoresizingMaskIntoConstraints = false
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
    recentProjectsListView.translatesAutoresizingMaskIntoConstraints = false
    openProjectButtonView.translatesAutoresizingMaskIntoConstraints = false

    let splashViewLeadingAnchorConstraint = splashView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + splashViewLeadingMargin)
    let splashViewTopAnchorConstraint = splashView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + splashViewTopMargin)
    let splashViewBottomAnchorConstraint = splashView
      .bottomAnchor
      .constraint(lessThanOrEqualTo: bottomAnchor, constant: -(bottomPadding + splashViewBottomMargin))
    let dividerViewLeadingAnchorConstraint = dividerView
      .leadingAnchor
      .constraint(equalTo: splashView.trailingAnchor, constant: splashViewTrailingMargin + dividerViewLeadingMargin)
    let dividerViewTopAnchorConstraint = dividerView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + dividerViewTopMargin)
    let dividerViewBottomAnchorConstraint = dividerView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + dividerViewBottomMargin))
    let projectsViewTrailingAnchorConstraint = projectsView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + projectsViewTrailingMargin))
    let projectsViewLeadingAnchorConstraint = projectsView
      .leadingAnchor
      .constraint(equalTo: dividerView.trailingAnchor, constant: dividerViewTrailingMargin + projectsViewLeadingMargin)
    let projectsViewTopAnchorConstraint = projectsView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + projectsViewTopMargin)
    let projectsViewBottomAnchorConstraint = projectsView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + projectsViewBottomMargin))
    let splashViewWidthAnchorConstraint = splashView.widthAnchor.constraint(equalToConstant: 448)
    let bannerViewTopAnchorConstraint = bannerView
      .topAnchor
      .constraint(equalTo: splashView.topAnchor, constant: splashViewTopPadding + bannerViewTopMargin)
    let bannerViewLeadingAnchorConstraint = bannerView
      .leadingAnchor
      .constraint(equalTo: splashView.leadingAnchor, constant: splashViewLeadingPadding + bannerViewLeadingMargin)
    let bannerViewTrailingAnchorConstraint = bannerView
      .trailingAnchor
      .constraint(equalTo: splashView.trailingAnchor, constant: -(splashViewTrailingPadding + bannerViewTrailingMargin))
    let rowsViewBottomAnchorConstraint = rowsView
      .bottomAnchor
      .constraint(equalTo: splashView.bottomAnchor, constant: -(splashViewBottomPadding + rowsViewBottomMargin))
    let rowsViewTopAnchorConstraint = rowsView
      .topAnchor
      .constraint(equalTo: bannerView.bottomAnchor, constant: bannerViewBottomMargin + rowsViewTopMargin)
    let rowsViewLeadingAnchorConstraint = rowsView
      .leadingAnchor
      .constraint(equalTo: splashView.leadingAnchor, constant: splashViewLeadingPadding + rowsViewLeadingMargin)
    let rowsViewTrailingAnchorConstraint = rowsView
      .trailingAnchor
      .constraint(equalTo: splashView.trailingAnchor, constant: -(splashViewTrailingPadding + rowsViewTrailingMargin))
    let dividerViewWidthAnchorConstraint = dividerView.widthAnchor.constraint(equalToConstant: 1)
    let recentProjectsListViewTopAnchorConstraint = recentProjectsListView
      .topAnchor
      .constraint(equalTo: projectsView.topAnchor, constant: projectsViewTopPadding + recentProjectsListViewTopMargin)
    let recentProjectsListViewLeadingAnchorConstraint = recentProjectsListView
      .leadingAnchor
      .constraint(
        equalTo: projectsView.leadingAnchor,
        constant: projectsViewLeadingPadding + recentProjectsListViewLeadingMargin)
    let recentProjectsListViewTrailingAnchorConstraint = recentProjectsListView
      .trailingAnchor
      .constraint(
        equalTo: projectsView.trailingAnchor,
        constant: -(projectsViewTrailingPadding + recentProjectsListViewTrailingMargin))
    let openProjectButtonViewBottomAnchorConstraint = openProjectButtonView
      .bottomAnchor
      .constraint(
        equalTo: projectsView.bottomAnchor,
        constant: -(projectsViewBottomPadding + openProjectButtonViewBottomMargin))
    let openProjectButtonViewTopAnchorConstraint = openProjectButtonView
      .topAnchor
      .constraint(
        equalTo: recentProjectsListView.bottomAnchor,
        constant: recentProjectsListViewBottomMargin + openProjectButtonViewTopMargin)
    let openProjectButtonViewLeadingAnchorConstraint = openProjectButtonView
      .leadingAnchor
      .constraint(
        equalTo: projectsView.leadingAnchor,
        constant: projectsViewLeadingPadding + openProjectButtonViewLeadingMargin)
    let openProjectButtonViewTrailingAnchorConstraint = openProjectButtonView
      .trailingAnchor
      .constraint(
        equalTo: projectsView.trailingAnchor,
        constant: -(projectsViewTrailingPadding + openProjectButtonViewTrailingMargin))
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
    let openProjectButtonViewHeightAnchorConstraint = openProjectButtonView.heightAnchor.constraint(equalToConstant: 48)

    NSLayoutConstraint.activate([
      splashViewLeadingAnchorConstraint,
      splashViewTopAnchorConstraint,
      splashViewBottomAnchorConstraint,
      dividerViewLeadingAnchorConstraint,
      dividerViewTopAnchorConstraint,
      dividerViewBottomAnchorConstraint,
      projectsViewTrailingAnchorConstraint,
      projectsViewLeadingAnchorConstraint,
      projectsViewTopAnchorConstraint,
      projectsViewBottomAnchorConstraint,
      splashViewWidthAnchorConstraint,
      bannerViewTopAnchorConstraint,
      bannerViewLeadingAnchorConstraint,
      bannerViewTrailingAnchorConstraint,
      rowsViewBottomAnchorConstraint,
      rowsViewTopAnchorConstraint,
      rowsViewLeadingAnchorConstraint,
      rowsViewTrailingAnchorConstraint,
      dividerViewWidthAnchorConstraint,
      recentProjectsListViewTopAnchorConstraint,
      recentProjectsListViewLeadingAnchorConstraint,
      recentProjectsListViewTrailingAnchorConstraint,
      openProjectButtonViewBottomAnchorConstraint,
      openProjectButtonViewTopAnchorConstraint,
      openProjectButtonViewLeadingAnchorConstraint,
      openProjectButtonViewTrailingAnchorConstraint,
      imageViewTopAnchorConstraint,
      imageViewCenterXAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewCenterXAnchorConstraint,
      titleViewTrailingAnchorConstraint,
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
      spacer2ViewHeightAnchorConstraint,
      openProjectButtonViewHeightAnchorConstraint
    ])

    self.splashViewLeadingAnchorConstraint = splashViewLeadingAnchorConstraint
    self.splashViewTopAnchorConstraint = splashViewTopAnchorConstraint
    self.splashViewBottomAnchorConstraint = splashViewBottomAnchorConstraint
    self.dividerViewLeadingAnchorConstraint = dividerViewLeadingAnchorConstraint
    self.dividerViewTopAnchorConstraint = dividerViewTopAnchorConstraint
    self.dividerViewBottomAnchorConstraint = dividerViewBottomAnchorConstraint
    self.projectsViewTrailingAnchorConstraint = projectsViewTrailingAnchorConstraint
    self.projectsViewLeadingAnchorConstraint = projectsViewLeadingAnchorConstraint
    self.projectsViewTopAnchorConstraint = projectsViewTopAnchorConstraint
    self.projectsViewBottomAnchorConstraint = projectsViewBottomAnchorConstraint
    self.splashViewWidthAnchorConstraint = splashViewWidthAnchorConstraint
    self.bannerViewTopAnchorConstraint = bannerViewTopAnchorConstraint
    self.bannerViewLeadingAnchorConstraint = bannerViewLeadingAnchorConstraint
    self.bannerViewTrailingAnchorConstraint = bannerViewTrailingAnchorConstraint
    self.rowsViewBottomAnchorConstraint = rowsViewBottomAnchorConstraint
    self.rowsViewTopAnchorConstraint = rowsViewTopAnchorConstraint
    self.rowsViewLeadingAnchorConstraint = rowsViewLeadingAnchorConstraint
    self.rowsViewTrailingAnchorConstraint = rowsViewTrailingAnchorConstraint
    self.dividerViewWidthAnchorConstraint = dividerViewWidthAnchorConstraint
    self.recentProjectsListViewTopAnchorConstraint = recentProjectsListViewTopAnchorConstraint
    self.recentProjectsListViewLeadingAnchorConstraint = recentProjectsListViewLeadingAnchorConstraint
    self.recentProjectsListViewTrailingAnchorConstraint = recentProjectsListViewTrailingAnchorConstraint
    self.openProjectButtonViewBottomAnchorConstraint = openProjectButtonViewBottomAnchorConstraint
    self.openProjectButtonViewTopAnchorConstraint = openProjectButtonViewTopAnchorConstraint
    self.openProjectButtonViewLeadingAnchorConstraint = openProjectButtonViewLeadingAnchorConstraint
    self.openProjectButtonViewTrailingAnchorConstraint = openProjectButtonViewTrailingAnchorConstraint
    self.imageViewTopAnchorConstraint = imageViewTopAnchorConstraint
    self.imageViewCenterXAnchorConstraint = imageViewCenterXAnchorConstraint
    self.titleViewTopAnchorConstraint = titleViewTopAnchorConstraint
    self.titleViewLeadingAnchorConstraint = titleViewLeadingAnchorConstraint
    self.titleViewCenterXAnchorConstraint = titleViewCenterXAnchorConstraint
    self.titleViewTrailingAnchorConstraint = titleViewTrailingAnchorConstraint
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
    self.openProjectButtonViewHeightAnchorConstraint = openProjectButtonViewHeightAnchorConstraint

    // For debugging
    splashViewLeadingAnchorConstraint.identifier = "splashViewLeadingAnchorConstraint"
    splashViewTopAnchorConstraint.identifier = "splashViewTopAnchorConstraint"
    splashViewBottomAnchorConstraint.identifier = "splashViewBottomAnchorConstraint"
    dividerViewLeadingAnchorConstraint.identifier = "dividerViewLeadingAnchorConstraint"
    dividerViewTopAnchorConstraint.identifier = "dividerViewTopAnchorConstraint"
    dividerViewBottomAnchorConstraint.identifier = "dividerViewBottomAnchorConstraint"
    projectsViewTrailingAnchorConstraint.identifier = "projectsViewTrailingAnchorConstraint"
    projectsViewLeadingAnchorConstraint.identifier = "projectsViewLeadingAnchorConstraint"
    projectsViewTopAnchorConstraint.identifier = "projectsViewTopAnchorConstraint"
    projectsViewBottomAnchorConstraint.identifier = "projectsViewBottomAnchorConstraint"
    splashViewWidthAnchorConstraint.identifier = "splashViewWidthAnchorConstraint"
    bannerViewTopAnchorConstraint.identifier = "bannerViewTopAnchorConstraint"
    bannerViewLeadingAnchorConstraint.identifier = "bannerViewLeadingAnchorConstraint"
    bannerViewTrailingAnchorConstraint.identifier = "bannerViewTrailingAnchorConstraint"
    rowsViewBottomAnchorConstraint.identifier = "rowsViewBottomAnchorConstraint"
    rowsViewTopAnchorConstraint.identifier = "rowsViewTopAnchorConstraint"
    rowsViewLeadingAnchorConstraint.identifier = "rowsViewLeadingAnchorConstraint"
    rowsViewTrailingAnchorConstraint.identifier = "rowsViewTrailingAnchorConstraint"
    dividerViewWidthAnchorConstraint.identifier = "dividerViewWidthAnchorConstraint"
    recentProjectsListViewTopAnchorConstraint.identifier = "recentProjectsListViewTopAnchorConstraint"
    recentProjectsListViewLeadingAnchorConstraint.identifier = "recentProjectsListViewLeadingAnchorConstraint"
    recentProjectsListViewTrailingAnchorConstraint.identifier = "recentProjectsListViewTrailingAnchorConstraint"
    openProjectButtonViewBottomAnchorConstraint.identifier = "openProjectButtonViewBottomAnchorConstraint"
    openProjectButtonViewTopAnchorConstraint.identifier = "openProjectButtonViewTopAnchorConstraint"
    openProjectButtonViewLeadingAnchorConstraint.identifier = "openProjectButtonViewLeadingAnchorConstraint"
    openProjectButtonViewTrailingAnchorConstraint.identifier = "openProjectButtonViewTrailingAnchorConstraint"
    imageViewTopAnchorConstraint.identifier = "imageViewTopAnchorConstraint"
    imageViewCenterXAnchorConstraint.identifier = "imageViewCenterXAnchorConstraint"
    titleViewTopAnchorConstraint.identifier = "titleViewTopAnchorConstraint"
    titleViewLeadingAnchorConstraint.identifier = "titleViewLeadingAnchorConstraint"
    titleViewCenterXAnchorConstraint.identifier = "titleViewCenterXAnchorConstraint"
    titleViewTrailingAnchorConstraint.identifier = "titleViewTrailingAnchorConstraint"
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
    openProjectButtonViewHeightAnchorConstraint.identifier = "openProjectButtonViewHeightAnchorConstraint"
  }

  private func update() {
    newButtonView.onClick = onCreateProject
    openProjectButtonView.onPressPlus = onCreateProject
    openProjectButtonView.onPressTitle = onOpenProject
    exampleButtonView.onClick = onOpenExample
    documentationButtonView.onClick = onOpenDocumentation
  }
}
