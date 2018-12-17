import AppKit
import Foundation

// MARK: - DimensionsInspector

public class DimensionsInspector: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(
    isExpanded: Bool,
    widthType: DimensionType,
    widthValue: CGFloat,
    heightType: DimensionType,
    heightValue: CGFloat,
    allowsFitContent: Bool,
    aspectRatioValue: CGFloat)
  {
    self
      .init(
        Parameters(
          isExpanded: isExpanded,
          widthType: widthType,
          widthValue: widthValue,
          heightType: heightType,
          heightValue: heightValue,
          allowsFitContent: allowsFitContent,
          aspectRatioValue: aspectRatioValue))
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

  public var isExpanded: Bool {
    get { return parameters.isExpanded }
    set {
      if parameters.isExpanded != newValue {
        parameters.isExpanded = newValue
      }
    }
  }

  public var onClickHeader: (() -> Void)? {
    get { return parameters.onClickHeader }
    set { parameters.onClickHeader = newValue }
  }

  public var widthType: DimensionType {
    get { return parameters.widthType }
    set {
      if parameters.widthType != newValue {
        parameters.widthType = newValue
      }
    }
  }

  public var widthValue: CGFloat {
    get { return parameters.widthValue }
    set {
      if parameters.widthValue != newValue {
        parameters.widthValue = newValue
      }
    }
  }

  public var heightType: DimensionType {
    get { return parameters.heightType }
    set {
      if parameters.heightType != newValue {
        parameters.heightType = newValue
      }
    }
  }

  public var heightValue: CGFloat {
    get { return parameters.heightValue }
    set {
      if parameters.heightValue != newValue {
        parameters.heightValue = newValue
      }
    }
  }

  public var onChangeWidthTypeIndex: ((Int) -> Void)? {
    get { return parameters.onChangeWidthTypeIndex }
    set { parameters.onChangeWidthTypeIndex = newValue }
  }

  public var onChangeHeightTypeIndex: ((Int) -> Void)? {
    get { return parameters.onChangeHeightTypeIndex }
    set { parameters.onChangeHeightTypeIndex = newValue }
  }

  public var onChangeWidthValue: ((CGFloat) -> Void)? {
    get { return parameters.onChangeWidthValue }
    set { parameters.onChangeWidthValue = newValue }
  }

  public var onChangeHeightValue: ((CGFloat) -> Void)? {
    get { return parameters.onChangeHeightValue }
    set { parameters.onChangeHeightValue = newValue }
  }

  public var allowsFitContent: Bool {
    get { return parameters.allowsFitContent }
    set {
      if parameters.allowsFitContent != newValue {
        parameters.allowsFitContent = newValue
      }
    }
  }

  public var aspectRatioValue: CGFloat {
    get { return parameters.aspectRatioValue }
    set {
      if parameters.aspectRatioValue != newValue {
        parameters.aspectRatioValue = newValue
      }
    }
  }

  public var onChangeAspectRatioValue: ((CGFloat) -> Void)? {
    get { return parameters.onChangeAspectRatioValue }
    set { parameters.onChangeAspectRatioValue = newValue }
  }

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private var inspectorSectionHeaderView = InspectorSectionHeader()
  private var contentContainerView = NSBox()
  private var dimensionsContainerView = NSBox()
  private var widthContainerView = NSBox()
  private var widthLabelView = LNATextField(labelWithString: "")
  private var widthDropdownView = ControlledDropdown()
  private var widthInputContainerView = NSBox()
  private var widthInputView = NumberInput()
  private var hSpacer2View = NSBox()
  private var heightContainerView = NSBox()
  private var heightLabelView = LNATextField(labelWithString: "")
  private var heightDropdownView = ControlledDropdown()
  private var heightInputContainerView = NSBox()
  private var heightInputView = NumberInput()
  private var aspectRatioLabelView = LNATextField(labelWithString: "")
  private var aspectRatioInputView = NumberInput()
  private var hDividerView = NSBox()

  private var widthLabelViewTextStyle = TextStyles.regular
  private var heightLabelViewTextStyle = TextStyles.regular
  private var aspectRatioLabelViewTextStyle = TextStyles.regular

  private var hDividerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint: NSLayoutConstraint?
  private var contentContainerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint: NSLayoutConstraint?
  private var contentContainerViewLeadingAnchorLeadingAnchorConstraint: NSLayoutConstraint?
  private var contentContainerViewTrailingAnchorTrailingAnchorConstraint: NSLayoutConstraint?
  private var hDividerViewTopAnchorContentContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var dimensionsContainerViewTopAnchorContentContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var dimensionsContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var dimensionsContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var aspectRatioLabelViewTopAnchorDimensionsContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var aspectRatioLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var aspectRatioLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var aspectRatioInputViewBottomAnchorContentContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var aspectRatioInputViewTopAnchorAspectRatioLabelViewBottomAnchorConstraint: NSLayoutConstraint?
  private var aspectRatioInputViewLeadingAnchorContentContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var aspectRatioInputViewTrailingAnchorContentContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var widthContainerViewHeightContainerViewWidthAnchorSiblingConstraint: NSLayoutConstraint?
  private var widthContainerViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var hSpacer2ViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var heightContainerViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var widthContainerViewLeadingAnchorDimensionsContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var widthContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var hSpacer2ViewLeadingAnchorWidthContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var hSpacer2ViewTopAnchorDimensionsContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var heightContainerViewTrailingAnchorDimensionsContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var heightContainerViewLeadingAnchorHSpacer2ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var heightContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var widthContainerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var widthLabelViewTopAnchorWidthContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var widthLabelViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var widthLabelViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var widthDropdownViewTopAnchorWidthLabelViewBottomAnchorConstraint: NSLayoutConstraint?
  private var widthDropdownViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var widthDropdownViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var hSpacer2ViewHeightAnchorConstraint: NSLayoutConstraint?
  private var hSpacer2ViewWidthAnchorConstraint: NSLayoutConstraint?
  private var heightContainerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var heightLabelViewTopAnchorHeightContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var heightLabelViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var heightLabelViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var heightDropdownViewTopAnchorHeightLabelViewBottomAnchorConstraint: NSLayoutConstraint?
  private var heightDropdownViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var heightDropdownViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var widthInputContainerViewTopAnchorWidthDropdownViewBottomAnchorConstraint: NSLayoutConstraint?
  private var widthInputContainerViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var widthInputContainerViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var widthInputViewTopAnchorWidthInputContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var widthInputViewBottomAnchorWidthInputContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var widthInputViewLeadingAnchorWidthInputContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var widthInputViewTrailingAnchorWidthInputContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var heightInputContainerViewTopAnchorHeightDropdownViewBottomAnchorConstraint: NSLayoutConstraint?
  private var heightInputContainerViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var heightInputContainerViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var heightInputViewTopAnchorHeightInputContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var heightInputViewBottomAnchorHeightInputContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var heightInputViewLeadingAnchorHeightInputContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var heightInputViewTrailingAnchorHeightInputContainerViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    contentContainerView.boxType = .custom
    contentContainerView.borderType = .noBorder
    contentContainerView.contentViewMargins = .zero
    hDividerView.boxType = .custom
    hDividerView.borderType = .noBorder
    hDividerView.contentViewMargins = .zero
    dimensionsContainerView.boxType = .custom
    dimensionsContainerView.borderType = .noBorder
    dimensionsContainerView.contentViewMargins = .zero
    aspectRatioLabelView.lineBreakMode = .byWordWrapping
    widthContainerView.boxType = .custom
    widthContainerView.borderType = .noBorder
    widthContainerView.contentViewMargins = .zero
    hSpacer2View.boxType = .custom
    hSpacer2View.borderType = .noBorder
    hSpacer2View.contentViewMargins = .zero
    heightContainerView.boxType = .custom
    heightContainerView.borderType = .noBorder
    heightContainerView.contentViewMargins = .zero
    widthLabelView.lineBreakMode = .byWordWrapping
    widthInputContainerView.boxType = .custom
    widthInputContainerView.borderType = .noBorder
    widthInputContainerView.contentViewMargins = .zero
    heightLabelView.lineBreakMode = .byWordWrapping
    heightInputContainerView.boxType = .custom
    heightInputContainerView.borderType = .noBorder
    heightInputContainerView.contentViewMargins = .zero

    addSubview(inspectorSectionHeaderView)
    addSubview(contentContainerView)
    addSubview(hDividerView)
    contentContainerView.addSubview(dimensionsContainerView)
    contentContainerView.addSubview(aspectRatioLabelView)
    contentContainerView.addSubview(aspectRatioInputView)
    dimensionsContainerView.addSubview(widthContainerView)
    dimensionsContainerView.addSubview(hSpacer2View)
    dimensionsContainerView.addSubview(heightContainerView)
    widthContainerView.addSubview(widthLabelView)
    widthContainerView.addSubview(widthDropdownView)
    widthContainerView.addSubview(widthInputContainerView)
    widthInputContainerView.addSubview(widthInputView)
    heightContainerView.addSubview(heightLabelView)
    heightContainerView.addSubview(heightDropdownView)
    heightContainerView.addSubview(heightInputContainerView)
    heightInputContainerView.addSubview(heightInputView)

    inspectorSectionHeaderView.titleText = "Dimensions"
    widthLabelView.attributedStringValue = widthLabelViewTextStyle.apply(to: "Width")
    widthLabelViewTextStyle = TextStyles.regular
    widthLabelView.attributedStringValue = widthLabelViewTextStyle.apply(to: widthLabelView.attributedStringValue)
    widthInputContainerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    hSpacer2View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    heightLabelView.attributedStringValue = heightLabelViewTextStyle.apply(to: "Height")
    heightInputContainerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    aspectRatioLabelView.attributedStringValue = aspectRatioLabelViewTextStyle.apply(to: "Aspect Ratio")
    hDividerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    inspectorSectionHeaderView.translatesAutoresizingMaskIntoConstraints = false
    contentContainerView.translatesAutoresizingMaskIntoConstraints = false
    hDividerView.translatesAutoresizingMaskIntoConstraints = false
    dimensionsContainerView.translatesAutoresizingMaskIntoConstraints = false
    aspectRatioLabelView.translatesAutoresizingMaskIntoConstraints = false
    aspectRatioInputView.translatesAutoresizingMaskIntoConstraints = false
    widthContainerView.translatesAutoresizingMaskIntoConstraints = false
    hSpacer2View.translatesAutoresizingMaskIntoConstraints = false
    heightContainerView.translatesAutoresizingMaskIntoConstraints = false
    widthLabelView.translatesAutoresizingMaskIntoConstraints = false
    widthDropdownView.translatesAutoresizingMaskIntoConstraints = false
    widthInputContainerView.translatesAutoresizingMaskIntoConstraints = false
    widthInputView.translatesAutoresizingMaskIntoConstraints = false
    heightLabelView.translatesAutoresizingMaskIntoConstraints = false
    heightDropdownView.translatesAutoresizingMaskIntoConstraints = false
    heightInputContainerView.translatesAutoresizingMaskIntoConstraints = false
    heightInputView.translatesAutoresizingMaskIntoConstraints = false

    let inspectorSectionHeaderViewTopAnchorConstraint = inspectorSectionHeaderView
      .topAnchor
      .constraint(equalTo: topAnchor)
    let inspectorSectionHeaderViewLeadingAnchorConstraint = inspectorSectionHeaderView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let inspectorSectionHeaderViewTrailingAnchorConstraint = inspectorSectionHeaderView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let hDividerViewBottomAnchorConstraint = hDividerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let hDividerViewLeadingAnchorConstraint = hDividerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let hDividerViewTrailingAnchorConstraint = hDividerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let hDividerViewHeightAnchorConstraint = hDividerView.heightAnchor.constraint(equalToConstant: 1)
    let hDividerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint = hDividerView
      .topAnchor
      .constraint(equalTo: inspectorSectionHeaderView.bottomAnchor)
    let contentContainerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint = contentContainerView
      .topAnchor
      .constraint(equalTo: inspectorSectionHeaderView.bottomAnchor)
    let contentContainerViewLeadingAnchorLeadingAnchorConstraint = contentContainerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let contentContainerViewTrailingAnchorTrailingAnchorConstraint = contentContainerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let hDividerViewTopAnchorContentContainerViewBottomAnchorConstraint = hDividerView
      .topAnchor
      .constraint(equalTo: contentContainerView.bottomAnchor)
    let dimensionsContainerViewTopAnchorContentContainerViewTopAnchorConstraint = dimensionsContainerView
      .topAnchor
      .constraint(equalTo: contentContainerView.topAnchor)
    let dimensionsContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint = dimensionsContainerView
      .leadingAnchor
      .constraint(equalTo: contentContainerView.leadingAnchor)
    let dimensionsContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint = dimensionsContainerView
      .trailingAnchor
      .constraint(equalTo: contentContainerView.trailingAnchor)
    let aspectRatioLabelViewTopAnchorDimensionsContainerViewBottomAnchorConstraint = aspectRatioLabelView
      .topAnchor
      .constraint(equalTo: dimensionsContainerView.bottomAnchor, constant: 16)
    let aspectRatioLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint = aspectRatioLabelView
      .leadingAnchor
      .constraint(equalTo: contentContainerView.leadingAnchor)
    let aspectRatioLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint = aspectRatioLabelView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: contentContainerView.trailingAnchor)
    let aspectRatioInputViewBottomAnchorContentContainerViewBottomAnchorConstraint = aspectRatioInputView
      .bottomAnchor
      .constraint(equalTo: contentContainerView.bottomAnchor, constant: -16)
    let aspectRatioInputViewTopAnchorAspectRatioLabelViewBottomAnchorConstraint = aspectRatioInputView
      .topAnchor
      .constraint(equalTo: aspectRatioLabelView.bottomAnchor, constant: 8)
    let aspectRatioInputViewLeadingAnchorContentContainerViewLeadingAnchorConstraint = aspectRatioInputView
      .leadingAnchor
      .constraint(equalTo: contentContainerView.leadingAnchor)
    let aspectRatioInputViewTrailingAnchorContentContainerViewTrailingAnchorConstraint = aspectRatioInputView
      .trailingAnchor
      .constraint(equalTo: contentContainerView.trailingAnchor)
    let widthContainerViewHeightContainerViewWidthAnchorSiblingConstraint = widthContainerView
      .widthAnchor
      .constraint(equalTo: heightContainerView.widthAnchor)
    let widthContainerViewHeightAnchorParentConstraint = widthContainerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: dimensionsContainerView.heightAnchor)
    let hSpacer2ViewHeightAnchorParentConstraint = hSpacer2View
      .heightAnchor
      .constraint(lessThanOrEqualTo: dimensionsContainerView.heightAnchor)
    let heightContainerViewHeightAnchorParentConstraint = heightContainerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: dimensionsContainerView.heightAnchor)
    let widthContainerViewLeadingAnchorDimensionsContainerViewLeadingAnchorConstraint = widthContainerView
      .leadingAnchor
      .constraint(equalTo: dimensionsContainerView.leadingAnchor)
    let widthContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint = widthContainerView
      .topAnchor
      .constraint(equalTo: dimensionsContainerView.topAnchor)
    let hSpacer2ViewLeadingAnchorWidthContainerViewTrailingAnchorConstraint = hSpacer2View
      .leadingAnchor
      .constraint(equalTo: widthContainerView.trailingAnchor)
    let hSpacer2ViewTopAnchorDimensionsContainerViewTopAnchorConstraint = hSpacer2View
      .topAnchor
      .constraint(equalTo: dimensionsContainerView.topAnchor)
    let heightContainerViewTrailingAnchorDimensionsContainerViewTrailingAnchorConstraint = heightContainerView
      .trailingAnchor
      .constraint(equalTo: dimensionsContainerView.trailingAnchor)
    let heightContainerViewLeadingAnchorHSpacer2ViewTrailingAnchorConstraint = heightContainerView
      .leadingAnchor
      .constraint(equalTo: hSpacer2View.trailingAnchor)
    let heightContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint = heightContainerView
      .topAnchor
      .constraint(equalTo: dimensionsContainerView.topAnchor)
    let widthContainerViewHeightAnchorConstraint = widthContainerView.heightAnchor.constraint(equalToConstant: 80)
    let widthLabelViewTopAnchorWidthContainerViewTopAnchorConstraint = widthLabelView
      .topAnchor
      .constraint(equalTo: widthContainerView.topAnchor)
    let widthLabelViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint = widthLabelView
      .leadingAnchor
      .constraint(equalTo: widthContainerView.leadingAnchor)
    let widthLabelViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint = widthLabelView
      .trailingAnchor
      .constraint(equalTo: widthContainerView.trailingAnchor)
    let widthDropdownViewTopAnchorWidthLabelViewBottomAnchorConstraint = widthDropdownView
      .topAnchor
      .constraint(equalTo: widthLabelView.bottomAnchor, constant: 8)
    let widthDropdownViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint = widthDropdownView
      .leadingAnchor
      .constraint(equalTo: widthContainerView.leadingAnchor)
    let widthDropdownViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint = widthDropdownView
      .trailingAnchor
      .constraint(equalTo: widthContainerView.trailingAnchor)
    let hSpacer2ViewHeightAnchorConstraint = hSpacer2View.heightAnchor.constraint(equalToConstant: 0)
    let hSpacer2ViewWidthAnchorConstraint = hSpacer2View.widthAnchor.constraint(equalToConstant: 20)
    let heightContainerViewHeightAnchorConstraint = heightContainerView.heightAnchor.constraint(equalToConstant: 80)
    let heightLabelViewTopAnchorHeightContainerViewTopAnchorConstraint = heightLabelView
      .topAnchor
      .constraint(equalTo: heightContainerView.topAnchor)
    let heightLabelViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint = heightLabelView
      .leadingAnchor
      .constraint(equalTo: heightContainerView.leadingAnchor)
    let heightLabelViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint = heightLabelView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: heightContainerView.trailingAnchor)
    let heightDropdownViewTopAnchorHeightLabelViewBottomAnchorConstraint = heightDropdownView
      .topAnchor
      .constraint(equalTo: heightLabelView.bottomAnchor, constant: 8)
    let heightDropdownViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint = heightDropdownView
      .leadingAnchor
      .constraint(equalTo: heightContainerView.leadingAnchor)
    let heightDropdownViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint = heightDropdownView
      .trailingAnchor
      .constraint(equalTo: heightContainerView.trailingAnchor)
    let widthInputContainerViewTopAnchorWidthDropdownViewBottomAnchorConstraint = widthInputContainerView
      .topAnchor
      .constraint(equalTo: widthDropdownView.bottomAnchor, constant: 8)
    let widthInputContainerViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint = widthInputContainerView
      .leadingAnchor
      .constraint(equalTo: widthContainerView.leadingAnchor)
    let widthInputContainerViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint = widthInputContainerView
      .trailingAnchor
      .constraint(equalTo: widthContainerView.trailingAnchor)
    let widthInputViewTopAnchorWidthInputContainerViewTopAnchorConstraint = widthInputView
      .topAnchor
      .constraint(equalTo: widthInputContainerView.topAnchor)
    let widthInputViewBottomAnchorWidthInputContainerViewBottomAnchorConstraint = widthInputView
      .bottomAnchor
      .constraint(equalTo: widthInputContainerView.bottomAnchor)
    let widthInputViewLeadingAnchorWidthInputContainerViewLeadingAnchorConstraint = widthInputView
      .leadingAnchor
      .constraint(equalTo: widthInputContainerView.leadingAnchor)
    let widthInputViewTrailingAnchorWidthInputContainerViewTrailingAnchorConstraint = widthInputView
      .trailingAnchor
      .constraint(equalTo: widthInputContainerView.trailingAnchor)
    let heightInputContainerViewTopAnchorHeightDropdownViewBottomAnchorConstraint = heightInputContainerView
      .topAnchor
      .constraint(equalTo: heightDropdownView.bottomAnchor, constant: 8)
    let heightInputContainerViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint = heightInputContainerView
      .leadingAnchor
      .constraint(equalTo: heightContainerView.leadingAnchor)
    let heightInputContainerViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint = heightInputContainerView
      .trailingAnchor
      .constraint(equalTo: heightContainerView.trailingAnchor)
    let heightInputViewTopAnchorHeightInputContainerViewTopAnchorConstraint = heightInputView
      .topAnchor
      .constraint(equalTo: heightInputContainerView.topAnchor)
    let heightInputViewBottomAnchorHeightInputContainerViewBottomAnchorConstraint = heightInputView
      .bottomAnchor
      .constraint(equalTo: heightInputContainerView.bottomAnchor)
    let heightInputViewLeadingAnchorHeightInputContainerViewLeadingAnchorConstraint = heightInputView
      .leadingAnchor
      .constraint(equalTo: heightInputContainerView.leadingAnchor)
    let heightInputViewTrailingAnchorHeightInputContainerViewTrailingAnchorConstraint = heightInputView
      .trailingAnchor
      .constraint(equalTo: heightInputContainerView.trailingAnchor)

    widthContainerViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    hSpacer2ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    heightContainerViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    self.hDividerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint =
      hDividerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint
    self.contentContainerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint =
      contentContainerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint
    self.contentContainerViewLeadingAnchorLeadingAnchorConstraint =
      contentContainerViewLeadingAnchorLeadingAnchorConstraint
    self.contentContainerViewTrailingAnchorTrailingAnchorConstraint =
      contentContainerViewTrailingAnchorTrailingAnchorConstraint
    self.hDividerViewTopAnchorContentContainerViewBottomAnchorConstraint =
      hDividerViewTopAnchorContentContainerViewBottomAnchorConstraint
    self.dimensionsContainerViewTopAnchorContentContainerViewTopAnchorConstraint =
      dimensionsContainerViewTopAnchorContentContainerViewTopAnchorConstraint
    self.dimensionsContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint =
      dimensionsContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint
    self.dimensionsContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint =
      dimensionsContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint
    self.aspectRatioLabelViewTopAnchorDimensionsContainerViewBottomAnchorConstraint =
      aspectRatioLabelViewTopAnchorDimensionsContainerViewBottomAnchorConstraint
    self.aspectRatioLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint =
      aspectRatioLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint
    self.aspectRatioLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint =
      aspectRatioLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint
    self.aspectRatioInputViewBottomAnchorContentContainerViewBottomAnchorConstraint =
      aspectRatioInputViewBottomAnchorContentContainerViewBottomAnchorConstraint
    self.aspectRatioInputViewTopAnchorAspectRatioLabelViewBottomAnchorConstraint =
      aspectRatioInputViewTopAnchorAspectRatioLabelViewBottomAnchorConstraint
    self.aspectRatioInputViewLeadingAnchorContentContainerViewLeadingAnchorConstraint =
      aspectRatioInputViewLeadingAnchorContentContainerViewLeadingAnchorConstraint
    self.aspectRatioInputViewTrailingAnchorContentContainerViewTrailingAnchorConstraint =
      aspectRatioInputViewTrailingAnchorContentContainerViewTrailingAnchorConstraint
    self.widthContainerViewHeightContainerViewWidthAnchorSiblingConstraint =
      widthContainerViewHeightContainerViewWidthAnchorSiblingConstraint
    self.widthContainerViewHeightAnchorParentConstraint = widthContainerViewHeightAnchorParentConstraint
    self.hSpacer2ViewHeightAnchorParentConstraint = hSpacer2ViewHeightAnchorParentConstraint
    self.heightContainerViewHeightAnchorParentConstraint = heightContainerViewHeightAnchorParentConstraint
    self.widthContainerViewLeadingAnchorDimensionsContainerViewLeadingAnchorConstraint =
      widthContainerViewLeadingAnchorDimensionsContainerViewLeadingAnchorConstraint
    self.widthContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint =
      widthContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint
    self.hSpacer2ViewLeadingAnchorWidthContainerViewTrailingAnchorConstraint =
      hSpacer2ViewLeadingAnchorWidthContainerViewTrailingAnchorConstraint
    self.hSpacer2ViewTopAnchorDimensionsContainerViewTopAnchorConstraint =
      hSpacer2ViewTopAnchorDimensionsContainerViewTopAnchorConstraint
    self.heightContainerViewTrailingAnchorDimensionsContainerViewTrailingAnchorConstraint =
      heightContainerViewTrailingAnchorDimensionsContainerViewTrailingAnchorConstraint
    self.heightContainerViewLeadingAnchorHSpacer2ViewTrailingAnchorConstraint =
      heightContainerViewLeadingAnchorHSpacer2ViewTrailingAnchorConstraint
    self.heightContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint =
      heightContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint
    self.widthContainerViewHeightAnchorConstraint = widthContainerViewHeightAnchorConstraint
    self.widthLabelViewTopAnchorWidthContainerViewTopAnchorConstraint =
      widthLabelViewTopAnchorWidthContainerViewTopAnchorConstraint
    self.widthLabelViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint =
      widthLabelViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint
    self.widthLabelViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint =
      widthLabelViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint
    self.widthDropdownViewTopAnchorWidthLabelViewBottomAnchorConstraint =
      widthDropdownViewTopAnchorWidthLabelViewBottomAnchorConstraint
    self.widthDropdownViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint =
      widthDropdownViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint
    self.widthDropdownViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint =
      widthDropdownViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint
    self.hSpacer2ViewHeightAnchorConstraint = hSpacer2ViewHeightAnchorConstraint
    self.hSpacer2ViewWidthAnchorConstraint = hSpacer2ViewWidthAnchorConstraint
    self.heightContainerViewHeightAnchorConstraint = heightContainerViewHeightAnchorConstraint
    self.heightLabelViewTopAnchorHeightContainerViewTopAnchorConstraint =
      heightLabelViewTopAnchorHeightContainerViewTopAnchorConstraint
    self.heightLabelViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint =
      heightLabelViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint
    self.heightLabelViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint =
      heightLabelViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint
    self.heightDropdownViewTopAnchorHeightLabelViewBottomAnchorConstraint =
      heightDropdownViewTopAnchorHeightLabelViewBottomAnchorConstraint
    self.heightDropdownViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint =
      heightDropdownViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint
    self.heightDropdownViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint =
      heightDropdownViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint
    self.widthInputContainerViewTopAnchorWidthDropdownViewBottomAnchorConstraint =
      widthInputContainerViewTopAnchorWidthDropdownViewBottomAnchorConstraint
    self.widthInputContainerViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint =
      widthInputContainerViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint
    self.widthInputContainerViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint =
      widthInputContainerViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint
    self.widthInputViewTopAnchorWidthInputContainerViewTopAnchorConstraint =
      widthInputViewTopAnchorWidthInputContainerViewTopAnchorConstraint
    self.widthInputViewBottomAnchorWidthInputContainerViewBottomAnchorConstraint =
      widthInputViewBottomAnchorWidthInputContainerViewBottomAnchorConstraint
    self.widthInputViewLeadingAnchorWidthInputContainerViewLeadingAnchorConstraint =
      widthInputViewLeadingAnchorWidthInputContainerViewLeadingAnchorConstraint
    self.widthInputViewTrailingAnchorWidthInputContainerViewTrailingAnchorConstraint =
      widthInputViewTrailingAnchorWidthInputContainerViewTrailingAnchorConstraint
    self.heightInputContainerViewTopAnchorHeightDropdownViewBottomAnchorConstraint =
      heightInputContainerViewTopAnchorHeightDropdownViewBottomAnchorConstraint
    self.heightInputContainerViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint =
      heightInputContainerViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint
    self.heightInputContainerViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint =
      heightInputContainerViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint
    self.heightInputViewTopAnchorHeightInputContainerViewTopAnchorConstraint =
      heightInputViewTopAnchorHeightInputContainerViewTopAnchorConstraint
    self.heightInputViewBottomAnchorHeightInputContainerViewBottomAnchorConstraint =
      heightInputViewBottomAnchorHeightInputContainerViewBottomAnchorConstraint
    self.heightInputViewLeadingAnchorHeightInputContainerViewLeadingAnchorConstraint =
      heightInputViewLeadingAnchorHeightInputContainerViewLeadingAnchorConstraint
    self.heightInputViewTrailingAnchorHeightInputContainerViewTrailingAnchorConstraint =
      heightInputViewTrailingAnchorHeightInputContainerViewTrailingAnchorConstraint

    NSLayoutConstraint.activate(
      [
        inspectorSectionHeaderViewTopAnchorConstraint,
        inspectorSectionHeaderViewLeadingAnchorConstraint,
        inspectorSectionHeaderViewTrailingAnchorConstraint,
        hDividerViewBottomAnchorConstraint,
        hDividerViewLeadingAnchorConstraint,
        hDividerViewTrailingAnchorConstraint,
        hDividerViewHeightAnchorConstraint
      ] +
        conditionalConstraints(
          contentContainerViewIsHidden: contentContainerView.isHidden,
          heightInputContainerViewIsHidden: heightInputContainerView.isHidden,
          widthInputContainerViewIsHidden: widthInputContainerView.isHidden))
  }

  private func conditionalConstraints(
    contentContainerViewIsHidden: Bool,
    heightInputContainerViewIsHidden: Bool,
    widthInputContainerViewIsHidden: Bool) -> [NSLayoutConstraint]
  {
    var constraints: [NSLayoutConstraint?]

    switch (contentContainerViewIsHidden, heightInputContainerViewIsHidden, widthInputContainerViewIsHidden) {
      case (true, true, true):
        constraints = [hDividerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint]
      case (false, true, true):
        constraints = [
          contentContainerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint,
          contentContainerViewLeadingAnchorLeadingAnchorConstraint,
          contentContainerViewTrailingAnchorTrailingAnchorConstraint,
          hDividerViewTopAnchorContentContainerViewBottomAnchorConstraint,
          dimensionsContainerViewTopAnchorContentContainerViewTopAnchorConstraint,
          dimensionsContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          dimensionsContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          aspectRatioLabelViewTopAnchorDimensionsContainerViewBottomAnchorConstraint,
          aspectRatioLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          aspectRatioLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          aspectRatioInputViewBottomAnchorContentContainerViewBottomAnchorConstraint,
          aspectRatioInputViewTopAnchorAspectRatioLabelViewBottomAnchorConstraint,
          aspectRatioInputViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          aspectRatioInputViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          widthContainerViewHeightContainerViewWidthAnchorSiblingConstraint,
          widthContainerViewHeightAnchorParentConstraint,
          hSpacer2ViewHeightAnchorParentConstraint,
          heightContainerViewHeightAnchorParentConstraint,
          widthContainerViewLeadingAnchorDimensionsContainerViewLeadingAnchorConstraint,
          widthContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint,
          hSpacer2ViewLeadingAnchorWidthContainerViewTrailingAnchorConstraint,
          hSpacer2ViewTopAnchorDimensionsContainerViewTopAnchorConstraint,
          heightContainerViewTrailingAnchorDimensionsContainerViewTrailingAnchorConstraint,
          heightContainerViewLeadingAnchorHSpacer2ViewTrailingAnchorConstraint,
          heightContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint,
          widthContainerViewHeightAnchorConstraint,
          widthLabelViewTopAnchorWidthContainerViewTopAnchorConstraint,
          widthLabelViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint,
          widthLabelViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint,
          widthDropdownViewTopAnchorWidthLabelViewBottomAnchorConstraint,
          widthDropdownViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint,
          widthDropdownViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint,
          hSpacer2ViewHeightAnchorConstraint,
          hSpacer2ViewWidthAnchorConstraint,
          heightContainerViewHeightAnchorConstraint,
          heightLabelViewTopAnchorHeightContainerViewTopAnchorConstraint,
          heightLabelViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint,
          heightLabelViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint,
          heightDropdownViewTopAnchorHeightLabelViewBottomAnchorConstraint,
          heightDropdownViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint,
          heightDropdownViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint
        ]
      case (true, false, true):
        constraints = [hDividerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint]
      case (true, true, false):
        constraints = [hDividerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint]
      case (false, true, false):
        constraints = [
          contentContainerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint,
          contentContainerViewLeadingAnchorLeadingAnchorConstraint,
          contentContainerViewTrailingAnchorTrailingAnchorConstraint,
          hDividerViewTopAnchorContentContainerViewBottomAnchorConstraint,
          dimensionsContainerViewTopAnchorContentContainerViewTopAnchorConstraint,
          dimensionsContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          dimensionsContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          aspectRatioLabelViewTopAnchorDimensionsContainerViewBottomAnchorConstraint,
          aspectRatioLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          aspectRatioLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          aspectRatioInputViewBottomAnchorContentContainerViewBottomAnchorConstraint,
          aspectRatioInputViewTopAnchorAspectRatioLabelViewBottomAnchorConstraint,
          aspectRatioInputViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          aspectRatioInputViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          widthContainerViewHeightContainerViewWidthAnchorSiblingConstraint,
          widthContainerViewHeightAnchorParentConstraint,
          hSpacer2ViewHeightAnchorParentConstraint,
          heightContainerViewHeightAnchorParentConstraint,
          widthContainerViewLeadingAnchorDimensionsContainerViewLeadingAnchorConstraint,
          widthContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint,
          hSpacer2ViewLeadingAnchorWidthContainerViewTrailingAnchorConstraint,
          hSpacer2ViewTopAnchorDimensionsContainerViewTopAnchorConstraint,
          heightContainerViewTrailingAnchorDimensionsContainerViewTrailingAnchorConstraint,
          heightContainerViewLeadingAnchorHSpacer2ViewTrailingAnchorConstraint,
          heightContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint,
          widthContainerViewHeightAnchorConstraint,
          widthLabelViewTopAnchorWidthContainerViewTopAnchorConstraint,
          widthLabelViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint,
          widthLabelViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint,
          widthDropdownViewTopAnchorWidthLabelViewBottomAnchorConstraint,
          widthDropdownViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint,
          widthDropdownViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint,
          widthInputContainerViewTopAnchorWidthDropdownViewBottomAnchorConstraint,
          widthInputContainerViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint,
          widthInputContainerViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint,
          hSpacer2ViewHeightAnchorConstraint,
          hSpacer2ViewWidthAnchorConstraint,
          heightContainerViewHeightAnchorConstraint,
          heightLabelViewTopAnchorHeightContainerViewTopAnchorConstraint,
          heightLabelViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint,
          heightLabelViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint,
          heightDropdownViewTopAnchorHeightLabelViewBottomAnchorConstraint,
          heightDropdownViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint,
          heightDropdownViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint,
          widthInputViewTopAnchorWidthInputContainerViewTopAnchorConstraint,
          widthInputViewBottomAnchorWidthInputContainerViewBottomAnchorConstraint,
          widthInputViewLeadingAnchorWidthInputContainerViewLeadingAnchorConstraint,
          widthInputViewTrailingAnchorWidthInputContainerViewTrailingAnchorConstraint
        ]
      case (false, false, true):
        constraints = [
          contentContainerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint,
          contentContainerViewLeadingAnchorLeadingAnchorConstraint,
          contentContainerViewTrailingAnchorTrailingAnchorConstraint,
          hDividerViewTopAnchorContentContainerViewBottomAnchorConstraint,
          dimensionsContainerViewTopAnchorContentContainerViewTopAnchorConstraint,
          dimensionsContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          dimensionsContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          aspectRatioLabelViewTopAnchorDimensionsContainerViewBottomAnchorConstraint,
          aspectRatioLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          aspectRatioLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          aspectRatioInputViewBottomAnchorContentContainerViewBottomAnchorConstraint,
          aspectRatioInputViewTopAnchorAspectRatioLabelViewBottomAnchorConstraint,
          aspectRatioInputViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          aspectRatioInputViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          widthContainerViewHeightContainerViewWidthAnchorSiblingConstraint,
          widthContainerViewHeightAnchorParentConstraint,
          hSpacer2ViewHeightAnchorParentConstraint,
          heightContainerViewHeightAnchorParentConstraint,
          widthContainerViewLeadingAnchorDimensionsContainerViewLeadingAnchorConstraint,
          widthContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint,
          hSpacer2ViewLeadingAnchorWidthContainerViewTrailingAnchorConstraint,
          hSpacer2ViewTopAnchorDimensionsContainerViewTopAnchorConstraint,
          heightContainerViewTrailingAnchorDimensionsContainerViewTrailingAnchorConstraint,
          heightContainerViewLeadingAnchorHSpacer2ViewTrailingAnchorConstraint,
          heightContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint,
          widthContainerViewHeightAnchorConstraint,
          widthLabelViewTopAnchorWidthContainerViewTopAnchorConstraint,
          widthLabelViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint,
          widthLabelViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint,
          widthDropdownViewTopAnchorWidthLabelViewBottomAnchorConstraint,
          widthDropdownViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint,
          widthDropdownViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint,
          hSpacer2ViewHeightAnchorConstraint,
          hSpacer2ViewWidthAnchorConstraint,
          heightContainerViewHeightAnchorConstraint,
          heightLabelViewTopAnchorHeightContainerViewTopAnchorConstraint,
          heightLabelViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint,
          heightLabelViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint,
          heightDropdownViewTopAnchorHeightLabelViewBottomAnchorConstraint,
          heightDropdownViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint,
          heightDropdownViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint,
          heightInputContainerViewTopAnchorHeightDropdownViewBottomAnchorConstraint,
          heightInputContainerViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint,
          heightInputContainerViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint,
          heightInputViewTopAnchorHeightInputContainerViewTopAnchorConstraint,
          heightInputViewBottomAnchorHeightInputContainerViewBottomAnchorConstraint,
          heightInputViewLeadingAnchorHeightInputContainerViewLeadingAnchorConstraint,
          heightInputViewTrailingAnchorHeightInputContainerViewTrailingAnchorConstraint
        ]
      case (true, false, false):
        constraints = [hDividerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint]
      case (false, false, false):
        constraints = [
          contentContainerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint,
          contentContainerViewLeadingAnchorLeadingAnchorConstraint,
          contentContainerViewTrailingAnchorTrailingAnchorConstraint,
          hDividerViewTopAnchorContentContainerViewBottomAnchorConstraint,
          dimensionsContainerViewTopAnchorContentContainerViewTopAnchorConstraint,
          dimensionsContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          dimensionsContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          aspectRatioLabelViewTopAnchorDimensionsContainerViewBottomAnchorConstraint,
          aspectRatioLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          aspectRatioLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          aspectRatioInputViewBottomAnchorContentContainerViewBottomAnchorConstraint,
          aspectRatioInputViewTopAnchorAspectRatioLabelViewBottomAnchorConstraint,
          aspectRatioInputViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          aspectRatioInputViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          widthContainerViewHeightContainerViewWidthAnchorSiblingConstraint,
          widthContainerViewHeightAnchorParentConstraint,
          hSpacer2ViewHeightAnchorParentConstraint,
          heightContainerViewHeightAnchorParentConstraint,
          widthContainerViewLeadingAnchorDimensionsContainerViewLeadingAnchorConstraint,
          widthContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint,
          hSpacer2ViewLeadingAnchorWidthContainerViewTrailingAnchorConstraint,
          hSpacer2ViewTopAnchorDimensionsContainerViewTopAnchorConstraint,
          heightContainerViewTrailingAnchorDimensionsContainerViewTrailingAnchorConstraint,
          heightContainerViewLeadingAnchorHSpacer2ViewTrailingAnchorConstraint,
          heightContainerViewTopAnchorDimensionsContainerViewTopAnchorConstraint,
          widthContainerViewHeightAnchorConstraint,
          widthLabelViewTopAnchorWidthContainerViewTopAnchorConstraint,
          widthLabelViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint,
          widthLabelViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint,
          widthDropdownViewTopAnchorWidthLabelViewBottomAnchorConstraint,
          widthDropdownViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint,
          widthDropdownViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint,
          widthInputContainerViewTopAnchorWidthDropdownViewBottomAnchorConstraint,
          widthInputContainerViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint,
          widthInputContainerViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint,
          hSpacer2ViewHeightAnchorConstraint,
          hSpacer2ViewWidthAnchorConstraint,
          heightContainerViewHeightAnchorConstraint,
          heightLabelViewTopAnchorHeightContainerViewTopAnchorConstraint,
          heightLabelViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint,
          heightLabelViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint,
          heightDropdownViewTopAnchorHeightLabelViewBottomAnchorConstraint,
          heightDropdownViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint,
          heightDropdownViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint,
          heightInputContainerViewTopAnchorHeightDropdownViewBottomAnchorConstraint,
          heightInputContainerViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint,
          heightInputContainerViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint,
          widthInputViewTopAnchorWidthInputContainerViewTopAnchorConstraint,
          widthInputViewBottomAnchorWidthInputContainerViewBottomAnchorConstraint,
          widthInputViewLeadingAnchorWidthInputContainerViewLeadingAnchorConstraint,
          widthInputViewTrailingAnchorWidthInputContainerViewTrailingAnchorConstraint,
          heightInputViewTopAnchorHeightInputContainerViewTopAnchorConstraint,
          heightInputViewBottomAnchorHeightInputContainerViewBottomAnchorConstraint,
          heightInputViewLeadingAnchorHeightInputContainerViewLeadingAnchorConstraint,
          heightInputViewTrailingAnchorHeightInputContainerViewTrailingAnchorConstraint
        ]
    }

    return constraints.compactMap({ $0 })
  }

  private func update() {
    let contentContainerViewIsHidden = contentContainerView.isHidden
    let heightInputContainerViewIsHidden = heightInputContainerView.isHidden
    let widthInputContainerViewIsHidden = widthInputContainerView.isHidden

    heightContainerViewHeightAnchorConstraint?.constant = 80
    heightDropdownView.selectedIndex = 0
    heightDropdownView.values = ["Fixed", "Fill", "Fit Content"]
    heightInputContainerView.isHidden = !true
    widthContainerViewHeightAnchorConstraint?.constant = 80
    widthDropdownView.selectedIndex = 0
    widthDropdownView.values = ["Fixed", "Fill", "Fit Content"]
    widthInputContainerView.isHidden = !true
    if allowsFitContent == false {
      widthDropdownView.values = ["Fixed", "Fill"]
      heightDropdownView.values = ["Fixed", "Fill"]
    }
    contentContainerView.isHidden = !isExpanded
    inspectorSectionHeaderView.isExpanded = isExpanded
    inspectorSectionHeaderView.onClick = handleOnClickHeader
    widthDropdownView.onChangeIndex = handleOnChangeWidthTypeIndex
    widthDropdownView.onChangeIndex = handleOnChangeWidthTypeIndex
    widthDropdownView.onChangeIndex = handleOnChangeWidthTypeIndex
    heightDropdownView.onChangeIndex = handleOnChangeHeightTypeIndex
    if widthType == .fitContent {
      widthDropdownView.selectedIndex = 2
      widthInputContainerView.isHidden = !false
    }
    if widthType == .fill {
      widthDropdownView.selectedIndex = 1
      widthInputContainerView.isHidden = !false
    }
    if heightType == .fitContent {
      heightDropdownView.selectedIndex = 2
      heightInputContainerView.isHidden = !false
    }
    if heightType == .fill {
      heightDropdownView.selectedIndex = 1
      heightInputContainerView.isHidden = !false
    }
    widthInputView.numberValue = widthValue
    widthInputView.onChangeNumberValue = handleOnChangeWidthValue
    heightInputView.numberValue = heightValue
    heightInputView.onChangeNumberValue = handleOnChangeHeightValue
    aspectRatioInputView.numberValue = aspectRatioValue
    aspectRatioInputView.onChangeNumberValue = handleOnChangeAspectRatioValue
    if widthType == .fitContent {
      if heightType == .fitContent {
        widthContainerViewHeightAnchorConstraint?.constant = 50
        heightContainerViewHeightAnchorConstraint?.constant = 50
      }
      if heightType == .fill {
        widthContainerViewHeightAnchorConstraint?.constant = 50
        heightContainerViewHeightAnchorConstraint?.constant = 50
      }
    }
    if widthType == .fill {
      if heightType == .fitContent {
        widthContainerViewHeightAnchorConstraint?.constant = 50
        heightContainerViewHeightAnchorConstraint?.constant = 50
      }
      if heightType == .fill {
        widthContainerViewHeightAnchorConstraint?.constant = 50
        heightContainerViewHeightAnchorConstraint?.constant = 50
      }
    }

    if
    contentContainerView.isHidden != contentContainerViewIsHidden ||
      heightInputContainerView.isHidden != heightInputContainerViewIsHidden ||
        widthInputContainerView.isHidden != widthInputContainerViewIsHidden
    {
      NSLayoutConstraint.deactivate(
        conditionalConstraints(
          contentContainerViewIsHidden: contentContainerViewIsHidden,
          heightInputContainerViewIsHidden: heightInputContainerViewIsHidden,
          widthInputContainerViewIsHidden: widthInputContainerViewIsHidden))
      NSLayoutConstraint.activate(
        conditionalConstraints(
          contentContainerViewIsHidden: contentContainerView.isHidden,
          heightInputContainerViewIsHidden: heightInputContainerView.isHidden,
          widthInputContainerViewIsHidden: widthInputContainerView.isHidden))
    }
  }

  private func handleOnClickHeader() {
    onClickHeader?()
  }

  private func handleOnChangeWidthTypeIndex(_ arg0: Int) {
    onChangeWidthTypeIndex?(arg0)
  }

  private func handleOnChangeHeightTypeIndex(_ arg0: Int) {
    onChangeHeightTypeIndex?(arg0)
  }

  private func handleOnChangeWidthValue(_ arg0: CGFloat) {
    onChangeWidthValue?(arg0)
  }

  private func handleOnChangeHeightValue(_ arg0: CGFloat) {
    onChangeHeightValue?(arg0)
  }

  private func handleOnChangeAspectRatioValue(_ arg0: CGFloat) {
    onChangeAspectRatioValue?(arg0)
  }
}

