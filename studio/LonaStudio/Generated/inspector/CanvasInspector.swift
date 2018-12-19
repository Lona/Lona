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

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private var presetRowView = NSBox()
  private var presetLabelView = LNATextField(labelWithString: "")
  private var presetDropdownView = ControlledDropdown()
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

  private var presetLabelViewTextStyle = TextStyles.regular
  private var deviceLabelViewTextStyle = TextStyles.regular
  private var widthLabelViewTextStyle = TextStyles.regular
  private var heightLabelViewTextStyle = TextStyles.regular
  private var nameLabelViewTextStyle = TextStyles.regular
  private var backgroundColorLabelViewTextStyle = TextStyles.regular

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    presetRowView.boxType = .custom
    presetRowView.borderType = .noBorder
    presetRowView.contentViewMargins = .zero
    deviceRowView.boxType = .custom
    deviceRowView.borderType = .noBorder
    deviceRowView.contentViewMargins = .zero
    nameRowView.boxType = .custom
    nameRowView.borderType = .noBorder
    nameRowView.contentViewMargins = .zero
    backgroundColorRowView.boxType = .custom
    backgroundColorRowView.borderType = .noBorder
    backgroundColorRowView.contentViewMargins = .zero
    presetLabelView.lineBreakMode = .byWordWrapping
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

    addSubview(presetRowView)
    addSubview(deviceRowView)
    addSubview(nameRowView)
    addSubview(backgroundColorRowView)
    presetRowView.addSubview(presetLabelView)
    presetRowView.addSubview(presetDropdownView)
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

    presetLabelView.attributedStringValue = presetLabelViewTextStyle.apply(to: "Preset")
    presetDropdownView.selectedIndex = 0
    presetDropdownView.values = ["Component (Flexible-height)", "Screen (Fixed-height)"]
    deviceLabelView.attributedStringValue = deviceLabelViewTextStyle.apply(to: "Device")
    deviceDropdownView.selectedIndex = 0
    deviceDropdownView.values = []
    widthLabelView.attributedStringValue = widthLabelViewTextStyle.apply(to: "Width")
    widthInputView.numberValue = 0
    heightLabelView.attributedStringValue = heightLabelViewTextStyle.apply(to: "Height")
    heightInputView.numberValue = 0
    nameLabelView.attributedStringValue = nameLabelViewTextStyle.apply(to: "Name")
    nameInputView.textValue = "Text"
    backgroundColorLabelView.attributedStringValue = backgroundColorLabelViewTextStyle.apply(to: "Background")
    backgroundColorInputView.textValue = "Text"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    presetRowView.translatesAutoresizingMaskIntoConstraints = false
    deviceRowView.translatesAutoresizingMaskIntoConstraints = false
    nameRowView.translatesAutoresizingMaskIntoConstraints = false
    backgroundColorRowView.translatesAutoresizingMaskIntoConstraints = false
    presetLabelView.translatesAutoresizingMaskIntoConstraints = false
    presetDropdownView.translatesAutoresizingMaskIntoConstraints = false
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

    let presetRowViewTopAnchorConstraint = presetRowView.topAnchor.constraint(equalTo: topAnchor, constant: 16)
    let presetRowViewLeadingAnchorConstraint = presetRowView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let presetRowViewTrailingAnchorConstraint = presetRowView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let deviceRowViewTopAnchorConstraint = deviceRowView
      .topAnchor
      .constraint(equalTo: presetRowView.bottomAnchor, constant: 16)
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
    let presetLabelViewHeightAnchorParentConstraint = presetLabelView
      .heightAnchor
      .constraint(lessThanOrEqualTo: presetRowView.heightAnchor)
    let presetDropdownViewHeightAnchorParentConstraint = presetDropdownView
      .heightAnchor
      .constraint(lessThanOrEqualTo: presetRowView.heightAnchor)
    let presetLabelViewLeadingAnchorConstraint = presetLabelView
      .leadingAnchor
      .constraint(equalTo: presetRowView.leadingAnchor)
    let presetLabelViewTopAnchorConstraint = presetLabelView.topAnchor.constraint(equalTo: presetRowView.topAnchor)
    let presetLabelViewCenterYAnchorConstraint = presetLabelView
      .centerYAnchor
      .constraint(equalTo: presetRowView.centerYAnchor)
    let presetLabelViewBottomAnchorConstraint = presetLabelView
      .bottomAnchor
      .constraint(equalTo: presetRowView.bottomAnchor)
    let presetDropdownViewTrailingAnchorConstraint = presetDropdownView
      .trailingAnchor
      .constraint(equalTo: presetRowView.trailingAnchor)
    let presetDropdownViewLeadingAnchorConstraint = presetDropdownView
      .leadingAnchor
      .constraint(equalTo: presetLabelView.trailingAnchor, constant: 20)
    let presetDropdownViewTopAnchorConstraint = presetDropdownView
      .topAnchor
      .constraint(equalTo: presetRowView.topAnchor)
    let presetDropdownViewCenterYAnchorConstraint = presetDropdownView
      .centerYAnchor
      .constraint(equalTo: presetRowView.centerYAnchor)
    let presetDropdownViewBottomAnchorConstraint = presetDropdownView
      .bottomAnchor
      .constraint(equalTo: presetRowView.bottomAnchor)
    let deviceLabelViewHeightAnchorParentConstraint = deviceLabelView
      .heightAnchor
      .constraint(lessThanOrEqualTo: deviceRowView.heightAnchor, constant: -4)
    let deviceValueContainerViewHeightAnchorParentConstraint = deviceValueContainerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: deviceRowView.heightAnchor)
    let deviceLabelViewLeadingAnchorConstraint = deviceLabelView
      .leadingAnchor
      .constraint(equalTo: deviceRowView.leadingAnchor)
    let deviceLabelViewTopAnchorConstraint = deviceLabelView
      .topAnchor
      .constraint(equalTo: deviceRowView.topAnchor, constant: 4)
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
    let presetLabelViewWidthAnchorConstraint = presetLabelView.widthAnchor.constraint(equalToConstant: 80)
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
    let hSpacerViewWidthAnchorConstraint = hSpacerView.widthAnchor.constraint(equalToConstant: 20)
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

    presetLabelViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    presetDropdownViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
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
      presetRowViewTopAnchorConstraint,
      presetRowViewLeadingAnchorConstraint,
      presetRowViewTrailingAnchorConstraint,
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
      presetLabelViewHeightAnchorParentConstraint,
      presetDropdownViewHeightAnchorParentConstraint,
      presetLabelViewLeadingAnchorConstraint,
      presetLabelViewTopAnchorConstraint,
      presetLabelViewCenterYAnchorConstraint,
      presetLabelViewBottomAnchorConstraint,
      presetDropdownViewTrailingAnchorConstraint,
      presetDropdownViewLeadingAnchorConstraint,
      presetDropdownViewTopAnchorConstraint,
      presetDropdownViewCenterYAnchorConstraint,
      presetDropdownViewBottomAnchorConstraint,
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
      presetLabelViewWidthAnchorConstraint,
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

  private func update() {}
}

// MARK: - Parameters

extension CanvasInspector {
  public struct Parameters: Equatable {
    public init() {}
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

    public init() {
      self.init(Parameters())
    }
  }
}
