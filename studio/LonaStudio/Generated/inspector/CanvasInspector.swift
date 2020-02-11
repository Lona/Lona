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
    availableDevices: [String],
    deviceIndex: Int,
    heightMode: CanvasHeight,
    devicePreset: String,
    canvasHeight: CGFloat,
    canvasWidth: CGFloat,
    canvasName: String?,
    canvasNamePlaceholder: String,
    backgroundColorId: String)
  {
    self
      .init(
        Parameters(
          showsDimensionInputs: showsDimensionInputs,
          availableDevices: availableDevices,
          deviceIndex: deviceIndex,
          heightMode: heightMode,
          devicePreset: devicePreset,
          canvasHeight: canvasHeight,
          canvasWidth: canvasWidth,
          canvasName: canvasName,
          canvasNamePlaceholder: canvasNamePlaceholder,
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

  public var availableDevices: [String] {
    get { return parameters.availableDevices }
    set {
      if parameters.availableDevices != newValue {
        parameters.availableDevices = newValue
      }
    }
  }

  public var deviceIndex: Int {
    get { return parameters.deviceIndex }
    set {
      if parameters.deviceIndex != newValue {
        parameters.deviceIndex = newValue
      }
    }
  }

  public var onChangeDeviceIndex: ((Int) -> Void)? {
    get { return parameters.onChangeDeviceIndex }
    set { parameters.onChangeDeviceIndex = newValue }
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

  public var canvasNamePlaceholder: String {
    get { return parameters.canvasNamePlaceholder }
    set {
      if parameters.canvasNamePlaceholder != newValue {
        parameters.canvasNamePlaceholder = newValue
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

  public var onChangeCanvasName: StringHandler {
    get { return parameters.onChangeCanvasName }
    set { parameters.onChangeCanvasName = newValue }
  }

  public var onChangeCanvasWidth: ((CGFloat) -> Void)? {
    get { return parameters.onChangeCanvasWidth }
    set { parameters.onChangeCanvasWidth = newValue }
  }

  public var onChangeCanvasHeight: ((CGFloat) -> Void)? {
    get { return parameters.onChangeCanvasHeight }
    set { parameters.onChangeCanvasHeight = newValue }
  }

  public var onChangeHeightModeIndex: ((Int) -> Void)? {
    get { return parameters.onChangeHeightModeIndex }
    set { parameters.onChangeHeightModeIndex = newValue }
  }

  public var onChangeBackgroundColorId: StringHandler {
    get { return parameters.onChangeBackgroundColorId }
    set { parameters.onChangeBackgroundColorId = newValue }
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
    layoutDropdownView.values = ["Flexible-height", "Fixed-size"]
    deviceLabelView.attributedStringValue = deviceLabelViewTextStyle.apply(to: "Device")
    widthLabelView.attributedStringValue = widthLabelViewTextStyle.apply(to: "Width")
    nameLabelView.attributedStringValue = nameLabelViewTextStyle.apply(to: "Name")
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
    let customDimensionsContainerViewBottomAnchorConstraint = customDimensionsContainerView
      .bottomAnchor
      .constraint(equalTo: deviceValueContainerView.bottomAnchor)
    let customDimensionsContainerViewTopAnchorConstraint = customDimensionsContainerView
      .topAnchor
      .constraint(equalTo: deviceDropdownView.bottomAnchor, constant: 16)
    let customDimensionsContainerViewLeadingAnchorConstraint = customDimensionsContainerView
      .leadingAnchor
      .constraint(equalTo: deviceValueContainerView.leadingAnchor)
    let customDimensionsContainerViewTrailingAnchorConstraint = customDimensionsContainerView
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
    let widthContainerViewLeadingAnchorConstraint = widthContainerView
      .leadingAnchor
      .constraint(equalTo: customDimensionsContainerView.leadingAnchor)
    let widthContainerViewTopAnchorConstraint = widthContainerView
      .topAnchor
      .constraint(equalTo: customDimensionsContainerView.topAnchor)
    let widthContainerViewBottomAnchorConstraint = widthContainerView
      .bottomAnchor
      .constraint(equalTo: customDimensionsContainerView.bottomAnchor)
    let hSpacerViewLeadingAnchorConstraint = hSpacerView
      .leadingAnchor
      .constraint(equalTo: widthContainerView.trailingAnchor)
    let hSpacerViewTopAnchorConstraint = hSpacerView
      .topAnchor
      .constraint(equalTo: customDimensionsContainerView.topAnchor)
    let heightContainerViewTrailingAnchorConstraint = heightContainerView
      .trailingAnchor
      .constraint(equalTo: customDimensionsContainerView.trailingAnchor)
    let heightContainerViewLeadingAnchorConstraint = heightContainerView
      .leadingAnchor
      .constraint(equalTo: hSpacerView.trailingAnchor)
    let heightContainerViewTopAnchorConstraint = heightContainerView
      .topAnchor
      .constraint(equalTo: customDimensionsContainerView.topAnchor)
    let heightContainerViewBottomAnchorConstraint = heightContainerView
      .bottomAnchor
      .constraint(equalTo: customDimensionsContainerView.bottomAnchor)
    let widthLabelViewTopAnchorConstraint = widthLabelView.topAnchor.constraint(equalTo: widthContainerView.topAnchor)
    let widthLabelViewLeadingAnchorConstraint = widthLabelView
      .leadingAnchor
      .constraint(equalTo: widthContainerView.leadingAnchor)
    let widthLabelViewTrailingAnchorConstraint = widthLabelView
      .trailingAnchor
      .constraint(equalTo: widthContainerView.trailingAnchor)
    let widthInputViewBottomAnchorConstraint = widthInputView
      .bottomAnchor
      .constraint(equalTo: widthContainerView.bottomAnchor)
    let widthInputViewTopAnchorConstraint = widthInputView
      .topAnchor
      .constraint(equalTo: widthLabelView.bottomAnchor, constant: 8)
    let widthInputViewLeadingAnchorConstraint = widthInputView
      .leadingAnchor
      .constraint(equalTo: widthContainerView.leadingAnchor)
    let widthInputViewTrailingAnchorConstraint = widthInputView
      .trailingAnchor
      .constraint(equalTo: widthContainerView.trailingAnchor)
    let hSpacerViewHeightAnchorConstraint = hSpacerView.heightAnchor.constraint(equalToConstant: 0)
    let hSpacerViewWidthAnchorConstraint = hSpacerView.widthAnchor.constraint(equalToConstant: 8)
    let heightLabelViewTopAnchorConstraint = heightLabelView
      .topAnchor
      .constraint(equalTo: heightContainerView.topAnchor)
    let heightLabelViewLeadingAnchorConstraint = heightLabelView
      .leadingAnchor
      .constraint(equalTo: heightContainerView.leadingAnchor)
    let heightLabelViewTrailingAnchorConstraint = heightLabelView
      .trailingAnchor
      .constraint(equalTo: heightContainerView.trailingAnchor)
    let heightInputViewBottomAnchorConstraint = heightInputView
      .bottomAnchor
      .constraint(equalTo: heightContainerView.bottomAnchor)
    let heightInputViewTopAnchorConstraint = heightInputView
      .topAnchor
      .constraint(equalTo: heightLabelView.bottomAnchor, constant: 8)
    let heightInputViewLeadingAnchorConstraint = heightInputView
      .leadingAnchor
      .constraint(equalTo: heightContainerView.leadingAnchor)
    let heightInputViewTrailingAnchorConstraint = heightInputView
      .trailingAnchor
      .constraint(equalTo: heightContainerView.trailingAnchor)
    let nameLabelViewWidthAnchorConstraint = nameLabelView.widthAnchor.constraint(equalToConstant: 80)
    let backgroundColorLabelViewWidthAnchorConstraint = backgroundColorLabelView
      .widthAnchor
      .constraint(equalToConstant: 80)

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

    NSLayoutConstraint.activate([
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
      customDimensionsContainerViewBottomAnchorConstraint,
      customDimensionsContainerViewTopAnchorConstraint,
      customDimensionsContainerViewLeadingAnchorConstraint,
      customDimensionsContainerViewTrailingAnchorConstraint,
      widthContainerViewHeightContainerViewWidthAnchorSiblingConstraint,
      widthContainerViewHeightAnchorParentConstraint,
      hSpacerViewHeightAnchorParentConstraint,
      heightContainerViewHeightAnchorParentConstraint,
      widthContainerViewLeadingAnchorConstraint,
      widthContainerViewTopAnchorConstraint,
      widthContainerViewBottomAnchorConstraint,
      hSpacerViewLeadingAnchorConstraint,
      hSpacerViewTopAnchorConstraint,
      heightContainerViewTrailingAnchorConstraint,
      heightContainerViewLeadingAnchorConstraint,
      heightContainerViewTopAnchorConstraint,
      heightContainerViewBottomAnchorConstraint,
      widthLabelViewTopAnchorConstraint,
      widthLabelViewLeadingAnchorConstraint,
      widthLabelViewTrailingAnchorConstraint,
      widthInputViewBottomAnchorConstraint,
      widthInputViewTopAnchorConstraint,
      widthInputViewLeadingAnchorConstraint,
      widthInputViewTrailingAnchorConstraint,
      hSpacerViewHeightAnchorConstraint,
      hSpacerViewWidthAnchorConstraint,
      heightLabelViewTopAnchorConstraint,
      heightLabelViewLeadingAnchorConstraint,
      heightLabelViewTrailingAnchorConstraint,
      heightInputViewBottomAnchorConstraint,
      heightInputViewTopAnchorConstraint,
      heightInputViewLeadingAnchorConstraint,
      heightInputViewTrailingAnchorConstraint,
      nameLabelViewWidthAnchorConstraint,
      backgroundColorLabelViewWidthAnchorConstraint
    ])
  }

  private func update() {
    heightLabelView.attributedStringValue = heightLabelViewTextStyle.apply(to: "Height")
    layoutDropdownView.selectedIndex = 0
    heightInputView.disabled = showsDimensionInputs
    widthInputView.disabled = showsDimensionInputs
    deviceDropdownView.values = availableDevices
    deviceDropdownView.selectedIndex = deviceIndex
    deviceDropdownView.onChangeIndex = handleOnChangeDeviceIndex
    layoutDropdownView.onChangeIndex = handleOnChangeHeightModeIndex
    widthInputView.numberValue = canvasWidth
    heightInputView.numberValue = canvasHeight
    backgroundColorInputView.textValue = backgroundColorId
    backgroundColorInputView.onChangeTextValue = handleOnChangeBackgroundColorId
    nameInputView.placeholderString = canvasNamePlaceholder
    if heightMode == .flexibleHeight {
      layoutDropdownView.selectedIndex = 0
      heightLabelView.attributedStringValue = heightLabelViewTextStyle.apply(to: "Min Height")
    }
    if heightMode == .fixedHeight {
      layoutDropdownView.selectedIndex = 1
    }
    var intermediateCanvasName = ""
    if let canvasName = canvasName {
      intermediateCanvasName = canvasName
    }
    nameInputView.textValue = intermediateCanvasName
    nameInputView.onChangeTextValue = handleOnChangeCanvasName
    heightInputView.onChangeNumberValue = handleOnChangeCanvasHeight
    widthInputView.onChangeNumberValue = handleOnChangeCanvasWidth
  }

  private func handleOnChangeDeviceIndex(_ arg0: Int) {
    onChangeDeviceIndex?(arg0)
  }

  private func handleOnChangeCanvasName(_ arg0: String) {
    onChangeCanvasName?(arg0)
  }

  private func handleOnChangeCanvasWidth(_ arg0: CGFloat) {
    onChangeCanvasWidth?(arg0)
  }

  private func handleOnChangeCanvasHeight(_ arg0: CGFloat) {
    onChangeCanvasHeight?(arg0)
  }

  private func handleOnChangeHeightModeIndex(_ arg0: Int) {
    onChangeHeightModeIndex?(arg0)
  }

  private func handleOnChangeBackgroundColorId(_ arg0: String) {
    onChangeBackgroundColorId?(arg0)
  }
}

// MARK: - Parameters

extension CanvasInspector {
  public struct Parameters: Equatable {
    public var showsDimensionInputs: Bool
    public var availableDevices: [String]
    public var deviceIndex: Int
    public var heightMode: CanvasHeight
    public var devicePreset: String
    public var canvasHeight: CGFloat
    public var canvasWidth: CGFloat
    public var canvasName: String?
    public var canvasNamePlaceholder: String
    public var backgroundColorId: String
    public var onChangeDeviceIndex: ((Int) -> Void)?
    public var onChangeCanvasName: StringHandler
    public var onChangeCanvasWidth: ((CGFloat) -> Void)?
    public var onChangeCanvasHeight: ((CGFloat) -> Void)?
    public var onChangeHeightModeIndex: ((Int) -> Void)?
    public var onChangeBackgroundColorId: StringHandler

    public init(
      showsDimensionInputs: Bool,
      availableDevices: [String],
      deviceIndex: Int,
      heightMode: CanvasHeight,
      devicePreset: String,
      canvasHeight: CGFloat,
      canvasWidth: CGFloat,
      canvasName: String? = nil,
      canvasNamePlaceholder: String,
      backgroundColorId: String,
      onChangeDeviceIndex: ((Int) -> Void)? = nil,
      onChangeCanvasName: StringHandler = nil,
      onChangeCanvasWidth: ((CGFloat) -> Void)? = nil,
      onChangeCanvasHeight: ((CGFloat) -> Void)? = nil,
      onChangeHeightModeIndex: ((Int) -> Void)? = nil,
      onChangeBackgroundColorId: StringHandler = nil)
    {
      self.showsDimensionInputs = showsDimensionInputs
      self.availableDevices = availableDevices
      self.deviceIndex = deviceIndex
      self.heightMode = heightMode
      self.devicePreset = devicePreset
      self.canvasHeight = canvasHeight
      self.canvasWidth = canvasWidth
      self.canvasName = canvasName
      self.canvasNamePlaceholder = canvasNamePlaceholder
      self.backgroundColorId = backgroundColorId
      self.onChangeDeviceIndex = onChangeDeviceIndex
      self.onChangeCanvasName = onChangeCanvasName
      self.onChangeCanvasWidth = onChangeCanvasWidth
      self.onChangeCanvasHeight = onChangeCanvasHeight
      self.onChangeHeightModeIndex = onChangeHeightModeIndex
      self.onChangeBackgroundColorId = onChangeBackgroundColorId
    }

    public init() {
      self
        .init(
          showsDimensionInputs: false,
          availableDevices: [],
          deviceIndex: 0,
          heightMode: .flexibleHeight,
          devicePreset: "",
          canvasHeight: 0,
          canvasWidth: 0,
          canvasName: nil,
          canvasNamePlaceholder: "",
          backgroundColorId: "")
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.showsDimensionInputs == rhs.showsDimensionInputs &&
        lhs.availableDevices == rhs.availableDevices &&
          lhs.deviceIndex == rhs.deviceIndex &&
            lhs.heightMode == rhs.heightMode &&
              lhs.devicePreset == rhs.devicePreset &&
                lhs.canvasHeight == rhs.canvasHeight &&
                  lhs.canvasWidth == rhs.canvasWidth &&
                    lhs.canvasName == rhs.canvasName &&
                      lhs.canvasNamePlaceholder == rhs.canvasNamePlaceholder &&
                        lhs.backgroundColorId == rhs.backgroundColorId
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
      availableDevices: [String],
      deviceIndex: Int,
      heightMode: CanvasHeight,
      devicePreset: String,
      canvasHeight: CGFloat,
      canvasWidth: CGFloat,
      canvasName: String? = nil,
      canvasNamePlaceholder: String,
      backgroundColorId: String,
      onChangeDeviceIndex: ((Int) -> Void)? = nil,
      onChangeCanvasName: StringHandler = nil,
      onChangeCanvasWidth: ((CGFloat) -> Void)? = nil,
      onChangeCanvasHeight: ((CGFloat) -> Void)? = nil,
      onChangeHeightModeIndex: ((Int) -> Void)? = nil,
      onChangeBackgroundColorId: StringHandler = nil)
    {
      self
        .init(
          Parameters(
            showsDimensionInputs: showsDimensionInputs,
            availableDevices: availableDevices,
            deviceIndex: deviceIndex,
            heightMode: heightMode,
            devicePreset: devicePreset,
            canvasHeight: canvasHeight,
            canvasWidth: canvasWidth,
            canvasName: canvasName,
            canvasNamePlaceholder: canvasNamePlaceholder,
            backgroundColorId: backgroundColorId,
            onChangeDeviceIndex: onChangeDeviceIndex,
            onChangeCanvasName: onChangeCanvasName,
            onChangeCanvasWidth: onChangeCanvasWidth,
            onChangeCanvasHeight: onChangeCanvasHeight,
            onChangeHeightModeIndex: onChangeHeightModeIndex,
            onChangeBackgroundColorId: onChangeBackgroundColorId))
    }

    public init() {
      self
        .init(
          showsDimensionInputs: false,
          availableDevices: [],
          deviceIndex: 0,
          heightMode: .flexibleHeight,
          devicePreset: "",
          canvasHeight: 0,
          canvasWidth: 0,
          canvasName: nil,
          canvasNamePlaceholder: "",
          backgroundColorId: "")
    }
  }
}

// MARK: - CanvasHeight

extension CanvasInspector {
  public indirect enum CanvasHeight: Codable & Equatable {
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
