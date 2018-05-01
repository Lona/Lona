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

  private var tabIconLayersView = TabIcon()
  private var tabIconDocumentationView = TabIcon()

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var tabIconLayersViewTopMargin: CGFloat = 0
  private var tabIconLayersViewTrailingMargin: CGFloat = 0
  private var tabIconLayersViewBottomMargin: CGFloat = 0
  private var tabIconLayersViewLeadingMargin: CGFloat = 0
  private var tabIconDocumentationViewTopMargin: CGFloat = 0
  private var tabIconDocumentationViewTrailingMargin: CGFloat = 0
  private var tabIconDocumentationViewBottomMargin: CGFloat = 0
  private var tabIconDocumentationViewLeadingMargin: CGFloat = 0

  private var tabIconLayersViewTopAnchorConstraint: NSLayoutConstraint?
  private var tabIconLayersViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var tabIconDocumentationViewBottomAnchorConstraint: NSLayoutConstraint?
  private var tabIconDocumentationViewTopAnchorConstraint: NSLayoutConstraint?
  private var tabIconDocumentationViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var tabIconLayersViewHeightAnchorConstraint: NSLayoutConstraint?
  private var tabIconLayersViewWidthAnchorConstraint: NSLayoutConstraint?
  private var tabIconDocumentationViewHeightAnchorConstraint: NSLayoutConstraint?
  private var tabIconDocumentationViewWidthAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero

    addSubview(tabIconLayersView)
    addSubview(tabIconDocumentationView)

    tabIconLayersView.icon = #imageLiteral(resourceName: "icon-tab-layers")
    tabIconDocumentationView.icon = #imageLiteral(resourceName: "icon-tab-docs")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    tabIconLayersView.translatesAutoresizingMaskIntoConstraints = false
    tabIconDocumentationView.translatesAutoresizingMaskIntoConstraints = false

    let tabIconLayersViewTopAnchorConstraint = tabIconLayersView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + tabIconLayersViewTopMargin)
    let tabIconLayersViewLeadingAnchorConstraint = tabIconLayersView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + tabIconLayersViewLeadingMargin)
    let tabIconDocumentationViewBottomAnchorConstraint = tabIconDocumentationView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + tabIconDocumentationViewBottomMargin))
    let tabIconDocumentationViewTopAnchorConstraint = tabIconDocumentationView
      .topAnchor
      .constraint(
        equalTo: tabIconLayersView.bottomAnchor,
        constant: tabIconLayersViewBottomMargin + tabIconDocumentationViewTopMargin)
    let tabIconDocumentationViewLeadingAnchorConstraint = tabIconDocumentationView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + tabIconDocumentationViewLeadingMargin)
    let tabIconLayersViewHeightAnchorConstraint = tabIconLayersView.heightAnchor.constraint(equalToConstant: 60)
    let tabIconLayersViewWidthAnchorConstraint = tabIconLayersView.widthAnchor.constraint(equalToConstant: 60)
    let tabIconDocumentationViewHeightAnchorConstraint = tabIconDocumentationView
      .heightAnchor
      .constraint(equalToConstant: 60)
    let tabIconDocumentationViewWidthAnchorConstraint = tabIconDocumentationView
      .widthAnchor
      .constraint(equalToConstant: 60)

    NSLayoutConstraint.activate([
      tabIconLayersViewTopAnchorConstraint,
      tabIconLayersViewLeadingAnchorConstraint,
      tabIconDocumentationViewBottomAnchorConstraint,
      tabIconDocumentationViewTopAnchorConstraint,
      tabIconDocumentationViewLeadingAnchorConstraint,
      tabIconLayersViewHeightAnchorConstraint,
      tabIconLayersViewWidthAnchorConstraint,
      tabIconDocumentationViewHeightAnchorConstraint,
      tabIconDocumentationViewWidthAnchorConstraint
    ])

    self.tabIconLayersViewTopAnchorConstraint = tabIconLayersViewTopAnchorConstraint
    self.tabIconLayersViewLeadingAnchorConstraint = tabIconLayersViewLeadingAnchorConstraint
    self.tabIconDocumentationViewBottomAnchorConstraint = tabIconDocumentationViewBottomAnchorConstraint
    self.tabIconDocumentationViewTopAnchorConstraint = tabIconDocumentationViewTopAnchorConstraint
    self.tabIconDocumentationViewLeadingAnchorConstraint = tabIconDocumentationViewLeadingAnchorConstraint
    self.tabIconLayersViewHeightAnchorConstraint = tabIconLayersViewHeightAnchorConstraint
    self.tabIconLayersViewWidthAnchorConstraint = tabIconLayersViewWidthAnchorConstraint
    self.tabIconDocumentationViewHeightAnchorConstraint = tabIconDocumentationViewHeightAnchorConstraint
    self.tabIconDocumentationViewWidthAnchorConstraint = tabIconDocumentationViewWidthAnchorConstraint

    // For debugging
    tabIconLayersViewTopAnchorConstraint.identifier = "tabIconLayersViewTopAnchorConstraint"
    tabIconLayersViewLeadingAnchorConstraint.identifier = "tabIconLayersViewLeadingAnchorConstraint"
    tabIconDocumentationViewBottomAnchorConstraint.identifier = "tabIconDocumentationViewBottomAnchorConstraint"
    tabIconDocumentationViewTopAnchorConstraint.identifier = "tabIconDocumentationViewTopAnchorConstraint"
    tabIconDocumentationViewLeadingAnchorConstraint.identifier = "tabIconDocumentationViewLeadingAnchorConstraint"
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
