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

  public convenience init(isExpanded: Bool) {
    self.init(Parameters(isExpanded: isExpanded))
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
  private var hDividerView = NSBox()

  private var typeLabelViewTextStyle = TextStyles.regular
  private var labelLabelViewTextStyle = TextStyles.regular

  private var hDividerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint: NSLayoutConstraint?
  private var contentContainerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint: NSLayoutConstraint?
  private var contentContainerViewLeadingAnchorLeadingAnchorConstraint: NSLayoutConstraint?
  private var contentContainerViewTrailingAnchorTrailingAnchorConstraint: NSLayoutConstraint?
  private var hDividerViewTopAnchorContentContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var typeLabelViewTopAnchorContentContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var typeLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var typeLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
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
  private var labelTextInputViewBottomAnchorElementContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var labelTextInputViewTopAnchorLabelLabelViewBottomAnchorConstraint: NSLayoutConstraint?
  private var labelTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var labelTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint: NSLayoutConstraint?

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

    addSubview(inspectorSectionHeaderView)
    addSubview(contentContainerView)
    addSubview(hDividerView)
    contentContainerView.addSubview(typeLabelView)
    contentContainerView.addSubview(typeDropdownView)
    contentContainerView.addSubview(elementContainerView)
    elementContainerView.addSubview(labelLabelView)
    elementContainerView.addSubview(labelTextInputView)

    inspectorSectionHeaderView.titleText = "Accessibility"
    typeLabelView.attributedStringValue = typeLabelViewTextStyle.apply(to: "Direction")
    typeLabelViewTextStyle = TextStyles.regular
    typeLabelView.attributedStringValue = typeLabelViewTextStyle.apply(to: typeLabelView.attributedStringValue)
    typeDropdownView.selectedIndex = 0
    typeDropdownView.values = ["Auto", "None", "Element", "Container"]
    labelLabelView.attributedStringValue = labelLabelViewTextStyle.apply(to: "Label")
    labelTextInputView.placeholderString = "Label"
    labelTextInputView.textValue = "Text"
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
    let labelTextInputViewBottomAnchorElementContainerViewBottomAnchorConstraint = labelTextInputView
      .bottomAnchor
      .constraint(equalTo: elementContainerView.bottomAnchor)
    let labelTextInputViewTopAnchorLabelLabelViewBottomAnchorConstraint = labelTextInputView
      .topAnchor
      .constraint(equalTo: labelLabelView.bottomAnchor, constant: 8)
    let labelTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint = labelTextInputView
      .leadingAnchor
      .constraint(equalTo: elementContainerView.leadingAnchor)
    let labelTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint = labelTextInputView
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
    self.labelTextInputViewBottomAnchorElementContainerViewBottomAnchorConstraint =
      labelTextInputViewBottomAnchorElementContainerViewBottomAnchorConstraint
    self.labelTextInputViewTopAnchorLabelLabelViewBottomAnchorConstraint =
      labelTextInputViewTopAnchorLabelLabelViewBottomAnchorConstraint
    self.labelTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint =
      labelTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint
    self.labelTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint =
      labelTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint

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
        conditionalConstraints(contentContainerViewIsHidden: contentContainerView.isHidden))
  }

  private func conditionalConstraints(contentContainerViewIsHidden: Bool) -> [NSLayoutConstraint] {
    var constraints: [NSLayoutConstraint?]

    switch (contentContainerViewIsHidden) {
      case (true):
        constraints = [hDividerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint]
      case (false):
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
          labelTextInputViewBottomAnchorElementContainerViewBottomAnchorConstraint,
          labelTextInputViewTopAnchorLabelLabelViewBottomAnchorConstraint,
          labelTextInputViewLeadingAnchorElementContainerViewLeadingAnchorConstraint,
          labelTextInputViewTrailingAnchorElementContainerViewTrailingAnchorConstraint
        ]
    }

    return constraints.compactMap({ $0 })
  }

  private func update() {
    let contentContainerViewIsHidden = contentContainerView.isHidden

    contentContainerView.isHidden = !isExpanded
    inspectorSectionHeaderView.isExpanded = isExpanded
    inspectorSectionHeaderView.onClick = handleOnClickHeader

    if contentContainerView.isHidden != contentContainerViewIsHidden {
      NSLayoutConstraint.deactivate(conditionalConstraints(contentContainerViewIsHidden: contentContainerViewIsHidden))
      NSLayoutConstraint.activate(conditionalConstraints(contentContainerViewIsHidden: contentContainerView.isHidden))
    }
  }

  private func handleOnClickHeader() {
    onClickHeader?()
  }
}

// MARK: - Parameters

extension AccessibilityInspector {
  public struct Parameters: Equatable {
    public var isExpanded: Bool
    public var onClickHeader: (() -> Void)?

    public init(isExpanded: Bool, onClickHeader: (() -> Void)? = nil) {
      self.isExpanded = isExpanded
      self.onClickHeader = onClickHeader
    }

    public init() {
      self.init(isExpanded: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.isExpanded == rhs.isExpanded
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

    public init(isExpanded: Bool, onClickHeader: (() -> Void)? = nil) {
      self.init(Parameters(isExpanded: isExpanded, onClickHeader: onClickHeader))
    }

    public init() {
      self.init(isExpanded: false)
    }
  }
}
