import AppKit
import Foundation

// MARK: - AccessibilityInspector

public class AccessibilityInspector: NSBox {

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
    accessibilityTypeIndex: Int,
    accessibilityLabelText: String,
    accessibilityHintText: String,
    accessibilityElements: [String])
  {
    self
      .init(
        Parameters(
          isExpanded: isExpanded,
          accessibilityTypeIndex: accessibilityTypeIndex,
          accessibilityLabelText: accessibilityLabelText,
          accessibilityHintText: accessibilityHintText,
          accessibilityElements: accessibilityElements))
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

  public var accessibilityTypeIndex: Int {
    get { return parameters.accessibilityTypeIndex }
    set {
      if parameters.accessibilityTypeIndex != newValue {
        parameters.accessibilityTypeIndex = newValue
      }
    }
  }

  public var onChangeAccessibilityTypeIndex: ((Int) -> Void)? {
    get { return parameters.onChangeAccessibilityTypeIndex }
    set { parameters.onChangeAccessibilityTypeIndex = newValue }
  }

  public var accessibilityLabelText: String {
    get { return parameters.accessibilityLabelText }
    set {
      if parameters.accessibilityLabelText != newValue {
        parameters.accessibilityLabelText = newValue
      }
    }
  }

  public var onChangeAccessibilityLabel: StringHandler {
    get { return parameters.onChangeAccessibilityLabel }
    set { parameters.onChangeAccessibilityLabel = newValue }
  }

  public var accessibilityHintText: String {
    get { return parameters.accessibilityHintText }
    set {
      if parameters.accessibilityHintText != newValue {
        parameters.accessibilityHintText = newValue
      }
    }
  }

  public var onChangeAccessibilityHintText: StringHandler {
    get { return parameters.onChangeAccessibilityHintText }
    set { parameters.onChangeAccessibilityHintText = newValue }
  }

  public var accessibilityElements: [String] {
    get { return parameters.accessibilityElements }
    set {
      if parameters.accessibilityElements != newValue {
        parameters.accessibilityElements = newValue
      }
    }
  }

  public var onChangeAccessibilityElements: (([String]) -> Void)? {
    get { return parameters.onChangeAccessibilityElements }
    set { parameters.onChangeAccessibilityElements = newValue }
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
  private var typeLabelView = LNATextField(labelWithString: "")
  private var typeDropdownView = ControlledDropdown()
  private var elementContainerView = NSBox()
  private var labelLabelView = LNATextField(labelWithString: "")
  private var labelTextInputView = TextInput()
  private var hintLabelView = LNATextField(labelWithString: "")
  private var hintTextInputView = TextInput()
  private var roleLabelView = LNATextField(labelWithString: "")
  private var roleDropdownView = ControlledDropdown()
  private var statesLabelView = LNATextField(labelWithString: "")
  private var statesDropdownView = ControlledDropdown()
  private var hDividerView = NSBox()

  private var typeLabelViewTextStyle = TextStyles.regular
  private var labelLabelViewTextStyle = TextStyles.regular
  private var hintLabelViewTextStyle = TextStyles.regular
  private var roleLabelViewTextStyle = TextStyles.regular
  private var statesLabelViewTextStyle = TextStyles.regular

  private var hDividerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint: NSLayoutConstraint?
  private var contentContainerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint: NSLayoutConstraint?
  private var contentContainerViewLeadingAnchorLeadingAnchorConstraint: NSLayoutConstraint?
  private var contentContainerViewTrailingAnchorTrailingAnchorConstraint: NSLayoutConstraint?
  private var hDividerViewTopAnchorContentContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var typeLabelViewTopAnchorContentContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var typeLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var typeLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var typeDropdownViewBottomAnchorContentContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var typeDropdownViewTopAnchorTypeLabelViewBottomAnchorConstraint: NSLayoutConstraint?
  private var typeDropdownViewLeadingAnchorContentContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var typeDropdownViewTrailingAnchorContentContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var elementContainerViewBottomAnchorContentContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var elementContainerViewTopAnchorTypeDropdownViewBottomAnchorConstraint: NSLayoutConstraint?
  private var elementContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var elementContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var labelLabelViewTopAnchorElementContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var labelLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var labelLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var labelTextInputViewTopAnchorLabelLabelViewBottomAnchorConstraint: NSLayoutConstraint?
  private var labelTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var labelTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var hintLabelViewTopAnchorLabelTextInputViewBottomAnchorConstraint: NSLayoutConstraint?
  private var hintLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var hintLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var hintTextInputViewTopAnchorHintLabelViewBottomAnchorConstraint: NSLayoutConstraint?
  private var hintTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var hintTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var roleLabelViewTopAnchorHintTextInputViewBottomAnchorConstraint: NSLayoutConstraint?
  private var roleLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var roleLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var roleDropdownViewTopAnchorRoleLabelViewBottomAnchorConstraint: NSLayoutConstraint?
  private var roleDropdownViewLeadingAnchorElementContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var roleDropdownViewTrailingAnchorElementContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var statesLabelViewTopAnchorRoleDropdownViewBottomAnchorConstraint: NSLayoutConstraint?
  private var statesLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var statesLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var statesDropdownViewBottomAnchorElementContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var statesDropdownViewTopAnchorStatesLabelViewBottomAnchorConstraint: NSLayoutConstraint?
  private var statesDropdownViewLeadingAnchorElementContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var statesDropdownViewTrailingAnchorElementContainerViewTrailingAnchorConstraint: NSLayoutConstraint?

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
    typeLabelView.lineBreakMode = .byWordWrapping
    elementContainerView.boxType = .custom
    elementContainerView.borderType = .noBorder
    elementContainerView.contentViewMargins = .zero
    labelLabelView.lineBreakMode = .byWordWrapping
    hintLabelView.lineBreakMode = .byWordWrapping
    roleLabelView.lineBreakMode = .byWordWrapping
    statesLabelView.lineBreakMode = .byWordWrapping

    addSubview(inspectorSectionHeaderView)
    addSubview(contentContainerView)
    addSubview(hDividerView)
    contentContainerView.addSubview(typeLabelView)
    contentContainerView.addSubview(typeDropdownView)
    contentContainerView.addSubview(elementContainerView)
    elementContainerView.addSubview(labelLabelView)
    elementContainerView.addSubview(labelTextInputView)
    elementContainerView.addSubview(hintLabelView)
    elementContainerView.addSubview(hintTextInputView)
    elementContainerView.addSubview(roleLabelView)
    elementContainerView.addSubview(roleDropdownView)
    elementContainerView.addSubview(statesLabelView)
    elementContainerView.addSubview(statesDropdownView)

    inspectorSectionHeaderView.titleText = "Accessibility"
    typeLabelView.attributedStringValue = typeLabelViewTextStyle.apply(to: "Type")
    typeLabelViewTextStyle = TextStyles.regular
    typeLabelView.attributedStringValue = typeLabelViewTextStyle.apply(to: typeLabelView.attributedStringValue)
    typeDropdownView.values = ["Auto", "None", "Element", "Container"]
    labelLabelView.attributedStringValue = labelLabelViewTextStyle.apply(to: "Label")
    labelTextInputView.placeholderString = "Label"
    hintLabelView.attributedStringValue = hintLabelViewTextStyle.apply(to: "Hint")
    hintTextInputView.placeholderString = "Hint"
    roleLabelView.attributedStringValue = roleLabelViewTextStyle.apply(to: "Role")
    roleDropdownView.selectedIndex = 0
    roleDropdownView.values = [
      "None",
      "Button",
      "Link",
      "Search",
      "Image",
      "Keyboard Key",
      "Text",
      "Adjustable",
      "Header",
      "Summary"
    ]
    statesLabelView.attributedStringValue = statesLabelViewTextStyle.apply(to: "States")
    statesDropdownView.selectedIndex = 0
    statesDropdownView.values = ["None", "Selected", "Disabled", "Selected and Disabled"]
    hDividerView.fillColor = Colors.dividerSubtle
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    inspectorSectionHeaderView.translatesAutoresizingMaskIntoConstraints = false
    contentContainerView.translatesAutoresizingMaskIntoConstraints = false
    hDividerView.translatesAutoresizingMaskIntoConstraints = false
    typeLabelView.translatesAutoresizingMaskIntoConstraints = false
    typeDropdownView.translatesAutoresizingMaskIntoConstraints = false
    elementContainerView.translatesAutoresizingMaskIntoConstraints = false
    labelLabelView.translatesAutoresizingMaskIntoConstraints = false
    labelTextInputView.translatesAutoresizingMaskIntoConstraints = false
    hintLabelView.translatesAutoresizingMaskIntoConstraints = false
    hintTextInputView.translatesAutoresizingMaskIntoConstraints = false
    roleLabelView.translatesAutoresizingMaskIntoConstraints = false
    roleDropdownView.translatesAutoresizingMaskIntoConstraints = false
    statesLabelView.translatesAutoresizingMaskIntoConstraints = false
    statesDropdownView.translatesAutoresizingMaskIntoConstraints = false

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
    let typeLabelViewTopAnchorContentContainerViewTopAnchorConstraint = typeLabelView
      .topAnchor
      .constraint(equalTo: contentContainerView.topAnchor)
    let typeLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint = typeLabelView
      .leadingAnchor
      .constraint(equalTo: contentContainerView.leadingAnchor)
    let typeLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint = typeLabelView
      .trailingAnchor
      .constraint(equalTo: contentContainerView.trailingAnchor)
    let typeDropdownViewBottomAnchorContentContainerViewBottomAnchorConstraint = typeDropdownView
      .bottomAnchor
      .constraint(equalTo: contentContainerView.bottomAnchor, constant: -16)
    let typeDropdownViewTopAnchorTypeLabelViewBottomAnchorConstraint = typeDropdownView
      .topAnchor
      .constraint(equalTo: typeLabelView.bottomAnchor, constant: 8)
    let typeDropdownViewLeadingAnchorContentContainerViewLeadingAnchorConstraint = typeDropdownView
      .leadingAnchor
      .constraint(equalTo: contentContainerView.leadingAnchor)
    let typeDropdownViewTrailingAnchorContentContainerViewTrailingAnchorConstraint = typeDropdownView
      .trailingAnchor
      .constraint(equalTo: contentContainerView.trailingAnchor)
    let elementContainerViewBottomAnchorContentContainerViewBottomAnchorConstraint = elementContainerView
      .bottomAnchor
      .constraint(equalTo: contentContainerView.bottomAnchor, constant: -16)
    let elementContainerViewTopAnchorTypeDropdownViewBottomAnchorConstraint = elementContainerView
      .topAnchor
      .constraint(equalTo: typeDropdownView.bottomAnchor)
    let elementContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint = elementContainerView
      .leadingAnchor
      .constraint(equalTo: contentContainerView.leadingAnchor)
    let elementContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint = elementContainerView
      .trailingAnchor
      .constraint(equalTo: contentContainerView.trailingAnchor)
    let labelLabelViewTopAnchorElementContainerViewTopAnchorConstraint = labelLabelView
      .topAnchor
      .constraint(equalTo: elementContainerView.topAnchor, constant: 16)
    let labelLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint = labelLabelView
      .leadingAnchor
      .constraint(equalTo: elementContainerView.leadingAnchor)
    let labelLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint = labelLabelView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: elementContainerView.trailingAnchor)
    let labelTextInputViewTopAnchorLabelLabelViewBottomAnchorConstraint = labelTextInputView
      .topAnchor
      .constraint(equalTo: labelLabelView.bottomAnchor, constant: 8)
    let labelTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint = labelTextInputView
      .leadingAnchor
      .constraint(equalTo: elementContainerView.leadingAnchor)
    let labelTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint = labelTextInputView
      .trailingAnchor
      .constraint(equalTo: elementContainerView.trailingAnchor)
    let hintLabelViewTopAnchorLabelTextInputViewBottomAnchorConstraint = hintLabelView
      .topAnchor
      .constraint(equalTo: labelTextInputView.bottomAnchor, constant: 16)
    let hintLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint = hintLabelView
      .leadingAnchor
      .constraint(equalTo: elementContainerView.leadingAnchor)
    let hintLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint = hintLabelView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: elementContainerView.trailingAnchor)
    let hintTextInputViewTopAnchorHintLabelViewBottomAnchorConstraint = hintTextInputView
      .topAnchor
      .constraint(equalTo: hintLabelView.bottomAnchor, constant: 8)
    let hintTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint = hintTextInputView
      .leadingAnchor
      .constraint(equalTo: elementContainerView.leadingAnchor)
    let hintTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint = hintTextInputView
      .trailingAnchor
      .constraint(equalTo: elementContainerView.trailingAnchor)
    let roleLabelViewTopAnchorHintTextInputViewBottomAnchorConstraint = roleLabelView
      .topAnchor
      .constraint(equalTo: hintTextInputView.bottomAnchor, constant: 16)
    let roleLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint = roleLabelView
      .leadingAnchor
      .constraint(equalTo: elementContainerView.leadingAnchor)
    let roleLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint = roleLabelView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: elementContainerView.trailingAnchor)
    let roleDropdownViewTopAnchorRoleLabelViewBottomAnchorConstraint = roleDropdownView
      .topAnchor
      .constraint(equalTo: roleLabelView.bottomAnchor, constant: 8)
    let roleDropdownViewLeadingAnchorElementContainerViewLeadingAnchorConstraint = roleDropdownView
      .leadingAnchor
      .constraint(equalTo: elementContainerView.leadingAnchor)
    let roleDropdownViewTrailingAnchorElementContainerViewTrailingAnchorConstraint = roleDropdownView
      .trailingAnchor
      .constraint(equalTo: elementContainerView.trailingAnchor)
    let statesLabelViewTopAnchorRoleDropdownViewBottomAnchorConstraint = statesLabelView
      .topAnchor
      .constraint(equalTo: roleDropdownView.bottomAnchor, constant: 16)
    let statesLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint = statesLabelView
      .leadingAnchor
      .constraint(equalTo: elementContainerView.leadingAnchor)
    let statesLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint = statesLabelView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: elementContainerView.trailingAnchor)
    let statesDropdownViewBottomAnchorElementContainerViewBottomAnchorConstraint = statesDropdownView
      .bottomAnchor
      .constraint(equalTo: elementContainerView.bottomAnchor)
    let statesDropdownViewTopAnchorStatesLabelViewBottomAnchorConstraint = statesDropdownView
      .topAnchor
      .constraint(equalTo: statesLabelView.bottomAnchor, constant: 8)
    let statesDropdownViewLeadingAnchorElementContainerViewLeadingAnchorConstraint = statesDropdownView
      .leadingAnchor
      .constraint(equalTo: elementContainerView.leadingAnchor)
    let statesDropdownViewTrailingAnchorElementContainerViewTrailingAnchorConstraint = statesDropdownView
      .trailingAnchor
      .constraint(equalTo: elementContainerView.trailingAnchor)

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
    self.typeLabelViewTopAnchorContentContainerViewTopAnchorConstraint =
      typeLabelViewTopAnchorContentContainerViewTopAnchorConstraint
    self.typeLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint =
      typeLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint
    self.typeLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint =
      typeLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint
    self.typeDropdownViewBottomAnchorContentContainerViewBottomAnchorConstraint =
      typeDropdownViewBottomAnchorContentContainerViewBottomAnchorConstraint
    self.typeDropdownViewTopAnchorTypeLabelViewBottomAnchorConstraint =
      typeDropdownViewTopAnchorTypeLabelViewBottomAnchorConstraint
    self.typeDropdownViewLeadingAnchorContentContainerViewLeadingAnchorConstraint =
      typeDropdownViewLeadingAnchorContentContainerViewLeadingAnchorConstraint
    self.typeDropdownViewTrailingAnchorContentContainerViewTrailingAnchorConstraint =
      typeDropdownViewTrailingAnchorContentContainerViewTrailingAnchorConstraint
    self.elementContainerViewBottomAnchorContentContainerViewBottomAnchorConstraint =
      elementContainerViewBottomAnchorContentContainerViewBottomAnchorConstraint
    self.elementContainerViewTopAnchorTypeDropdownViewBottomAnchorConstraint =
      elementContainerViewTopAnchorTypeDropdownViewBottomAnchorConstraint
    self.elementContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint =
      elementContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint
    self.elementContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint =
      elementContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint
    self.labelLabelViewTopAnchorElementContainerViewTopAnchorConstraint =
      labelLabelViewTopAnchorElementContainerViewTopAnchorConstraint
    self.labelLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint =
      labelLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint
    self.labelLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint =
      labelLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint
    self.labelTextInputViewTopAnchorLabelLabelViewBottomAnchorConstraint =
      labelTextInputViewTopAnchorLabelLabelViewBottomAnchorConstraint
    self.labelTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint =
      labelTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint
    self.labelTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint =
      labelTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint
    self.hintLabelViewTopAnchorLabelTextInputViewBottomAnchorConstraint =
      hintLabelViewTopAnchorLabelTextInputViewBottomAnchorConstraint
    self.hintLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint =
      hintLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint
    self.hintLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint =
      hintLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint
    self.hintTextInputViewTopAnchorHintLabelViewBottomAnchorConstraint =
      hintTextInputViewTopAnchorHintLabelViewBottomAnchorConstraint
    self.hintTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint =
      hintTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint
    self.hintTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint =
      hintTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint
    self.roleLabelViewTopAnchorHintTextInputViewBottomAnchorConstraint =
      roleLabelViewTopAnchorHintTextInputViewBottomAnchorConstraint
    self.roleLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint =
      roleLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint
    self.roleLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint =
      roleLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint
    self.roleDropdownViewTopAnchorRoleLabelViewBottomAnchorConstraint =
      roleDropdownViewTopAnchorRoleLabelViewBottomAnchorConstraint
    self.roleDropdownViewLeadingAnchorElementContainerViewLeadingAnchorConstraint =
      roleDropdownViewLeadingAnchorElementContainerViewLeadingAnchorConstraint
    self.roleDropdownViewTrailingAnchorElementContainerViewTrailingAnchorConstraint =
      roleDropdownViewTrailingAnchorElementContainerViewTrailingAnchorConstraint
    self.statesLabelViewTopAnchorRoleDropdownViewBottomAnchorConstraint =
      statesLabelViewTopAnchorRoleDropdownViewBottomAnchorConstraint
    self.statesLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint =
      statesLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint
    self.statesLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint =
      statesLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint
    self.statesDropdownViewBottomAnchorElementContainerViewBottomAnchorConstraint =
      statesDropdownViewBottomAnchorElementContainerViewBottomAnchorConstraint
    self.statesDropdownViewTopAnchorStatesLabelViewBottomAnchorConstraint =
      statesDropdownViewTopAnchorStatesLabelViewBottomAnchorConstraint
    self.statesDropdownViewLeadingAnchorElementContainerViewLeadingAnchorConstraint =
      statesDropdownViewLeadingAnchorElementContainerViewLeadingAnchorConstraint
    self.statesDropdownViewTrailingAnchorElementContainerViewTrailingAnchorConstraint =
      statesDropdownViewTrailingAnchorElementContainerViewTrailingAnchorConstraint

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
          elementContainerViewIsHidden: elementContainerView.isHidden))
  }

  private func conditionalConstraints(
    contentContainerViewIsHidden: Bool,
    elementContainerViewIsHidden: Bool) -> [NSLayoutConstraint]
  {
    var constraints: [NSLayoutConstraint?]

    switch (contentContainerViewIsHidden, elementContainerViewIsHidden) {
      case (true, true):
        constraints = [hDividerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint]
      case (false, true):
        constraints = [
          contentContainerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint,
          contentContainerViewLeadingAnchorLeadingAnchorConstraint,
          contentContainerViewTrailingAnchorTrailingAnchorConstraint,
          hDividerViewTopAnchorContentContainerViewBottomAnchorConstraint,
          typeLabelViewTopAnchorContentContainerViewTopAnchorConstraint,
          typeLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          typeLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          typeDropdownViewBottomAnchorContentContainerViewBottomAnchorConstraint,
          typeDropdownViewTopAnchorTypeLabelViewBottomAnchorConstraint,
          typeDropdownViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          typeDropdownViewTrailingAnchorContentContainerViewTrailingAnchorConstraint
        ]
      case (true, false):
        constraints = [hDividerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint]
      case (false, false):
        constraints = [
          contentContainerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint,
          contentContainerViewLeadingAnchorLeadingAnchorConstraint,
          contentContainerViewTrailingAnchorTrailingAnchorConstraint,
          hDividerViewTopAnchorContentContainerViewBottomAnchorConstraint,
          typeLabelViewTopAnchorContentContainerViewTopAnchorConstraint,
          typeLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          typeLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          typeDropdownViewTopAnchorTypeLabelViewBottomAnchorConstraint,
          typeDropdownViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          typeDropdownViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          elementContainerViewBottomAnchorContentContainerViewBottomAnchorConstraint,
          elementContainerViewTopAnchorTypeDropdownViewBottomAnchorConstraint,
          elementContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          elementContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          labelLabelViewTopAnchorElementContainerViewTopAnchorConstraint,
          labelLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint,
          labelLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint,
          labelTextInputViewTopAnchorLabelLabelViewBottomAnchorConstraint,
          labelTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint,
          labelTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint,
          hintLabelViewTopAnchorLabelTextInputViewBottomAnchorConstraint,
          hintLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint,
          hintLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint,
          hintTextInputViewTopAnchorHintLabelViewBottomAnchorConstraint,
          hintTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint,
          hintTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint,
          roleLabelViewTopAnchorHintTextInputViewBottomAnchorConstraint,
          roleLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint,
          roleLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint,
          roleDropdownViewTopAnchorRoleLabelViewBottomAnchorConstraint,
          roleDropdownViewLeadingAnchorElementContainerViewLeadingAnchorConstraint,
          roleDropdownViewTrailingAnchorElementContainerViewTrailingAnchorConstraint,
          statesLabelViewTopAnchorRoleDropdownViewBottomAnchorConstraint,
          statesLabelViewLeadingAnchorElementContainerViewLeadingAnchorConstraint,
          statesLabelViewTrailingAnchorElementContainerViewTrailingAnchorConstraint,
          statesDropdownViewBottomAnchorElementContainerViewBottomAnchorConstraint,
          statesDropdownViewTopAnchorStatesLabelViewBottomAnchorConstraint,
          statesDropdownViewLeadingAnchorElementContainerViewLeadingAnchorConstraint,
          statesDropdownViewTrailingAnchorElementContainerViewTrailingAnchorConstraint
        ]
    }

    return constraints.compactMap({ $0 })
  }

  private func update() {
    let contentContainerViewIsHidden = contentContainerView.isHidden
    let elementContainerViewIsHidden = elementContainerView.isHidden

    contentContainerView.isHidden = !isExpanded
    inspectorSectionHeaderView.isExpanded = isExpanded
    inspectorSectionHeaderView.onClick = handleOnClickHeader
    var elementViewsHidden = false
    if accessibilityTypeIndex == 2 {
      elementViewsHidden = true
    }
    elementContainerView.isHidden = !elementViewsHidden
    typeDropdownView.selectedIndex = accessibilityTypeIndex
    typeDropdownView.onChangeIndex = handleOnChangeAccessibilityTypeIndex
    labelTextInputView.textValue = accessibilityLabelText
    labelTextInputView.onChangeTextValue = handleOnChangeAccessibilityLabel
    hintTextInputView.textValue = accessibilityHintText
    hintTextInputView.onChangeTextValue = handleOnChangeAccessibilityHintText

    if
    contentContainerView.isHidden != contentContainerViewIsHidden ||
      elementContainerView.isHidden != elementContainerViewIsHidden
    {
      NSLayoutConstraint.deactivate(
        conditionalConstraints(
          contentContainerViewIsHidden: contentContainerViewIsHidden,
          elementContainerViewIsHidden: elementContainerViewIsHidden))
      NSLayoutConstraint.activate(
        conditionalConstraints(
          contentContainerViewIsHidden: contentContainerView.isHidden,
          elementContainerViewIsHidden: elementContainerView.isHidden))
    }
  }

  private func handleOnClickHeader() {
    onClickHeader?()
  }

  private func handleOnChangeAccessibilityTypeIndex(_ arg0: Int) {
    onChangeAccessibilityTypeIndex?(arg0)
  }

  private func handleOnChangeAccessibilityLabel(_ arg0: String) {
    onChangeAccessibilityLabel?(arg0)
  }

  private func handleOnChangeAccessibilityHintText(_ arg0: String) {
    onChangeAccessibilityHintText?(arg0)
  }

  private func handleOnChangeAccessibilityElements(_ arg0: [String]) {
    onChangeAccessibilityElements?(arg0)
  }
}

