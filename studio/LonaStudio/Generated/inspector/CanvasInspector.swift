import AppKit
import Foundation

// MARK: - CanvasInspector

public class CanvasInspector: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(
    showsDimensionInputs: Bool,
    heightMode: CanvasHeight,
    devicePreset: String,
    canvasHeight: CGFloat,
    canvasWidth: CGFloat,
    canvasName: String?,
    backgroundColorId: String)
  {
    self
      .init(
        Parameters(
          showsDimensionInputs: showsDimensionInputs,
          heightMode: heightMode,
          devicePreset: devicePreset,
          canvasHeight: canvasHeight,
          canvasWidth: canvasWidth,
          canvasName: canvasName,
          backgroundColorId: backgroundColorId))
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

  public var showsDimensionInputs: Bool {
    get { return parameters.showsDimensionInputs }
    set {
      if parameters.showsDimensionInputs != newValue {
        parameters.showsDimensionInputs = newValue
      }
    }
  }

  public var heightMode: CanvasHeight {
    get { return parameters.heightMode }
    set {
      if parameters.heightMode != newValue {
        parameters.heightMode = newValue
      }
    }
  }

  public var devicePreset: String {
    get { return parameters.devicePreset }
    set {
      if parameters.devicePreset != newValue {
        parameters.devicePreset = newValue
      }
    }
  }

  public var canvasHeight: CGFloat {
    get { return parameters.canvasHeight }
    set {
      if parameters.canvasHeight != newValue {
        parameters.canvasHeight = newValue
      }
    }
  }

  public var canvasWidth: CGFloat {
    get { return parameters.canvasWidth }
    set {
      if parameters.canvasWidth != newValue {
        parameters.canvasWidth = newValue
      }
    }
  }

  public var canvasName: String? {
    get { return parameters.canvasName }
    set {
      if parameters.canvasName != newValue {
        parameters.canvasName = newValue
      }
    }
  }

  public var backgroundColorId: String {
    get { return parameters.backgroundColorId }
    set {
      if parameters.backgroundColorId != newValue {
        parameters.backgroundColorId = newValue
      }
    }
  }

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private var layoutRowView = NSBox()
  private var layoutLabelView = LNATextField(labelWithString: "")
  private var layoutDropdownView = ControlledDropdown()
  private var deviceRowView = NSBox()
  private var deviceLabelView = LNATextField(labelWithString: "")
  private var deviceValueContainerView = NSBox()
  private var deviceDropdownView = ControlledDropdown()
  private var customDimensionsContainerView = NSBox()
  private var widthContainerView = NSBox()
  private var widthLabelView = LNATextField(labelWithString: "")
  private var widthInputView = NumberInput()
  private var hSpacerView = NSBox()
  private var heightContainerView = NSBox()
  private var heightLabelView = LNATextField(labelWithString: "")
  private var heightInputView = NumberInput()
  private var nameRowView = NSBox()
  private var nameLabelView = LNATextField(labelWithString: "")
  private var nameInputView = TextInput()
  private var backgroundColorRowView = NSBox()
  private var backgroundColorLabelView = LNATextField(labelWithString: "")
  private var backgroundColorInputView = TextInput()

  private var layoutLabelViewTextStyle = TextStyles.regular
  private var deviceLabelViewTextStyle = TextStyles.regular
  private var widthLabelViewTextStyle = TextStyles.regular
  private var heightLabelViewTextStyle = TextStyles.regular
  private var nameLabelViewTextStyle = TextStyles.regular
  private var backgroundColorLabelViewTextStyle = TextStyles.regular

  private var deviceDropdownViewBottomAnchorDeviceValueContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var customDimensionsContainerViewBottomAnchorDeviceValueContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var customDimensionsContainerViewTopAnchorDeviceDropdownViewBottomAnchorConstraint: NSLayoutConstraint?
  private var customDimensionsContainerViewLeadingAnchorDeviceValueContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var customDimensionsContainerViewTrailingAnchorDeviceValueContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var widthContainerViewHeightContainerViewWidthAnchorSiblingConstraint: NSLayoutConstraint?
  private var widthContainerViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var hSpacerViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var heightContainerViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var widthContainerViewLeadingAnchorCustomDimensionsContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var widthContainerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var widthContainerViewBottomAnchorCustomDimensionsContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var hSpacerViewLeadingAnchorWidthContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var hSpacerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var heightContainerViewTrailingAnchorCustomDimensionsContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var heightContainerViewLeadingAnchorHSpacerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var heightContainerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var heightContainerViewBottomAnchorCustomDimensionsContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var widthLabelViewTopAnchorWidthContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var widthLabelViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var widthLabelViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var widthInputViewBottomAnchorWidthContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var widthInputViewTopAnchorWidthLabelViewBottomAnchorConstraint: NSLayoutConstraint?
  private var widthInputViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var widthInputViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var hSpacerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var hSpacerViewWidthAnchorConstraint: NSLayoutConstraint?
  private var heightLabelViewTopAnchorHeightContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var heightLabelViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var heightLabelViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var heightInputViewBottomAnchorHeightContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var heightInputViewTopAnchorHeightLabelViewBottomAnchorConstraint: NSLayoutConstraint?
  private var heightInputViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var heightInputViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    layoutRowView.boxType = .custom
    layoutRowView.borderType = .noBorder
    layoutRowView.contentViewMargins = .zero
    deviceRowView.boxType = .custom
    deviceRowView.borderType = .noBorder
    deviceRowView.contentViewMargins = .zero
    nameRowView.boxType = .custom
    nameRowView.borderType = .noBorder
    nameRowView.contentViewMargins = .zero
    backgroundColorRowView.boxType = .custom
    backgroundColorRowView.borderType = .noBorder
    backgroundColorRowView.contentViewMargins = .zero
    layoutLabelView.lineBreakMode = .byWordWrapping
    deviceLabelView.lineBreakMode = .byWordWrapping
    deviceValueContainerView.boxType = .custom
    deviceValueContainerView.borderType = .noBorder
    deviceValueContainerView.contentViewMargins = .zero
    customDimensionsContainerView.boxType = .custom
    customDimensionsContainerView.borderType = .noBorder
    customDimensionsContainerView.contentViewMargins = .zero
    widthContainerView.boxType = .custom
    widthContainerView.borderType = .noBorder
    widthContainerView.contentViewMargins = .zero
    hSpacerView.boxType = .custom
    hSpacerView.borderType = .noBorder
    hSpacerView.contentViewMargins = .zero
    heightContainerView.boxType = .custom
    heightContainerView.borderType = .noBorder
    heightContainerView.contentViewMargins = .zero
    widthLabelView.lineBreakMode = .byWordWrapping
    heightLabelView.lineBreakMode = .byWordWrapping
    nameLabelView.lineBreakMode = .byWordWrapping
    backgroundColorLabelView.lineBreakMode = .byWordWrapping

    addSubview(layoutRowView)
    addSubview(deviceRowView)
    addSubview(nameRowView)
    addSubview(backgroundColorRowView)
    layoutRowView.addSubview(layoutLabelView)
    layoutRowView.addSubview(layoutDropdownView)
    deviceRowView.addSubview(deviceLabelView)
    deviceRowView.addSubview(deviceValueContainerView)
    deviceValueContainerView.addSubview(deviceDropdownView)
    deviceValueContainerView.addSubview(customDimensionsContainerView)
    customDimensionsContainerView.addSubview(widthContainerView)
    customDimensionsContainerView.addSubview(hSpacerView)
    customDimensionsContainerView.addSubview(heightContainerView)
    widthContainerView.addSubview(widthLabelView)
    widthContainerView.addSubview(widthInputView)
    heightContainerView.addSubview(heightLabelView)
    heightContainerView.addSubview(heightInputView)
    nameRowView.addSubview(nameLabelView)
    nameRowView.addSubview(nameInputView)
    backgroundColorRowView.addSubview(backgroundColorLabelView)
    backgroundColorRowView.addSubview(backgroundColorInputView)

    layoutLabelView.attributedStringValue = layoutLabelViewTextStyle.apply(to: "Layout")
    layoutDropdownView.selectedIndex = 0
    layoutDropdownView.values = ["Component (Flexible-height)", "Screen (Fixed-height)"]
    deviceLabelView.attributedStringValue = deviceLabelViewTextStyle.apply(to: "Device")
    deviceDropdownView.selectedIndex = 0
    deviceDropdownView.values = ["iPhone SE"]
    widthLabelView.attributedStringValue = widthLabelViewTextStyle.apply(to: "Width")
    heightLabelView.attributedStringValue = heightLabelViewTextStyle.apply(to: "Height")
    nameLabelView.attributedStringValue = nameLabelViewTextStyle.apply(to: "Name")
    nameInputView.textValue = "Text"
    backgroundColorLabelView.attributedStringValue = backgroundColorLabelViewTextStyle.apply(to: "Background")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    layoutRowView.translatesAutoresizingMaskIntoConstraints = false
    deviceRowView.translatesAutoresizingMaskIntoConstraints = false
    nameRowView.translatesAutoresizingMaskIntoConstraints = false
    backgroundColorRowView.translatesAutoresizingMaskIntoConstraints = false
    layoutLabelView.translatesAutoresizingMaskIntoConstraints = false
    layoutDropdownView.translatesAutoresizingMaskIntoConstraints = false
    deviceLabelView.translatesAutoresizingMaskIntoConstraints = false
    deviceValueContainerView.translatesAutoresizingMaskIntoConstraints = false
    deviceDropdownView.translatesAutoresizingMaskIntoConstraints = false
    customDimensionsContainerView.translatesAutoresizingMaskIntoConstraints = false
    widthContainerView.translatesAutoresizingMaskIntoConstraints = false
    hSpacerView.translatesAutoresizingMaskIntoConstraints = false
    heightContainerView.translatesAutoresizingMaskIntoConstraints = false
    widthLabelView.translatesAutoresizingMaskIntoConstraints = false
    widthInputView.translatesAutoresizingMaskIntoConstraints = false
    heightLabelView.translatesAutoresizingMaskIntoConstraints = false
    heightInputView.translatesAutoresizingMaskIntoConstraints = false
    nameLabelView.translatesAutoresizingMaskIntoConstraints = false
    nameInputView.translatesAutoresizingMaskIntoConstraints = false
    backgroundColorLabelView.translatesAutoresizingMaskIntoConstraints = false
    backgroundColorInputView.translatesAutoresizingMaskIntoConstraints = false

    let layoutRowViewTopAnchorConstraint = layoutRowView.topAnchor.constraint(equalTo: topAnchor, constant: 16)
    let layoutRowViewLeadingAnchorConstraint = layoutRowView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let layoutRowViewTrailingAnchorConstraint = layoutRowView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let deviceRowViewTopAnchorConstraint = deviceRowView
      .topAnchor
      .constraint(equalTo: layoutRowView.bottomAnchor, constant: 16)
    let deviceRowViewLeadingAnchorConstraint = deviceRowView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let deviceRowViewTrailingAnchorConstraint = deviceRowView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let nameRowViewTopAnchorConstraint = nameRowView
      .topAnchor
      .constraint(equalTo: deviceRowView.bottomAnchor, constant: 16)
    let nameRowViewLeadingAnchorConstraint = nameRowView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let nameRowViewTrailingAnchorConstraint = nameRowView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let backgroundColorRowViewBottomAnchorConstraint = backgroundColorRowView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -16)
    let backgroundColorRowViewTopAnchorConstraint = backgroundColorRowView
      .topAnchor
      .constraint(equalTo: nameRowView.bottomAnchor, constant: 16)
    let backgroundColorRowViewLeadingAnchorConstraint = backgroundColorRowView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor)
    let backgroundColorRowViewTrailingAnchorConstraint = backgroundColorRowView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let layoutLabelViewHeightAnchorParentConstraint = layoutLabelView
      .heightAnchor
      .constraint(lessThanOrEqualTo: layoutRowView.heightAnchor)
    let layoutDropdownViewHeightAnchorParentConstraint = layoutDropdownView
      .heightAnchor
      .constraint(lessThanOrEqualTo: layoutRowView.heightAnchor)
    let layoutLabelViewLeadingAnchorConstraint = layoutLabelView
      .leadingAnchor
      .constraint(equalTo: layoutRowView.leadingAnchor)
    let layoutLabelViewTopAnchorConstraint = layoutLabelView.topAnchor.constraint(equalTo: layoutRowView.topAnchor)
    let layoutLabelViewCenterYAnchorConstraint = layoutLabelView
      .centerYAnchor
      .constraint(equalTo: layoutRowView.centerYAnchor)
    let layoutLabelViewBottomAnchorConstraint = layoutLabelView
      .bottomAnchor
      .constraint(equalTo: layoutRowView.bottomAnchor)
    let layoutDropdownViewTrailingAnchorConstraint = layoutDropdownView
      .trailingAnchor
      .constraint(equalTo: layoutRowView.trailingAnchor)
    let layoutDropdownViewLeadingAnchorConstraint = layoutDropdownView
      .leadingAnchor
      .constraint(equalTo: layoutLabelView.trailingAnchor, constant: 20)
    let layoutDropdownViewTopAnchorConstraint = layoutDropdownView
      .topAnchor
      .constraint(equalTo: layoutRowView.topAnchor)
    let layoutDropdownViewCenterYAnchorConstraint = layoutDropdownView
      .centerYAnchor
      .constraint(equalTo: layoutRowView.centerYAnchor)
    let layoutDropdownViewBottomAnchorConstraint = layoutDropdownView
      .bottomAnchor
      .constraint(equalTo: layoutRowView.bottomAnchor)
    let deviceLabelViewHeightAnchorParentConstraint = deviceLabelView
      .heightAnchor
      .constraint(lessThanOrEqualTo: deviceRowView.heightAnchor, constant: -2)
    let deviceValueContainerViewHeightAnchorParentConstraint = deviceValueContainerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: deviceRowView.heightAnchor)
    let deviceLabelViewLeadingAnchorConstraint = deviceLabelView
      .leadingAnchor
      .constraint(equalTo: deviceRowView.leadingAnchor)
    let deviceLabelViewTopAnchorConstraint = deviceLabelView
      .topAnchor
      .constraint(equalTo: deviceRowView.topAnchor, constant: 2)
    let deviceLabelViewBottomAnchorConstraint = deviceLabelView
      .bottomAnchor
      .constraint(equalTo: deviceRowView.bottomAnchor)
    let deviceValueContainerViewTrailingAnchorConstraint = deviceValueContainerView
      .trailingAnchor
      .constraint(equalTo: deviceRowView.trailingAnchor)
    let deviceValueContainerViewLeadingAnchorConstraint = deviceValueContainerView
      .leadingAnchor
      .constraint(equalTo: deviceLabelView.trailingAnchor, constant: 20)
    let deviceValueContainerViewTopAnchorConstraint = deviceValueContainerView
      .topAnchor
      .constraint(equalTo: deviceRowView.topAnchor)
    let deviceValueContainerViewBottomAnchorConstraint = deviceValueContainerView
      .bottomAnchor
      .constraint(equalTo: deviceRowView.bottomAnchor)
    let nameLabelViewHeightAnchorParentConstraint = nameLabelView
      .heightAnchor
      .constraint(lessThanOrEqualTo: nameRowView.heightAnchor)
    let nameInputViewHeightAnchorParentConstraint = nameInputView
      .heightAnchor
      .constraint(lessThanOrEqualTo: nameRowView.heightAnchor)
    let nameLabelViewLeadingAnchorConstraint = nameLabelView
      .leadingAnchor
      .constraint(equalTo: nameRowView.leadingAnchor)
    let nameLabelViewTopAnchorConstraint = nameLabelView.topAnchor.constraint(equalTo: nameRowView.topAnchor)
    let nameLabelViewCenterYAnchorConstraint = nameLabelView
      .centerYAnchor
      .constraint(equalTo: nameRowView.centerYAnchor)
    let nameLabelViewBottomAnchorConstraint = nameLabelView.bottomAnchor.constraint(equalTo: nameRowView.bottomAnchor)
    let nameInputViewTrailingAnchorConstraint = nameInputView
      .trailingAnchor
      .constraint(equalTo: nameRowView.trailingAnchor)
    let nameInputViewLeadingAnchorConstraint = nameInputView
      .leadingAnchor
      .constraint(equalTo: nameLabelView.trailingAnchor, constant: 20)
    let nameInputViewTopAnchorConstraint = nameInputView.topAnchor.constraint(equalTo: nameRowView.topAnchor)
    let nameInputViewCenterYAnchorConstraint = nameInputView
      .centerYAnchor
      .constraint(equalTo: nameRowView.centerYAnchor)
    let nameInputViewBottomAnchorConstraint = nameInputView.bottomAnchor.constraint(equalTo: nameRowView.bottomAnchor)
    let backgroundColorLabelViewHeightAnchorParentConstraint = backgroundColorLabelView
      .heightAnchor
      .constraint(lessThanOrEqualTo: backgroundColorRowView.heightAnchor)
    let backgroundColorInputViewHeightAnchorParentConstraint = backgroundColorInputView
      .heightAnchor
      .constraint(lessThanOrEqualTo: backgroundColorRowView.heightAnchor)
    let backgroundColorLabelViewLeadingAnchorConstraint = backgroundColorLabelView
      .leadingAnchor
      .constraint(equalTo: backgroundColorRowView.leadingAnchor)
    let backgroundColorLabelViewTopAnchorConstraint = backgroundColorLabelView
      .topAnchor
      .constraint(equalTo: backgroundColorRowView.topAnchor)
    let backgroundColorLabelViewCenterYAnchorConstraint = backgroundColorLabelView
      .centerYAnchor
      .constraint(equalTo: backgroundColorRowView.centerYAnchor)
    let backgroundColorLabelViewBottomAnchorConstraint = backgroundColorLabelView
      .bottomAnchor
      .constraint(equalTo: backgroundColorRowView.bottomAnchor)
    let backgroundColorInputViewTrailingAnchorConstraint = backgroundColorInputView
      .trailingAnchor
      .constraint(equalTo: backgroundColorRowView.trailingAnchor)
    let backgroundColorInputViewLeadingAnchorConstraint = backgroundColorInputView
      .leadingAnchor
      .constraint(equalTo: backgroundColorLabelView.trailingAnchor, constant: 20)
    let backgroundColorInputViewTopAnchorConstraint = backgroundColorInputView
      .topAnchor
      .constraint(equalTo: backgroundColorRowView.topAnchor)
    let backgroundColorInputViewCenterYAnchorConstraint = backgroundColorInputView
      .centerYAnchor
      .constraint(equalTo: backgroundColorRowView.centerYAnchor)
    let backgroundColorInputViewBottomAnchorConstraint = backgroundColorInputView
      .bottomAnchor
      .constraint(equalTo: backgroundColorRowView.bottomAnchor)
    let layoutLabelViewWidthAnchorConstraint = layoutLabelView.widthAnchor.constraint(equalToConstant: 80)
    let deviceLabelViewWidthAnchorConstraint = deviceLabelView.widthAnchor.constraint(equalToConstant: 80)
    let deviceDropdownViewTopAnchorConstraint = deviceDropdownView
      .topAnchor
      .constraint(equalTo: deviceValueContainerView.topAnchor)
    let deviceDropdownViewLeadingAnchorConstraint = deviceDropdownView
      .leadingAnchor
      .constraint(equalTo: deviceValueContainerView.leadingAnchor)
    let deviceDropdownViewTrailingAnchorConstraint = deviceDropdownView
      .trailingAnchor
      .constraint(equalTo: deviceValueContainerView.trailingAnchor)
    let nameLabelViewWidthAnchorConstraint = nameLabelView.widthAnchor.constraint(equalToConstant: 80)
    let backgroundColorLabelViewWidthAnchorConstraint = backgroundColorLabelView
      .widthAnchor
      .constraint(equalToConstant: 80)
    let deviceDropdownViewBottomAnchorDeviceValueContainerViewBottomAnchorConstraint = deviceDropdownView
      .bottomAnchor
      .constraint(equalTo: deviceValueContainerView.bottomAnchor)
    let customDimensionsContainerViewBottomAnchorDeviceValueContainerViewBottomAnchorConstraint = customDimensionsContainerView
      .bottomAnchor
      .constraint(equalTo: deviceValueContainerView.bottomAnchor)
    let customDimensionsContainerViewTopAnchorDeviceDropdownViewBottomAnchorConstraint = customDimensionsContainerView
      .topAnchor
      .constraint(equalTo: deviceDropdownView.bottomAnchor, constant: 16)
    let customDimensionsContainerViewLeadingAnchorDeviceValueContainerViewLeadingAnchorConstraint = customDimensionsContainerView
      .leadingAnchor
      .constraint(equalTo: deviceValueContainerView.leadingAnchor)
    let customDimensionsContainerViewTrailingAnchorDeviceValueContainerViewTrailingAnchorConstraint = customDimensionsContainerView
      .trailingAnchor
      .constraint(equalTo: deviceValueContainerView.trailingAnchor)
    let widthContainerViewHeightContainerViewWidthAnchorSiblingConstraint = widthContainerView
      .widthAnchor
      .constraint(equalTo: heightContainerView.widthAnchor)
    let widthContainerViewHeightAnchorParentConstraint = widthContainerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: customDimensionsContainerView.heightAnchor)
    let hSpacerViewHeightAnchorParentConstraint = hSpacerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: customDimensionsContainerView.heightAnchor)
    let heightContainerViewHeightAnchorParentConstraint = heightContainerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: customDimensionsContainerView.heightAnchor)
    let widthContainerViewLeadingAnchorCustomDimensionsContainerViewLeadingAnchorConstraint = widthContainerView
      .leadingAnchor
      .constraint(equalTo: customDimensionsContainerView.leadingAnchor)
    let widthContainerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint = widthContainerView
      .topAnchor
      .constraint(equalTo: customDimensionsContainerView.topAnchor)
    let widthContainerViewBottomAnchorCustomDimensionsContainerViewBottomAnchorConstraint = widthContainerView
      .bottomAnchor
      .constraint(equalTo: customDimensionsContainerView.bottomAnchor)
    let hSpacerViewLeadingAnchorWidthContainerViewTrailingAnchorConstraint = hSpacerView
      .leadingAnchor
      .constraint(equalTo: widthContainerView.trailingAnchor)
    let hSpacerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint = hSpacerView
      .topAnchor
      .constraint(equalTo: customDimensionsContainerView.topAnchor)
    let heightContainerViewTrailingAnchorCustomDimensionsContainerViewTrailingAnchorConstraint = heightContainerView
      .trailingAnchor
      .constraint(equalTo: customDimensionsContainerView.trailingAnchor)
    let heightContainerViewLeadingAnchorHSpacerViewTrailingAnchorConstraint = heightContainerView
      .leadingAnchor
      .constraint(equalTo: hSpacerView.trailingAnchor)
    let heightContainerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint = heightContainerView
      .topAnchor
      .constraint(equalTo: customDimensionsContainerView.topAnchor)
    let heightContainerViewBottomAnchorCustomDimensionsContainerViewBottomAnchorConstraint = heightContainerView
      .bottomAnchor
      .constraint(equalTo: customDimensionsContainerView.bottomAnchor)
    let widthLabelViewTopAnchorWidthContainerViewTopAnchorConstraint = widthLabelView
      .topAnchor
      .constraint(equalTo: widthContainerView.topAnchor)
    let widthLabelViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint = widthLabelView
      .leadingAnchor
      .constraint(equalTo: widthContainerView.leadingAnchor)
    let widthLabelViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint = widthLabelView
      .trailingAnchor
      .constraint(equalTo: widthContainerView.trailingAnchor)
    let widthInputViewBottomAnchorWidthContainerViewBottomAnchorConstraint = widthInputView
      .bottomAnchor
      .constraint(equalTo: widthContainerView.bottomAnchor)
    let widthInputViewTopAnchorWidthLabelViewBottomAnchorConstraint = widthInputView
      .topAnchor
      .constraint(equalTo: widthLabelView.bottomAnchor, constant: 8)
    let widthInputViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint = widthInputView
      .leadingAnchor
      .constraint(equalTo: widthContainerView.leadingAnchor)
    let widthInputViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint = widthInputView
      .trailingAnchor
      .constraint(equalTo: widthContainerView.trailingAnchor)
    let hSpacerViewHeightAnchorConstraint = hSpacerView.heightAnchor.constraint(equalToConstant: 0)
    let hSpacerViewWidthAnchorConstraint = hSpacerView.widthAnchor.constraint(equalToConstant: 20)
    let heightLabelViewTopAnchorHeightContainerViewTopAnchorConstraint = heightLabelView
      .topAnchor
      .constraint(equalTo: heightContainerView.topAnchor)
    let heightLabelViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint = heightLabelView
      .leadingAnchor
      .constraint(equalTo: heightContainerView.leadingAnchor)
    let heightLabelViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint = heightLabelView
      .trailingAnchor
      .constraint(equalTo: heightContainerView.trailingAnchor)
    let heightInputViewBottomAnchorHeightContainerViewBottomAnchorConstraint = heightInputView
      .bottomAnchor
      .constraint(equalTo: heightContainerView.bottomAnchor)
    let heightInputViewTopAnchorHeightLabelViewBottomAnchorConstraint = heightInputView
      .topAnchor
      .constraint(equalTo: heightLabelView.bottomAnchor, constant: 8)
    let heightInputViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint = heightInputView
      .leadingAnchor
      .constraint(equalTo: heightContainerView.leadingAnchor)
    let heightInputViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint = heightInputView
      .trailingAnchor
      .constraint(equalTo: heightContainerView.trailingAnchor)

    layoutLabelViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    layoutDropdownViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    deviceLabelViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    deviceValueContainerViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    nameLabelViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    nameInputViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    backgroundColorLabelViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    backgroundColorInputViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    widthContainerViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    hSpacerViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    heightContainerViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    self.deviceDropdownViewBottomAnchorDeviceValueContainerViewBottomAnchorConstraint =
      deviceDropdownViewBottomAnchorDeviceValueContainerViewBottomAnchorConstraint
    self.customDimensionsContainerViewBottomAnchorDeviceValueContainerViewBottomAnchorConstraint =
      customDimensionsContainerViewBottomAnchorDeviceValueContainerViewBottomAnchorConstraint
    self.customDimensionsContainerViewTopAnchorDeviceDropdownViewBottomAnchorConstraint =
      customDimensionsContainerViewTopAnchorDeviceDropdownViewBottomAnchorConstraint
    self.customDimensionsContainerViewLeadingAnchorDeviceValueContainerViewLeadingAnchorConstraint =
      customDimensionsContainerViewLeadingAnchorDeviceValueContainerViewLeadingAnchorConstraint
    self.customDimensionsContainerViewTrailingAnchorDeviceValueContainerViewTrailingAnchorConstraint =
      customDimensionsContainerViewTrailingAnchorDeviceValueContainerViewTrailingAnchorConstraint
    self.widthContainerViewHeightContainerViewWidthAnchorSiblingConstraint =
      widthContainerViewHeightContainerViewWidthAnchorSiblingConstraint
    self.widthContainerViewHeightAnchorParentConstraint = widthContainerViewHeightAnchorParentConstraint
    self.hSpacerViewHeightAnchorParentConstraint = hSpacerViewHeightAnchorParentConstraint
    self.heightContainerViewHeightAnchorParentConstraint = heightContainerViewHeightAnchorParentConstraint
    self.widthContainerViewLeadingAnchorCustomDimensionsContainerViewLeadingAnchorConstraint =
      widthContainerViewLeadingAnchorCustomDimensionsContainerViewLeadingAnchorConstraint
    self.widthContainerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint =
      widthContainerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint
    self.widthContainerViewBottomAnchorCustomDimensionsContainerViewBottomAnchorConstraint =
      widthContainerViewBottomAnchorCustomDimensionsContainerViewBottomAnchorConstraint
    self.hSpacerViewLeadingAnchorWidthContainerViewTrailingAnchorConstraint =
      hSpacerViewLeadingAnchorWidthContainerViewTrailingAnchorConstraint
    self.hSpacerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint =
      hSpacerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint
    self.heightContainerViewTrailingAnchorCustomDimensionsContainerViewTrailingAnchorConstraint =
      heightContainerViewTrailingAnchorCustomDimensionsContainerViewTrailingAnchorConstraint
    self.heightContainerViewLeadingAnchorHSpacerViewTrailingAnchorConstraint =
      heightContainerViewLeadingAnchorHSpacerViewTrailingAnchorConstraint
    self.heightContainerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint =
      heightContainerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint
    self.heightContainerViewBottomAnchorCustomDimensionsContainerViewBottomAnchorConstraint =
      heightContainerViewBottomAnchorCustomDimensionsContainerViewBottomAnchorConstraint
    self.widthLabelViewTopAnchorWidthContainerViewTopAnchorConstraint =
      widthLabelViewTopAnchorWidthContainerViewTopAnchorConstraint
    self.widthLabelViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint =
      widthLabelViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint
    self.widthLabelViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint =
      widthLabelViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint
    self.widthInputViewBottomAnchorWidthContainerViewBottomAnchorConstraint =
      widthInputViewBottomAnchorWidthContainerViewBottomAnchorConstraint
    self.widthInputViewTopAnchorWidthLabelViewBottomAnchorConstraint =
      widthInputViewTopAnchorWidthLabelViewBottomAnchorConstraint
    self.widthInputViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint =
      widthInputViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint
    self.widthInputViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint =
      widthInputViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint
    self.hSpacerViewHeightAnchorConstraint = hSpacerViewHeightAnchorConstraint
    self.hSpacerViewWidthAnchorConstraint = hSpacerViewWidthAnchorConstraint
    self.heightLabelViewTopAnchorHeightContainerViewTopAnchorConstraint =
      heightLabelViewTopAnchorHeightContainerViewTopAnchorConstraint
    self.heightLabelViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint =
      heightLabelViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint
    self.heightLabelViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint =
      heightLabelViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint
    self.heightInputViewBottomAnchorHeightContainerViewBottomAnchorConstraint =
      heightInputViewBottomAnchorHeightContainerViewBottomAnchorConstraint
    self.heightInputViewTopAnchorHeightLabelViewBottomAnchorConstraint =
      heightInputViewTopAnchorHeightLabelViewBottomAnchorConstraint
    self.heightInputViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint =
      heightInputViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint
    self.heightInputViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint =
      heightInputViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint

    NSLayoutConstraint.activate(
      [
        layoutRowViewTopAnchorConstraint,
        layoutRowViewLeadingAnchorConstraint,
        layoutRowViewTrailingAnchorConstraint,
        deviceRowViewTopAnchorConstraint,
        deviceRowViewLeadingAnchorConstraint,
        deviceRowViewTrailingAnchorConstraint,
        nameRowViewTopAnchorConstraint,
        nameRowViewLeadingAnchorConstraint,
        nameRowViewTrailingAnchorConstraint,
        backgroundColorRowViewBottomAnchorConstraint,
        backgroundColorRowViewTopAnchorConstraint,
        backgroundColorRowViewLeadingAnchorConstraint,
        backgroundColorRowViewTrailingAnchorConstraint,
        layoutLabelViewHeightAnchorParentConstraint,
        layoutDropdownViewHeightAnchorParentConstraint,
        layoutLabelViewLeadingAnchorConstraint,
        layoutLabelViewTopAnchorConstraint,
        layoutLabelViewCenterYAnchorConstraint,
        layoutLabelViewBottomAnchorConstraint,
        layoutDropdownViewTrailingAnchorConstraint,
        layoutDropdownViewLeadingAnchorConstraint,
        layoutDropdownViewTopAnchorConstraint,
        layoutDropdownViewCenterYAnchorConstraint,
        layoutDropdownViewBottomAnchorConstraint,
        deviceLabelViewHeightAnchorParentConstraint,
        deviceValueContainerViewHeightAnchorParentConstraint,
        deviceLabelViewLeadingAnchorConstraint,
        deviceLabelViewTopAnchorConstraint,
        deviceLabelViewBottomAnchorConstraint,
        deviceValueContainerViewTrailingAnchorConstraint,
        deviceValueContainerViewLeadingAnchorConstraint,
        deviceValueContainerViewTopAnchorConstraint,
        deviceValueContainerViewBottomAnchorConstraint,
        nameLabelViewHeightAnchorParentConstraint,
        nameInputViewHeightAnchorParentConstraint,
        nameLabelViewLeadingAnchorConstraint,
        nameLabelViewTopAnchorConstraint,
        nameLabelViewCenterYAnchorConstraint,
        nameLabelViewBottomAnchorConstraint,
        nameInputViewTrailingAnchorConstraint,
        nameInputViewLeadingAnchorConstraint,
        nameInputViewTopAnchorConstraint,
        nameInputViewCenterYAnchorConstraint,
        nameInputViewBottomAnchorConstraint,
        backgroundColorLabelViewHeightAnchorParentConstraint,
        backgroundColorInputViewHeightAnchorParentConstraint,
        backgroundColorLabelViewLeadingAnchorConstraint,
        backgroundColorLabelViewTopAnchorConstraint,
        backgroundColorLabelViewCenterYAnchorConstraint,
        backgroundColorLabelViewBottomAnchorConstraint,
        backgroundColorInputViewTrailingAnchorConstraint,
        backgroundColorInputViewLeadingAnchorConstraint,
        backgroundColorInputViewTopAnchorConstraint,
        backgroundColorInputViewCenterYAnchorConstraint,
        backgroundColorInputViewBottomAnchorConstraint,
        layoutLabelViewWidthAnchorConstraint,
        deviceLabelViewWidthAnchorConstraint,
        deviceDropdownViewTopAnchorConstraint,
        deviceDropdownViewLeadingAnchorConstraint,
        deviceDropdownViewTrailingAnchorConstraint,
        nameLabelViewWidthAnchorConstraint,
        backgroundColorLabelViewWidthAnchorConstraint
      ] +
        conditionalConstraints(customDimensionsContainerViewIsHidden: customDimensionsContainerView.isHidden))
  }

  private func conditionalConstraints(customDimensionsContainerViewIsHidden: Bool) -> [NSLayoutConstraint] {
    var constraints: [NSLayoutConstraint?]

    switch (customDimensionsContainerViewIsHidden) {
      case (true):
        constraints = [deviceDropdownViewBottomAnchorDeviceValueContainerViewBottomAnchorConstraint]
      case (false):
        constraints = [
          customDimensionsContainerViewBottomAnchorDeviceValueContainerViewBottomAnchorConstraint,
          customDimensionsContainerViewTopAnchorDeviceDropdownViewBottomAnchorConstraint,
          customDimensionsContainerViewLeadingAnchorDeviceValueContainerViewLeadingAnchorConstraint,
          customDimensionsContainerViewTrailingAnchorDeviceValueContainerViewTrailingAnchorConstraint,
          widthContainerViewHeightContainerViewWidthAnchorSiblingConstraint,
          widthContainerViewHeightAnchorParentConstraint,
          hSpacerViewHeightAnchorParentConstraint,
          heightContainerViewHeightAnchorParentConstraint,
          widthContainerViewLeadingAnchorCustomDimensionsContainerViewLeadingAnchorConstraint,
          widthContainerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint,
          widthContainerViewBottomAnchorCustomDimensionsContainerViewBottomAnchorConstraint,
          hSpacerViewLeadingAnchorWidthContainerViewTrailingAnchorConstraint,
          hSpacerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint,
          heightContainerViewTrailingAnchorCustomDimensionsContainerViewTrailingAnchorConstraint,
          heightContainerViewLeadingAnchorHSpacerViewTrailingAnchorConstraint,
          heightContainerViewTopAnchorCustomDimensionsContainerViewTopAnchorConstraint,
          heightContainerViewBottomAnchorCustomDimensionsContainerViewBottomAnchorConstraint,
          widthLabelViewTopAnchorWidthContainerViewTopAnchorConstraint,
          widthLabelViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint,
          widthLabelViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint,
          widthInputViewBottomAnchorWidthContainerViewBottomAnchorConstraint,
          widthInputViewTopAnchorWidthLabelViewBottomAnchorConstraint,
          widthInputViewLeadingAnchorWidthContainerViewLeadingAnchorConstraint,
          widthInputViewTrailingAnchorWidthContainerViewTrailingAnchorConstraint,
          hSpacerViewHeightAnchorConstraint,
          hSpacerViewWidthAnchorConstraint,
          heightLabelViewTopAnchorHeightContainerViewTopAnchorConstraint,
          heightLabelViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint,
          heightLabelViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint,
          heightInputViewBottomAnchorHeightContainerViewBottomAnchorConstraint,
          heightInputViewTopAnchorHeightLabelViewBottomAnchorConstraint,
          heightInputViewLeadingAnchorHeightContainerViewLeadingAnchorConstraint,
          heightInputViewTrailingAnchorHeightContainerViewTrailingAnchorConstraint
        ]
    }

    return constraints.compactMap({ $0 })
  }

  private func update() {
    let customDimensionsContainerViewIsHidden = customDimensionsContainerView.isHidden

    customDimensionsContainerView.isHidden = !showsDimensionInputs
    widthInputView.numberValue = canvasWidth
    heightInputView.numberValue = canvasHeight
    backgroundColorInputView.textValue = backgroundColorId

    if customDimensionsContainerView.isHidden != customDimensionsContainerViewIsHidden {
      NSLayoutConstraint.deactivate(
        conditionalConstraints(customDimensionsContainerViewIsHidden: customDimensionsContainerViewIsHidden))
      NSLayoutConstraint.activate(
        conditionalConstraints(customDimensionsContainerViewIsHidden: customDimensionsContainerView.isHidden))
    }
  }
}

