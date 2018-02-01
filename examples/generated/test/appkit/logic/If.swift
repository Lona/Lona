import AppKit
import Foundation

// MARK: - If

public class If: NSBox {

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

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false


    NSLayoutConstraint.activate([])


    // For debugging
  }

  private func update() {
    var _fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    if enabled {
      _fillColor = Colors.red500
    }
    fillColor = _fillColor
  }
}
