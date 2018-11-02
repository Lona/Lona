import AppKit
import Foundation

// MARK: - ColorBrowser

public class ColorBrowser: NSBox {

  // MARK: Lifecycle

  public init(
    onSelectColor: ColorHandler,
    onDeleteColor: ColorHandler,
    colors: ColorList,
    onMoveColor: ItemMoveHandler)
  {
    self.onSelectColor = onSelectColor
    self.onDeleteColor = onDeleteColor
    self.colors = colors
    self.onMoveColor = onMoveColor

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(onSelectColor: nil, onDeleteColor: nil, colors: nil, onMoveColor: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var onSelectColor: ColorHandler { didSet { update() } }
  public var onDeleteColor: ColorHandler { didSet { update() } }
  public var colors: ColorList { didSet { update() } }
  public var onClickAddColor: (() -> Void)? { didSet { update() } }
  public var onMoveColor: ItemMoveHandler { didSet { update() } }

  // MARK: Private

  private var innerView = NSBox()
  private var headerView = NSBox()
  private var titleView = LNATextField(labelWithString: "")
  private var spacerView = NSBox()
  private var fixedHeightFixButtonContainerView = NSBox()
  private var addColorButtonView = Button()
  private var colorPreviewCollectionView = ColorPreviewCollection()

  private var titleViewTextStyle = TextStyles.title

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
    fixedHeightFixButtonContainerView.boxType = .custom
    fixedHeightFixButtonContainerView.borderType = .noBorder
    fixedHeightFixButtonContainerView.contentViewMargins = .zero

    addSubview(innerView)
    innerView.addSubview(headerView)
    innerView.addSubview(colorPreviewCollectionView)
    headerView.addSubview(titleView)
    headerView.addSubview(spacerView)
    headerView.addSubview(fixedHeightFixButtonContainerView)
    fixedHeightFixButtonContainerView.addSubview(addColorButtonView)

    fillColor = Colors.white
    titleView.attributedStringValue = titleViewTextStyle.apply(to: "Colors")
    titleViewTextStyle = TextStyles.title
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    addColorButtonView.titleText = "Add Color"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    headerView.translatesAutoresizingMaskIntoConstraints = false
    colorPreviewCollectionView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    fixedHeightFixButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
    addColorButtonView.translatesAutoresizingMaskIntoConstraints = false

    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor, constant: 48)
    let innerViewBottomAnchorConstraint = innerView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let innerViewCenterXAnchorConstraint = innerView.centerXAnchor.constraint(equalTo: centerXAnchor)
    let innerViewTrailingAnchorConstraint = innerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let headerViewTopAnchorConstraint = headerView.topAnchor.constraint(equalTo: innerView.topAnchor)
    let headerViewLeadingAnchorConstraint = headerView.leadingAnchor.constraint(equalTo: innerView.leadingAnchor)
    let headerViewTrailingAnchorConstraint = headerView.trailingAnchor.constraint(equalTo: innerView.trailingAnchor)
    let colorPreviewCollectionViewBottomAnchorConstraint = colorPreviewCollectionView
      .bottomAnchor
      .constraint(equalTo: innerView.bottomAnchor)
    let colorPreviewCollectionViewTopAnchorConstraint = colorPreviewCollectionView
      .topAnchor
      .constraint(equalTo: headerView.bottomAnchor)
    let colorPreviewCollectionViewLeadingAnchorConstraint = colorPreviewCollectionView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor)
    let colorPreviewCollectionViewTrailingAnchorConstraint = colorPreviewCollectionView
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
    let fixedHeightFixButtonContainerViewTrailingAnchorConstraint = fixedHeightFixButtonContainerView
      .trailingAnchor
      .constraint(equalTo: headerView.trailingAnchor, constant: -64)
    let fixedHeightFixButtonContainerViewLeadingAnchorConstraint = fixedHeightFixButtonContainerView
      .leadingAnchor
      .constraint(equalTo: spacerView.trailingAnchor)
    let fixedHeightFixButtonContainerViewTopAnchorConstraint = fixedHeightFixButtonContainerView
      .topAnchor
      .constraint(equalTo: headerView.topAnchor)
    let fixedHeightFixButtonContainerViewCenterYAnchorConstraint = fixedHeightFixButtonContainerView
      .centerYAnchor
      .constraint(equalTo: headerView.centerYAnchor)
    let fixedHeightFixButtonContainerViewBottomAnchorConstraint = fixedHeightFixButtonContainerView
      .bottomAnchor
      .constraint(equalTo: headerView.bottomAnchor)
    let spacerViewHeightAnchorConstraint = spacerView.heightAnchor.constraint(equalToConstant: 0)
    let addColorButtonViewWidthAnchorParentConstraint = addColorButtonView
      .widthAnchor
      .constraint(lessThanOrEqualTo: fixedHeightFixButtonContainerView.widthAnchor)
    let addColorButtonViewTopAnchorConstraint = addColorButtonView
      .topAnchor
      .constraint(equalTo: fixedHeightFixButtonContainerView.topAnchor)
    let addColorButtonViewBottomAnchorConstraint = addColorButtonView
      .bottomAnchor
      .constraint(equalTo: fixedHeightFixButtonContainerView.bottomAnchor)
    let addColorButtonViewLeadingAnchorConstraint = addColorButtonView
      .leadingAnchor
      .constraint(equalTo: fixedHeightFixButtonContainerView.leadingAnchor)
    let addColorButtonViewTrailingAnchorConstraint = addColorButtonView
      .trailingAnchor
      .constraint(equalTo: fixedHeightFixButtonContainerView.trailingAnchor)

    addColorButtonViewWidthAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      innerViewTopAnchorConstraint,
      innerViewBottomAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewCenterXAnchorConstraint,
      innerViewTrailingAnchorConstraint,
      headerViewTopAnchorConstraint,
      headerViewLeadingAnchorConstraint,
      headerViewTrailingAnchorConstraint,
      colorPreviewCollectionViewBottomAnchorConstraint,
      colorPreviewCollectionViewTopAnchorConstraint,
      colorPreviewCollectionViewLeadingAnchorConstraint,
      colorPreviewCollectionViewTrailingAnchorConstraint,
      headerViewHeightAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewCenterYAnchorConstraint,
      titleViewBottomAnchorConstraint,
      spacerViewLeadingAnchorConstraint,
      spacerViewCenterYAnchorConstraint,
      fixedHeightFixButtonContainerViewTrailingAnchorConstraint,
      fixedHeightFixButtonContainerViewLeadingAnchorConstraint,
      fixedHeightFixButtonContainerViewTopAnchorConstraint,
      fixedHeightFixButtonContainerViewCenterYAnchorConstraint,
      fixedHeightFixButtonContainerViewBottomAnchorConstraint,
      spacerViewHeightAnchorConstraint,
      addColorButtonViewWidthAnchorParentConstraint,
      addColorButtonViewTopAnchorConstraint,
      addColorButtonViewBottomAnchorConstraint,
      addColorButtonViewLeadingAnchorConstraint,
      addColorButtonViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    colorPreviewCollectionView.onSelectColor = onSelectColor
    colorPreviewCollectionView.onDeleteColor = onDeleteColor
    colorPreviewCollectionView.colors = colors
    addColorButtonView.onClick = onClickAddColor
    colorPreviewCollectionView.onMoveColor = onMoveColor
  }
}
