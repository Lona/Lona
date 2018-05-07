import AppKit
import Foundation

// MARK: - WorkspaceVerticalTabs

public class WorkspaceVerticalTabs: NSBox {

  // MARK: Lifecycle

  public init(selectedValue: String) {
    self.selectedValue = selectedValue

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(selectedValue: "")
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var onClickLayers: (() -> Void)? { didSet { update() } }
  public var onClickDocumentation: (() -> Void)? { didSet { update() } }
  public var selectedValue: String { didSet { update() } }

  // MARK: Private

  private var innerView = NSBox()
  private var tabIconLayersView = TabIcon()
  private var tabIconDocumentationView = TabIcon()
  private var dividerView = NSBox()

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var innerViewTopMargin: CGFloat = 0
  private var innerViewTrailingMargin: CGFloat = 0
  private var innerViewBottomMargin: CGFloat = 0
  private var innerViewLeadingMargin: CGFloat = 0
  private var innerViewTopPadding: CGFloat = 0
  private var innerViewTrailingPadding: CGFloat = 0
  private var innerViewBottomPadding: CGFloat = 0
  private var innerViewLeadingPadding: CGFloat = 0
  private var dividerViewTopMargin: CGFloat = 0
  private var dividerViewTrailingMargin: CGFloat = 0
  private var dividerViewBottomMargin: CGFloat = 0
  private var dividerViewLeadingMargin: CGFloat = 0
  private var tabIconLayersViewTopMargin: CGFloat = 0
  private var tabIconLayersViewTrailingMargin: CGFloat = 0
  private var tabIconLayersViewBottomMargin: CGFloat = 0
  private var tabIconLayersViewLeadingMargin: CGFloat = 0
  private var tabIconDocumentationViewTopMargin: CGFloat = 0
  private var tabIconDocumentationViewTrailingMargin: CGFloat = 0
  private var tabIconDocumentationViewBottomMargin: CGFloat = 0
  private var tabIconDocumentationViewLeadingMargin: CGFloat = 0

  private var innerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var innerViewTopAnchorConstraint: NSLayoutConstraint?
  private var innerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var dividerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewTopAnchorConstraint: NSLayoutConstraint?
  private var dividerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var tabIconLayersViewTopAnchorConstraint: NSLayoutConstraint?
  private var tabIconLayersViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var tabIconDocumentationViewTopAnchorConstraint: NSLayoutConstraint?
  private var tabIconDocumentationViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewWidthAnchorConstraint: NSLayoutConstraint?
  private var tabIconLayersViewHeightAnchorConstraint: NSLayoutConstraint?
  private var tabIconLayersViewWidthAnchorConstraint: NSLayoutConstraint?
  private var tabIconDocumentationViewHeightAnchorConstraint: NSLayoutConstraint?
  private var tabIconDocumentationViewWidthAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .noBorder
    innerView.contentViewMargins = .zero
    dividerView.boxType = .custom
    dividerView.borderType = .noBorder
    dividerView.contentViewMargins = .zero

    addSubview(innerView)
    addSubview(dividerView)
    innerView.addSubview(tabIconLayersView)
    innerView.addSubview(tabIconDocumentationView)

    tabIconLayersView.icon = #imageLiteral(resourceName: "icon-tab-layers")
    tabIconDocumentationView.icon = #imageLiteral(resourceName: "icon-tab-docs")
    dividerView.fillColor = Colors.grey300
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    tabIconLayersView.translatesAutoresizingMaskIntoConstraints = false
    tabIconDocumentationView.translatesAutoresizingMaskIntoConstraints = false

    let innerViewLeadingAnchorConstraint = innerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + innerViewLeadingMargin)
    let innerViewTopAnchorConstraint = innerView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + innerViewTopMargin)
    let innerViewBottomAnchorConstraint = innerView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + innerViewBottomMargin))
    let dividerViewTrailingAnchorConstraint = dividerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + dividerViewTrailingMargin))
    let dividerViewLeadingAnchorConstraint = dividerView
      .leadingAnchor
      .constraint(equalTo: innerView.trailingAnchor, constant: innerViewTrailingMargin + dividerViewLeadingMargin)
    let dividerViewTopAnchorConstraint = dividerView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + dividerViewTopMargin)
    let dividerViewBottomAnchorConstraint = dividerView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + dividerViewBottomMargin))
    let tabIconLayersViewTopAnchorConstraint = tabIconLayersView
      .topAnchor
      .constraint(equalTo: innerView.topAnchor, constant: innerViewTopPadding + tabIconLayersViewTopMargin)
    let tabIconLayersViewLeadingAnchorConstraint = tabIconLayersView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: innerViewLeadingPadding + tabIconLayersViewLeadingMargin)
    let tabIconDocumentationViewTopAnchorConstraint = tabIconDocumentationView
      .topAnchor
      .constraint(
        equalTo: tabIconLayersView.bottomAnchor,
        constant: tabIconLayersViewBottomMargin + tabIconDocumentationViewTopMargin)
    let tabIconDocumentationViewLeadingAnchorConstraint = tabIconDocumentationView
      .leadingAnchor
      .constraint(
        equalTo: innerView.leadingAnchor,
        constant: innerViewLeadingPadding + tabIconDocumentationViewLeadingMargin)
    let dividerViewWidthAnchorConstraint = dividerView.widthAnchor.constraint(equalToConstant: 1)
    let tabIconLayersViewHeightAnchorConstraint = tabIconLayersView.heightAnchor.constraint(equalToConstant: 60)
    let tabIconLayersViewWidthAnchorConstraint = tabIconLayersView.widthAnchor.constraint(equalToConstant: 60)
    let tabIconDocumentationViewHeightAnchorConstraint = tabIconDocumentationView
      .heightAnchor
      .constraint(equalToConstant: 60)
    let tabIconDocumentationViewWidthAnchorConstraint = tabIconDocumentationView
      .widthAnchor
      .constraint(equalToConstant: 60)

    NSLayoutConstraint.activate([
      innerViewLeadingAnchorConstraint,
      innerViewTopAnchorConstraint,
      innerViewBottomAnchorConstraint,
      dividerViewTrailingAnchorConstraint,
      dividerViewLeadingAnchorConstraint,
      dividerViewTopAnchorConstraint,
      dividerViewBottomAnchorConstraint,
      tabIconLayersViewTopAnchorConstraint,
      tabIconLayersViewLeadingAnchorConstraint,
      tabIconDocumentationViewTopAnchorConstraint,
      tabIconDocumentationViewLeadingAnchorConstraint,
      dividerViewWidthAnchorConstraint,
      tabIconLayersViewHeightAnchorConstraint,
      tabIconLayersViewWidthAnchorConstraint,
      tabIconDocumentationViewHeightAnchorConstraint,
      tabIconDocumentationViewWidthAnchorConstraint
    ])

    self.innerViewLeadingAnchorConstraint = innerViewLeadingAnchorConstraint
    self.innerViewTopAnchorConstraint = innerViewTopAnchorConstraint
    self.innerViewBottomAnchorConstraint = innerViewBottomAnchorConstraint
    self.dividerViewTrailingAnchorConstraint = dividerViewTrailingAnchorConstraint
    self.dividerViewLeadingAnchorConstraint = dividerViewLeadingAnchorConstraint
    self.dividerViewTopAnchorConstraint = dividerViewTopAnchorConstraint
    self.dividerViewBottomAnchorConstraint = dividerViewBottomAnchorConstraint
    self.tabIconLayersViewTopAnchorConstraint = tabIconLayersViewTopAnchorConstraint
    self.tabIconLayersViewLeadingAnchorConstraint = tabIconLayersViewLeadingAnchorConstraint
    self.tabIconDocumentationViewTopAnchorConstraint = tabIconDocumentationViewTopAnchorConstraint
    self.tabIconDocumentationViewLeadingAnchorConstraint = tabIconDocumentationViewLeadingAnchorConstraint
    self.dividerViewWidthAnchorConstraint = dividerViewWidthAnchorConstraint
    self.tabIconLayersViewHeightAnchorConstraint = tabIconLayersViewHeightAnchorConstraint
    self.tabIconLayersViewWidthAnchorConstraint = tabIconLayersViewWidthAnchorConstraint
    self.tabIconDocumentationViewHeightAnchorConstraint = tabIconDocumentationViewHeightAnchorConstraint
    self.tabIconDocumentationViewWidthAnchorConstraint = tabIconDocumentationViewWidthAnchorConstraint

    // For debugging
    innerViewLeadingAnchorConstraint.identifier = "innerViewLeadingAnchorConstraint"
    innerViewTopAnchorConstraint.identifier = "innerViewTopAnchorConstraint"
    innerViewBottomAnchorConstraint.identifier = "innerViewBottomAnchorConstraint"
    dividerViewTrailingAnchorConstraint.identifier = "dividerViewTrailingAnchorConstraint"
    dividerViewLeadingAnchorConstraint.identifier = "dividerViewLeadingAnchorConstraint"
    dividerViewTopAnchorConstraint.identifier = "dividerViewTopAnchorConstraint"
    dividerViewBottomAnchorConstraint.identifier = "dividerViewBottomAnchorConstraint"
    tabIconLayersViewTopAnchorConstraint.identifier = "tabIconLayersViewTopAnchorConstraint"
    tabIconLayersViewLeadingAnchorConstraint.identifier = "tabIconLayersViewLeadingAnchorConstraint"
    tabIconDocumentationViewTopAnchorConstraint.identifier = "tabIconDocumentationViewTopAnchorConstraint"
    tabIconDocumentationViewLeadingAnchorConstraint.identifier = "tabIconDocumentationViewLeadingAnchorConstraint"
    dividerViewWidthAnchorConstraint.identifier = "dividerViewWidthAnchorConstraint"
    tabIconLayersViewHeightAnchorConstraint.identifier = "tabIconLayersViewHeightAnchorConstraint"
    tabIconLayersViewWidthAnchorConstraint.identifier = "tabIconLayersViewWidthAnchorConstraint"
    tabIconDocumentationViewHeightAnchorConstraint.identifier = "tabIconDocumentationViewHeightAnchorConstraint"
    tabIconDocumentationViewWidthAnchorConstraint.identifier = "tabIconDocumentationViewWidthAnchorConstraint"
  }

  private func update() {
    tabIconDocumentationView.selected = false
    tabIconLayersView.selected = false
    tabIconLayersView.onClick = onClickLayers
    tabIconDocumentationView.onClick = onClickDocumentation
    if selectedValue == "layers" {
      tabIconLayersView.selected = true
    }
    if selectedValue == "documentation" {
      tabIconDocumentationView.selected = true
    }
  }
}
