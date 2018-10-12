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
    titleView.attributedStringValue = titleViewTextStyle.apply(to: "Welcome to Lona")
    titleViewTextStyle = TextStyles.title
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    versionView.attributedStringValue = versionViewTextStyle.apply(to: "Developer Preview")
    versionViewTextStyle = TextStyles.versionInfo
    versionView.attributedStringValue = versionViewTextStyle.apply(to: versionView.attributedStringValue)
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

    let splashViewLeadingAnchorConstraint = splashView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let splashViewTopAnchorConstraint = splashView.topAnchor.constraint(equalTo: topAnchor)
    let splashViewBottomAnchorConstraint = splashView
      .bottomAnchor
      .constraint(lessThanOrEqualTo: bottomAnchor, constant: -20)
    let dividerViewLeadingAnchorConstraint = dividerView.leadingAnchor.constraint(equalTo: splashView.trailingAnchor)
    let dividerViewTopAnchorConstraint = dividerView.topAnchor.constraint(equalTo: topAnchor)
    let dividerViewBottomAnchorConstraint = dividerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let projectsViewTrailingAnchorConstraint = projectsView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let projectsViewLeadingAnchorConstraint = projectsView.leadingAnchor.constraint(equalTo: dividerView.trailingAnchor)
    let projectsViewTopAnchorConstraint = projectsView.topAnchor.constraint(equalTo: topAnchor)
    let projectsViewBottomAnchorConstraint = projectsView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let splashViewWidthAnchorConstraint = splashView.widthAnchor.constraint(equalToConstant: 448)
    let bannerViewTopAnchorConstraint = bannerView.topAnchor.constraint(equalTo: splashView.topAnchor)
    let bannerViewLeadingAnchorConstraint = bannerView.leadingAnchor.constraint(equalTo: splashView.leadingAnchor)
    let bannerViewTrailingAnchorConstraint = bannerView.trailingAnchor.constraint(equalTo: splashView.trailingAnchor)
    let rowsViewBottomAnchorConstraint = rowsView.bottomAnchor.constraint(equalTo: splashView.bottomAnchor)
    let rowsViewTopAnchorConstraint = rowsView.topAnchor.constraint(equalTo: bannerView.bottomAnchor)
    let rowsViewLeadingAnchorConstraint = rowsView.leadingAnchor.constraint(equalTo: splashView.leadingAnchor)
    let rowsViewTrailingAnchorConstraint = rowsView.trailingAnchor.constraint(equalTo: splashView.trailingAnchor)
    let dividerViewWidthAnchorConstraint = dividerView.widthAnchor.constraint(equalToConstant: 1)
    let recentProjectsListViewTopAnchorConstraint = recentProjectsListView
      .topAnchor
      .constraint(equalTo: projectsView.topAnchor)
    let recentProjectsListViewLeadingAnchorConstraint = recentProjectsListView
      .leadingAnchor
      .constraint(equalTo: projectsView.leadingAnchor)
    let recentProjectsListViewTrailingAnchorConstraint = recentProjectsListView
      .trailingAnchor
      .constraint(equalTo: projectsView.trailingAnchor)
    let openProjectButtonViewBottomAnchorConstraint = openProjectButtonView
      .bottomAnchor
      .constraint(equalTo: projectsView.bottomAnchor)
    let openProjectButtonViewTopAnchorConstraint = openProjectButtonView
      .topAnchor
      .constraint(equalTo: recentProjectsListView.bottomAnchor)
    let openProjectButtonViewLeadingAnchorConstraint = openProjectButtonView
      .leadingAnchor
      .constraint(equalTo: projectsView.leadingAnchor)
    let openProjectButtonViewTrailingAnchorConstraint = openProjectButtonView
      .trailingAnchor
      .constraint(equalTo: projectsView.trailingAnchor)
    let imageViewTopAnchorConstraint = imageView.topAnchor.constraint(equalTo: bannerView.topAnchor, constant: 60)
    let imageViewCenterXAnchorConstraint = imageView.centerXAnchor.constraint(equalTo: bannerView.centerXAnchor)
    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: imageView.bottomAnchor)
    let titleViewLeadingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(greaterThanOrEqualTo: bannerView.leadingAnchor)
    let titleViewCenterXAnchorConstraint = titleView.centerXAnchor.constraint(equalTo: bannerView.centerXAnchor)
    let titleViewTrailingAnchorConstraint = titleView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: bannerView.trailingAnchor)
    let versionViewTopAnchorConstraint = versionView.topAnchor.constraint(equalTo: titleView.bottomAnchor)
    let versionViewLeadingAnchorConstraint = versionView
      .leadingAnchor
      .constraint(greaterThanOrEqualTo: bannerView.leadingAnchor)
    let versionViewCenterXAnchorConstraint = versionView.centerXAnchor.constraint(equalTo: bannerView.centerXAnchor)
    let versionViewTrailingAnchorConstraint = versionView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: bannerView.trailingAnchor)
    let newButtonViewTopAnchorConstraint = newButtonView.topAnchor.constraint(equalTo: rowsView.topAnchor)
    let newButtonViewLeadingAnchorConstraint = newButtonView
      .leadingAnchor
      .constraint(equalTo: rowsView.leadingAnchor, constant: 24)
    let newButtonViewTrailingAnchorConstraint = newButtonView
      .trailingAnchor
      .constraint(equalTo: rowsView.trailingAnchor, constant: -24)
    let spacerViewTopAnchorConstraint = spacerView.topAnchor.constraint(equalTo: newButtonView.bottomAnchor)
    let spacerViewLeadingAnchorConstraint = spacerView
      .leadingAnchor
      .constraint(equalTo: rowsView.leadingAnchor, constant: 24)
    let spacerViewTrailingAnchorConstraint = spacerView
      .trailingAnchor
      .constraint(equalTo: rowsView.trailingAnchor, constant: -24)
    let exampleButtonViewTopAnchorConstraint = exampleButtonView.topAnchor.constraint(equalTo: spacerView.bottomAnchor)
    let exampleButtonViewLeadingAnchorConstraint = exampleButtonView
      .leadingAnchor
      .constraint(equalTo: rowsView.leadingAnchor, constant: 24)
    let exampleButtonViewTrailingAnchorConstraint = exampleButtonView
      .trailingAnchor
      .constraint(equalTo: rowsView.trailingAnchor, constant: -24)
    let spacer2ViewTopAnchorConstraint = spacer2View.topAnchor.constraint(equalTo: exampleButtonView.bottomAnchor)
    let spacer2ViewLeadingAnchorConstraint = spacer2View
      .leadingAnchor
      .constraint(equalTo: rowsView.leadingAnchor, constant: 24)
    let spacer2ViewTrailingAnchorConstraint = spacer2View
      .trailingAnchor
      .constraint(equalTo: rowsView.trailingAnchor, constant: -24)
    let documentationButtonViewBottomAnchorConstraint = documentationButtonView
      .bottomAnchor
      .constraint(equalTo: rowsView.bottomAnchor)
    let documentationButtonViewTopAnchorConstraint = documentationButtonView
      .topAnchor
      .constraint(equalTo: spacer2View.bottomAnchor)
    let documentationButtonViewLeadingAnchorConstraint = documentationButtonView
      .leadingAnchor
      .constraint(equalTo: rowsView.leadingAnchor, constant: 24)
    let documentationButtonViewTrailingAnchorConstraint = documentationButtonView
      .trailingAnchor
      .constraint(equalTo: rowsView.trailingAnchor, constant: -24)
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
  }

  private func update() {
    newButtonView.onClick = onCreateProject
    openProjectButtonView.onPressPlus = onCreateProject
    openProjectButtonView.onPressTitle = onOpenProject
    exampleButtonView.onClick = onOpenExample
    documentationButtonView.onClick = onOpenDocumentation
  }
}
