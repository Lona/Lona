import AppKit
import Foundation

// MARK: - TextStyleInspector

public class TextStyleInspector: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(
    idText: String,
    nameText: String,
    fontNameText: String,
    fontFamilyText: String,
    fontWeightText: String,
    fontSizeNumber: CGFloat,
    lineHeightNumber: CGFloat,
    letterSpacingNumber: CGFloat,
    textTransformText: String,
    colorValue: String,
    descriptionText: String)
  {
    self
      .init(
        Parameters(
          idText: idText,
          nameText: nameText,
          fontNameText: fontNameText,
          fontFamilyText: fontFamilyText,
          fontWeightText: fontWeightText,
          fontSizeNumber: fontSizeNumber,
          lineHeightNumber: lineHeightNumber,
          letterSpacingNumber: letterSpacingNumber,
          textTransformText: textTransformText,
          colorValue: colorValue,
          descriptionText: descriptionText))
  }

  public convenience init() {
    self.init(Parameters())
  }

  public required init?(coder aDecoder: NSCoder) {
    self.parameters = Parameters()

    super.init(coder: aDecoder)

    setUpViews()
    setUpConstraints()

    update()
  }

  // MARK: Public

  public var idText: String {
    get { return parameters.idText }
    set {
      if parameters.idText != newValue {
        parameters.idText = newValue
      }
    }
  }

  public var nameText: String {
    get { return parameters.nameText }
    set {
      if parameters.nameText != newValue {
        parameters.nameText = newValue
      }
    }
  }

  public var fontNameText: String {
    get { return parameters.fontNameText }
    set {
      if parameters.fontNameText != newValue {
        parameters.fontNameText = newValue
      }
    }
  }

  public var fontFamilyText: String {
    get { return parameters.fontFamilyText }
    set {
      if parameters.fontFamilyText != newValue {
        parameters.fontFamilyText = newValue
      }
    }
  }

  public var fontWeightText: String {
    get { return parameters.fontWeightText }
    set {
      if parameters.fontWeightText != newValue {
        parameters.fontWeightText = newValue
      }
    }
  }

  public var fontSizeNumber: CGFloat {
    get { return parameters.fontSizeNumber }
    set {
      if parameters.fontSizeNumber != newValue {
        parameters.fontSizeNumber = newValue
      }
    }
  }

  public var lineHeightNumber: CGFloat {
    get { return parameters.lineHeightNumber }
    set {
      if parameters.lineHeightNumber != newValue {
        parameters.lineHeightNumber = newValue
      }
    }
  }

  public var letterSpacingNumber: CGFloat {
    get { return parameters.letterSpacingNumber }
    set {
      if parameters.letterSpacingNumber != newValue {
        parameters.letterSpacingNumber = newValue
      }
    }
  }

  public var textTransformText: String {
    get { return parameters.textTransformText }
    set {
      if parameters.textTransformText != newValue {
        parameters.textTransformText = newValue
      }
    }
  }

  public var colorValue: String {
    get { return parameters.colorValue }
    set {
      if parameters.colorValue != newValue {
        parameters.colorValue = newValue
      }
    }
  }

  public var descriptionText: String {
    get { return parameters.descriptionText }
    set {
      if parameters.descriptionText != newValue {
        parameters.descriptionText = newValue
      }
    }
  }

  public var onChangeIdText: StringHandler {
    get { return parameters.onChangeIdText }
    set { parameters.onChangeIdText = newValue }
  }

  public var onChangeNameText: StringHandler {
    get { return parameters.onChangeNameText }
    set { parameters.onChangeNameText = newValue }
  }

  public var onChangeFontNameText: StringHandler {
    get { return parameters.onChangeFontNameText }
    set { parameters.onChangeFontNameText = newValue }
  }

  public var onChangeFontFamilyText: StringHandler {
    get { return parameters.onChangeFontFamilyText }
    set { parameters.onChangeFontFamilyText = newValue }
  }

  public var onChangeFontWeightText: StringHandler {
    get { return parameters.onChangeFontWeightText }
    set { parameters.onChangeFontWeightText = newValue }
  }

  public var onChangeFontSizeNumber: NumberHandler {
    get { return parameters.onChangeFontSizeNumber }
    set { parameters.onChangeFontSizeNumber = newValue }
  }

  public var onChangeLineHeightNumber: NumberHandler {
    get { return parameters.onChangeLineHeightNumber }
    set { parameters.onChangeLineHeightNumber = newValue }
  }

  public var onChangeLetterSpacingNumber: NumberHandler {
    get { return parameters.onChangeLetterSpacingNumber }
    set { parameters.onChangeLetterSpacingNumber = newValue }
  }

  public var onChangeTextTransformText: StringHandler {
    get { return parameters.onChangeTextTransformText }
    set { parameters.onChangeTextTransformText = newValue }
  }

  public var onChangeColorValue: StringHandler {
    get { return parameters.onChangeColorValue }
    set { parameters.onChangeColorValue = newValue }
  }

  public var onChangeDescriptionText: StringHandler {
    get { return parameters.onChangeDescriptionText }
    set { parameters.onChangeDescriptionText = newValue }
  }

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private var nameLabelView = LNATextField(labelWithString: "")
  private var nameInputView = TextInput()
  private var spacer1View = NSBox()
  private var idLabelView = LNATextField(labelWithString: "")
  private var idInputView = TextInput()
  private var spacer2View = NSBox()
  private var fontNameLabelView = LNATextField(labelWithString: "")
  private var fontNameInputView = TextInput()
  private var spacer3View = NSBox()
  private var fontFamilyLabelView = LNATextField(labelWithString: "")
  private var fontFamilyInputView = TextInput()
  private var spacer4View = NSBox()
  private var fontWeightLabelView = LNATextField(labelWithString: "")
  private var fontWeightInputView = TextInput()
  private var spacer5View = NSBox()
  private var fontSizeLabelView = LNATextField(labelWithString: "")
  private var fontSizeInputView = NumberInput()
  private var spacer6View = NSBox()
  private var lineHeightLabelView = LNATextField(labelWithString: "")
  private var lineHeightInputView = NumberInput()
  private var spacer7View = NSBox()
  private var letterSpacingLabelView = LNATextField(labelWithString: "")
  private var letterSpacingInputView = NumberInput()
  private var spacerView = NSBox()
  private var textTransformLabelView = LNATextField(labelWithString: "")
  private var textTransformInputView = TextInput()
  private var spacer8View = NSBox()
  private var colorLabelView = LNATextField(labelWithString: "")
  private var colorInputView = ColorPickerButton()
  private var spacer9View = NSBox()
  private var descriptionLabelView = LNATextField(labelWithString: "")
  private var descriptionInputView = TextInput()

  private var nameLabelViewTextStyle = TextStyles.small
  private var idLabelViewTextStyle = TextStyles.small
  private var fontNameLabelViewTextStyle = TextStyles.small
  private var fontFamilyLabelViewTextStyle = TextStyles.small
  private var fontWeightLabelViewTextStyle = TextStyles.small
  private var fontSizeLabelViewTextStyle = TextStyles.small
  private var lineHeightLabelViewTextStyle = TextStyles.small
  private var letterSpacingLabelViewTextStyle = TextStyles.small
  private var textTransformLabelViewTextStyle = TextStyles.small
  private var colorLabelViewTextStyle = TextStyles.small
  private var descriptionLabelViewTextStyle = TextStyles.small

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    nameLabelView.lineBreakMode = .byWordWrapping
    spacer1View.boxType = .custom
    spacer1View.borderType = .noBorder
    spacer1View.contentViewMargins = .zero
    idLabelView.lineBreakMode = .byWordWrapping
    spacer2View.boxType = .custom
    spacer2View.borderType = .noBorder
    spacer2View.contentViewMargins = .zero
    fontNameLabelView.lineBreakMode = .byWordWrapping
    spacer3View.boxType = .custom
    spacer3View.borderType = .noBorder
    spacer3View.contentViewMargins = .zero
    fontFamilyLabelView.lineBreakMode = .byWordWrapping
    spacer4View.boxType = .custom
    spacer4View.borderType = .noBorder
    spacer4View.contentViewMargins = .zero
    fontWeightLabelView.lineBreakMode = .byWordWrapping
    spacer5View.boxType = .custom
    spacer5View.borderType = .noBorder
    spacer5View.contentViewMargins = .zero
    fontSizeLabelView.lineBreakMode = .byWordWrapping
    spacer6View.boxType = .custom
    spacer6View.borderType = .noBorder
    spacer6View.contentViewMargins = .zero
    lineHeightLabelView.lineBreakMode = .byWordWrapping
    spacer7View.boxType = .custom
    spacer7View.borderType = .noBorder
    spacer7View.contentViewMargins = .zero
    letterSpacingLabelView.lineBreakMode = .byWordWrapping
    spacerView.boxType = .custom
    spacerView.borderType = .noBorder
    spacerView.contentViewMargins = .zero
    textTransformLabelView.lineBreakMode = .byWordWrapping
    spacer8View.boxType = .custom
    spacer8View.borderType = .noBorder
    spacer8View.contentViewMargins = .zero
    colorLabelView.lineBreakMode = .byWordWrapping
    spacer9View.boxType = .custom
    spacer9View.borderType = .noBorder
    spacer9View.contentViewMargins = .zero
    descriptionLabelView.lineBreakMode = .byWordWrapping

    addSubview(nameLabelView)
    addSubview(nameInputView)
    addSubview(spacer1View)
    addSubview(idLabelView)
    addSubview(idInputView)
    addSubview(spacer2View)
    addSubview(fontNameLabelView)
    addSubview(fontNameInputView)
    addSubview(spacer3View)
    addSubview(fontFamilyLabelView)
    addSubview(fontFamilyInputView)
    addSubview(spacer4View)
    addSubview(fontWeightLabelView)
    addSubview(fontWeightInputView)
    addSubview(spacer5View)
    addSubview(fontSizeLabelView)
    addSubview(fontSizeInputView)
    addSubview(spacer6View)
    addSubview(lineHeightLabelView)
    addSubview(lineHeightInputView)
    addSubview(spacer7View)
    addSubview(letterSpacingLabelView)
    addSubview(letterSpacingInputView)
    addSubview(spacerView)
    addSubview(textTransformLabelView)
    addSubview(textTransformInputView)
    addSubview(spacer8View)
    addSubview(colorLabelView)
    addSubview(colorInputView)
    addSubview(spacer9View)
    addSubview(descriptionLabelView)
    addSubview(descriptionInputView)

    nameLabelView.attributedStringValue = nameLabelViewTextStyle.apply(to: "NAME")
    nameLabelViewTextStyle = TextStyles.small
    nameLabelView.attributedStringValue = nameLabelViewTextStyle.apply(to: nameLabelView.attributedStringValue)
    spacer1View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    idLabelView.attributedStringValue = idLabelViewTextStyle.apply(to: "ID")
    idLabelViewTextStyle = TextStyles.small
    idLabelView.attributedStringValue = idLabelViewTextStyle.apply(to: idLabelView.attributedStringValue)
    spacer2View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    fontNameLabelView.attributedStringValue = fontNameLabelViewTextStyle.apply(to: "FONT NAME")
    fontNameLabelViewTextStyle = TextStyles.small
    fontNameLabelView.attributedStringValue =
      fontNameLabelViewTextStyle.apply(to: fontNameLabelView.attributedStringValue)
    spacer3View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    fontFamilyLabelView.attributedStringValue = fontFamilyLabelViewTextStyle.apply(to: "FONT FAMILY")
    fontFamilyLabelViewTextStyle = TextStyles.small
    fontFamilyLabelView.attributedStringValue =
      fontFamilyLabelViewTextStyle.apply(to: fontFamilyLabelView.attributedStringValue)
    spacer4View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    fontWeightLabelView.attributedStringValue = fontWeightLabelViewTextStyle.apply(to: "FONT WEIGHT")
    fontWeightLabelViewTextStyle = TextStyles.small
    fontWeightLabelView.attributedStringValue =
      fontWeightLabelViewTextStyle.apply(to: fontWeightLabelView.attributedStringValue)
    spacer5View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    fontSizeLabelView.attributedStringValue = fontSizeLabelViewTextStyle.apply(to: "FONT SIZE")
    fontSizeLabelViewTextStyle = TextStyles.small
    fontSizeLabelView.attributedStringValue =
      fontSizeLabelViewTextStyle.apply(to: fontSizeLabelView.attributedStringValue)
    spacer6View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    lineHeightLabelView.attributedStringValue = lineHeightLabelViewTextStyle.apply(to: "LINE HEIGHT")
    lineHeightLabelViewTextStyle = TextStyles.small
    lineHeightLabelView.attributedStringValue =
      lineHeightLabelViewTextStyle.apply(to: lineHeightLabelView.attributedStringValue)
    spacer7View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    letterSpacingLabelView.attributedStringValue = letterSpacingLabelViewTextStyle.apply(to: "LETTER SPACING")
    letterSpacingLabelViewTextStyle = TextStyles.small
    letterSpacingLabelView.attributedStringValue =
      letterSpacingLabelViewTextStyle.apply(to: letterSpacingLabelView.attributedStringValue)
    spacerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    textTransformLabelView.attributedStringValue = textTransformLabelViewTextStyle.apply(to: "TEXT TRANSFORM")
    textTransformLabelViewTextStyle = TextStyles.small
    textTransformLabelView.attributedStringValue =
      textTransformLabelViewTextStyle.apply(to: textTransformLabelView.attributedStringValue)
    spacer8View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    colorLabelView.attributedStringValue = colorLabelViewTextStyle.apply(to: "COLOR")
    colorLabelViewTextStyle = TextStyles.small
    colorLabelView.attributedStringValue = colorLabelViewTextStyle.apply(to: colorLabelView.attributedStringValue)
    spacer9View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    descriptionLabelView.attributedStringValue = descriptionLabelViewTextStyle.apply(to: "DESCRIPTION")
    descriptionLabelViewTextStyle = TextStyles.small
    descriptionLabelView.attributedStringValue =
      descriptionLabelViewTextStyle.apply(to: descriptionLabelView.attributedStringValue)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    nameLabelView.translatesAutoresizingMaskIntoConstraints = false
    nameInputView.translatesAutoresizingMaskIntoConstraints = false
    spacer1View.translatesAutoresizingMaskIntoConstraints = false
    idLabelView.translatesAutoresizingMaskIntoConstraints = false
    idInputView.translatesAutoresizingMaskIntoConstraints = false
    spacer2View.translatesAutoresizingMaskIntoConstraints = false
    fontNameLabelView.translatesAutoresizingMaskIntoConstraints = false
    fontNameInputView.translatesAutoresizingMaskIntoConstraints = false
    spacer3View.translatesAutoresizingMaskIntoConstraints = false
    fontFamilyLabelView.translatesAutoresizingMaskIntoConstraints = false
    fontFamilyInputView.translatesAutoresizingMaskIntoConstraints = false
    spacer4View.translatesAutoresizingMaskIntoConstraints = false
    fontWeightLabelView.translatesAutoresizingMaskIntoConstraints = false
    fontWeightInputView.translatesAutoresizingMaskIntoConstraints = false
    spacer5View.translatesAutoresizingMaskIntoConstraints = false
    fontSizeLabelView.translatesAutoresizingMaskIntoConstraints = false
    fontSizeInputView.translatesAutoresizingMaskIntoConstraints = false
    spacer6View.translatesAutoresizingMaskIntoConstraints = false
    lineHeightLabelView.translatesAutoresizingMaskIntoConstraints = false
    lineHeightInputView.translatesAutoresizingMaskIntoConstraints = false
    spacer7View.translatesAutoresizingMaskIntoConstraints = false
    letterSpacingLabelView.translatesAutoresizingMaskIntoConstraints = false
    letterSpacingInputView.translatesAutoresizingMaskIntoConstraints = false
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    textTransformLabelView.translatesAutoresizingMaskIntoConstraints = false
    textTransformInputView.translatesAutoresizingMaskIntoConstraints = false
    spacer8View.translatesAutoresizingMaskIntoConstraints = false
    colorLabelView.translatesAutoresizingMaskIntoConstraints = false
    colorInputView.translatesAutoresizingMaskIntoConstraints = false
    spacer9View.translatesAutoresizingMaskIntoConstraints = false
    descriptionLabelView.translatesAutoresizingMaskIntoConstraints = false
    descriptionInputView.translatesAutoresizingMaskIntoConstraints = false

    let fontSizeInputViewLineHeightInputViewHeightAnchorSiblingConstraint = fontSizeInputView
      .heightAnchor
      .constraint(equalTo: lineHeightInputView.heightAnchor)
    let fontSizeInputViewLetterSpacingInputViewHeightAnchorSiblingConstraint = fontSizeInputView
      .heightAnchor
      .constraint(equalTo: letterSpacingInputView.heightAnchor)
    let nameLabelViewTopAnchorConstraint = nameLabelView.topAnchor.constraint(equalTo: topAnchor, constant: 20)
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
    let fontNameLabelViewTopAnchorConstraint = fontNameLabelView.topAnchor.constraint(equalTo: spacer2View.bottomAnchor)
    let fontNameLabelViewLeadingAnchorConstraint = fontNameLabelView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let fontNameLabelViewTrailingAnchorConstraint = fontNameLabelView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let fontNameInputViewTopAnchorConstraint = fontNameInputView
      .topAnchor
      .constraint(equalTo: fontNameLabelView.bottomAnchor, constant: 4)
    let fontNameInputViewLeadingAnchorConstraint = fontNameInputView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let fontNameInputViewTrailingAnchorConstraint = fontNameInputView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let spacer3ViewTopAnchorConstraint = spacer3View.topAnchor.constraint(equalTo: fontNameInputView.bottomAnchor)
    let spacer3ViewLeadingAnchorConstraint = spacer3View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let fontFamilyLabelViewTopAnchorConstraint = fontFamilyLabelView
      .topAnchor
      .constraint(equalTo: spacer3View.bottomAnchor)
    let fontFamilyLabelViewLeadingAnchorConstraint = fontFamilyLabelView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let fontFamilyLabelViewTrailingAnchorConstraint = fontFamilyLabelView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let fontFamilyInputViewTopAnchorConstraint = fontFamilyInputView
      .topAnchor
      .constraint(equalTo: fontFamilyLabelView.bottomAnchor, constant: 4)
    let fontFamilyInputViewLeadingAnchorConstraint = fontFamilyInputView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let fontFamilyInputViewTrailingAnchorConstraint = fontFamilyInputView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let spacer4ViewTopAnchorConstraint = spacer4View.topAnchor.constraint(equalTo: fontFamilyInputView.bottomAnchor)
    let spacer4ViewLeadingAnchorConstraint = spacer4View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let fontWeightLabelViewTopAnchorConstraint = fontWeightLabelView
      .topAnchor
      .constraint(equalTo: spacer4View.bottomAnchor)
    let fontWeightLabelViewLeadingAnchorConstraint = fontWeightLabelView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let fontWeightLabelViewTrailingAnchorConstraint = fontWeightLabelView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let fontWeightInputViewTopAnchorConstraint = fontWeightInputView
      .topAnchor
      .constraint(equalTo: fontWeightLabelView.bottomAnchor, constant: 4)
    let fontWeightInputViewLeadingAnchorConstraint = fontWeightInputView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let fontWeightInputViewTrailingAnchorConstraint = fontWeightInputView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let spacer5ViewTopAnchorConstraint = spacer5View.topAnchor.constraint(equalTo: fontWeightInputView.bottomAnchor)
    let spacer5ViewLeadingAnchorConstraint = spacer5View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let fontSizeLabelViewTopAnchorConstraint = fontSizeLabelView.topAnchor.constraint(equalTo: spacer5View.bottomAnchor)
    let fontSizeLabelViewLeadingAnchorConstraint = fontSizeLabelView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let fontSizeLabelViewTrailingAnchorConstraint = fontSizeLabelView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let fontSizeInputViewTopAnchorConstraint = fontSizeInputView
      .topAnchor
      .constraint(equalTo: fontSizeLabelView.bottomAnchor, constant: 4)
    let fontSizeInputViewLeadingAnchorConstraint = fontSizeInputView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let fontSizeInputViewTrailingAnchorConstraint = fontSizeInputView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let spacer6ViewTopAnchorConstraint = spacer6View.topAnchor.constraint(equalTo: fontSizeInputView.bottomAnchor)
    let spacer6ViewLeadingAnchorConstraint = spacer6View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let lineHeightLabelViewTopAnchorConstraint = lineHeightLabelView
      .topAnchor
      .constraint(equalTo: spacer6View.bottomAnchor)
    let lineHeightLabelViewLeadingAnchorConstraint = lineHeightLabelView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let lineHeightLabelViewTrailingAnchorConstraint = lineHeightLabelView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let lineHeightInputViewTopAnchorConstraint = lineHeightInputView
      .topAnchor
      .constraint(equalTo: lineHeightLabelView.bottomAnchor, constant: 4)
    let lineHeightInputViewLeadingAnchorConstraint = lineHeightInputView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let lineHeightInputViewTrailingAnchorConstraint = lineHeightInputView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let spacer7ViewTopAnchorConstraint = spacer7View.topAnchor.constraint(equalTo: lineHeightInputView.bottomAnchor)
    let spacer7ViewLeadingAnchorConstraint = spacer7View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let letterSpacingLabelViewTopAnchorConstraint = letterSpacingLabelView
      .topAnchor
      .constraint(equalTo: spacer7View.bottomAnchor)
    let letterSpacingLabelViewLeadingAnchorConstraint = letterSpacingLabelView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let letterSpacingLabelViewTrailingAnchorConstraint = letterSpacingLabelView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let letterSpacingInputViewTopAnchorConstraint = letterSpacingInputView
      .topAnchor
      .constraint(equalTo: letterSpacingLabelView.bottomAnchor, constant: 4)
    let letterSpacingInputViewLeadingAnchorConstraint = letterSpacingInputView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let letterSpacingInputViewTrailingAnchorConstraint = letterSpacingInputView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let spacerViewTopAnchorConstraint = spacerView.topAnchor.constraint(equalTo: letterSpacingInputView.bottomAnchor)
    let spacerViewLeadingAnchorConstraint = spacerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let textTransformLabelViewTopAnchorConstraint = textTransformLabelView
      .topAnchor
      .constraint(equalTo: spacerView.bottomAnchor)
    let textTransformLabelViewLeadingAnchorConstraint = textTransformLabelView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let textTransformLabelViewTrailingAnchorConstraint = textTransformLabelView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let textTransformInputViewTopAnchorConstraint = textTransformInputView
      .topAnchor
      .constraint(equalTo: textTransformLabelView.bottomAnchor, constant: 4)
    let textTransformInputViewLeadingAnchorConstraint = textTransformInputView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let textTransformInputViewTrailingAnchorConstraint = textTransformInputView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let spacer8ViewTopAnchorConstraint = spacer8View.topAnchor.constraint(equalTo: textTransformInputView.bottomAnchor)
    let spacer8ViewLeadingAnchorConstraint = spacer8View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let colorLabelViewTopAnchorConstraint = colorLabelView.topAnchor.constraint(equalTo: spacer8View.bottomAnchor)
    let colorLabelViewLeadingAnchorConstraint = colorLabelView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let colorLabelViewTrailingAnchorConstraint = colorLabelView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let colorInputViewTopAnchorConstraint = colorInputView
      .topAnchor
      .constraint(equalTo: colorLabelView.bottomAnchor, constant: 4)
    let colorInputViewLeadingAnchorConstraint = colorInputView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let colorInputViewTrailingAnchorConstraint = colorInputView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let spacer9ViewTopAnchorConstraint = spacer9View.topAnchor.constraint(equalTo: colorInputView.bottomAnchor)
    let spacer9ViewLeadingAnchorConstraint = spacer9View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let descriptionLabelViewTopAnchorConstraint = descriptionLabelView
      .topAnchor
      .constraint(equalTo: spacer9View.bottomAnchor)
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
    let spacer2ViewHeightAnchorConstraint = spacer2View.heightAnchor.constraint(equalToConstant: 20)
    let spacer2ViewWidthAnchorConstraint = spacer2View.widthAnchor.constraint(equalToConstant: 0)
    let spacer3ViewHeightAnchorConstraint = spacer3View.heightAnchor.constraint(equalToConstant: 20)
    let spacer3ViewWidthAnchorConstraint = spacer3View.widthAnchor.constraint(equalToConstant: 0)
    let spacer4ViewHeightAnchorConstraint = spacer4View.heightAnchor.constraint(equalToConstant: 20)
    let spacer4ViewWidthAnchorConstraint = spacer4View.widthAnchor.constraint(equalToConstant: 0)
    let spacer5ViewHeightAnchorConstraint = spacer5View.heightAnchor.constraint(equalToConstant: 20)
    let spacer5ViewWidthAnchorConstraint = spacer5View.widthAnchor.constraint(equalToConstant: 0)
    let spacer6ViewHeightAnchorConstraint = spacer6View.heightAnchor.constraint(equalToConstant: 20)
    let spacer6ViewWidthAnchorConstraint = spacer6View.widthAnchor.constraint(equalToConstant: 0)
    let spacer7ViewHeightAnchorConstraint = spacer7View.heightAnchor.constraint(equalToConstant: 20)
    let spacer7ViewWidthAnchorConstraint = spacer7View.widthAnchor.constraint(equalToConstant: 0)
    let spacerViewHeightAnchorConstraint = spacerView.heightAnchor.constraint(equalToConstant: 20)
    let spacerViewWidthAnchorConstraint = spacerView.widthAnchor.constraint(equalToConstant: 0)
    let spacer8ViewHeightAnchorConstraint = spacer8View.heightAnchor.constraint(equalToConstant: 20)
    let spacer8ViewWidthAnchorConstraint = spacer8View.widthAnchor.constraint(equalToConstant: 0)
    let spacer9ViewHeightAnchorConstraint = spacer9View.heightAnchor.constraint(equalToConstant: 20)
    let spacer9ViewWidthAnchorConstraint = spacer9View.widthAnchor.constraint(equalToConstant: 0)

    NSLayoutConstraint.activate([
      fontSizeInputViewLineHeightInputViewHeightAnchorSiblingConstraint,
      fontSizeInputViewLetterSpacingInputViewHeightAnchorSiblingConstraint,
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
      fontNameLabelViewTopAnchorConstraint,
      fontNameLabelViewLeadingAnchorConstraint,
      fontNameLabelViewTrailingAnchorConstraint,
      fontNameInputViewTopAnchorConstraint,
      fontNameInputViewLeadingAnchorConstraint,
      fontNameInputViewTrailingAnchorConstraint,
      spacer3ViewTopAnchorConstraint,
      spacer3ViewLeadingAnchorConstraint,
      fontFamilyLabelViewTopAnchorConstraint,
      fontFamilyLabelViewLeadingAnchorConstraint,
      fontFamilyLabelViewTrailingAnchorConstraint,
      fontFamilyInputViewTopAnchorConstraint,
      fontFamilyInputViewLeadingAnchorConstraint,
      fontFamilyInputViewTrailingAnchorConstraint,
      spacer4ViewTopAnchorConstraint,
      spacer4ViewLeadingAnchorConstraint,
      fontWeightLabelViewTopAnchorConstraint,
      fontWeightLabelViewLeadingAnchorConstraint,
      fontWeightLabelViewTrailingAnchorConstraint,
      fontWeightInputViewTopAnchorConstraint,
      fontWeightInputViewLeadingAnchorConstraint,
      fontWeightInputViewTrailingAnchorConstraint,
      spacer5ViewTopAnchorConstraint,
      spacer5ViewLeadingAnchorConstraint,
      fontSizeLabelViewTopAnchorConstraint,
      fontSizeLabelViewLeadingAnchorConstraint,
      fontSizeLabelViewTrailingAnchorConstraint,
      fontSizeInputViewTopAnchorConstraint,
      fontSizeInputViewLeadingAnchorConstraint,
      fontSizeInputViewTrailingAnchorConstraint,
      spacer6ViewTopAnchorConstraint,
      spacer6ViewLeadingAnchorConstraint,
      lineHeightLabelViewTopAnchorConstraint,
      lineHeightLabelViewLeadingAnchorConstraint,
      lineHeightLabelViewTrailingAnchorConstraint,
      lineHeightInputViewTopAnchorConstraint,
      lineHeightInputViewLeadingAnchorConstraint,
      lineHeightInputViewTrailingAnchorConstraint,
      spacer7ViewTopAnchorConstraint,
      spacer7ViewLeadingAnchorConstraint,
      letterSpacingLabelViewTopAnchorConstraint,
      letterSpacingLabelViewLeadingAnchorConstraint,
      letterSpacingLabelViewTrailingAnchorConstraint,
      letterSpacingInputViewTopAnchorConstraint,
      letterSpacingInputViewLeadingAnchorConstraint,
      letterSpacingInputViewTrailingAnchorConstraint,
      spacerViewTopAnchorConstraint,
      spacerViewLeadingAnchorConstraint,
      textTransformLabelViewTopAnchorConstraint,
      textTransformLabelViewLeadingAnchorConstraint,
      textTransformLabelViewTrailingAnchorConstraint,
      textTransformInputViewTopAnchorConstraint,
      textTransformInputViewLeadingAnchorConstraint,
      textTransformInputViewTrailingAnchorConstraint,
      spacer8ViewTopAnchorConstraint,
      spacer8ViewLeadingAnchorConstraint,
      colorLabelViewTopAnchorConstraint,
      colorLabelViewLeadingAnchorConstraint,
      colorLabelViewTrailingAnchorConstraint,
      colorInputViewTopAnchorConstraint,
      colorInputViewLeadingAnchorConstraint,
      colorInputViewTrailingAnchorConstraint,
      spacer9ViewTopAnchorConstraint,
      spacer9ViewLeadingAnchorConstraint,
      descriptionLabelViewTopAnchorConstraint,
      descriptionLabelViewLeadingAnchorConstraint,
      descriptionLabelViewTrailingAnchorConstraint,
      descriptionInputViewBottomAnchorConstraint,
      descriptionInputViewTopAnchorConstraint,
      descriptionInputViewLeadingAnchorConstraint,
      descriptionInputViewTrailingAnchorConstraint,
      spacer1ViewHeightAnchorConstraint,
      spacer1ViewWidthAnchorConstraint,
      spacer2ViewHeightAnchorConstraint,
      spacer2ViewWidthAnchorConstraint,
      spacer3ViewHeightAnchorConstraint,
      spacer3ViewWidthAnchorConstraint,
      spacer4ViewHeightAnchorConstraint,
      spacer4ViewWidthAnchorConstraint,
      spacer5ViewHeightAnchorConstraint,
      spacer5ViewWidthAnchorConstraint,
      spacer6ViewHeightAnchorConstraint,
      spacer6ViewWidthAnchorConstraint,
      spacer7ViewHeightAnchorConstraint,
      spacer7ViewWidthAnchorConstraint,
      spacerViewHeightAnchorConstraint,
      spacerViewWidthAnchorConstraint,
      spacer8ViewHeightAnchorConstraint,
      spacer8ViewWidthAnchorConstraint,
      spacer9ViewHeightAnchorConstraint,
      spacer9ViewWidthAnchorConstraint
    ])
  }

  private func update() {
    idInputView.textValue = idText
    nameInputView.textValue = nameText
    fontNameInputView.textValue = fontNameText
    fontFamilyInputView.textValue = fontFamilyText
    fontWeightInputView.textValue = fontWeightText
    fontSizeInputView.numberValue = fontSizeNumber
    lineHeightInputView.numberValue = lineHeightNumber
    letterSpacingInputView.numberValue = letterSpacingNumber
    textTransformInputView.textValue = textTransformText
    colorInputView.textValue = colorValue
    descriptionInputView.textValue = descriptionText
    idInputView.onChangeTextValue = handleOnChangeIdText
    nameInputView.onChangeTextValue = handleOnChangeNameText
    fontNameInputView.onChangeTextValue = handleOnChangeFontNameText
    fontFamilyInputView.onChangeTextValue = handleOnChangeFontFamilyText
    fontWeightInputView.onChangeTextValue = handleOnChangeFontWeightText
    fontSizeInputView.onChangeNumberValue = handleOnChangeFontSizeNumber
    lineHeightInputView.onChangeNumberValue = handleOnChangeLineHeightNumber
    letterSpacingInputView.onChangeNumberValue = handleOnChangeLetterSpacingNumber
    colorInputView.onChangeTextValue = handleOnChangeColorValue
    descriptionInputView.onChangeTextValue = handleOnChangeDescriptionText
    textTransformInputView.onChangeTextValue = handleOnChangeTextTransformText
  }

  private func handleOnChangeIdText(_ arg0: String) {
    onChangeIdText?(arg0)
  }

  private func handleOnChangeNameText(_ arg0: String) {
    onChangeNameText?(arg0)
  }

  private func handleOnChangeFontNameText(_ arg0: String) {
    onChangeFontNameText?(arg0)
  }

  private func handleOnChangeFontFamilyText(_ arg0: String) {
    onChangeFontFamilyText?(arg0)
  }

  private func handleOnChangeFontWeightText(_ arg0: String) {
    onChangeFontWeightText?(arg0)
  }

  private func handleOnChangeFontSizeNumber(_ arg0: CGFloat) {
    onChangeFontSizeNumber?(arg0)
  }

  private func handleOnChangeLineHeightNumber(_ arg0: CGFloat) {
    onChangeLineHeightNumber?(arg0)
  }

  private func handleOnChangeLetterSpacingNumber(_ arg0: CGFloat) {
    onChangeLetterSpacingNumber?(arg0)
  }

  private func handleOnChangeTextTransformText(_ arg0: String) {
    onChangeTextTransformText?(arg0)
  }

  private func handleOnChangeColorValue(_ arg0: String) {
    onChangeColorValue?(arg0)
  }

  private func handleOnChangeDescriptionText(_ arg0: String) {
    onChangeDescriptionText?(arg0)
  }
}