// MARK: - Parameters

extension CanvasInspector {
  public struct Parameters: Equatable {
    public var showsDimensionInputs: Bool
    public var heightMode: CanvasHeight
    public var devicePreset: String
    public var canvasHeight: CGFloat
    public var canvasWidth: CGFloat
    public var canvasName: String?
    public var backgroundColorId: String

    public init(
      showsDimensionInputs: Bool,
      heightMode: CanvasHeight,
      devicePreset: String,
      canvasHeight: CGFloat,
      canvasWidth: CGFloat,
      canvasName: String? = nil,
      backgroundColorId: String)
    {
      self.showsDimensionInputs = showsDimensionInputs
      self.heightMode = heightMode
      self.devicePreset = devicePreset
      self.canvasHeight = canvasHeight
      self.canvasWidth = canvasWidth
      self.canvasName = canvasName
      self.backgroundColorId = backgroundColorId
    }

    public init() {
      self
        .init(
          showsDimensionInputs: false,
          heightMode: .flexibleHeight,
          devicePreset: "",
          canvasHeight: 0,
          canvasWidth: 0,
          canvasName: nil,
          backgroundColorId: "")
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.showsDimensionInputs == rhs.showsDimensionInputs &&
        lhs.heightMode == rhs.heightMode &&
          lhs.devicePreset == rhs.devicePreset &&
            lhs.canvasHeight == rhs.canvasHeight &&
              lhs.canvasWidth == rhs.canvasWidth &&
                lhs.canvasName == rhs.canvasName && lhs.backgroundColorId == rhs.backgroundColorId
    }
  }
}

