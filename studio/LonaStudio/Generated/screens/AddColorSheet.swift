import AppKit
import Foundation

// MARK: - AddColorSheet

public class AddColorSheet: NSBox {

  // MARK: Lifecycle

  public init(
    nameText: String,
    idText: String,
    valueText: String,
    descriptionText: String,
    colorValue: ColorPickerColor,
    onChangeNameText: StringHandler,
    onChangeIdText: StringHandler,
    onChangeValueText: StringHandler,
    onChangeDescriptionText: StringHandler,
    onChangeColorValue: ColorPickerHandler)
  {
    self.nameText = nameText
    self.idText = idText
    self.valueText = valueText
    self.descriptionText = descriptionText
    self.colorValue = colorValue
    self.onChangeNameText = onChangeNameText
    self.onChangeIdText = onChangeIdText
    self.onChangeValueText = onChangeValueText
    self.onChangeDescriptionText = onChangeDescriptionText
    self.onChangeColorValue = onChangeColorValue

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self
      .init(
        nameText: "",
        idText: "",
        valueText: "",
        descriptionText: "",
        colorValue: nil,
        onChangeNameText: nil,
        onChangeIdText: nil,
        onChangeValueText: nil,
        onChangeDescriptionText: nil,
        onChangeColorValue: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var onSubmit: (() -> Void)? { didSet { update() } }
  public var onCancel: (() -> Void)? { didSet { update() } }
  public var nameText: String { didSet { update() } }
  public var idText: String { didSet { update() } }
  public var valueText: String { didSet { update() } }
  public var descriptionText: String { didSet { update() } }
  public var colorValue: ColorPickerColor { didSet { update() } }
  public var onChangeNameText: StringHandler { didSet { update() } }
  public var onChangeIdText: StringHandler { didSet { update() } }
  public var onChangeValueText: StringHandler { didSet { update() } }
  public var onChangeDescriptionText: StringHandler { didSet { update() } }
  public var onChangeColorValue: ColorPickerHandler { didSet { update() } }

  // MARK: Private

  private var colorInspectorView = ColorInspector()
  private var footerView = NSBox()
  private var cancelButtonView = Button()
  private var footerSpacerView = NSBox()
  private var doneButtonView = Button()

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 20
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 20
  private var colorInspectorViewTopMargin: CGFloat = 0
  private var colorInspectorViewTrailingMargin: CGFloat = 0
  private var colorInspectorViewBottomMargin: CGFloat = 0
  private var colorInspectorViewLeadingMargin: CGFloat = 0
  private var footerViewTopMargin: CGFloat = 40
  private var footerViewTrailingMargin: CGFloat = 0
  private var footerViewBottomMargin: CGFloat = 20
  private var footerViewLeadingMargin: CGFloat = 0
  private var footerViewTopPadding: CGFloat = 0
  private var footerViewTrailingPadding: CGFloat = 0
  private var footerViewBottomPadding: CGFloat = 0
  private var footerViewLeadingPadding: CGFloat = 0
  private var cancelButtonViewTopMargin: CGFloat = 0
  private var cancelButtonViewTrailingMargin: CGFloat = 0
  private var cancelButtonViewBottomMargin: CGFloat = 0
  private var cancelButtonViewLeadingMargin: CGFloat = 0
  private var footerSpacerViewTopMargin: CGFloat = 0
  private var footerSpacerViewTrailingMargin: CGFloat = 0
  private var footerSpacerViewBottomMargin: CGFloat = 0
  private var footerSpacerViewLeadingMargin: CGFloat = 0
  private var doneButtonViewTopMargin: CGFloat = 0
  private var doneButtonViewTrailingMargin: CGFloat = 0
  private var doneButtonViewBottomMargin: CGFloat = 0
  private var doneButtonViewLeadingMargin: CGFloat = 0

  private var widthAnchorConstraint: NSLayoutConstraint?
  private var colorInspectorViewTopAnchorConstraint: NSLayoutConstraint?
  private var colorInspectorViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var colorInspectorViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var footerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var footerViewTopAnchorConstraint: NSLayoutConstraint?
  private var footerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var footerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var cancelButtonViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var footerSpacerViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var doneButtonViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var cancelButtonViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var cancelButtonViewTopAnchorConstraint: NSLayoutConstraint?
  private var cancelButtonViewBottomAnchorConstraint: NSLayoutConstraint?
  private var footerSpacerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var footerSpacerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var doneButtonViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var doneButtonViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var doneButtonViewTopAnchorConstraint: NSLayoutConstraint?
  private var doneButtonViewBottomAnchorConstraint: NSLayoutConstraint?
  private var footerSpacerViewHeightAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    footerView.boxType = .custom
    footerView.borderType = .noBorder
    footerView.contentViewMargins = .zero
    footerSpacerView.boxType = .custom
    footerSpacerView.borderType = .noBorder
    footerSpacerView.contentViewMargins = .zero

    addSubview(colorInspectorView)
    addSubview(footerView)
    footerView.addSubview(cancelButtonView)
    footerView.addSubview(footerSpacerView)
    footerView.addSubview(doneButtonView)

    colorInspectorView.titleText = "New Color"
    cancelButtonView.titleText = "Cancel"
    footerSpacerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    doneButtonView.titleText = "Done"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    colorInspectorView.translatesAutoresizingMaskIntoConstraints = false
    footerView.translatesAutoresizingMaskIntoConstraints = false
    cancelButtonView.translatesAutoresizingMaskIntoConstraints = false
    footerSpacerView.translatesAutoresizingMaskIntoConstraints = false
    doneButtonView.translatesAutoresizingMaskIntoConstraints = false

    let widthAnchorConstraint = widthAnchor.constraint(equalToConstant: 480)
    let colorInspectorViewTopAnchorConstraint = colorInspectorView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + colorInspectorViewTopMargin)
    let colorInspectorViewLeadingAnchorConstraint = colorInspectorView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + colorInspectorViewLeadingMargin)
    let colorInspectorViewTrailingAnchorConstraint = colorInspectorView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + colorInspectorViewTrailingMargin))
    let footerViewBottomAnchorConstraint = footerView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + footerViewBottomMargin))
    let footerViewTopAnchorConstraint = footerView
      .topAnchor
      .constraint(
        equalTo: colorInspectorView.bottomAnchor,
        constant: colorInspectorViewBottomMargin + footerViewTopMargin)
    let footerViewLeadingAnchorConstraint = footerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + footerViewLeadingMargin)
    let footerViewTrailingAnchorConstraint = footerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + footerViewTrailingMargin))
    let cancelButtonViewHeightAnchorParentConstraint = cancelButtonView
      .heightAnchor
      .constraint(
        lessThanOrEqualTo: footerView.heightAnchor,
        constant:
        -(footerViewTopPadding + cancelButtonViewTopMargin + footerViewBottomPadding + cancelButtonViewBottomMargin))
    let footerSpacerViewHeightAnchorParentConstraint = footerSpacerView
      .heightAnchor
      .constraint(
        lessThanOrEqualTo: footerView.heightAnchor,
        constant:
        -(footerViewTopPadding + footerSpacerViewTopMargin + footerViewBottomPadding + footerSpacerViewBottomMargin))
    let doneButtonViewHeightAnchorParentConstraint = doneButtonView
      .heightAnchor
      .constraint(
        lessThanOrEqualTo: footerView.heightAnchor,
        constant:
        -(footerViewTopPadding + doneButtonViewTopMargin + footerViewBottomPadding + doneButtonViewBottomMargin))
    let cancelButtonViewLeadingAnchorConstraint = cancelButtonView
      .leadingAnchor
      .constraint(equalTo: footerView.leadingAnchor, constant: footerViewLeadingPadding + cancelButtonViewLeadingMargin)
    let cancelButtonViewTopAnchorConstraint = cancelButtonView
      .topAnchor
      .constraint(equalTo: footerView.topAnchor, constant: footerViewTopPadding + cancelButtonViewTopMargin)
    let cancelButtonViewBottomAnchorConstraint = cancelButtonView
      .bottomAnchor
      .constraint(equalTo: footerView.bottomAnchor, constant: -(footerViewBottomPadding + cancelButtonViewBottomMargin))
    let footerSpacerViewLeadingAnchorConstraint = footerSpacerView
      .leadingAnchor
      .constraint(
        equalTo: cancelButtonView.trailingAnchor,
        constant: cancelButtonViewTrailingMargin + footerSpacerViewLeadingMargin)
    let footerSpacerViewBottomAnchorConstraint = footerSpacerView
      .bottomAnchor
      .constraint(equalTo: footerView.bottomAnchor, constant: -(footerViewBottomPadding + footerSpacerViewBottomMargin))
    let doneButtonViewTrailingAnchorConstraint = doneButtonView
      .trailingAnchor
      .constraint(
        equalTo: footerView.trailingAnchor,
        constant: -(footerViewTrailingPadding + doneButtonViewTrailingMargin))
    let doneButtonViewLeadingAnchorConstraint = doneButtonView
      .leadingAnchor
      .constraint(
        equalTo: footerSpacerView.trailingAnchor,
        constant: footerSpacerViewTrailingMargin + doneButtonViewLeadingMargin)
    let doneButtonViewTopAnchorConstraint = doneButtonView
      .topAnchor
      .constraint(equalTo: footerView.topAnchor, constant: footerViewTopPadding + doneButtonViewTopMargin)
    let doneButtonViewBottomAnchorConstraint = doneButtonView
      .bottomAnchor
      .constraint(equalTo: footerView.bottomAnchor, constant: -(footerViewBottomPadding + doneButtonViewBottomMargin))
    let footerSpacerViewHeightAnchorConstraint = footerSpacerView.heightAnchor.constraint(equalToConstant: 0)

    cancelButtonViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    footerSpacerViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    doneButtonViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      widthAnchorConstraint,
      colorInspectorViewTopAnchorConstraint,
      colorInspectorViewLeadingAnchorConstraint,
      colorInspectorViewTrailingAnchorConstraint,
      footerViewBottomAnchorConstraint,
      footerViewTopAnchorConstraint,
      footerViewLeadingAnchorConstraint,
      footerViewTrailingAnchorConstraint,
      cancelButtonViewHeightAnchorParentConstraint,
      footerSpacerViewHeightAnchorParentConstraint,
      doneButtonViewHeightAnchorParentConstraint,
      cancelButtonViewLeadingAnchorConstraint,
      cancelButtonViewTopAnchorConstraint,
      cancelButtonViewBottomAnchorConstraint,
      footerSpacerViewLeadingAnchorConstraint,
      footerSpacerViewBottomAnchorConstraint,
      doneButtonViewTrailingAnchorConstraint,
      doneButtonViewLeadingAnchorConstraint,
      doneButtonViewTopAnchorConstraint,
      doneButtonViewBottomAnchorConstraint,
      footerSpacerViewHeightAnchorConstraint
    ])

    self.widthAnchorConstraint = widthAnchorConstraint
    self.colorInspectorViewTopAnchorConstraint = colorInspectorViewTopAnchorConstraint
    self.colorInspectorViewLeadingAnchorConstraint = colorInspectorViewLeadingAnchorConstraint
    self.colorInspectorViewTrailingAnchorConstraint = colorInspectorViewTrailingAnchorConstraint
    self.footerViewBottomAnchorConstraint = footerViewBottomAnchorConstraint
    self.footerViewTopAnchorConstraint = footerViewTopAnchorConstraint
    self.footerViewLeadingAnchorConstraint = footerViewLeadingAnchorConstraint
    self.footerViewTrailingAnchorConstraint = footerViewTrailingAnchorConstraint
    self.cancelButtonViewHeightAnchorParentConstraint = cancelButtonViewHeightAnchorParentConstraint
    self.footerSpacerViewHeightAnchorParentConstraint = footerSpacerViewHeightAnchorParentConstraint
    self.doneButtonViewHeightAnchorParentConstraint = doneButtonViewHeightAnchorParentConstraint
    self.cancelButtonViewLeadingAnchorConstraint = cancelButtonViewLeadingAnchorConstraint
    self.cancelButtonViewTopAnchorConstraint = cancelButtonViewTopAnchorConstraint
    self.cancelButtonViewBottomAnchorConstraint = cancelButtonViewBottomAnchorConstraint
    self.footerSpacerViewLeadingAnchorConstraint = footerSpacerViewLeadingAnchorConstraint
    self.footerSpacerViewBottomAnchorConstraint = footerSpacerViewBottomAnchorConstraint
    self.doneButtonViewTrailingAnchorConstraint = doneButtonViewTrailingAnchorConstraint
    self.doneButtonViewLeadingAnchorConstraint = doneButtonViewLeadingAnchorConstraint
    self.doneButtonViewTopAnchorConstraint = doneButtonViewTopAnchorConstraint
    self.doneButtonViewBottomAnchorConstraint = doneButtonViewBottomAnchorConstraint
    self.footerSpacerViewHeightAnchorConstraint = footerSpacerViewHeightAnchorConstraint

    // For debugging
    widthAnchorConstraint.identifier = "widthAnchorConstraint"
    colorInspectorViewTopAnchorConstraint.identifier = "colorInspectorViewTopAnchorConstraint"
    colorInspectorViewLeadingAnchorConstraint.identifier = "colorInspectorViewLeadingAnchorConstraint"
    colorInspectorViewTrailingAnchorConstraint.identifier = "colorInspectorViewTrailingAnchorConstraint"
    footerViewBottomAnchorConstraint.identifier = "footerViewBottomAnchorConstraint"
    footerViewTopAnchorConstraint.identifier = "footerViewTopAnchorConstraint"
    footerViewLeadingAnchorConstraint.identifier = "footerViewLeadingAnchorConstraint"
    footerViewTrailingAnchorConstraint.identifier = "footerViewTrailingAnchorConstraint"
    cancelButtonViewHeightAnchorParentConstraint.identifier = "cancelButtonViewHeightAnchorParentConstraint"
    footerSpacerViewHeightAnchorParentConstraint.identifier = "footerSpacerViewHeightAnchorParentConstraint"
    doneButtonViewHeightAnchorParentConstraint.identifier = "doneButtonViewHeightAnchorParentConstraint"
    cancelButtonViewLeadingAnchorConstraint.identifier = "cancelButtonViewLeadingAnchorConstraint"
    cancelButtonViewTopAnchorConstraint.identifier = "cancelButtonViewTopAnchorConstraint"
    cancelButtonViewBottomAnchorConstraint.identifier = "cancelButtonViewBottomAnchorConstraint"
    footerSpacerViewLeadingAnchorConstraint.identifier = "footerSpacerViewLeadingAnchorConstraint"
    footerSpacerViewBottomAnchorConstraint.identifier = "footerSpacerViewBottomAnchorConstraint"
    doneButtonViewTrailingAnchorConstraint.identifier = "doneButtonViewTrailingAnchorConstraint"
    doneButtonViewLeadingAnchorConstraint.identifier = "doneButtonViewLeadingAnchorConstraint"
    doneButtonViewTopAnchorConstraint.identifier = "doneButtonViewTopAnchorConstraint"
    doneButtonViewBottomAnchorConstraint.identifier = "doneButtonViewBottomAnchorConstraint"
    footerSpacerViewHeightAnchorConstraint.identifier = "footerSpacerViewHeightAnchorConstraint"
  }

  private func update() {
    doneButtonView.onClick = onSubmit
    cancelButtonView.onClick = onCancel
    colorInspectorView.idText = idText
    colorInspectorView.nameText = nameText
    colorInspectorView.valueText = valueText
    colorInspectorView.descriptionText = descriptionText
    colorInspectorView.colorValue = colorValue
    colorInspectorView.onChangeIdText = onChangeIdText
    colorInspectorView.onChangeNameText = onChangeNameText
    colorInspectorView.onChangeValueText = onChangeValueText
    colorInspectorView.onChangeDescriptionText = onChangeDescriptionText
    colorInspectorView.onChangeColorValue = onChangeColorValue
  }
}
