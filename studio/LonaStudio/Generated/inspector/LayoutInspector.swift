import AppKit
import Foundation

// MARK: - LayoutInspector

public class LayoutInspector: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(
    direction: Direction,
    horizontalAlignment: HorizontalAlignment,
    verticalAlignment: VerticalAlignment,
    isExpanded: Bool)
  {
    self
      .init(
        Parameters(
          direction: direction,
          horizontalAlignment: horizontalAlignment,
          verticalAlignment: verticalAlignment,
          isExpanded: isExpanded))
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

  public var direction: Direction {
    get { return parameters.direction }
    set {
      if parameters.direction != newValue {
        parameters.direction = newValue
      }
    }
  }

  public var onChangeDirectionIndex: ((Int) -> Void)? {
    get { return parameters.onChangeDirectionIndex }
    set { parameters.onChangeDirectionIndex = newValue }
  }

  public var horizontalAlignment: HorizontalAlignment {
    get { return parameters.horizontalAlignment }
    set {
      if parameters.horizontalAlignment != newValue {
        parameters.horizontalAlignment = newValue
      }
    }
  }

  public var onChangeHorizontalAlignmentIndex: ((Int) -> Void)? {
    get { return parameters.onChangeHorizontalAlignmentIndex }
    set { parameters.onChangeHorizontalAlignmentIndex = newValue }
  }

  public var verticalAlignment: VerticalAlignment {
    get { return parameters.verticalAlignment }
    set {
      if parameters.verticalAlignment != newValue {
        parameters.verticalAlignment = newValue
      }
    }
  }

  public var onChangeVerticalAlignmentIndex: ((Int) -> Void)? {
    get { return parameters.onChangeVerticalAlignmentIndex }
    set { parameters.onChangeVerticalAlignmentIndex = newValue }
  }

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
  private var directionLabelView = LNATextField(labelWithString: "")
  private var directionDropdownView = ControlledDropdown()
  private var alignmentLabelView = LNATextField(labelWithString: "")
  private var alignmentContainerView = NSBox()
  private var horizontalAlignmentView = ControlledDropdown()
  private var hSpacerView = NSBox()
  private var verticalAlignmentView = ControlledDropdown()
  private var hDividerView = NSBox()

  private var directionLabelViewTextStyle = TextStyles.regular
  private var alignmentLabelViewTextStyle = TextStyles.regular

  private var hDividerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint: NSLayoutConstraint?
  private var contentContainerViewTopAnchorInspectorSectionHeaderViewBottomAnchorConstraint: NSLayoutConstraint?
  private var contentContainerViewLeadingAnchorLeadingAnchorConstraint: NSLayoutConstraint?
  private var contentContainerViewTrailingAnchorTrailingAnchorConstraint: NSLayoutConstraint?
  private var hDividerViewTopAnchorContentContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var directionLabelViewTopAnchorContentContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var directionLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var directionLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var directionDropdownViewTopAnchorDirectionLabelViewBottomAnchorConstraint: NSLayoutConstraint?
  private var directionDropdownViewLeadingAnchorContentContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var directionDropdownViewTrailingAnchorContentContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var alignmentLabelViewTopAnchorDirectionDropdownViewBottomAnchorConstraint: NSLayoutConstraint?
  private var alignmentLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var alignmentLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var alignmentContainerViewBottomAnchorContentContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var alignmentContainerViewTopAnchorAlignmentLabelViewBottomAnchorConstraint: NSLayoutConstraint?
  private var alignmentContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var alignmentContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var horizontalAlignmentViewVerticalAlignmentViewWidthAnchorSiblingConstraint: NSLayoutConstraint?
  private var horizontalAlignmentViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var hSpacerViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var verticalAlignmentViewHeightAnchorParentConstraint: NSLayoutConstraint?
  private var horizontalAlignmentViewLeadingAnchorAlignmentContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var horizontalAlignmentViewTopAnchorAlignmentContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var horizontalAlignmentViewBottomAnchorAlignmentContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var hSpacerViewLeadingAnchorHorizontalAlignmentViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var hSpacerViewTopAnchorAlignmentContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var verticalAlignmentViewTrailingAnchorAlignmentContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var verticalAlignmentViewLeadingAnchorHSpacerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var verticalAlignmentViewTopAnchorAlignmentContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var verticalAlignmentViewBottomAnchorAlignmentContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var hSpacerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var hSpacerViewWidthAnchorConstraint: NSLayoutConstraint?

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
    directionLabelView.lineBreakMode = .byWordWrapping
    alignmentLabelView.lineBreakMode = .byWordWrapping
    alignmentContainerView.boxType = .custom
    alignmentContainerView.borderType = .noBorder
    alignmentContainerView.contentViewMargins = .zero
    hSpacerView.boxType = .custom
    hSpacerView.borderType = .noBorder
    hSpacerView.contentViewMargins = .zero

    addSubview(inspectorSectionHeaderView)
    addSubview(contentContainerView)
    addSubview(hDividerView)
    contentContainerView.addSubview(directionLabelView)
    contentContainerView.addSubview(directionDropdownView)
    contentContainerView.addSubview(alignmentLabelView)
    contentContainerView.addSubview(alignmentContainerView)
    alignmentContainerView.addSubview(horizontalAlignmentView)
    alignmentContainerView.addSubview(hSpacerView)
    alignmentContainerView.addSubview(verticalAlignmentView)

    inspectorSectionHeaderView.titleText = "Layout"
    directionLabelView.attributedStringValue = directionLabelViewTextStyle.apply(to: "Direction")
    directionLabelViewTextStyle = TextStyles.regular
    directionLabelView.attributedStringValue =
      directionLabelViewTextStyle.apply(to: directionLabelView.attributedStringValue)
    directionDropdownView.values = ["Horizontal", "Vertical"]
    alignmentLabelView.attributedStringValue = alignmentLabelViewTextStyle.apply(to: "Children Alignment")
    horizontalAlignmentView.values = ["Left", "Center", "Right"]
    verticalAlignmentView.values = ["Top", "Middle", "Bottom"]
    hDividerView.fillColor = Colors.dividerSubtle
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    inspectorSectionHeaderView.translatesAutoresizingMaskIntoConstraints = false
    contentContainerView.translatesAutoresizingMaskIntoConstraints = false
    hDividerView.translatesAutoresizingMaskIntoConstraints = false
    directionLabelView.translatesAutoresizingMaskIntoConstraints = false
    directionDropdownView.translatesAutoresizingMaskIntoConstraints = false
    alignmentLabelView.translatesAutoresizingMaskIntoConstraints = false
    alignmentContainerView.translatesAutoresizingMaskIntoConstraints = false
    horizontalAlignmentView.translatesAutoresizingMaskIntoConstraints = false
    hSpacerView.translatesAutoresizingMaskIntoConstraints = false
    verticalAlignmentView.translatesAutoresizingMaskIntoConstraints = false

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
    let directionLabelViewTopAnchorContentContainerViewTopAnchorConstraint = directionLabelView
      .topAnchor
      .constraint(equalTo: contentContainerView.topAnchor)
    let directionLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint = directionLabelView
      .leadingAnchor
      .constraint(equalTo: contentContainerView.leadingAnchor)
    let directionLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint = directionLabelView
      .trailingAnchor
      .constraint(equalTo: contentContainerView.trailingAnchor)
    let directionDropdownViewTopAnchorDirectionLabelViewBottomAnchorConstraint = directionDropdownView
      .topAnchor
      .constraint(equalTo: directionLabelView.bottomAnchor, constant: 8)
    let directionDropdownViewLeadingAnchorContentContainerViewLeadingAnchorConstraint = directionDropdownView
      .leadingAnchor
      .constraint(equalTo: contentContainerView.leadingAnchor)
    let directionDropdownViewTrailingAnchorContentContainerViewTrailingAnchorConstraint = directionDropdownView
      .trailingAnchor
      .constraint(equalTo: contentContainerView.trailingAnchor)
    let alignmentLabelViewTopAnchorDirectionDropdownViewBottomAnchorConstraint = alignmentLabelView
      .topAnchor
      .constraint(equalTo: directionDropdownView.bottomAnchor, constant: 16)
    let alignmentLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint = alignmentLabelView
      .leadingAnchor
      .constraint(equalTo: contentContainerView.leadingAnchor)
    let alignmentLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint = alignmentLabelView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: contentContainerView.trailingAnchor)
    let alignmentContainerViewBottomAnchorContentContainerViewBottomAnchorConstraint = alignmentContainerView
      .bottomAnchor
      .constraint(equalTo: contentContainerView.bottomAnchor, constant: -16)
    let alignmentContainerViewTopAnchorAlignmentLabelViewBottomAnchorConstraint = alignmentContainerView
      .topAnchor
      .constraint(equalTo: alignmentLabelView.bottomAnchor, constant: 8)
    let alignmentContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint = alignmentContainerView
      .leadingAnchor
      .constraint(equalTo: contentContainerView.leadingAnchor)
    let alignmentContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint = alignmentContainerView
      .trailingAnchor
      .constraint(equalTo: contentContainerView.trailingAnchor)
    let horizontalAlignmentViewVerticalAlignmentViewWidthAnchorSiblingConstraint = horizontalAlignmentView
      .widthAnchor
      .constraint(equalTo: verticalAlignmentView.widthAnchor)
    let horizontalAlignmentViewHeightAnchorParentConstraint = horizontalAlignmentView
      .heightAnchor
      .constraint(lessThanOrEqualTo: alignmentContainerView.heightAnchor)
    let hSpacerViewHeightAnchorParentConstraint = hSpacerView
      .heightAnchor
      .constraint(lessThanOrEqualTo: alignmentContainerView.heightAnchor)
    let verticalAlignmentViewHeightAnchorParentConstraint = verticalAlignmentView
      .heightAnchor
      .constraint(lessThanOrEqualTo: alignmentContainerView.heightAnchor)
    let horizontalAlignmentViewLeadingAnchorAlignmentContainerViewLeadingAnchorConstraint = horizontalAlignmentView
      .leadingAnchor
      .constraint(equalTo: alignmentContainerView.leadingAnchor)
    let horizontalAlignmentViewTopAnchorAlignmentContainerViewTopAnchorConstraint = horizontalAlignmentView
      .topAnchor
      .constraint(equalTo: alignmentContainerView.topAnchor)
    let horizontalAlignmentViewBottomAnchorAlignmentContainerViewBottomAnchorConstraint = horizontalAlignmentView
      .bottomAnchor
      .constraint(equalTo: alignmentContainerView.bottomAnchor)
    let hSpacerViewLeadingAnchorHorizontalAlignmentViewTrailingAnchorConstraint = hSpacerView
      .leadingAnchor
      .constraint(equalTo: horizontalAlignmentView.trailingAnchor)
    let hSpacerViewTopAnchorAlignmentContainerViewTopAnchorConstraint = hSpacerView
      .topAnchor
      .constraint(equalTo: alignmentContainerView.topAnchor)
    let verticalAlignmentViewTrailingAnchorAlignmentContainerViewTrailingAnchorConstraint = verticalAlignmentView
      .trailingAnchor
      .constraint(equalTo: alignmentContainerView.trailingAnchor)
    let verticalAlignmentViewLeadingAnchorHSpacerViewTrailingAnchorConstraint = verticalAlignmentView
      .leadingAnchor
      .constraint(equalTo: hSpacerView.trailingAnchor)
    let verticalAlignmentViewTopAnchorAlignmentContainerViewTopAnchorConstraint = verticalAlignmentView
      .topAnchor
      .constraint(equalTo: alignmentContainerView.topAnchor)
    let verticalAlignmentViewBottomAnchorAlignmentContainerViewBottomAnchorConstraint = verticalAlignmentView
      .bottomAnchor
      .constraint(equalTo: alignmentContainerView.bottomAnchor)
    let hSpacerViewHeightAnchorConstraint = hSpacerView.heightAnchor.constraint(equalToConstant: 0)
    let hSpacerViewWidthAnchorConstraint = hSpacerView.widthAnchor.constraint(equalToConstant: 20)

    horizontalAlignmentViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    hSpacerViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    verticalAlignmentViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

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
    self.directionLabelViewTopAnchorContentContainerViewTopAnchorConstraint =
      directionLabelViewTopAnchorContentContainerViewTopAnchorConstraint
    self.directionLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint =
      directionLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint
    self.directionLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint =
      directionLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint
    self.directionDropdownViewTopAnchorDirectionLabelViewBottomAnchorConstraint =
      directionDropdownViewTopAnchorDirectionLabelViewBottomAnchorConstraint
    self.directionDropdownViewLeadingAnchorContentContainerViewLeadingAnchorConstraint =
      directionDropdownViewLeadingAnchorContentContainerViewLeadingAnchorConstraint
    self.directionDropdownViewTrailingAnchorContentContainerViewTrailingAnchorConstraint =
      directionDropdownViewTrailingAnchorContentContainerViewTrailingAnchorConstraint
    self.alignmentLabelViewTopAnchorDirectionDropdownViewBottomAnchorConstraint =
      alignmentLabelViewTopAnchorDirectionDropdownViewBottomAnchorConstraint
    self.alignmentLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint =
      alignmentLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint
    self.alignmentLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint =
      alignmentLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint
    self.alignmentContainerViewBottomAnchorContentContainerViewBottomAnchorConstraint =
      alignmentContainerViewBottomAnchorContentContainerViewBottomAnchorConstraint
    self.alignmentContainerViewTopAnchorAlignmentLabelViewBottomAnchorConstraint =
      alignmentContainerViewTopAnchorAlignmentLabelViewBottomAnchorConstraint
    self.alignmentContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint =
      alignmentContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint
    self.alignmentContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint =
      alignmentContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint
    self.horizontalAlignmentViewVerticalAlignmentViewWidthAnchorSiblingConstraint =
      horizontalAlignmentViewVerticalAlignmentViewWidthAnchorSiblingConstraint
    self.horizontalAlignmentViewHeightAnchorParentConstraint = horizontalAlignmentViewHeightAnchorParentConstraint
    self.hSpacerViewHeightAnchorParentConstraint = hSpacerViewHeightAnchorParentConstraint
    self.verticalAlignmentViewHeightAnchorParentConstraint = verticalAlignmentViewHeightAnchorParentConstraint
    self.horizontalAlignmentViewLeadingAnchorAlignmentContainerViewLeadingAnchorConstraint =
      horizontalAlignmentViewLeadingAnchorAlignmentContainerViewLeadingAnchorConstraint
    self.horizontalAlignmentViewTopAnchorAlignmentContainerViewTopAnchorConstraint =
      horizontalAlignmentViewTopAnchorAlignmentContainerViewTopAnchorConstraint
    self.horizontalAlignmentViewBottomAnchorAlignmentContainerViewBottomAnchorConstraint =
      horizontalAlignmentViewBottomAnchorAlignmentContainerViewBottomAnchorConstraint
    self.hSpacerViewLeadingAnchorHorizontalAlignmentViewTrailingAnchorConstraint =
      hSpacerViewLeadingAnchorHorizontalAlignmentViewTrailingAnchorConstraint
    self.hSpacerViewTopAnchorAlignmentContainerViewTopAnchorConstraint =
      hSpacerViewTopAnchorAlignmentContainerViewTopAnchorConstraint
    self.verticalAlignmentViewTrailingAnchorAlignmentContainerViewTrailingAnchorConstraint =
      verticalAlignmentViewTrailingAnchorAlignmentContainerViewTrailingAnchorConstraint
    self.verticalAlignmentViewLeadingAnchorHSpacerViewTrailingAnchorConstraint =
      verticalAlignmentViewLeadingAnchorHSpacerViewTrailingAnchorConstraint
    self.verticalAlignmentViewTopAnchorAlignmentContainerViewTopAnchorConstraint =
      verticalAlignmentViewTopAnchorAlignmentContainerViewTopAnchorConstraint
    self.verticalAlignmentViewBottomAnchorAlignmentContainerViewBottomAnchorConstraint =
      verticalAlignmentViewBottomAnchorAlignmentContainerViewBottomAnchorConstraint
    self.hSpacerViewHeightAnchorConstraint = hSpacerViewHeightAnchorConstraint
    self.hSpacerViewWidthAnchorConstraint = hSpacerViewWidthAnchorConstraint

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
          directionLabelViewTopAnchorContentContainerViewTopAnchorConstraint,
          directionLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          directionLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          directionDropdownViewTopAnchorDirectionLabelViewBottomAnchorConstraint,
          directionDropdownViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          directionDropdownViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          alignmentLabelViewTopAnchorDirectionDropdownViewBottomAnchorConstraint,
          alignmentLabelViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          alignmentLabelViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          alignmentContainerViewBottomAnchorContentContainerViewBottomAnchorConstraint,
          alignmentContainerViewTopAnchorAlignmentLabelViewBottomAnchorConstraint,
          alignmentContainerViewLeadingAnchorContentContainerViewLeadingAnchorConstraint,
          alignmentContainerViewTrailingAnchorContentContainerViewTrailingAnchorConstraint,
          horizontalAlignmentViewVerticalAlignmentViewWidthAnchorSiblingConstraint,
          horizontalAlignmentViewHeightAnchorParentConstraint,
          hSpacerViewHeightAnchorParentConstraint,
          verticalAlignmentViewHeightAnchorParentConstraint,
          horizontalAlignmentViewLeadingAnchorAlignmentContainerViewLeadingAnchorConstraint,
          horizontalAlignmentViewTopAnchorAlignmentContainerViewTopAnchorConstraint,
          horizontalAlignmentViewBottomAnchorAlignmentContainerViewBottomAnchorConstraint,
          hSpacerViewLeadingAnchorHorizontalAlignmentViewTrailingAnchorConstraint,
          hSpacerViewTopAnchorAlignmentContainerViewTopAnchorConstraint,
          verticalAlignmentViewTrailingAnchorAlignmentContainerViewTrailingAnchorConstraint,
          verticalAlignmentViewLeadingAnchorHSpacerViewTrailingAnchorConstraint,
          verticalAlignmentViewTopAnchorAlignmentContainerViewTopAnchorConstraint,
          verticalAlignmentViewBottomAnchorAlignmentContainerViewBottomAnchorConstraint,
          hSpacerViewHeightAnchorConstraint,
          hSpacerViewWidthAnchorConstraint
        ]
    }

    return constraints.compactMap({ $0 })
  }

  private func update() {
    let contentContainerViewIsHidden = contentContainerView.isHidden

    directionDropdownView.selectedIndex = 0
    horizontalAlignmentView.selectedIndex = 0
    verticalAlignmentView.selectedIndex = 0
    if direction == .horizontal {
      directionDropdownView.selectedIndex = 0
    }
    if direction == .vertical {
      directionDropdownView.selectedIndex = 1
    }
    if horizontalAlignment == .left {
      horizontalAlignmentView.selectedIndex = 0
    }
    if horizontalAlignment == .center {
      horizontalAlignmentView.selectedIndex = 1
    }
    if horizontalAlignment == .right {
      horizontalAlignmentView.selectedIndex = 2
    }
    if verticalAlignment == .top {
      verticalAlignmentView.selectedIndex = 0
    }
    if verticalAlignment == .middle {
      verticalAlignmentView.selectedIndex = 1
    }
    if verticalAlignment == .bottom {
      verticalAlignmentView.selectedIndex = 2
    }
    directionDropdownView.onChangeIndex = handleOnChangeDirectionIndex
    horizontalAlignmentView.onChangeIndex = handleOnChangeHorizontalAlignmentIndex
    verticalAlignmentView.onChangeIndex = handleOnChangeVerticalAlignmentIndex
    contentContainerView.isHidden = !isExpanded
    inspectorSectionHeaderView.isExpanded = isExpanded
    inspectorSectionHeaderView.onClick = handleOnClickHeader

    if contentContainerView.isHidden != contentContainerViewIsHidden {
      NSLayoutConstraint.deactivate(conditionalConstraints(contentContainerViewIsHidden: contentContainerViewIsHidden))
      NSLayoutConstraint.activate(conditionalConstraints(contentContainerViewIsHidden: contentContainerView.isHidden))
    }
  }

  private func handleOnChangeDirectionIndex(_ arg0: Int) {
    onChangeDirectionIndex?(arg0)
  }

  private func handleOnChangeHorizontalAlignmentIndex(_ arg0: Int) {
    onChangeHorizontalAlignmentIndex?(arg0)
  }

  private func handleOnChangeVerticalAlignmentIndex(_ arg0: Int) {
    onChangeVerticalAlignmentIndex?(arg0)
  }

  private func handleOnClickHeader() {
    onClickHeader?()
  }
}

