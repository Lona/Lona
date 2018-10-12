import ColorPicker

// LONA: KEEP ABOVE

import AppKit
import Foundation

// MARK: - CoreColorPicker

public class CoreColorPicker: NSBox {

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

  private var colorPickerView = ColorPicker()

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero

    addSubview(colorPickerView)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    colorPickerView.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 240)
    let colorPickerViewTopAnchorConstraint = colorPickerView.topAnchor.constraint(equalTo: topAnchor)
    let colorPickerViewBottomAnchorConstraint = colorPickerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let colorPickerViewLeadingAnchorConstraint = colorPickerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let colorPickerViewTrailingAnchorConstraint = colorPickerView.trailingAnchor.constraint(equalTo: trailingAnchor)

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      colorPickerViewTopAnchorConstraint,
      colorPickerViewBottomAnchorConstraint,
      colorPickerViewLeadingAnchorConstraint,
      colorPickerViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    colorPickerView.colorValue = colorValue
    colorPickerView.onChangeColorValue = onChangeColorValue
  }
}

// LONA: KEEP BELOW

extension CoreColorPicker {
    convenience init(<#parameters#>) {
        <#statements#>
    }
}