// MARK: - Parameters

extension AccessibilityInspector {
  public struct Parameters: Equatable {
    public var isExpanded: Bool
    public var accessibilityTypeIndex: Int
    public var accessibilityLabelText: String
    public var accessibilityHintText: String
    public var accessibilityElements: [String]
    public var onClickHeader: (() -> Void)?
    public var onChangeAccessibilityTypeIndex: ((Int) -> Void)?
    public var onChangeAccessibilityLabel: StringHandler
    public var onChangeAccessibilityHintText: StringHandler
    public var onChangeAccessibilityElements: (([String]) -> Void)?

    public init(
      isExpanded: Bool,
      accessibilityTypeIndex: Int,
      accessibilityLabelText: String,
      accessibilityHintText: String,
      accessibilityElements: [String],
      onClickHeader: (() -> Void)? = nil,
      onChangeAccessibilityTypeIndex: ((Int) -> Void)? = nil,
      onChangeAccessibilityLabel: StringHandler = nil,
      onChangeAccessibilityHintText: StringHandler = nil,
      onChangeAccessibilityElements: (([String]) -> Void)? = nil)
    {
      self.isExpanded = isExpanded
      self.accessibilityTypeIndex = accessibilityTypeIndex
      self.accessibilityLabelText = accessibilityLabelText
      self.accessibilityHintText = accessibilityHintText
      self.accessibilityElements = accessibilityElements
      self.onClickHeader = onClickHeader
      self.onChangeAccessibilityTypeIndex = onChangeAccessibilityTypeIndex
      self.onChangeAccessibilityLabel = onChangeAccessibilityLabel
      self.onChangeAccessibilityHintText = onChangeAccessibilityHintText
      self.onChangeAccessibilityElements = onChangeAccessibilityElements
    }

