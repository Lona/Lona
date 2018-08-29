import AppKit
import Foundation

// MARK: - ColorInspector

public class ColorInspector: NSBox {

  // MARK: Lifecycle

  public init(
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

  private var titleView = NSTextField(labelWithString: "")
  private var nameLabelView = NSTextField(labelWithString: "")
  private var nameInputView = TextInput()
  private var spacer1View = NSBox()
  private var idLabelView = NSTextField(labelWithString: "")
  private var idInputView = CoreTextInput()
  private var spacer2View = NSBox()
  private var valueLabelView = NSTextField(labelWithString: "")
  private var fitWidthFixValueContainerView = NSBox()
  private var coreColorWellPickerView = CoreColorWellPicker()
  private var smallSpacer1View = NSBox()
  private var valueInputView = TextInput()
  private var spacer3View = NSBox()
  private var descriptionLabelView = NSTextField(labelWithString: "")
  private var descriptionInputView = TextInput()

  private var titleViewTextStyle = TextStyles.large
  private var nameLabelViewTextStyle = TextStyles.small
  private var idLabelViewTextStyle = TextStyles.small
  private var valueLabelViewTextStyle = TextStyles.small
  private var descriptionLabelViewTextStyle = TextStyles.small

  private var topPadding: CGFloat = 20
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var titleViewTopMargin: CGFloat = 0
  private var titleViewTrailingMargin: CGFloat = 0
  private var titleViewBottomMargin: CGFloat = 20
  private var titleViewLeadingMargin: CGFloat = 0
  private var nameLabelViewTopMargin: CGFloat = 0
  private var nameLabelViewTrailingMargin: CGFloat = 0
  private var nameLabelViewBottomMargin: CGFloat = 4
  private var nameLabelViewLeadingMargin: CGFloat = 0
  private var nameInputViewTopMargin: CGFloat = 0
  private var nameInputViewTrailingMargin: CGFloat = 0
  private var nameInputViewBottomMargin: CGFloat = 0
  private var nameInputViewLeadingMargin: CGFloat = 0
  private var spacer1ViewTopMargin: CGFloat = 0
  private var spacer1ViewTrailingMargin: CGFloat = 0
  private var spacer1ViewBottomMargin: CGFloat = 0
  private var spacer1ViewLeadingMargin: CGFloat = 0
  private var idLabelViewTopMargin: CGFloat = 0
  private var idLabelViewTrailingMargin: CGFloat = 0
  private var idLabelViewBottomMargin: CGFloat = 4
  private var idLabelViewLeadingMargin: CGFloat = 0
  private var idInputViewTopMargin: CGFloat = 0
  private var idInputViewTrailingMargin: CGFloat = 0
  private var idInputViewBottomMargin: CGFloat = 0
  private var idInputViewLeadingMargin: CGFloat = 0
  private var spacer2ViewTopMargin: CGFloat = 0
  private var spacer2ViewTrailingMargin: CGFloat = 0
  private var spacer2ViewBottomMargin: CGFloat = 0
  private var spacer2ViewLeadingMargin: CGFloat = 0
  private var valueLabelViewTopMargin: CGFloat = 0
  private var valueLabelViewTrailingMargin: CGFloat = 0
  private var valueLabelViewBottomMargin: CGFloat = 4
  private var valueLabelViewLeadingMargin: CGFloat = 0
  private var fitWidthFixValueContainerViewTopMargin: CGFloat = 0
  private var fitWidthFixValueContainerViewTrailingMargin: CGFloat = 0
  private var fitWidthFixValueContainerViewBottomMargin: CGFloat = 0
  private var fitWidthFixValueContainerViewLeadingMargin: CGFloat = 0
  private var fitWidthFixValueContainerViewTopPadding: CGFloat = 0
  private var fitWidthFixValueContainerViewTrailingPadding: CGFloat = 0
  private var fitWidthFixValueContainerViewBottomPadding: CGFloat = 0
  private var fitWidthFixValueContainerViewLeadingPadding: CGFloat = 0
  private var spacer3ViewTopMargin: CGFloat = 0
  private var spacer3ViewTrailingMargin: CGFloat = 0
  private var spacer3ViewBottomMargin: CGFloat = 0
  private var spacer3ViewLeadingMargin: CGFloat = 0
  private var descriptionLabelViewTopMargin: CGFloat = 0
  private var descriptionLabelViewTrailingMargin: CGFloat = 0
  private var descriptionLabelViewBottomMargin: CGFloat = 4
  private var descriptionLabelViewLeadingMargin: CGFloat = 0
  private var descriptionInputViewTopMargin: CGFloat = 0
  private var descriptionInputViewTrailingMargin: CGFloat = 0
  private var descriptionInputViewBottomMargin: CGFloat = 0
  private var descriptionInputViewLeadingMargin: CGFloat = 0
  private var coreColorWellPickerViewTopMargin: CGFloat = 0
  private var coreColorWellPickerViewTrailingMargin: CGFloat = 0
  private var coreColorWellPickerViewBottomMargin: CGFloat = 0
  private var coreColorWellPickerViewLeadingMargin: CGFloat = 0
  private var smallSpacer1ViewTopMargin: CGFloat = 0
  private var smallSpacer1ViewTrailingMargin: CGFloat = 0
  private var smallSpacer1ViewBottomMargin: CGFloat = 0
  private var smallSpacer1ViewLeadingMargin: CGFloat = 0
  private var valueInputViewTopMargin: CGFloat = 0
  private var valueInputViewTrailingMargin: CGFloat = 0
  private var valueInputViewBottomMargin: CGFloat = 0
  private var valueInputViewLeadingMargin: CGFloat = 0

  private var titleViewTopAnchorConstraint: NSLayoutConstraint?
  private var titleViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var titleViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var nameLabelViewTopAnchorConstraint: NSLayoutConstraint?
  private var nameLabelViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var nameLabelViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var nameInputViewTopAnchorConstraint: NSLayoutConstraint?
  private var nameInputViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var nameInputViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var spacer1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var spacer1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var idLabelViewTopAnchorConstraint: NSLayoutConstraint?
  private var idLabelViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var idLabelViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var idInputViewTopAnchorConstraint: NSLayoutConstraint?
  private var idInputViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var idInputViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var spacer2ViewTopAnchorConstraint: NSLayoutConstraint?
  private var spacer2ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var valueLabelViewTopAnchorConstraint: NSLayoutConstraint?
  private var valueLabelViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var valueLabelViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var fitWidthFixValueContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var fitWidthFixValueContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var fitWidthFixValueContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var spacer3ViewTopAnchorConstraint: NSLayoutConstraint?
  private var spacer3ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var descriptionLabelViewTopAnchorConstraint: NSLayoutConstraint?
  private var descriptionLabelViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var descriptionLabelViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var descriptionInputViewBottomAnchorConstraint: NSLayoutConstraint?
  private var descriptionInputViewTopAnchorConstraint: NSLayoutConstraint?
  private var descriptionInputViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var descriptionInputViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var spacer1ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var spacer1ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var idInputViewHeightAnchorConstraint: NSLayoutConstraint?
  private var spacer2ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var spacer2ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var coreColorWellPickerViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var smallSpacer1ViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var valueInputViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var coreColorWellPickerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var coreColorWellPickerViewTopAnchorConstraint: NSLayoutConstraint?
  private var smallSpacer1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var smallSpacer1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var valueInputViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var valueInputViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var valueInputViewTopAnchorConstraint: NSLayoutConstraint?
  private var valueInputViewBottomAnchorConstraint: NSLayoutConstraint?
  private var spacer3ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var spacer3ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var coreColorWellPickerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var coreColorWellPickerViewWidthAnchorConstraint: NSLayoutConstraint?
  private var smallSpacer1ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var smallSpacer1ViewWidthAnchorConstraint: NSLayoutConstraint?

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

    let titleViewTopAnchorConstraint = titleView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + titleViewTopMargin)
    let titleViewLeadingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + titleViewLeadingMargin)
    let titleViewTrailingAnchorConstraint = titleView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + titleViewTrailingMargin))
    let nameLabelViewTopAnchorConstraint = nameLabelView
      .topAnchor
      .constraint(equalTo: titleView.bottomAnchor, constant: titleViewBottomMargin + nameLabelViewTopMargin)
    let nameLabelViewLeadingAnchorConstraint = nameLabelView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + nameLabelViewLeadingMargin)
    let nameLabelViewTrailingAnchorConstraint = nameLabelView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + nameLabelViewTrailingMargin))
    let nameInputViewTopAnchorConstraint = nameInputView
      .topAnchor
      .constraint(equalTo: nameLabelView.bottomAnchor, constant: nameLabelViewBottomMargin + nameInputViewTopMargin)
    let nameInputViewLeadingAnchorConstraint = nameInputView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + nameInputViewLeadingMargin)
    let nameInputViewTrailingAnchorConstraint = nameInputView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + nameInputViewTrailingMargin))
    let spacer1ViewTopAnchorConstraint = spacer1View
      .topAnchor
      .constraint(equalTo: nameInputView.bottomAnchor, constant: nameInputViewBottomMargin + spacer1ViewTopMargin)
    let spacer1ViewLeadingAnchorConstraint = spacer1View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + spacer1ViewLeadingMargin)
    let idLabelViewTopAnchorConstraint = idLabelView
      .topAnchor
      .constraint(equalTo: spacer1View.bottomAnchor, constant: spacer1ViewBottomMargin + idLabelViewTopMargin)
    let idLabelViewLeadingAnchorConstraint = idLabelView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + idLabelViewLeadingMargin)
    let idLabelViewTrailingAnchorConstraint = idLabelView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + idLabelViewTrailingMargin))
    let idInputViewTopAnchorConstraint = idInputView
      .topAnchor
      .constraint(equalTo: idLabelView.bottomAnchor, constant: idLabelViewBottomMargin + idInputViewTopMargin)
    let idInputViewLeadingAnchorConstraint = idInputView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + idInputViewLeadingMargin)
    let idInputViewTrailingAnchorConstraint = idInputView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + idInputViewTrailingMargin))
    let spacer2ViewTopAnchorConstraint = spacer2View
      .topAnchor
      .constraint(equalTo: idInputView.bottomAnchor, constant: idInputViewBottomMargin + spacer2ViewTopMargin)
    let spacer2ViewLeadingAnchorConstraint = spacer2View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + spacer2ViewLeadingMargin)
    let valueLabelViewTopAnchorConstraint = valueLabelView
      .topAnchor
      .constraint(equalTo: spacer2View.bottomAnchor, constant: spacer2ViewBottomMargin + valueLabelViewTopMargin)
    let valueLabelViewLeadingAnchorConstraint = valueLabelView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + valueLabelViewLeadingMargin)
    let valueLabelViewTrailingAnchorConstraint = valueLabelView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + valueLabelViewTrailingMargin))
    let fitWidthFixValueContainerViewTopAnchorConstraint = fitWidthFixValueContainerView
      .topAnchor
      .constraint(
        equalTo: valueLabelView.bottomAnchor,
        constant: valueLabelViewBottomMargin + fitWidthFixValueContainerViewTopMargin)
    let fitWidthFixValueContainerViewLeadingAnchorConstraint = fitWidthFixValueContainerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + fitWidthFixValueContainerViewLeadingMargin)
    let fitWidthFixValueContainerViewTrailingAnchorConstraint = fitWidthFixValueContainerView
      .trailingAnchor
      .constraint(
        lessThanOrEqualTo: trailingAnchor,
        constant: -(trailingPadding + fitWidthFixValueContainerViewTrailingMargin))
    let spacer3ViewTopAnchorConstraint = spacer3View
      .topAnchor
      .constraint(
        equalTo: fitWidthFixValueContainerView.bottomAnchor,
        constant: fitWidthFixValueContainerViewBottomMargin + spacer3ViewTopMargin)
    let spacer3ViewLeadingAnchorConstraint = spacer3View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + spacer3ViewLeadingMargin)
    let descriptionLabelViewTopAnchorConstraint = descriptionLabelView
      .topAnchor
      .constraint(equalTo: spacer3View.bottomAnchor, constant: spacer3ViewBottomMargin + descriptionLabelViewTopMargin)
    let descriptionLabelViewLeadingAnchorConstraint = descriptionLabelView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + descriptionLabelViewLeadingMargin)
    let descriptionLabelViewTrailingAnchorConstraint = descriptionLabelView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + descriptionLabelViewTrailingMargin))
    let descriptionInputViewBottomAnchorConstraint = descriptionInputView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + descriptionInputViewBottomMargin))
    let descriptionInputViewTopAnchorConstraint = descriptionInputView
      .topAnchor
      .constraint(
        equalTo: descriptionLabelView.bottomAnchor,
        constant: descriptionLabelViewBottomMargin + descriptionInputViewTopMargin)
    let descriptionInputViewLeadingAnchorConstraint = descriptionInputView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + descriptionInputViewLeadingMargin)
    let descriptionInputViewTrailingAnchorConstraint = descriptionInputView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + descriptionInputViewTrailingMargin))
    let spacer1ViewHeightAnchorConstraint = spacer1View.heightAnchor.constraint(equalToConstant: 20)
    let spacer1ViewWidthAnchorConstraint = spacer1View.widthAnchor.constraint(equalToConstant: 0)
    let idInputViewHeightAnchorConstraint = idInputView.heightAnchor.constraint(equalToConstant: 21)
    let spacer2ViewHeightAnchorConstraint = spacer2View.heightAnchor.constraint(equalToConstant: 20)
    let spacer2ViewWidthAnchorConstraint = spacer2View.widthAnchor.constraint(equalToConstant: 0)
    let coreColorWellPickerViewHeightAnchorParentConstraint = coreColorWellPickerView
      .heightAnchor
      .constraint(
        lessThanOrEqualTo: fitWidthFixValueContainerView.heightAnchor,
        constant:
        -(
        fitWidthFixValueContainerViewTopPadding + coreColorWellPickerViewTopMargin +
          fitWidthFixValueContainerViewBottomPadding + coreColorWellPickerViewBottomMargin
        ))
    let smallSpacer1ViewHeightAnchorParentConstraint = smallSpacer1View
      .heightAnchor
      .constraint(
        lessThanOrEqualTo: fitWidthFixValueContainerView.heightAnchor,
        constant:
        -(
        fitWidthFixValueContainerViewTopPadding + smallSpacer1ViewTopMargin +
          fitWidthFixValueContainerViewBottomPadding + smallSpacer1ViewBottomMargin
        ))
    let valueInputViewHeightAnchorParentConstraint = valueInputView
      .heightAnchor
      .constraint(
        lessThanOrEqualTo: fitWidthFixValueContainerView.heightAnchor,
        constant:
        -(
        fitWidthFixValueContainerViewTopPadding + valueInputViewTopMargin +
          fitWidthFixValueContainerViewBottomPadding + valueInputViewBottomMargin
        ))
    let coreColorWellPickerViewLeadingAnchorConstraint = coreColorWellPickerView
      .leadingAnchor
      .constraint(
        equalTo: fitWidthFixValueContainerView.leadingAnchor,
        constant: fitWidthFixValueContainerViewLeadingPadding + coreColorWellPickerViewLeadingMargin)
    let coreColorWellPickerViewTopAnchorConstraint = coreColorWellPickerView
      .topAnchor
      .constraint(
        equalTo: fitWidthFixValueContainerView.topAnchor,
        constant: fitWidthFixValueContainerViewTopPadding + coreColorWellPickerViewTopMargin)
    let smallSpacer1ViewLeadingAnchorConstraint = smallSpacer1View
      .leadingAnchor
      .constraint(
        equalTo: coreColorWellPickerView.trailingAnchor,
        constant: coreColorWellPickerViewTrailingMargin + smallSpacer1ViewLeadingMargin)
    let smallSpacer1ViewTopAnchorConstraint = smallSpacer1View
      .topAnchor
      .constraint(
        equalTo: fitWidthFixValueContainerView.topAnchor,
        constant: fitWidthFixValueContainerViewTopPadding + smallSpacer1ViewTopMargin)
    let valueInputViewTrailingAnchorConstraint = valueInputView
      .trailingAnchor
      .constraint(
        equalTo: fitWidthFixValueContainerView.trailingAnchor,
        constant: -(fitWidthFixValueContainerViewTrailingPadding + valueInputViewTrailingMargin))
    let valueInputViewLeadingAnchorConstraint = valueInputView
      .leadingAnchor
      .constraint(
        equalTo: smallSpacer1View.trailingAnchor,
        constant: smallSpacer1ViewTrailingMargin + valueInputViewLeadingMargin)
    let valueInputViewTopAnchorConstraint = valueInputView
      .topAnchor
      .constraint(
        equalTo: fitWidthFixValueContainerView.topAnchor,
        constant: fitWidthFixValueContainerViewTopPadding + valueInputViewTopMargin)
    let valueInputViewBottomAnchorConstraint = valueInputView
      .bottomAnchor
      .constraint(
        equalTo: fitWidthFixValueContainerView.bottomAnchor,
        constant: -(fitWidthFixValueContainerViewBottomPadding + valueInputViewBottomMargin))
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

    self.titleViewTopAnchorConstraint = titleViewTopAnchorConstraint
    self.titleViewLeadingAnchorConstraint = titleViewLeadingAnchorConstraint
    self.titleViewTrailingAnchorConstraint = titleViewTrailingAnchorConstraint
    self.nameLabelViewTopAnchorConstraint = nameLabelViewTopAnchorConstraint
    self.nameLabelViewLeadingAnchorConstraint = nameLabelViewLeadingAnchorConstraint
    self.nameLabelViewTrailingAnchorConstraint = nameLabelViewTrailingAnchorConstraint
    self.nameInputViewTopAnchorConstraint = nameInputViewTopAnchorConstraint
    self.nameInputViewLeadingAnchorConstraint = nameInputViewLeadingAnchorConstraint
    self.nameInputViewTrailingAnchorConstraint = nameInputViewTrailingAnchorConstraint
    self.spacer1ViewTopAnchorConstraint = spacer1ViewTopAnchorConstraint
    self.spacer1ViewLeadingAnchorConstraint = spacer1ViewLeadingAnchorConstraint
    self.idLabelViewTopAnchorConstraint = idLabelViewTopAnchorConstraint
    self.idLabelViewLeadingAnchorConstraint = idLabelViewLeadingAnchorConstraint
    self.idLabelViewTrailingAnchorConstraint = idLabelViewTrailingAnchorConstraint
    self.idInputViewTopAnchorConstraint = idInputViewTopAnchorConstraint
    self.idInputViewLeadingAnchorConstraint = idInputViewLeadingAnchorConstraint
    self.idInputViewTrailingAnchorConstraint = idInputViewTrailingAnchorConstraint
    self.spacer2ViewTopAnchorConstraint = spacer2ViewTopAnchorConstraint
    self.spacer2ViewLeadingAnchorConstraint = spacer2ViewLeadingAnchorConstraint
    self.valueLabelViewTopAnchorConstraint = valueLabelViewTopAnchorConstraint
    self.valueLabelViewLeadingAnchorConstraint = valueLabelViewLeadingAnchorConstraint
    self.valueLabelViewTrailingAnchorConstraint = valueLabelViewTrailingAnchorConstraint
    self.fitWidthFixValueContainerViewTopAnchorConstraint = fitWidthFixValueContainerViewTopAnchorConstraint
    self.fitWidthFixValueContainerViewLeadingAnchorConstraint = fitWidthFixValueContainerViewLeadingAnchorConstraint
    self.fitWidthFixValueContainerViewTrailingAnchorConstraint = fitWidthFixValueContainerViewTrailingAnchorConstraint
    self.spacer3ViewTopAnchorConstraint = spacer3ViewTopAnchorConstraint
    self.spacer3ViewLeadingAnchorConstraint = spacer3ViewLeadingAnchorConstraint
    self.descriptionLabelViewTopAnchorConstraint = descriptionLabelViewTopAnchorConstraint
    self.descriptionLabelViewLeadingAnchorConstraint = descriptionLabelViewLeadingAnchorConstraint
    self.descriptionLabelViewTrailingAnchorConstraint = descriptionLabelViewTrailingAnchorConstraint
    self.descriptionInputViewBottomAnchorConstraint = descriptionInputViewBottomAnchorConstraint
    self.descriptionInputViewTopAnchorConstraint = descriptionInputViewTopAnchorConstraint
    self.descriptionInputViewLeadingAnchorConstraint = descriptionInputViewLeadingAnchorConstraint
    self.descriptionInputViewTrailingAnchorConstraint = descriptionInputViewTrailingAnchorConstraint
    self.spacer1ViewHeightAnchorConstraint = spacer1ViewHeightAnchorConstraint
    self.spacer1ViewWidthAnchorConstraint = spacer1ViewWidthAnchorConstraint
    self.idInputViewHeightAnchorConstraint = idInputViewHeightAnchorConstraint
    self.spacer2ViewHeightAnchorConstraint = spacer2ViewHeightAnchorConstraint
    self.spacer2ViewWidthAnchorConstraint = spacer2ViewWidthAnchorConstraint
    self.coreColorWellPickerViewHeightAnchorParentConstraint = coreColorWellPickerViewHeightAnchorParentConstraint
    self.smallSpacer1ViewHeightAnchorParentConstraint = smallSpacer1ViewHeightAnchorParentConstraint
    self.valueInputViewHeightAnchorParentConstraint = valueInputViewHeightAnchorParentConstraint
    self.coreColorWellPickerViewLeadingAnchorConstraint = coreColorWellPickerViewLeadingAnchorConstraint
    self.coreColorWellPickerViewTopAnchorConstraint = coreColorWellPickerViewTopAnchorConstraint
    self.smallSpacer1ViewLeadingAnchorConstraint = smallSpacer1ViewLeadingAnchorConstraint
    self.smallSpacer1ViewTopAnchorConstraint = smallSpacer1ViewTopAnchorConstraint
    self.valueInputViewTrailingAnchorConstraint = valueInputViewTrailingAnchorConstraint
    self.valueInputViewLeadingAnchorConstraint = valueInputViewLeadingAnchorConstraint
    self.valueInputViewTopAnchorConstraint = valueInputViewTopAnchorConstraint
    self.valueInputViewBottomAnchorConstraint = valueInputViewBottomAnchorConstraint
    self.spacer3ViewHeightAnchorConstraint = spacer3ViewHeightAnchorConstraint
    self.spacer3ViewWidthAnchorConstraint = spacer3ViewWidthAnchorConstraint
    self.coreColorWellPickerViewHeightAnchorConstraint = coreColorWellPickerViewHeightAnchorConstraint
    self.coreColorWellPickerViewWidthAnchorConstraint = coreColorWellPickerViewWidthAnchorConstraint
    self.smallSpacer1ViewHeightAnchorConstraint = smallSpacer1ViewHeightAnchorConstraint
    self.smallSpacer1ViewWidthAnchorConstraint = smallSpacer1ViewWidthAnchorConstraint

    // For debugging
    titleViewTopAnchorConstraint.identifier = "titleViewTopAnchorConstraint"
    titleViewLeadingAnchorConstraint.identifier = "titleViewLeadingAnchorConstraint"
    titleViewTrailingAnchorConstraint.identifier = "titleViewTrailingAnchorConstraint"
    nameLabelViewTopAnchorConstraint.identifier = "nameLabelViewTopAnchorConstraint"
    nameLabelViewLeadingAnchorConstraint.identifier = "nameLabelViewLeadingAnchorConstraint"
    nameLabelViewTrailingAnchorConstraint.identifier = "nameLabelViewTrailingAnchorConstraint"
    nameInputViewTopAnchorConstraint.identifier = "nameInputViewTopAnchorConstraint"
    nameInputViewLeadingAnchorConstraint.identifier = "nameInputViewLeadingAnchorConstraint"
    nameInputViewTrailingAnchorConstraint.identifier = "nameInputViewTrailingAnchorConstraint"
    spacer1ViewTopAnchorConstraint.identifier = "spacer1ViewTopAnchorConstraint"
    spacer1ViewLeadingAnchorConstraint.identifier = "spacer1ViewLeadingAnchorConstraint"
    idLabelViewTopAnchorConstraint.identifier = "idLabelViewTopAnchorConstraint"
    idLabelViewLeadingAnchorConstraint.identifier = "idLabelViewLeadingAnchorConstraint"
    idLabelViewTrailingAnchorConstraint.identifier = "idLabelViewTrailingAnchorConstraint"
    idInputViewTopAnchorConstraint.identifier = "idInputViewTopAnchorConstraint"
    idInputViewLeadingAnchorConstraint.identifier = "idInputViewLeadingAnchorConstraint"
    idInputViewTrailingAnchorConstraint.identifier = "idInputViewTrailingAnchorConstraint"
    spacer2ViewTopAnchorConstraint.identifier = "spacer2ViewTopAnchorConstraint"
    spacer2ViewLeadingAnchorConstraint.identifier = "spacer2ViewLeadingAnchorConstraint"
    valueLabelViewTopAnchorConstraint.identifier = "valueLabelViewTopAnchorConstraint"
    valueLabelViewLeadingAnchorConstraint.identifier = "valueLabelViewLeadingAnchorConstraint"
    valueLabelViewTrailingAnchorConstraint.identifier = "valueLabelViewTrailingAnchorConstraint"
    fitWidthFixValueContainerViewTopAnchorConstraint.identifier = "fitWidthFixValueContainerViewTopAnchorConstraint"
    fitWidthFixValueContainerViewLeadingAnchorConstraint.identifier =
      "fitWidthFixValueContainerViewLeadingAnchorConstraint"
    fitWidthFixValueContainerViewTrailingAnchorConstraint.identifier =
      "fitWidthFixValueContainerViewTrailingAnchorConstraint"
    spacer3ViewTopAnchorConstraint.identifier = "spacer3ViewTopAnchorConstraint"
    spacer3ViewLeadingAnchorConstraint.identifier = "spacer3ViewLeadingAnchorConstraint"
    descriptionLabelViewTopAnchorConstraint.identifier = "descriptionLabelViewTopAnchorConstraint"
    descriptionLabelViewLeadingAnchorConstraint.identifier = "descriptionLabelViewLeadingAnchorConstraint"
    descriptionLabelViewTrailingAnchorConstraint.identifier = "descriptionLabelViewTrailingAnchorConstraint"
    descriptionInputViewBottomAnchorConstraint.identifier = "descriptionInputViewBottomAnchorConstraint"
    descriptionInputViewTopAnchorConstraint.identifier = "descriptionInputViewTopAnchorConstraint"
    descriptionInputViewLeadingAnchorConstraint.identifier = "descriptionInputViewLeadingAnchorConstraint"
    descriptionInputViewTrailingAnchorConstraint.identifier = "descriptionInputViewTrailingAnchorConstraint"
    spacer1ViewHeightAnchorConstraint.identifier = "spacer1ViewHeightAnchorConstraint"
    spacer1ViewWidthAnchorConstraint.identifier = "spacer1ViewWidthAnchorConstraint"
    idInputViewHeightAnchorConstraint.identifier = "idInputViewHeightAnchorConstraint"
    spacer2ViewHeightAnchorConstraint.identifier = "spacer2ViewHeightAnchorConstraint"
    spacer2ViewWidthAnchorConstraint.identifier = "spacer2ViewWidthAnchorConstraint"
    coreColorWellPickerViewHeightAnchorParentConstraint.identifier =
      "coreColorWellPickerViewHeightAnchorParentConstraint"
    smallSpacer1ViewHeightAnchorParentConstraint.identifier = "smallSpacer1ViewHeightAnchorParentConstraint"
    valueInputViewHeightAnchorParentConstraint.identifier = "valueInputViewHeightAnchorParentConstraint"
    coreColorWellPickerViewLeadingAnchorConstraint.identifier = "coreColorWellPickerViewLeadingAnchorConstraint"
    coreColorWellPickerViewTopAnchorConstraint.identifier = "coreColorWellPickerViewTopAnchorConstraint"
    smallSpacer1ViewLeadingAnchorConstraint.identifier = "smallSpacer1ViewLeadingAnchorConstraint"
    smallSpacer1ViewTopAnchorConstraint.identifier = "smallSpacer1ViewTopAnchorConstraint"
    valueInputViewTrailingAnchorConstraint.identifier = "valueInputViewTrailingAnchorConstraint"
    valueInputViewLeadingAnchorConstraint.identifier = "valueInputViewLeadingAnchorConstraint"
    valueInputViewTopAnchorConstraint.identifier = "valueInputViewTopAnchorConstraint"
    valueInputViewBottomAnchorConstraint.identifier = "valueInputViewBottomAnchorConstraint"
    spacer3ViewHeightAnchorConstraint.identifier = "spacer3ViewHeightAnchorConstraint"
    spacer3ViewWidthAnchorConstraint.identifier = "spacer3ViewWidthAnchorConstraint"
    coreColorWellPickerViewHeightAnchorConstraint.identifier = "coreColorWellPickerViewHeightAnchorConstraint"
    coreColorWellPickerViewWidthAnchorConstraint.identifier = "coreColorWellPickerViewWidthAnchorConstraint"
    smallSpacer1ViewHeightAnchorConstraint.identifier = "smallSpacer1ViewHeightAnchorConstraint"
    smallSpacer1ViewWidthAnchorConstraint.identifier = "smallSpacer1ViewWidthAnchorConstraint"
  }

  private func update() {
    idInputView.textValue = idText
    nameInputView.textValue = nameText
    titleView.attributedStringValue = titleViewTextStyle.apply(to: nameText)
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