// MARK: - Parameters

extension LayoutInspector {
  public struct Parameters: Equatable {
    public var direction: Direction
    public var horizontalAlignment: HorizontalAlignment
    public var verticalAlignment: VerticalAlignment
    public var isExpanded: Bool
    public var onChangeDirectionIndex: ((Int) -> Void)?
    public var onChangeHorizontalAlignmentIndex: ((Int) -> Void)?
    public var onChangeVerticalAlignmentIndex: ((Int) -> Void)?
    public var onClickHeader: (() -> Void)?

    public init(
      direction: Direction,
      horizontalAlignment: HorizontalAlignment,
      verticalAlignment: VerticalAlignment,
      isExpanded: Bool,
      onChangeDirectionIndex: ((Int) -> Void)? = nil,
      onChangeHorizontalAlignmentIndex: ((Int) -> Void)? = nil,
      onChangeVerticalAlignmentIndex: ((Int) -> Void)? = nil,
      onClickHeader: (() -> Void)? = nil)
    {
      self.direction = direction
      self.horizontalAlignment = horizontalAlignment
      self.verticalAlignment = verticalAlignment
      self.isExpanded = isExpanded
      self.onChangeDirectionIndex = onChangeDirectionIndex
      self.onChangeHorizontalAlignmentIndex = onChangeHorizontalAlignmentIndex
      self.onChangeVerticalAlignmentIndex = onChangeVerticalAlignmentIndex
      self.onClickHeader = onClickHeader
    }