// MARK: - Parameters

extension TextStyleInspector {
  public struct Parameters: Equatable {
    public var idText: String
    public var nameText: String
    public var fontNameText: String
    public var fontFamilyText: String
    public var fontWeightText: String
    public var fontSizeNumber: CGFloat
    public var lineHeightNumber: CGFloat
    public var letterSpacingNumber: CGFloat
    public var textTransformText: String
    public var colorValue: String
    public var descriptionText: String
    public var onChangeIdText: StringHandler
    public var onChangeNameText: StringHandler
    public var onChangeFontNameText: StringHandler
    public var onChangeFontFamilyText: StringHandler
    public var onChangeFontWeightText: StringHandler
    public var onChangeFontSizeNumber: NumberHandler
    public var onChangeLineHeightNumber: NumberHandler
    public var onChangeLetterSpacingNumber: NumberHandler
    public var onChangeTextTransformText: StringHandler
    public var onChangeColorValue: StringHandler
    public var onChangeDescriptionText: StringHandler

    public init(
      idText: String,
      nameText: String,
      fontNameText: String,
      fontFamilyText: String,
      fontWeightText: String,
      fontSizeNumber: CGFloat,
      lineHeightNumber: CGFloat,
      letterSpacingNumber: CGFloat,
      textTransformText: String,
      colorValue: String,
      descriptionText: String,
      onChangeIdText: StringHandler = nil,
      onChangeNameText: StringHandler = nil,
      onChangeFontNameText: StringHandler = nil,
      onChangeFontFamilyText: StringHandler = nil,
      onChangeFontWeightText: StringHandler = nil,
      onChangeFontSizeNumber: NumberHandler = nil,
      onChangeLineHeightNumber: NumberHandler = nil,
      onChangeLetterSpacingNumber: NumberHandler = nil,
      onChangeTextTransformText: StringHandler = nil,
      onChangeColorValue: StringHandler = nil,
      onChangeDescriptionText: StringHandler = nil)
    {
      self.idText = idText
      self.nameText = nameText
      self.fontNameText = fontNameText
      self.fontFamilyText = fontFamilyText
      self.fontWeightText = fontWeightText
      self.fontSizeNumber = fontSizeNumber
      self.lineHeightNumber = lineHeightNumber
      self.letterSpacingNumber = letterSpacingNumber
      self.textTransformText = textTransformText
      self.colorValue = colorValue
      self.descriptionText = descriptionText
      self.onChangeIdText = onChangeIdText
      self.onChangeNameText = onChangeNameText
      self.onChangeFontNameText = onChangeFontNameText
      self.onChangeFontFamilyText = onChangeFontFamilyText
      self.onChangeFontWeightText = onChangeFontWeightText
      self.onChangeFontSizeNumber = onChangeFontSizeNumber
      self.onChangeLineHeightNumber = onChangeLineHeightNumber
      self.onChangeLetterSpacingNumber = onChangeLetterSpacingNumber
      self.onChangeTextTransformText = onChangeTextTransformText
      self.onChangeColorValue = onChangeColorValue
      self.onChangeDescriptionText = onChangeDescriptionText
    }