// MARK: - Model

extension CanvasInspector {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "CanvasInspector"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      showsDimensionInputs: Bool,
      heightMode: CanvasHeight,
      devicePreset: String,
      canvasHeight: CGFloat,
      canvasWidth: CGFloat,
      canvasName: String? = nil,
      backgroundColorId: String)
    {
      self
        .init(
          Parameters(
            showsDimensionInputs: showsDimensionInputs,
            heightMode: heightMode,
            devicePreset: devicePreset,
            canvasHeight: canvasHeight,
            canvasWidth: canvasWidth,
            canvasName: canvasName,
            backgroundColorId: backgroundColorId))
    }

    public init() {
      self
        .init(
          showsDimensionInputs: false,
          heightMode: .flexibleHeight,
          devicePreset: "",
          canvasHeight: 0,
          canvasWidth: 0,
          canvasName: nil,
          backgroundColorId: "")
    }
  }
}

// MARK: - CanvasHeight

extension CanvasInspector {
  public enum CanvasHeight: Codable, Equatable {
    case flexibleHeight
    case fixedHeight

    // MARK: Codable

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let type = try container.decode(Bool.self)

      switch type {
        case false:
          self = .flexibleHeight
        case true:
          self = .fixedHeight
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()

      switch self {
        case .flexibleHeight:
          try container.encode(false)
        case .fixedHeight:
          try container.encode(true)
      }
    }
  }
}
