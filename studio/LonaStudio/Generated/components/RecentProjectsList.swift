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

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero

    fillColor = Colors.pink50
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false


    NSLayoutConstraint.activate([])


    // For debugging
  }

  private func update() {}
}
