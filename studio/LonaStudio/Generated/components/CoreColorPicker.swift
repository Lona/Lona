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

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var colorPickerViewTopMargin: CGFloat = 0
  private var colorPickerViewTrailingMargin: CGFloat = 0
  private var colorPickerViewBottomMargin: CGFloat = 0
  private var colorPickerViewLeadingMargin: CGFloat = 0

  private var heightAnchorConstraint: NSLayoutConstraint?
  private var colorPickerViewTopAnchorConstraint: NSLayoutConstraint?
  private var colorPickerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var colorPickerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var colorPickerViewTrailingAnchorConstraint: NSLayoutConstraint?

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
    let colorPickerViewTopAnchorConstraint = colorPickerView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + colorPickerViewTopMargin)
    let colorPickerViewBottomAnchorConstraint = colorPickerView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + colorPickerViewBottomMargin))
    let colorPickerViewLeadingAnchorConstraint = colorPickerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + colorPickerViewLeadingMargin)
    let colorPickerViewTrailingAnchorConstraint = colorPickerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + colorPickerViewTrailingMargin))

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      colorPickerViewTopAnchorConstraint,
      colorPickerViewBottomAnchorConstraint,
      colorPickerViewLeadingAnchorConstraint,
      colorPickerViewTrailingAnchorConstraint
    ])

    self.heightAnchorConstraint = heightAnchorConstraint
    self.colorPickerViewTopAnchorConstraint = colorPickerViewTopAnchorConstraint
    self.colorPickerViewBottomAnchorConstraint = colorPickerViewBottomAnchorConstraint
    self.colorPickerViewLeadingAnchorConstraint = colorPickerViewLeadingAnchorConstraint
    self.colorPickerViewTrailingAnchorConstraint = colorPickerViewTrailingAnchorConstraint

    // For debugging
    heightAnchorConstraint.identifier = "heightAnchorConstraint"
    colorPickerViewTopAnchorConstraint.identifier = "colorPickerViewTopAnchorConstraint"
    colorPickerViewBottomAnchorConstraint.identifier = "colorPickerViewBottomAnchorConstraint"
    colorPickerViewLeadingAnchorConstraint.identifier = "colorPickerViewLeadingAnchorConstraint"
    colorPickerViewTrailingAnchorConstraint.identifier = "colorPickerViewTrailingAnchorConstraint"
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
