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
    let colorInspectorViewTopAnchorConstraint = colorInspectorView.topAnchor.constraint(equalTo: topAnchor)
    let colorInspectorViewLeadingAnchorConstraint = colorInspectorView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: 20)
    let colorInspectorViewTrailingAnchorConstraint = colorInspectorView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -20)
    let footerViewBottomAnchorConstraint = footerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
    let footerViewTopAnchorConstraint = footerView
      .topAnchor
      .constraint(equalTo: colorInspectorView.bottomAnchor, constant: 40)
    let footerViewLeadingAnchorConstraint = footerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20)
    let footerViewTrailingAnchorConstraint = footerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -20)
    let cancelButtonViewHeightAnchorParentConstraint = cancelButtonView
      .heightAnchor
      .constraint(lessThanOrEqualTo: footerView.heightAnchor)
    let footerSpacerViewHeightAnchorParentConstraint = footerSpacerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: footerView.heightAnchor)
    let doneButtonViewHeightAnchorParentConstraint = doneButtonView
      .heightAnchor
      .constraint(lessThanOrEqualTo: footerView.heightAnchor)
    let cancelButtonViewLeadingAnchorConstraint = cancelButtonView
      .leadingAnchor
      .constraint(equalTo: footerView.leadingAnchor)
    let cancelButtonViewTopAnchorConstraint = cancelButtonView.topAnchor.constraint(equalTo: footerView.topAnchor)
    let cancelButtonViewBottomAnchorConstraint = cancelButtonView
      .bottomAnchor
      .constraint(equalTo: footerView.bottomAnchor)
    let footerSpacerViewLeadingAnchorConstraint = footerSpacerView
      .leadingAnchor
      .constraint(equalTo: cancelButtonView.trailingAnchor)
    let footerSpacerViewBottomAnchorConstraint = footerSpacerView
      .bottomAnchor
      .constraint(equalTo: footerView.bottomAnchor)
    let doneButtonViewTrailingAnchorConstraint = doneButtonView
      .trailingAnchor
      .constraint(equalTo: footerView.trailingAnchor)
    let doneButtonViewLeadingAnchorConstraint = doneButtonView
      .leadingAnchor
      .constraint(equalTo: footerSpacerView.trailingAnchor)
    let doneButtonViewTopAnchorConstraint = doneButtonView.topAnchor.constraint(equalTo: footerView.topAnchor)
    let doneButtonViewBottomAnchorConstraint = doneButtonView.bottomAnchor.constraint(equalTo: footerView.bottomAnchor)
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
