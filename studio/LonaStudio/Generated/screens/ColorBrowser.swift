import AppKit
import Foundation

// MARK: - ColorBrowser

public class ColorBrowser: NSBox {

  // MARK: Lifecycle

  public init(onSelectColor: ColorHandler, colors: ColorList) {
    self.onSelectColor = onSelectColor
    self.colors = colors

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(onSelectColor: nil, colors: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var onSelectColor: ColorHandler { didSet { update() } }
  public var colors: ColorList { didSet { update() } }
  public var onClickAddColor: (() -> Void)? { didSet { update() } }

  // MARK: Private

  private var innerView = NSBox()
  private var headerView = NSBox()
  private var titleView = NSTextField(labelWithString: "")
  private var spacerView = NSBox()
  private var fixedHeightFixButtonContainerView = NSBox()
  private var addColorButtonView = Button()
  private var colorPreviewCollectionView = ColorPreviewCollection()

  private var titleViewTextStyle = TextStyles.title

  private var topPadding: CGFloat = 48
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var innerViewTopMargin: CGFloat = 0
  private var innerViewTrailingMargin: CGFloat = 0
  private var innerViewBottomMargin: CGFloat = 0
  private var innerViewLeadingMargin: CGFloat = 0
  private var innerViewTopPadding: CGFloat = 0
  private var innerViewTrailingPadding: CGFloat = 0
  private var innerViewBottomPadding: CGFloat = 0
  private var innerViewLeadingPadding: CGFloat = 0
  private var headerViewTopMargin: CGFloat = 0
  private var headerViewTrailingMargin: CGFloat = 0
  private var headerViewBottomMargin: CGFloat = 0
  private var headerViewLeadingMargin: CGFloat = 0
  private var headerViewTopPadding: CGFloat = 0
  private var headerViewTrailingPadding: CGFloat = 64
  private var headerViewBottomPadding: CGFloat = 0
  private var headerViewLeadingPadding: CGFloat = 64
  private var colorPreviewCollectionViewTopMargin: CGFloat = 0
  private var colorPreviewCollectionViewTrailingMargin: CGFloat = 0
  private var colorPreviewCollectionViewBottomMargin: CGFloat = 0
  private var colorPreviewCollectionViewLeadingMargin: CGFloat = 0
  private var titleViewTopMargin: CGFloat = 0
  private var titleViewTrailingMargin: CGFloat = 0
  private var titleViewBottomMargin: CGFloat = 0
  private var titleViewLeadingMargin: CGFloat = 0
  private var spacerViewTopMargin: CGFloat = 0
  private var spacerViewTrailingMargin: CGFloat = 0
  private var spacerViewBottomMargin: CGFloat = 0
  private var spacerViewLeadingMargin: CGFloat = 0
  private var fixedHeightFixButtonContainerViewTopMargin: CGFloat = 0
  private var fixedHeightFixButtonContainerViewTrailingMargin: CGFloat = 0
  private var fixedHeightFixButtonContainerViewBottomMargin: CGFloat = 0
  private var fixedHeightFixButtonContainerViewLeadingMargin: CGFloat = 0
  private var fixedHeightFixButtonContainerViewTopPadding: CGFloat = 0
  private var fixedHeightFixButtonContainerViewTrailingPadding: CGFloat = 0
  private var fixedHeightFixButtonContainerViewBottomPadding: CGFloat = 0
  private var fixedHeightFixButtonContainerViewLeadingPadding: CGFloat = 0
  private var addColorButtonViewTopMargin: CGFloat = 0
  private var addColorButtonViewTrailingMargin: CGFloat = 0
  private var addColorButtonViewBottomMargin: CGFloat = 0
  private var addColorButtonViewLeadingMargin: CGFloat = 0

  private var innerViewTopAnchorConstraint: NSLayoutConstraint?
  private var innerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var innerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var innerViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var innerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var headerViewTopAnchorConstraint: NSLayoutConstraint?
  private var headerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var headerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var colorPreviewCollectionViewBottomAnchorConstraint: NSLayoutConstraint?
  private var colorPreviewCollectionViewTopAnchorConstraint: NSLayoutConstraint?
  private var colorPreviewCollectionViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var colorPreviewCollectionViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var headerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var titleViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var titleViewTopAnchorConstraint: NSLayoutConstraint?
  private var titleViewCenterYAnchorConstraint: NSLayoutConstraint?
  private var titleViewBottomAnchorConstraint: NSLayoutConstraint?
  private var spacerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var spacerViewCenterYAnchorConstraint: NSLayoutConstraint?
  private var fixedHeightFixButtonContainerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var fixedHeightFixButtonContainerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var fixedHeightFixButtonContainerViewTopAnchorConstraint: NSLayoutConstraint?
  private var fixedHeightFixButtonContainerViewCenterYAnchorConstraint: NSLayoutConstraint?
  private var fixedHeightFixButtonContainerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var spacerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var addColorButtonViewWidthAnchorParentConstraint: NSLayoutConstraint?
  private var addColorButtonViewTopAnchorConstraint: NSLayoutConstraint?
  private var addColorButtonViewBottomAnchorConstraint: NSLayoutConstraint?
  private var addColorButtonViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var addColorButtonViewTrailingAnchorConstraint: NSLayoutConstraint?

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

    let innerViewTopAnchorConstraint = innerView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + innerViewTopMargin)
    let innerViewBottomAnchorConstraint = innerView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + innerViewBottomMargin))
    let innerViewLeadingAnchorConstraint = innerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + innerViewLeadingMargin)
    let innerViewCenterXAnchorConstraint = innerView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0)
    let innerViewTrailingAnchorConstraint = innerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + innerViewTrailingMargin))
    let headerViewTopAnchorConstraint = headerView
      .topAnchor
      .constraint(equalTo: innerView.topAnchor, constant: innerViewTopPadding + headerViewTopMargin)
    let headerViewLeadingAnchorConstraint = headerView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: innerViewLeadingPadding + headerViewLeadingMargin)
    let headerViewTrailingAnchorConstraint = headerView
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor, constant: -(innerViewTrailingPadding + headerViewTrailingMargin))
    let colorPreviewCollectionViewBottomAnchorConstraint = colorPreviewCollectionView
      .bottomAnchor
      .constraint(
        equalTo: innerView.bottomAnchor,
        constant: -(innerViewBottomPadding + colorPreviewCollectionViewBottomMargin))
    let colorPreviewCollectionViewTopAnchorConstraint = colorPreviewCollectionView
      .topAnchor
      .constraint(
        equalTo: headerView.bottomAnchor,
        constant: headerViewBottomMargin + colorPreviewCollectionViewTopMargin)
    let colorPreviewCollectionViewLeadingAnchorConstraint = colorPreviewCollectionView
      .leadingAnchor
      .constraint(
        equalTo: innerView.leadingAnchor,
        constant: innerViewLeadingPadding + colorPreviewCollectionViewLeadingMargin)
    let colorPreviewCollectionViewTrailingAnchorConstraint = colorPreviewCollectionView
      .trailingAnchor
      .constraint(
        equalTo: innerView.trailingAnchor,
        constant: -(innerViewTrailingPadding + colorPreviewCollectionViewTrailingMargin))
    let headerViewHeightAnchorConstraint = headerView.heightAnchor.constraint(equalToConstant: 38)
    let titleViewLeadingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(equalTo: headerView.leadingAnchor, constant: headerViewLeadingPadding + titleViewLeadingMargin)
    let titleViewTopAnchorConstraint = titleView
      .topAnchor
      .constraint(equalTo: headerView.topAnchor, constant: headerViewTopPadding + titleViewTopMargin)
    let titleViewCenterYAnchorConstraint = titleView
      .centerYAnchor
      .constraint(equalTo: headerView.centerYAnchor, constant: 0)
    let titleViewBottomAnchorConstraint = titleView
      .bottomAnchor
      .constraint(equalTo: headerView.bottomAnchor, constant: -(headerViewBottomPadding + titleViewBottomMargin))
    let spacerViewLeadingAnchorConstraint = spacerView
      .leadingAnchor
      .constraint(equalTo: titleView.trailingAnchor, constant: titleViewTrailingMargin + spacerViewLeadingMargin)
    let spacerViewCenterYAnchorConstraint = spacerView
      .centerYAnchor
      .constraint(equalTo: headerView.centerYAnchor, constant: 0)
    let fixedHeightFixButtonContainerViewTrailingAnchorConstraint = fixedHeightFixButtonContainerView
      .trailingAnchor
      .constraint(
        equalTo: headerView.trailingAnchor,
        constant: -(headerViewTrailingPadding + fixedHeightFixButtonContainerViewTrailingMargin))
    let fixedHeightFixButtonContainerViewLeadingAnchorConstraint = fixedHeightFixButtonContainerView
      .leadingAnchor
      .constraint(
        equalTo: spacerView.trailingAnchor,
        constant: spacerViewTrailingMargin + fixedHeightFixButtonContainerViewLeadingMargin)
    let fixedHeightFixButtonContainerViewTopAnchorConstraint = fixedHeightFixButtonContainerView
      .topAnchor
      .constraint(
        equalTo: headerView.topAnchor,
        constant: headerViewTopPadding + fixedHeightFixButtonContainerViewTopMargin)
    let fixedHeightFixButtonContainerViewCenterYAnchorConstraint = fixedHeightFixButtonContainerView
      .centerYAnchor
      .constraint(equalTo: headerView.centerYAnchor, constant: 0)
    let fixedHeightFixButtonContainerViewBottomAnchorConstraint = fixedHeightFixButtonContainerView
      .bottomAnchor
      .constraint(
        equalTo: headerView.bottomAnchor,
        constant: -(headerViewBottomPadding + fixedHeightFixButtonContainerViewBottomMargin))
    let spacerViewHeightAnchorConstraint = spacerView.heightAnchor.constraint(equalToConstant: 0)
    let addColorButtonViewWidthAnchorParentConstraint = addColorButtonView
      .widthAnchor
      .constraint(
        lessThanOrEqualTo: fixedHeightFixButtonContainerView.widthAnchor,
        constant:
        -(
        fixedHeightFixButtonContainerViewLeadingPadding + addColorButtonViewLeadingMargin +
          fixedHeightFixButtonContainerViewTrailingPadding + addColorButtonViewTrailingMargin
        ))
    let addColorButtonViewTopAnchorConstraint = addColorButtonView
      .topAnchor
      .constraint(
        equalTo: fixedHeightFixButtonContainerView.topAnchor,
        constant: fixedHeightFixButtonContainerViewTopPadding + addColorButtonViewTopMargin)
    let addColorButtonViewBottomAnchorConstraint = addColorButtonView
      .bottomAnchor
      .constraint(
        equalTo: fixedHeightFixButtonContainerView.bottomAnchor,
        constant: -(fixedHeightFixButtonContainerViewBottomPadding + addColorButtonViewBottomMargin))
    let addColorButtonViewLeadingAnchorConstraint = addColorButtonView
      .leadingAnchor
      .constraint(
        equalTo: fixedHeightFixButtonContainerView.leadingAnchor,
        constant: fixedHeightFixButtonContainerViewLeadingPadding + addColorButtonViewLeadingMargin)
    let addColorButtonViewTrailingAnchorConstraint = addColorButtonView
      .trailingAnchor
      .constraint(
        equalTo: fixedHeightFixButtonContainerView.trailingAnchor,
        constant: -(fixedHeightFixButtonContainerViewTrailingPadding + addColorButtonViewTrailingMargin))

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

    self.innerViewTopAnchorConstraint = innerViewTopAnchorConstraint
    self.innerViewBottomAnchorConstraint = innerViewBottomAnchorConstraint
    self.innerViewLeadingAnchorConstraint = innerViewLeadingAnchorConstraint
    self.innerViewCenterXAnchorConstraint = innerViewCenterXAnchorConstraint
    self.innerViewTrailingAnchorConstraint = innerViewTrailingAnchorConstraint
    self.headerViewTopAnchorConstraint = headerViewTopAnchorConstraint
    self.headerViewLeadingAnchorConstraint = headerViewLeadingAnchorConstraint
    self.headerViewTrailingAnchorConstraint = headerViewTrailingAnchorConstraint
    self.colorPreviewCollectionViewBottomAnchorConstraint = colorPreviewCollectionViewBottomAnchorConstraint
    self.colorPreviewCollectionViewTopAnchorConstraint = colorPreviewCollectionViewTopAnchorConstraint
    self.colorPreviewCollectionViewLeadingAnchorConstraint = colorPreviewCollectionViewLeadingAnchorConstraint
    self.colorPreviewCollectionViewTrailingAnchorConstraint = colorPreviewCollectionViewTrailingAnchorConstraint
    self.headerViewHeightAnchorConstraint = headerViewHeightAnchorConstraint
    self.titleViewLeadingAnchorConstraint = titleViewLeadingAnchorConstraint
    self.titleViewTopAnchorConstraint = titleViewTopAnchorConstraint
    self.titleViewCenterYAnchorConstraint = titleViewCenterYAnchorConstraint
    self.titleViewBottomAnchorConstraint = titleViewBottomAnchorConstraint
    self.spacerViewLeadingAnchorConstraint = spacerViewLeadingAnchorConstraint
    self.spacerViewCenterYAnchorConstraint = spacerViewCenterYAnchorConstraint
    self.fixedHeightFixButtonContainerViewTrailingAnchorConstraint =
      fixedHeightFixButtonContainerViewTrailingAnchorConstraint
    self.fixedHeightFixButtonContainerViewLeadingAnchorConstraint =
      fixedHeightFixButtonContainerViewLeadingAnchorConstraint
    self.fixedHeightFixButtonContainerViewTopAnchorConstraint = fixedHeightFixButtonContainerViewTopAnchorConstraint
    self.fixedHeightFixButtonContainerViewCenterYAnchorConstraint =
      fixedHeightFixButtonContainerViewCenterYAnchorConstraint
    self.fixedHeightFixButtonContainerViewBottomAnchorConstraint =
      fixedHeightFixButtonContainerViewBottomAnchorConstraint
    self.spacerViewHeightAnchorConstraint = spacerViewHeightAnchorConstraint
    self.addColorButtonViewWidthAnchorParentConstraint = addColorButtonViewWidthAnchorParentConstraint
    self.addColorButtonViewTopAnchorConstraint = addColorButtonViewTopAnchorConstraint
    self.addColorButtonViewBottomAnchorConstraint = addColorButtonViewBottomAnchorConstraint
    self.addColorButtonViewLeadingAnchorConstraint = addColorButtonViewLeadingAnchorConstraint
    self.addColorButtonViewTrailingAnchorConstraint = addColorButtonViewTrailingAnchorConstraint

    // For debugging
    innerViewTopAnchorConstraint.identifier = "innerViewTopAnchorConstraint"
    innerViewBottomAnchorConstraint.identifier = "innerViewBottomAnchorConstraint"
    innerViewLeadingAnchorConstraint.identifier = "innerViewLeadingAnchorConstraint"
    innerViewCenterXAnchorConstraint.identifier = "innerViewCenterXAnchorConstraint"
    innerViewTrailingAnchorConstraint.identifier = "innerViewTrailingAnchorConstraint"
    headerViewTopAnchorConstraint.identifier = "headerViewTopAnchorConstraint"
    headerViewLeadingAnchorConstraint.identifier = "headerViewLeadingAnchorConstraint"
    headerViewTrailingAnchorConstraint.identifier = "headerViewTrailingAnchorConstraint"
    colorPreviewCollectionViewBottomAnchorConstraint.identifier = "colorPreviewCollectionViewBottomAnchorConstraint"
    colorPreviewCollectionViewTopAnchorConstraint.identifier = "colorPreviewCollectionViewTopAnchorConstraint"
    colorPreviewCollectionViewLeadingAnchorConstraint.identifier = "colorPreviewCollectionViewLeadingAnchorConstraint"
    colorPreviewCollectionViewTrailingAnchorConstraint.identifier = "colorPreviewCollectionViewTrailingAnchorConstraint"
    headerViewHeightAnchorConstraint.identifier = "headerViewHeightAnchorConstraint"
    titleViewLeadingAnchorConstraint.identifier = "titleViewLeadingAnchorConstraint"
    titleViewTopAnchorConstraint.identifier = "titleViewTopAnchorConstraint"
    titleViewCenterYAnchorConstraint.identifier = "titleViewCenterYAnchorConstraint"
    titleViewBottomAnchorConstraint.identifier = "titleViewBottomAnchorConstraint"
    spacerViewLeadingAnchorConstraint.identifier = "spacerViewLeadingAnchorConstraint"
    spacerViewCenterYAnchorConstraint.identifier = "spacerViewCenterYAnchorConstraint"
    fixedHeightFixButtonContainerViewTrailingAnchorConstraint.identifier =
      "fixedHeightFixButtonContainerViewTrailingAnchorConstraint"
    fixedHeightFixButtonContainerViewLeadingAnchorConstraint.identifier =
      "fixedHeightFixButtonContainerViewLeadingAnchorConstraint"
    fixedHeightFixButtonContainerViewTopAnchorConstraint.identifier =
      "fixedHeightFixButtonContainerViewTopAnchorConstraint"
    fixedHeightFixButtonContainerViewCenterYAnchorConstraint.identifier =
      "fixedHeightFixButtonContainerViewCenterYAnchorConstraint"
    fixedHeightFixButtonContainerViewBottomAnchorConstraint.identifier =
      "fixedHeightFixButtonContainerViewBottomAnchorConstraint"
    spacerViewHeightAnchorConstraint.identifier = "spacerViewHeightAnchorConstraint"
    addColorButtonViewWidthAnchorParentConstraint.identifier = "addColorButtonViewWidthAnchorParentConstraint"
    addColorButtonViewTopAnchorConstraint.identifier = "addColorButtonViewTopAnchorConstraint"
    addColorButtonViewBottomAnchorConstraint.identifier = "addColorButtonViewBottomAnchorConstraint"
    addColorButtonViewLeadingAnchorConstraint.identifier = "addColorButtonViewLeadingAnchorConstraint"
    addColorButtonViewTrailingAnchorConstraint.identifier = "addColorButtonViewTrailingAnchorConstraint"
  }

  private func update() {
    colorPreviewCollectionView.onSelectColor = onSelectColor
    colorPreviewCollectionView.colors = colors
    addColorButtonView.onClick = onClickAddColor
  }
}
