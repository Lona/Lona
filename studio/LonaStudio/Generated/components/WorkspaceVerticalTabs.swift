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

    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor)
    let innerViewBottomAnchorConstraint = innerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let dividerViewTrailingAnchorConstraint = dividerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let dividerViewLeadingAnchorConstraint = dividerView.leadingAnchor.constraint(equalTo: innerView.trailingAnchor)
    let dividerViewTopAnchorConstraint = dividerView.topAnchor.constraint(equalTo: topAnchor)
    let dividerViewBottomAnchorConstraint = dividerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let tabIconLayersViewTopAnchorConstraint = tabIconLayersView.topAnchor.constraint(equalTo: innerView.topAnchor)
    let tabIconLayersViewLeadingAnchorConstraint = tabIconLayersView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor)
    let tabIconDocumentationViewTopAnchorConstraint = tabIconDocumentationView
      .topAnchor
      .constraint(equalTo: tabIconLayersView.bottomAnchor)
    let tabIconDocumentationViewLeadingAnchorConstraint = tabIconDocumentationView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor)
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
