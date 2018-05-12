import AppKit
import Foundation

// MARK: - RecentProjectItem

public class RecentProjectItem: NSBox {

  // MARK: Lifecycle

  public init(projectName: String, projectDirectoryPath: String) {
    self.projectName = projectName
    self.projectDirectoryPath = projectDirectoryPath

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(projectName: "", projectDirectoryPath: "")
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var projectName: String { didSet { update() } }
  public var projectDirectoryPath: String { didSet { update() } }

  // MARK: Private

  private var projectNameView = NSTextField(labelWithString: "")
  private var projectDirectoryPathView = NSTextField(labelWithString: "")

  private var projectNameViewTextStyle = TextStyles.large
  private var projectDirectoryPathViewTextStyle = TextStyles.regular

  private var topPadding: CGFloat = 10
  private var trailingPadding: CGFloat = 12
  private var bottomPadding: CGFloat = 10
  private var leadingPadding: CGFloat = 12
  private var projectNameViewTopMargin: CGFloat = 0
  private var projectNameViewTrailingMargin: CGFloat = 0
  private var projectNameViewBottomMargin: CGFloat = 0
  private var projectNameViewLeadingMargin: CGFloat = 0
  private var projectDirectoryPathViewTopMargin: CGFloat = 2
  private var projectDirectoryPathViewTrailingMargin: CGFloat = 0
  private var projectDirectoryPathViewBottomMargin: CGFloat = 0
  private var projectDirectoryPathViewLeadingMargin: CGFloat = 0

  private var heightAnchorConstraint: NSLayoutConstraint?
  private var projectNameViewTopAnchorConstraint: NSLayoutConstraint?
  private var projectNameViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var projectNameViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var projectDirectoryPathViewTopAnchorConstraint: NSLayoutConstraint?
  private var projectDirectoryPathViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var projectDirectoryPathViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    projectNameView.lineBreakMode = .byWordWrapping
    projectDirectoryPathView.lineBreakMode = .byWordWrapping

    addSubview(projectNameView)
    addSubview(projectDirectoryPathView)

    projectNameViewTextStyle = TextStyles.large
    projectNameView.maximumNumberOfLines = 1
    projectDirectoryPathView.maximumNumberOfLines = 1
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    projectNameView.translatesAutoresizingMaskIntoConstraints = false
    projectDirectoryPathView.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 58)
    let projectNameViewTopAnchorConstraint = projectNameView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + projectNameViewTopMargin)
    let projectNameViewLeadingAnchorConstraint = projectNameView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + projectNameViewLeadingMargin)
    let projectNameViewTrailingAnchorConstraint = projectNameView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + projectNameViewTrailingMargin))
    let projectDirectoryPathViewTopAnchorConstraint = projectDirectoryPathView
      .topAnchor
      .constraint(
        equalTo: projectNameView.bottomAnchor,
        constant: projectNameViewBottomMargin + projectDirectoryPathViewTopMargin)
    let projectDirectoryPathViewLeadingAnchorConstraint = projectDirectoryPathView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + projectDirectoryPathViewLeadingMargin)
    let projectDirectoryPathViewTrailingAnchorConstraint = projectDirectoryPathView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + projectDirectoryPathViewTrailingMargin))

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      projectNameViewTopAnchorConstraint,
      projectNameViewLeadingAnchorConstraint,
      projectNameViewTrailingAnchorConstraint,
      projectDirectoryPathViewTopAnchorConstraint,
      projectDirectoryPathViewLeadingAnchorConstraint,
      projectDirectoryPathViewTrailingAnchorConstraint
    ])

    self.heightAnchorConstraint = heightAnchorConstraint
    self.projectNameViewTopAnchorConstraint = projectNameViewTopAnchorConstraint
    self.projectNameViewLeadingAnchorConstraint = projectNameViewLeadingAnchorConstraint
    self.projectNameViewTrailingAnchorConstraint = projectNameViewTrailingAnchorConstraint
    self.projectDirectoryPathViewTopAnchorConstraint = projectDirectoryPathViewTopAnchorConstraint
    self.projectDirectoryPathViewLeadingAnchorConstraint = projectDirectoryPathViewLeadingAnchorConstraint
    self.projectDirectoryPathViewTrailingAnchorConstraint = projectDirectoryPathViewTrailingAnchorConstraint

    // For debugging
    heightAnchorConstraint.identifier = "heightAnchorConstraint"
    projectNameViewTopAnchorConstraint.identifier = "projectNameViewTopAnchorConstraint"
    projectNameViewLeadingAnchorConstraint.identifier = "projectNameViewLeadingAnchorConstraint"
    projectNameViewTrailingAnchorConstraint.identifier = "projectNameViewTrailingAnchorConstraint"
    projectDirectoryPathViewTopAnchorConstraint.identifier = "projectDirectoryPathViewTopAnchorConstraint"
    projectDirectoryPathViewLeadingAnchorConstraint.identifier = "projectDirectoryPathViewLeadingAnchorConstraint"
    projectDirectoryPathViewTrailingAnchorConstraint.identifier = "projectDirectoryPathViewTrailingAnchorConstraint"
  }

  private func update() {
    projectNameView.attributedStringValue = projectNameViewTextStyle.apply(to: projectName)
    projectDirectoryPathView.attributedStringValue = projectDirectoryPathViewTextStyle.apply(to: projectDirectoryPath)
  }
}
