import AppKit
import Foundation

// MARK: - RecentProjectsList

public class RecentProjectsList: NSBox {

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

  // MARK: Private

  private var recentProjectItemView = RecentProjectItem()
  private var recentProjectItem2View = RecentProjectItem()

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero

    addSubview(recentProjectItemView)
    addSubview(recentProjectItem2View)

    recentProjectItemView.projectDirectoryPath = "~/Projects/ExampleWorkspace"
    recentProjectItemView.projectName = "ExampleWorkspace"
    recentProjectItemView.selected = false
    recentProjectItem2View.projectDirectoryPath = "~/Projects/TestWorkspace"
    recentProjectItem2View.projectName = "Test"
    recentProjectItem2View.selected = false
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    recentProjectItemView.translatesAutoresizingMaskIntoConstraints = false
    recentProjectItem2View.translatesAutoresizingMaskIntoConstraints = false

    let recentProjectItemViewTopAnchorConstraint = recentProjectItemView.topAnchor.constraint(equalTo: topAnchor)
    let recentProjectItemViewLeadingAnchorConstraint = recentProjectItemView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let recentProjectItemViewTrailingAnchorConstraint = recentProjectItemView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let recentProjectItem2ViewTopAnchorConstraint = recentProjectItem2View
      .topAnchor
      .constraint(equalTo: recentProjectItemView.bottomAnchor)
    let recentProjectItem2ViewLeadingAnchorConstraint = recentProjectItem2View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let recentProjectItem2ViewTrailingAnchorConstraint = recentProjectItem2View
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let recentProjectItemViewHeightAnchorConstraint = recentProjectItemView.heightAnchor.constraint(equalToConstant: 54)
    let recentProjectItem2ViewHeightAnchorConstraint = recentProjectItem2View
      .heightAnchor
      .constraint(equalToConstant: 54)

    NSLayoutConstraint.activate([
      recentProjectItemViewTopAnchorConstraint,
      recentProjectItemViewLeadingAnchorConstraint,
      recentProjectItemViewTrailingAnchorConstraint,
      recentProjectItem2ViewTopAnchorConstraint,
      recentProjectItem2ViewLeadingAnchorConstraint,
      recentProjectItem2ViewTrailingAnchorConstraint,
      recentProjectItemViewHeightAnchorConstraint,
      recentProjectItem2ViewHeightAnchorConstraint
    ])
  }

  private func update() {}
}
