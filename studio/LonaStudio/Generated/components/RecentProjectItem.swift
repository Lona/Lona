import AppKit
import Foundation

// MARK: - RecentProjectItem

public class RecentProjectItem: NSBox {

  // MARK: Lifecycle

  public init(projectName: String, projectDirectoryPath: String, selected: Bool) {
    self.projectName = projectName
    self.projectDirectoryPath = projectDirectoryPath
    self.selected = selected

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(projectName: "", projectDirectoryPath: "", selected: false)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var projectName: String { didSet { update() } }
  public var projectDirectoryPath: String { didSet { update() } }
  public var selected: Bool { didSet { update() } }

  // MARK: Private

  private var projectNameView = NSTextField(labelWithString: "")
  private var projectDirectoryPathView = NSTextField(labelWithString: "")

  private var projectNameViewTextStyle = TextStyles.regular
  private var projectDirectoryPathViewTextStyle = TextStyles.regularMuted

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    projectNameView.lineBreakMode = .byWordWrapping
    projectDirectoryPathView.lineBreakMode = .byWordWrapping

    addSubview(projectNameView)
    addSubview(projectDirectoryPathView)

    projectNameView.maximumNumberOfLines = 1
    projectDirectoryPathView.maximumNumberOfLines = 1
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    projectNameView.translatesAutoresizingMaskIntoConstraints = false
    projectDirectoryPathView.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 54)
    let projectNameViewTopAnchorConstraint = projectNameView.topAnchor.constraint(equalTo: topAnchor, constant: 10)
    let projectNameViewLeadingAnchorConstraint = projectNameView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: 12)
    let projectNameViewTrailingAnchorConstraint = projectNameView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -12)
    let projectDirectoryPathViewTopAnchorConstraint = projectDirectoryPathView
      .topAnchor
      .constraint(equalTo: projectNameView.bottomAnchor, constant: 4)
    let projectDirectoryPathViewLeadingAnchorConstraint = projectDirectoryPathView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: 12)
    let projectDirectoryPathViewTrailingAnchorConstraint = projectDirectoryPathView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -12)

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      projectNameViewTopAnchorConstraint,
      projectNameViewLeadingAnchorConstraint,
      projectNameViewTrailingAnchorConstraint,
      projectDirectoryPathViewTopAnchorConstraint,
      projectDirectoryPathViewLeadingAnchorConstraint,
      projectDirectoryPathViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    projectDirectoryPathViewTextStyle = TextStyles.regularMuted
    projectDirectoryPathView.attributedStringValue =
      projectDirectoryPathViewTextStyle.apply(to: projectDirectoryPathView.attributedStringValue)
    projectNameViewTextStyle = TextStyles.regular
    projectNameView.attributedStringValue = projectNameViewTextStyle.apply(to: projectNameView.attributedStringValue)
    projectNameView.attributedStringValue = projectNameViewTextStyle.apply(to: projectName)
    projectDirectoryPathView.attributedStringValue = projectDirectoryPathViewTextStyle.apply(to: projectDirectoryPath)
    if selected {
      projectNameViewTextStyle = TextStyles.regularInverse
      projectNameView.attributedStringValue = projectNameViewTextStyle.apply(to: projectNameView.attributedStringValue)
      projectDirectoryPathViewTextStyle = TextStyles.regularInverse
      projectDirectoryPathView.attributedStringValue =
        projectDirectoryPathViewTextStyle.apply(to: projectDirectoryPathView.attributedStringValue)
    }
  }
}
