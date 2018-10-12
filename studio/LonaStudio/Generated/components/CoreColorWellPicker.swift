import AppKit
import Foundation

// MARK: - CoreColorWellPicker

public class CoreColorWellPicker: NSBox {

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

  private var colorWellPickerView = ColorWellPicker()

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero

    addSubview(colorWellPickerView)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    colorWellPickerView.translatesAutoresizingMaskIntoConstraints = false

    let heightAnchorConstraint = heightAnchor.constraint(equalToConstant: 22)
    let widthAnchorConstraint = widthAnchor.constraint(equalToConstant: 34)
    let colorWellPickerViewTopAnchorConstraint = colorWellPickerView.topAnchor.constraint(equalTo: topAnchor)
    let colorWellPickerViewBottomAnchorConstraint = colorWellPickerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let colorWellPickerViewLeadingAnchorConstraint = colorWellPickerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let colorWellPickerViewTrailingAnchorConstraint = colorWellPickerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      widthAnchorConstraint,
      colorWellPickerViewTopAnchorConstraint,
      colorWellPickerViewBottomAnchorConstraint,
      colorWellPickerViewLeadingAnchorConstraint,
      colorWellPickerViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    colorWellPickerView.colorValue = colorValue
    colorWellPickerView.onChangeColorValue = onChangeColorValue
  }
}