// MARK: - Parameters

extension DimensionsInspector {
  public struct Parameters: Equatable {
    public var isExpanded: Bool
    public var widthType: DimensionType
    public var widthValue: CGFloat
    public var heightType: DimensionType
    public var heightValue: CGFloat
    public var allowsFitContent: Bool
    public var aspectRatioValue: CGFloat
    public var onClickHeader: (() -> Void)?
    public var onChangeWidthTypeIndex: ((Int) -> Void)?
    public var onChangeHeightTypeIndex: ((Int) -> Void)?
    public var onChangeWidthValue: ((CGFloat) -> Void)?
    public var onChangeHeightValue: ((CGFloat) -> Void)?
    public var onChangeAspectRatioValue: ((CGFloat) -> Void)?

    public init(
      isExpanded: Bool,
      widthType: DimensionType,
      widthValue: CGFloat,
      heightType: DimensionType,
      heightValue: CGFloat,
      allowsFitContent: Bool,
      aspectRatioValue: CGFloat,
      onClickHeader: (() -> Void)? = nil,
      onChangeWidthTypeIndex: ((Int) -> Void)? = nil,
      onChangeHeightTypeIndex: ((Int) -> Void)? = nil,
      onChangeWidthValue: ((CGFloat) -> Void)? = nil,
      onChangeHeightValue: ((CGFloat) -> Void)? = nil,
      onChangeAspectRatioValue: ((CGFloat) -> Void)? = nil)
    {
      self.isExpanded = isExpanded
      self.widthType = widthType
      self.widthValue = widthValue
      self.heightType = heightType
      self.heightValue = heightValue
      self.allowsFitContent = allowsFitContent
      self.aspectRatioValue = aspectRatioValue
      self.onClickHeader = onClickHeader
      self.onChangeWidthTypeIndex = onChangeWidthTypeIndex
      self.onChangeHeightTypeIndex = onChangeHeightTypeIndex
      self.onChangeWidthValue = onChangeWidthValue
      self.onChangeHeightValue = onChangeHeightValue
      self.onChangeAspectRatioValue = onChangeAspectRatioValue
    }

