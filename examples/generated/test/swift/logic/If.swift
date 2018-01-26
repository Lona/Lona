import UIKit
import Foundation

// MARK: - If

public class If: UIView {

  // MARK: Lifecycle

  public init(enabled: Bool) {
    self.enabled = enabled

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var enabled: Bool { didSet { update() } }

  // MARK: Private

  private func setUpViews() {}

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false


    NSLayoutConstraint.activate([])


    // For debugging
  }

  private func update() {
    var _backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    if enabled {
      _backgroundColor = Colors.red500
    }
    backgroundColor = _backgroundColor
  }
}