    public init() {
      self
        .init(
          isExpanded: false,
          accessibilityTypeIndex: 0,
          accessibilityLabelText: "",
          accessibilityHintText: "",
          accessibilityElements: [])
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.isExpanded == rhs.isExpanded &&
        lhs.accessibilityTypeIndex == rhs.accessibilityTypeIndex &&
          lhs.accessibilityLabelText == rhs.accessibilityLabelText &&
            lhs.accessibilityHintText == rhs.accessibilityHintText &&
              lhs.accessibilityElements == rhs.accessibilityElements
    }
  }
}

// MARK: - Model

extension AccessibilityInspector {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "AccessibilityInspector"
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
      accessibilityTypeIndex: Int,
      accessibilityLabelText: String,
      accessibilityHintText: String,
      accessibilityElements: [String],
      onClickHeader: (() -> Void)? = nil,
      onChangeAccessibilityTypeIndex: ((Int) -> Void)? = nil,
      onChangeAccessibilityLabel: StringHandler = nil,
      onChangeAccessibilityHintText: StringHandler = nil,
      onChangeAccessibilityElements: (([String]) -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            isExpanded: isExpanded,
            accessibilityTypeIndex: accessibilityTypeIndex,
            accessibilityLabelText: accessibilityLabelText,
            accessibilityHintText: accessibilityHintText,
            accessibilityElements: accessibilityElements,
            onClickHeader: onClickHeader,
            onChangeAccessibilityTypeIndex: onChangeAccessibilityTypeIndex,
            onChangeAccessibilityLabel: onChangeAccessibilityLabel,
            onChangeAccessibilityHintText: onChangeAccessibilityHintText,
            onChangeAccessibilityElements: onChangeAccessibilityElements))
    }

    public init() {
      self
        .init(
          isExpanded: false,
          accessibilityTypeIndex: 0,
          accessibilityLabelText: "",
          accessibilityHintText: "",
          accessibilityElements: [])
    }
  }
}
