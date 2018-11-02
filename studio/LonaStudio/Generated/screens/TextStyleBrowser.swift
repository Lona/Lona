import AppKit
import Foundation

// MARK: - TextStyleBrowser

public class TextStyleBrowser: NSBox {

  // MARK: Lifecycle

  public init(
    onSelectTextStyle: TextStyleHandler,
    onDeleteTextStyle: TextStyleHandler,
    textStyles: TextStyleList,
    onMoveTextStyle: ItemMoveHandler)
  {
    self.onSelectTextStyle = onSelectTextStyle
    self.onDeleteTextStyle = onDeleteTextStyle
    self.textStyles = textStyles
    self.onMoveTextStyle = onMoveTextStyle

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(onSelectTextStyle: nil, onDeleteTextStyle: nil, textStyles: nil, onMoveTextStyle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var onSelectTextStyle: TextStyleHandler { didSet { update() } }
  public var onDeleteTextStyle: TextStyleHandler { didSet { update() } }
  public var textStyles: TextStyleList { didSet { update() } }
  public var onClickAddTextStyle: (() -> Void)? { didSet { update() } }
  public var onMoveTextStyle: ItemMoveHandler { didSet { update() } }

  // MARK: Private

  private var innerView = NSBox()
  private var headerView = NSBox()
  private var titleView = LNATextField(labelWithString: "")
  private var spacerView = NSBox()
  private var fixedHeightFixView = NSBox()
  private var buttonView = Button()
  private var textStylePreviewCollectionView = TextStylePreviewCollection()

  private var titleViewTextStyle = TextStyles.title

  private var spacerViewTrailingAnchorHeaderViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var fixedHeightFixViewTrailingAnchorHeaderViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var fixedHeightFixViewLeadingAnchorSpacerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var fixedHeightFixViewTopAnchorHeaderViewTopAnchorConstraint: NSLayoutConstraint?
  private var fixedHeightFixViewCenterYAnchorHeaderViewCenterYAnchorConstraint: NSLayoutConstraint?
  private var fixedHeightFixViewBottomAnchorHeaderViewBottomAnchorConstraint: NSLayoutConstraint?
  private var buttonViewWidthAnchorParentConstraint: NSLayoutConstraint?
  private var buttonViewTopAnchorFixedHeightFixViewTopAnchorConstraint: NSLayoutConstraint?
  private var buttonViewBottomAnchorFixedHeightFixViewBottomAnchorConstraint: NSLayoutConstraint?
  private var buttonViewLeadingAnchorFixedHeightFixViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var buttonViewTrailingAnchorFixedHeightFixViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .noBorder
    innerView.contentViewMargins = .zero
    headerView.boxType = .custom
    headerView.borderType = .noBorder
    headerView.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    spacerView.boxType = .custom
    spacerView.borderType = .noBorder
    spacerView.contentViewMargins = .zero
    fixedHeightFixView.boxType = .custom
    fixedHeightFixView.borderType = .noBorder
    fixedHeightFixView.contentViewMargins = .zero

    addSubview(innerView)
    innerView.addSubview(headerView)
    innerView.addSubview(textStylePreviewCollectionView)
    headerView.addSubview(titleView)
    headerView.addSubview(spacerView)
    headerView.addSubview(fixedHeightFixView)
    fixedHeightFixView.addSubview(buttonView)

    fillColor = Colors.white
    titleView.attributedStringValue = titleViewTextStyle.apply(to: "Text Styles")
    titleViewTextStyle = TextStyles.title
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    fixedHeightFixView.isHidden = !false
    buttonView.titleText = "Add Text Style"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    headerView.translatesAutoresizingMaskIntoConstraints = false
    textStylePreviewCollectionView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    fixedHeightFixView.translatesAutoresizingMaskIntoConstraints = false
    buttonView.translatesAutoresizingMaskIntoConstraints = false

    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor, constant: 48)
    let innerViewBottomAnchorConstraint = innerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let innerViewCenterXAnchorConstraint = innerView.centerXAnchor.constraint(equalTo: centerXAnchor)
    let innerViewTrailingAnchorConstraint = innerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let headerViewTopAnchorConstraint = headerView.topAnchor.constraint(equalTo: innerView.topAnchor)
    let headerViewLeadingAnchorConstraint = headerView.leadingAnchor.constraint(equalTo: innerView.leadingAnchor)
    let headerViewTrailingAnchorConstraint = headerView.trailingAnchor.constraint(equalTo: innerView.trailingAnchor)
    let textStylePreviewCollectionViewBottomAnchorConstraint = textStylePreviewCollectionView
      .bottomAnchor
      .constraint(equalTo: innerView.bottomAnchor)
    let textStylePreviewCollectionViewTopAnchorConstraint = textStylePreviewCollectionView
      .topAnchor
      .constraint(equalTo: headerView.bottomAnchor)
    let textStylePreviewCollectionViewLeadingAnchorConstraint = textStylePreviewCollectionView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor)
    let textStylePreviewCollectionViewTrailingAnchorConstraint = textStylePreviewCollectionView
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor)
    let headerViewHeightAnchorConstraint = headerView.heightAnchor.constraint(equalToConstant: 38)
    let titleViewLeadingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(equalTo: headerView.leadingAnchor, constant: 64)
    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: headerView.topAnchor)
    let titleViewCenterYAnchorConstraint = titleView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
    let titleViewBottomAnchorConstraint = titleView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor)
    let spacerViewLeadingAnchorConstraint = spacerView.leadingAnchor.constraint(equalTo: titleView.trailingAnchor)
    let spacerViewCenterYAnchorConstraint = spacerView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
    let spacerViewHeightAnchorConstraint = spacerView.heightAnchor.constraint(equalToConstant: 24)
    let spacerViewTrailingAnchorHeaderViewTrailingAnchorConstraint = spacerView
      .trailingAnchor
      .constraint(equalTo: headerView.trailingAnchor, constant: -64)
    let fixedHeightFixViewTrailingAnchorHeaderViewTrailingAnchorConstraint = fixedHeightFixView
      .trailingAnchor
      .constraint(equalTo: headerView.trailingAnchor, constant: -64)
    let fixedHeightFixViewLeadingAnchorSpacerViewTrailingAnchorConstraint = fixedHeightFixView
      .leadingAnchor
      .constraint(equalTo: spacerView.trailingAnchor)
    let fixedHeightFixViewTopAnchorHeaderViewTopAnchorConstraint = fixedHeightFixView
      .topAnchor
      .constraint(equalTo: headerView.topAnchor)
    let fixedHeightFixViewCenterYAnchorHeaderViewCenterYAnchorConstraint = fixedHeightFixView
      .centerYAnchor
      .constraint(equalTo: headerView.centerYAnchor)
    let fixedHeightFixViewBottomAnchorHeaderViewBottomAnchorConstraint = fixedHeightFixView
      .bottomAnchor
      .constraint(equalTo: headerView.bottomAnchor)
    let buttonViewWidthAnchorParentConstraint = buttonView
      .widthAnchor
      .constraint(lessThanOrEqualTo: fixedHeightFixView.widthAnchor)
    let buttonViewTopAnchorFixedHeightFixViewTopAnchorConstraint = buttonView
      .topAnchor
      .constraint(equalTo: fixedHeightFixView.topAnchor)
    let buttonViewBottomAnchorFixedHeightFixViewBottomAnchorConstraint = buttonView
      .bottomAnchor
      .constraint(equalTo: fixedHeightFixView.bottomAnchor)
    let buttonViewLeadingAnchorFixedHeightFixViewLeadingAnchorConstraint = buttonView
      .leadingAnchor
      .constraint(equalTo: fixedHeightFixView.leadingAnchor)
    let buttonViewTrailingAnchorFixedHeightFixViewTrailingAnchorConstraint = buttonView
      .trailingAnchor
      .constraint(equalTo: fixedHeightFixView.trailingAnchor)

    buttonViewWidthAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      innerViewTopAnchorConstraint,
      innerViewBottomAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewCenterXAnchorConstraint,
      innerViewTrailingAnchorConstraint,
      headerViewTopAnchorConstraint,
      headerViewLeadingAnchorConstraint,
      headerViewTrailingAnchorConstraint,
      textStylePreviewCollectionViewBottomAnchorConstraint,
      textStylePreviewCollectionViewTopAnchorConstraint,
      textStylePreviewCollectionViewLeadingAnchorConstraint,
      textStylePreviewCollectionViewTrailingAnchorConstraint,
      headerViewHeightAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewCenterYAnchorConstraint,
      titleViewBottomAnchorConstraint,
      spacerViewLeadingAnchorConstraint,
      spacerViewCenterYAnchorConstraint,
      spacerViewHeightAnchorConstraint
    ])

    self.spacerViewTrailingAnchorHeaderViewTrailingAnchorConstraint =
      spacerViewTrailingAnchorHeaderViewTrailingAnchorConstraint
    self.fixedHeightFixViewTrailingAnchorHeaderViewTrailingAnchorConstraint =
      fixedHeightFixViewTrailingAnchorHeaderViewTrailingAnchorConstraint
    self.fixedHeightFixViewLeadingAnchorSpacerViewTrailingAnchorConstraint =
      fixedHeightFixViewLeadingAnchorSpacerViewTrailingAnchorConstraint
    self.fixedHeightFixViewTopAnchorHeaderViewTopAnchorConstraint =
      fixedHeightFixViewTopAnchorHeaderViewTopAnchorConstraint
    self.fixedHeightFixViewCenterYAnchorHeaderViewCenterYAnchorConstraint =
      fixedHeightFixViewCenterYAnchorHeaderViewCenterYAnchorConstraint
    self.fixedHeightFixViewBottomAnchorHeaderViewBottomAnchorConstraint =
      fixedHeightFixViewBottomAnchorHeaderViewBottomAnchorConstraint
    self.buttonViewWidthAnchorParentConstraint = buttonViewWidthAnchorParentConstraint
    self.buttonViewTopAnchorFixedHeightFixViewTopAnchorConstraint =
      buttonViewTopAnchorFixedHeightFixViewTopAnchorConstraint
    self.buttonViewBottomAnchorFixedHeightFixViewBottomAnchorConstraint =
      buttonViewBottomAnchorFixedHeightFixViewBottomAnchorConstraint
    self.buttonViewLeadingAnchorFixedHeightFixViewLeadingAnchorConstraint =
      buttonViewLeadingAnchorFixedHeightFixViewLeadingAnchorConstraint
    self.buttonViewTrailingAnchorFixedHeightFixViewTrailingAnchorConstraint =
      buttonViewTrailingAnchorFixedHeightFixViewTrailingAnchorConstraint
  }

  private func conditionalConstraints() -> [NSLayoutConstraint] {
    var constraints: [NSLayoutConstraint?]

    switch (fixedHeightFixView.isHidden) {
      case (true):
        constraints = [spacerViewTrailingAnchorHeaderViewTrailingAnchorConstraint]
      case (false):
        constraints = [
          fixedHeightFixViewTrailingAnchorHeaderViewTrailingAnchorConstraint,
          fixedHeightFixViewLeadingAnchorSpacerViewTrailingAnchorConstraint,
          fixedHeightFixViewTopAnchorHeaderViewTopAnchorConstraint,
          fixedHeightFixViewCenterYAnchorHeaderViewCenterYAnchorConstraint,
          fixedHeightFixViewBottomAnchorHeaderViewBottomAnchorConstraint,
          buttonViewWidthAnchorParentConstraint,
          buttonViewTopAnchorFixedHeightFixViewTopAnchorConstraint,
          buttonViewBottomAnchorFixedHeightFixViewBottomAnchorConstraint,
          buttonViewLeadingAnchorFixedHeightFixViewLeadingAnchorConstraint,
          buttonViewTrailingAnchorFixedHeightFixViewTrailingAnchorConstraint
        ]
    }

    return constraints.compactMap({ $0 })
  }

  private func update() {
    NSLayoutConstraint.deactivate(conditionalConstraints())

    NSLayoutConstraint.activate(conditionalConstraints())
  }
}
