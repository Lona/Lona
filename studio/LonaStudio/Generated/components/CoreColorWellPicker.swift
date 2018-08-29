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

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var colorWellPickerViewTopMargin: CGFloat = 0
  private var colorWellPickerViewTrailingMargin: CGFloat = 0
  private var colorWellPickerViewBottomMargin: CGFloat = 0
  private var colorWellPickerViewLeadingMargin: CGFloat = 0

  private var heightAnchorConstraint: NSLayoutConstraint?
  private var widthAnchorConstraint: NSLayoutConstraint?
  private var colorWellPickerViewTopAnchorConstraint: NSLayoutConstraint?
  private var colorWellPickerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var colorWellPickerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var colorWellPickerViewTrailingAnchorConstraint: NSLayoutConstraint?

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
    let colorWellPickerViewTopAnchorConstraint = colorWellPickerView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + colorWellPickerViewTopMargin)
    let colorWellPickerViewBottomAnchorConstraint = colorWellPickerView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + colorWellPickerViewBottomMargin))
    let colorWellPickerViewLeadingAnchorConstraint = colorWellPickerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + colorWellPickerViewLeadingMargin)
    let colorWellPickerViewTrailingAnchorConstraint = colorWellPickerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + colorWellPickerViewTrailingMargin))

    NSLayoutConstraint.activate([
      heightAnchorConstraint,
      widthAnchorConstraint,
      colorWellPickerViewTopAnchorConstraint,
      colorWellPickerViewBottomAnchorConstraint,
      colorWellPickerViewLeadingAnchorConstraint,
      colorWellPickerViewTrailingAnchorConstraint
    ])

    self.heightAnchorConstraint = heightAnchorConstraint
    self.widthAnchorConstraint = widthAnchorConstraint
    self.colorWellPickerViewTopAnchorConstraint = colorWellPickerViewTopAnchorConstraint
    self.colorWellPickerViewBottomAnchorConstraint = colorWellPickerViewBottomAnchorConstraint
    self.colorWellPickerViewLeadingAnchorConstraint = colorWellPickerViewLeadingAnchorConstraint
    self.colorWellPickerViewTrailingAnchorConstraint = colorWellPickerViewTrailingAnchorConstraint

    // For debugging
    heightAnchorConstraint.identifier = "heightAnchorConstraint"
    widthAnchorConstraint.identifier = "widthAnchorConstraint"
    colorWellPickerViewTopAnchorConstraint.identifier = "colorWellPickerViewTopAnchorConstraint"
    colorWellPickerViewBottomAnchorConstraint.identifier = "colorWellPickerViewBottomAnchorConstraint"
    colorWellPickerViewLeadingAnchorConstraint.identifier = "colorWellPickerViewLeadingAnchorConstraint"
    colorWellPickerViewTrailingAnchorConstraint.identifier = "colorWellPickerViewTrailingAnchorConstraint"
  }

  private func update() {
    colorWellPickerView.colorValue = colorValue
    colorWellPickerView.onChangeColorValue = onChangeColorValue
  }
}
