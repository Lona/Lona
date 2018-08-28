import AppKit
import Foundation

// MARK: - ColorPreviewCollection

public class ColorPreviewCollection: NSBox {

  // MARK: Lifecycle

  public init(onSelectColor: ColorHandler, onChangeColor: ColorHandler) {
    self.onSelectColor = onSelectColor
    self.onChangeColor = onChangeColor

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(onSelectColor: nil, onChangeColor: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var onSelectColor: ColorHandler { didSet { update() } }
  public var onChangeColor: ColorHandler { didSet { update() } }

  // MARK: Private

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero

    fillColor = Colors.pink50
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
  }

  private func update() {}
}