    public init() {
      self
        .init(
          isExpanded: false,
          widthType: .fitContent,
          widthValue: 0,
          heightType: .fitContent,
          heightValue: 0,
          allowsFitContent: false,
          aspectRatioValue: 0)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.isExpanded == rhs.isExpanded &&
        lhs.widthType == rhs.widthType &&
          lhs.widthValue == rhs.widthValue &&
            lhs.heightType == rhs.heightType &&
              lhs.heightValue == rhs.heightValue &&
                lhs.allowsFitContent == rhs.allowsFitContent && lhs.aspectRatioValue == rhs.aspectRatioValue
    }
  }
}

// MARK: - Model

extension DimensionsInspector {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "DimensionsInspector"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      isExpanded: Bool,
      widthType: DimensionType,
      widthValue: CGFloat,
      heightType: DimensionType,
      heightValue: CGFloat,
      allowsFitContent: Bool,
      aspectRatioValue: CGFloat,
      onClickHeader: (() -> Void)? = nil,
      onChangeWidthTypeIndex: ((Int) -> Void)? = nil,
      onChangeHeightTypeIndex: ((Int) -> Void)? = nil,
      onChangeWidthValue: ((CGFloat) -> Void)? = nil,
      onChangeHeightValue: ((CGFloat) -> Void)? = nil,
      onChangeAspectRatioValue: ((CGFloat) -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            isExpanded: isExpanded,
            widthType: widthType,
            widthValue: widthValue,
            heightType: heightType,
            heightValue: heightValue,
            allowsFitContent: allowsFitContent,
            aspectRatioValue: aspectRatioValue,
            onClickHeader: onClickHeader,
            onChangeWidthTypeIndex: onChangeWidthTypeIndex,
            onChangeHeightTypeIndex: onChangeHeightTypeIndex,
            onChangeWidthValue: onChangeWidthValue,
            onChangeHeightValue: onChangeHeightValue,
            onChangeAspectRatioValue: onChangeAspectRatioValue))
    }

    public init() {
      self
        .init(
          isExpanded: false,
          widthType: .fitContent,
          widthValue: 0,
          heightType: .fitContent,
          heightValue: 0,
          allowsFitContent: false,
          aspectRatioValue: 0)
    }
  }
}
