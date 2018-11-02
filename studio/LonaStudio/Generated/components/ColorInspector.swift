import AppKit
import Foundation

// MARK: - ColorInspector

public class ColorInspector: NSBox {

  // MARK: Lifecycle

  public init(
    titleText: String,
    idText: String,
    nameText: String,
    valueText: String,
    descriptionText: String,
    onChangeIdText: StringHandler,
    onChangeNameText: StringHandler,
    onChangeValueText: StringHandler,
    onChangeDescriptionText: StringHandler,
    colorValue: ColorPickerColor,
    onChangeColorValue: ColorPickerHandler)
  {
    self.titleText = titleText
    self.idText = idText
    self.nameText = nameText
    self.valueText = valueText
    self.descriptionText = descriptionText
    self.onChangeIdText = onChangeIdText
    self.onChangeNameText = onChangeNameText
    self.onChangeValueText = onChangeValueText
    self.onChangeDescriptionText = onChangeDescriptionText
    self.colorValue = colorValue
    self.onChangeColorValue = onChangeColorValue

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self
      .init(
        titleText: "",
        idText: "",
        nameText: "",
        valueText: "",
        descriptionText: "",
        onChangeIdText: nil,
        onChangeNameText: nil,
        onChangeValueText: nil,
        onChangeDescriptionText: nil,
        colorValue: nil,
        onChangeColorValue: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var titleText: String { didSet { update() } }
  public var idText: String { didSet { update() } }
  public var nameText: String { didSet { update() } }
  public var valueText: String { didSet { update() } }
  public var descriptionText: String { didSet { update() } }
  public var onChangeIdText: StringHandler { didSet { update() } }
  public var onChangeNameText: StringHandler { didSet { update() } }
  public var onChangeValueText: StringHandler { didSet { update() } }
  public var onChangeDescriptionText: StringHandler { didSet { update() } }
  public var colorValue: ColorPickerColor { didSet { update() } }
  public var onChangeColorValue: ColorPickerHandler { didSet { update() } }

  // MARK: Private

  private var titleView = LNATextField(labelWithString: "")
  private var nameLabelView = LNATextField(labelWithString: "")
  private var nameInputView = TextInput()
  private var spacer1View = NSBox()
  private var idLabelView = LNATextField(labelWithString: "")
  private var idInputView = CoreTextInput()
  private var spacer2View = NSBox()
  private var valueLabelView = LNATextField(labelWithString: "")
  private var fitWidthFixValueContainerView = NSBox()
  private var coreColorWellPickerView = CoreColorWellPicker()
  private var smallSpacer1View = NSBox()
  private var valueInputView = TextInput()
  private var spacer3View = NSBox()
  private var descriptionLabelView = LNATextField(labelWithString: "")
  private var descriptionInputView = TextInput()

  private var titleViewTextStyle = TextStyles.large
  private var nameLabelViewTextStyle = TextStyles.small
  private var idLabelViewTextStyle = TextStyles.small
  private var valueLabelViewTextStyle = TextStyles.small
  private var descriptionLabelViewTextStyle = TextStyles.small

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    nameLabelView.lineBreakMode = .byWordWrapping
    spacer1View.boxType = .custom
    spacer1View.borderType = .noBorder
    spacer1View.contentViewMargins = .zero
    idLabelView.lineBreakMode = .byWordWrapping
    spacer2View.boxType = .custom
    spacer2View.borderType = .noBorder
    spacer2View.contentViewMargins = .zero
    valueLabelView.lineBreakMode = .byWordWrapping
    fitWidthFixValueContainerView.boxType = .custom
    fitWidthFixValueContainerView.borderType = .noBorder
    fitWidthFixValueContainerView.contentViewMargins = .zero
    spacer3View.boxType = .custom
    spacer3View.borderType = .noBorder
    spacer3View.contentViewMargins = .zero
    descriptionLabelView.lineBreakMode = .byWordWrapping
    smallSpacer1View.boxType = .custom
    smallSpacer1View.borderType = .noBorder
    smallSpacer1View.contentViewMargins = .zero

    addSubview(titleView)
    addSubview(nameLabelView)
    addSubview(nameInputView)
    addSubview(spacer1View)
    addSubview(idLabelView)
    addSubview(idInputView)
    addSubview(spacer2View)
    addSubview(valueLabelView)
    addSubview(fitWidthFixValueContainerView)
    addSubview(spacer3View)
    addSubview(descriptionLabelView)
    addSubview(descriptionInputView)
    fitWidthFixValueContainerView.addSubview(coreColorWellPickerView)
    fitWidthFixValueContainerView.addSubview(smallSpacer1View)
    fitWidthFixValueContainerView.addSubview(valueInputView)

    titleViewTextStyle = TextStyles.large
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    nameLabelView.attributedStringValue = nameLabelViewTextStyle.apply(to: "NAME")
    nameLabelViewTextStyle = TextStyles.small
    nameLabelView.attributedStringValue = nameLabelViewTextStyle.apply(to: nameLabelView.attributedStringValue)
    spacer1View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    idLabelView.attributedStringValue = idLabelViewTextStyle.apply(to: "ID")
    idLabelViewTextStyle = TextStyles.small
    idLabelView.attributedStringValue = idLabelViewTextStyle.apply(to: idLabelView.attributedStringValue)
    spacer2View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    valueLabelView.attributedStringValue = valueLabelViewTextStyle.apply(to: "VALUE")
    valueLabelViewTextStyle = TextStyles.small
    valueLabelView.attributedStringValue = valueLabelViewTextStyle.apply(to: valueLabelView.attributedStringValue)
    spacer3View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    descriptionLabelView.attributedStringValue = descriptionLabelViewTextStyle.apply(to: "DESCRIPTION")
    descriptionLabelViewTextStyle = TextStyles.small
    descriptionLabelView.attributedStringValue =
      descriptionLabelViewTextStyle.apply(to: descriptionLabelView.attributedStringValue)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    nameLabelView.translatesAutoresizingMaskIntoConstraints = false
    nameInputView.translatesAutoresizingMaskIntoConstraints = false
    spacer1View.translatesAutoresizingMaskIntoConstraints = false
    idLabelView.translatesAutoresizingMaskIntoConstraints = false
    idInputView.translatesAutoresizingMaskIntoConstraints = false
    spacer2View.translatesAutoresizingMaskIntoConstraints = false
    valueLabelView.translatesAutoresizingMaskIntoConstraints = false
    fitWidthFixValueContainerView.translatesAutoresizingMaskIntoConstraints = false
    spacer3View.translatesAutoresizingMaskIntoConstraints = false
    descriptionLabelView.translatesAutoresizingMaskIntoConstraints = false
    descriptionInputView.translatesAutoresizingMaskIntoConstraints = false
    coreColorWellPickerView.translatesAutoresizingMaskIntoConstraints = false
    smallSpacer1View.translatesAutoresizingMaskIntoConstraints = false
    valueInputView.translatesAutoresizingMaskIntoConstraints = false

    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: topAnchor, constant: 20)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let titleViewTrailingAnchorConstraint = titleView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
    let nameLabelViewTopAnchorConstraint = nameLabelView
      .topAnchor
      .constraint(equalTo: titleView.bottomAnchor, constant: 20)
    let nameLabelViewLeadingAnchorConstraint = nameLabelView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let nameLabelViewTrailingAnchorConstraint = nameLabelView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let nameInputViewTopAnchorConstraint = nameInputView
      .topAnchor
      .constraint(equalTo: nameLabelView.bottomAnchor, constant: 4)
    let nameInputViewLeadingAnchorConstraint = nameInputView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let nameInputViewTrailingAnchorConstraint = nameInputView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let spacer1ViewTopAnchorConstraint = spacer1View.topAnchor.constraint(equalTo: nameInputView.bottomAnchor)
    let spacer1ViewLeadingAnchorConstraint = spacer1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let idLabelViewTopAnchorConstraint = idLabelView.topAnchor.constraint(equalTo: spacer1View.bottomAnchor)
    let idLabelViewLeadingAnchorConstraint = idLabelView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let idLabelViewTrailingAnchorConstraint = idLabelView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let idInputViewTopAnchorConstraint = idInputView
      .topAnchor
      .constraint(equalTo: idLabelView.bottomAnchor, constant: 4)
    let idInputViewLeadingAnchorConstraint = idInputView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let idInputViewTrailingAnchorConstraint = idInputView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let spacer2ViewTopAnchorConstraint = spacer2View.topAnchor.constraint(equalTo: idInputView.bottomAnchor)
    let spacer2ViewLeadingAnchorConstraint = spacer2View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let valueLabelViewTopAnchorConstraint = valueLabelView.topAnchor.constraint(equalTo: spacer2View.bottomAnchor)
    let valueLabelViewLeadingAnchorConstraint = valueLabelView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let valueLabelViewTrailingAnchorConstraint = valueLabelView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let fitWidthFixValueContainerViewTopAnchorConstraint = fitWidthFixValueContainerView
      .topAnchor
      .constraint(equalTo: valueLabelView.bottomAnchor, constant: 4)
    let fitWidthFixValueContainerViewLeadingAnchorConstraint = fitWidthFixValueContainerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let fitWidthFixValueContainerViewTrailingAnchorConstraint = fitWidthFixValueContainerView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor)
    let spacer3ViewTopAnchorConstraint = spacer3View
      .topAnchor
      .constraint(equalTo: fitWidthFixValueContainerView.bottomAnchor)
    let spacer3ViewLeadingAnchorConstraint = spacer3View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let descriptionLabelViewTopAnchorConstraint = descriptionLabelView
      .topAnchor
      .constraint(equalTo: spacer3View.bottomAnchor)
    let descriptionLabelViewLeadingAnchorConstraint = descriptionLabelView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let descriptionLabelViewTrailingAnchorConstraint = descriptionLabelView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let descriptionInputViewBottomAnchorConstraint = descriptionInputView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let descriptionInputViewTopAnchorConstraint = descriptionInputView
      .topAnchor
      .constraint(equalTo: descriptionLabelView.bottomAnchor, constant: 4)
    let descriptionInputViewLeadingAnchorConstraint = descriptionInputView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let descriptionInputViewTrailingAnchorConstraint = descriptionInputView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let spacer1ViewHeightAnchorConstraint = spacer1View.heightAnchor.constraint(equalToConstant: 20)
    let spacer1ViewWidthAnchorConstraint = spacer1View.widthAnchor.constraint(equalToConstant: 0)
    let idInputViewHeightAnchorConstraint = idInputView.heightAnchor.constraint(equalToConstant: 21)
    let spacer2ViewHeightAnchorConstraint = spacer2View.heightAnchor.constraint(equalToConstant: 20)
    let spacer2ViewWidthAnchorConstraint = spacer2View.widthAnchor.constraint(equalToConstant: 0)
    let coreColorWellPickerViewHeightAnchorParentConstraint = coreColorWellPickerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: fitWidthFixValueContainerView.heightAnchor)
    let smallSpacer1ViewHeightAnchorParentConstraint = smallSpacer1View
      .heightAnchor
      .constraint(lessThanOrEqualTo: fitWidthFixValueContainerView.heightAnchor)
    let valueInputViewHeightAnchorParentConstraint = valueInputView
      .heightAnchor
      .constraint(lessThanOrEqualTo: fitWidthFixValueContainerView.heightAnchor)
    let coreColorWellPickerViewLeadingAnchorConstraint = coreColorWellPickerView
      .leadingAnchor
      .constraint(equalTo: fitWidthFixValueContainerView.leadingAnchor)
    let coreColorWellPickerViewTopAnchorConstraint = coreColorWellPickerView
      .topAnchor
      .constraint(equalTo: fitWidthFixValueContainerView.topAnchor)
    let smallSpacer1ViewLeadingAnchorConstraint = smallSpacer1View
      .leadingAnchor
      .constraint(equalTo: coreColorWellPickerView.trailingAnchor)
    let smallSpacer1ViewTopAnchorConstraint = smallSpacer1View
      .topAnchor
      .constraint(equalTo: fitWidthFixValueContainerView.topAnchor)
    let valueInputViewTrailingAnchorConstraint = valueInputView
      .trailingAnchor
      .constraint(equalTo: fitWidthFixValueContainerView.trailingAnchor)
    let valueInputViewLeadingAnchorConstraint = valueInputView
      .leadingAnchor
      .constraint(equalTo: smallSpacer1View.trailingAnchor)
    let valueInputViewTopAnchorConstraint = valueInputView
      .topAnchor
      .constraint(equalTo: fitWidthFixValueContainerView.topAnchor)
    let valueInputViewBottomAnchorConstraint = valueInputView
      .bottomAnchor
      .constraint(equalTo: fitWidthFixValueContainerView.bottomAnchor)
    let spacer3ViewHeightAnchorConstraint = spacer3View.heightAnchor.constraint(equalToConstant: 20)
    let spacer3ViewWidthAnchorConstraint = spacer3View.widthAnchor.constraint(equalToConstant: 0)
    let coreColorWellPickerViewHeightAnchorConstraint = coreColorWellPickerView
      .heightAnchor
      .constraint(equalToConstant: 22)
    let coreColorWellPickerViewWidthAnchorConstraint = coreColorWellPickerView
      .widthAnchor
      .constraint(equalToConstant: 34)
    let smallSpacer1ViewHeightAnchorConstraint = smallSpacer1View.heightAnchor.constraint(equalToConstant: 0)
    let smallSpacer1ViewWidthAnchorConstraint = smallSpacer1View.widthAnchor.constraint(equalToConstant: 4)

    coreColorWellPickerViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    smallSpacer1ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    valueInputViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      nameLabelViewTopAnchorConstraint,
      nameLabelViewLeadingAnchorConstraint,
      nameLabelViewTrailingAnchorConstraint,
      nameInputViewTopAnchorConstraint,
      nameInputViewLeadingAnchorConstraint,
      nameInputViewTrailingAnchorConstraint,
      spacer1ViewTopAnchorConstraint,
      spacer1ViewLeadingAnchorConstraint,
      idLabelViewTopAnchorConstraint,
      idLabelViewLeadingAnchorConstraint,
      idLabelViewTrailingAnchorConstraint,
      idInputViewTopAnchorConstraint,
      idInputViewLeadingAnchorConstraint,
      idInputViewTrailingAnchorConstraint,
      spacer2ViewTopAnchorConstraint,
      spacer2ViewLeadingAnchorConstraint,
      valueLabelViewTopAnchorConstraint,
      valueLabelViewLeadingAnchorConstraint,
      valueLabelViewTrailingAnchorConstraint,
      fitWidthFixValueContainerViewTopAnchorConstraint,
      fitWidthFixValueContainerViewLeadingAnchorConstraint,
      fitWidthFixValueContainerViewTrailingAnchorConstraint,
      spacer3ViewTopAnchorConstraint,
      spacer3ViewLeadingAnchorConstraint,
      descriptionLabelViewTopAnchorConstraint,
      descriptionLabelViewLeadingAnchorConstraint,
      descriptionLabelViewTrailingAnchorConstraint,
      descriptionInputViewBottomAnchorConstraint,
      descriptionInputViewTopAnchorConstraint,
      descriptionInputViewLeadingAnchorConstraint,
      descriptionInputViewTrailingAnchorConstraint,
      spacer1ViewHeightAnchorConstraint,
      spacer1ViewWidthAnchorConstraint,
      idInputViewHeightAnchorConstraint,
      spacer2ViewHeightAnchorConstraint,
      spacer2ViewWidthAnchorConstraint,
      coreColorWellPickerViewHeightAnchorParentConstraint,
      smallSpacer1ViewHeightAnchorParentConstraint,
      valueInputViewHeightAnchorParentConstraint,
      coreColorWellPickerViewLeadingAnchorConstraint,
      coreColorWellPickerViewTopAnchorConstraint,
      smallSpacer1ViewLeadingAnchorConstraint,
      smallSpacer1ViewTopAnchorConstraint,
      valueInputViewTrailingAnchorConstraint,
      valueInputViewLeadingAnchorConstraint,
      valueInputViewTopAnchorConstraint,
      valueInputViewBottomAnchorConstraint,
      spacer3ViewHeightAnchorConstraint,
      spacer3ViewWidthAnchorConstraint,
      coreColorWellPickerViewHeightAnchorConstraint,
      coreColorWellPickerViewWidthAnchorConstraint,
      smallSpacer1ViewHeightAnchorConstraint,
      smallSpacer1ViewWidthAnchorConstraint
    ])
  }

  private func update() {
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleText)
    idInputView.textValue = idText
    nameInputView.textValue = nameText
    valueInputView.textValue = valueText
    descriptionInputView.textValue = descriptionText
    idInputView.onChangeTextValue = onChangeIdText
    nameInputView.onChangeTextValue = onChangeNameText
    valueInputView.onChangeTextValue = onChangeValueText
    descriptionInputView.onChangeTextValue = onChangeDescriptionText
    coreColorWellPickerView.colorValue = colorValue
    coreColorWellPickerView.onChangeColorValue = onChangeColorValue
  }
}