    public init() {
      self.init(direction: .horizontal, horizontalAlignment: .left, verticalAlignment: .top, isExpanded: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.direction == rhs.direction &&
        lhs.horizontalAlignment == rhs.horizontalAlignment &&
          lhs.verticalAlignment == rhs.verticalAlignment && lhs.isExpanded == rhs.isExpanded
    }
  }
}

// MARK: - Model

extension LayoutInspector {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "LayoutInspector"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      direction: Direction,
      horizontalAlignment: HorizontalAlignment,
      verticalAlignment: VerticalAlignment,
      isExpanded: Bool,
      onChangeDirectionIndex: ((Int) -> Void)? = nil,
      onChangeHorizontalAlignmentIndex: ((Int) -> Void)? = nil,
      onChangeVerticalAlignmentIndex: ((Int) -> Void)? = nil,
      onClickHeader: (() -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            direction: direction,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment,
            isExpanded: isExpanded,
            onChangeDirectionIndex: onChangeDirectionIndex,
            onChangeHorizontalAlignmentIndex: onChangeHorizontalAlignmentIndex,
            onChangeVerticalAlignmentIndex: onChangeVerticalAlignmentIndex,
            onClickHeader: onClickHeader))
    }

    public init() {
      self.init(direction: .horizontal, horizontalAlignment: .left, verticalAlignment: .top, isExpanded: false)
    }
  }
}

// MARK: - Direction

extension LayoutInspector {
  public enum Direction: Codable, Equatable {
    case horizontal
    case vertical

    // MARK: Codable

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let type = try container.decode(Bool.self)

      switch type {
        case false:
          self = .horizontal
        case true:
          self = .vertical
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()

      switch self {
        case .horizontal:
          try container.encode(false)
        case .vertical:
          try container.encode(true)
      }
    }
  }
}

// MARK: - HorizontalAlignment

extension LayoutInspector {
  public enum HorizontalAlignment: String, Codable, Equatable {
    case left
    case center
    case right
  }
}

// MARK: - VerticalAlignment

extension LayoutInspector {
  public enum VerticalAlignment: String, Codable, Equatable {
    case top
    case middle
    case bottom
  }
}