    public init() {
      self
        .init(
          idText: "",
          nameText: "",
          fontNameText: "",
          fontFamilyText: "",
          fontWeightText: "",
          fontSizeNumber: 0,
          lineHeightNumber: 0,
          letterSpacingNumber: 0,
          textTransformText: "",
          colorValue: "",
          descriptionText: "")
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.idText == rhs.idText &&
        lhs.nameText == rhs.nameText &&
          lhs.fontNameText == rhs.fontNameText &&
            lhs.fontFamilyText == rhs.fontFamilyText &&
              lhs.fontWeightText == rhs.fontWeightText &&
                lhs.fontSizeNumber == rhs.fontSizeNumber &&
                  lhs.lineHeightNumber == rhs.lineHeightNumber &&
                    lhs.letterSpacingNumber == rhs.letterSpacingNumber &&
                      lhs.textTransformText == rhs.textTransformText &&
                        lhs.colorValue == rhs.colorValue && lhs.descriptionText == rhs.descriptionText
    }
  }
}

// MARK: - Model

extension TextStyleInspector {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "TextStyleInspector"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      idText: String,
      nameText: String,
      fontNameText: String,
      fontFamilyText: String,
      fontWeightText: String,
      fontSizeNumber: CGFloat,
      lineHeightNumber: CGFloat,
      letterSpacingNumber: CGFloat,
      textTransformText: String,
      colorValue: String,
      descriptionText: String,
      onChangeIdText: StringHandler = nil,
      onChangeNameText: StringHandler = nil,
      onChangeFontNameText: StringHandler = nil,
      onChangeFontFamilyText: StringHandler = nil,
      onChangeFontWeightText: StringHandler = nil,
      onChangeFontSizeNumber: NumberHandler = nil,
      onChangeLineHeightNumber: NumberHandler = nil,
      onChangeLetterSpacingNumber: NumberHandler = nil,
      onChangeTextTransformText: StringHandler = nil,
      onChangeColorValue: StringHandler = nil,
      onChangeDescriptionText: StringHandler = nil)
    {
      self
        .init(
          Parameters(
            idText: idText,
            nameText: nameText,
            fontNameText: fontNameText,
            fontFamilyText: fontFamilyText,
            fontWeightText: fontWeightText,
            fontSizeNumber: fontSizeNumber,
            lineHeightNumber: lineHeightNumber,
            letterSpacingNumber: letterSpacingNumber,
            textTransformText: textTransformText,
            colorValue: colorValue,
            descriptionText: descriptionText,
            onChangeIdText: onChangeIdText,
            onChangeNameText: onChangeNameText,
            onChangeFontNameText: onChangeFontNameText,
            onChangeFontFamilyText: onChangeFontFamilyText,
            onChangeFontWeightText: onChangeFontWeightText,
            onChangeFontSizeNumber: onChangeFontSizeNumber,
            onChangeLineHeightNumber: onChangeLineHeightNumber,
            onChangeLetterSpacingNumber: onChangeLetterSpacingNumber,
            onChangeTextTransformText: onChangeTextTransformText,
            onChangeColorValue: onChangeColorValue,
            onChangeDescriptionText: onChangeDescriptionText))
    }

    public init() {
      self
        .init(
          idText: "",
          nameText: "",
          fontNameText: "",
          fontFamilyText: "",
          fontWeightText: "",
          fontSizeNumber: 0,
          lineHeightNumber: 0,
          letterSpacingNumber: 0,
          textTransformText: "",
          colorValue: "",
          descriptionText: "")
    }
  }
}
