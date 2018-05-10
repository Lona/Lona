import AppKit
import Foundation

// MARK: - ComponentPreview

public class ComponentPreview: NSBox {

  // MARK: Lifecycle

  public init(componentName: String) {
    self.componentName = componentName

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(componentName: "")
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var componentName: String { didSet { update() } }

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
  }

  private func update() {}
}
