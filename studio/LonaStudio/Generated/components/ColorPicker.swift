import AppKit
import Foundation

// MARK: - ColorPicker

public class ColorPicker: NSBox {

  // MARK: Lifecycle

  public init(colorValue: ColorPickerColor, onChangeColorValue: ColorPickerHandler) {
    self.colorValue = colorValue
    self.onChangeColorValue = onChangeColorValue

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(colorValue: nil, onChangeColorValue: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var colorValue: ColorPickerColor { didSet { update() } }
  public var onChangeColorValue: ColorPickerHandler { didSet { update() } }

  // MARK: Private

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero

    fillColor = Colors.red50
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
  }

  private func update() {}
}
