import AppKit
import Foundation

// MARK: - TextStyleBrowser

public class TextStyleBrowser: NSBox {

  // MARK: Lifecycle

  public init() {
    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private

  private var innerView = NSBox()
  private var titleView = NSTextField(labelWithString: "")
  private var spacerView = NSBox()
  private var textStylePreviewCollectionView = TextStylePreviewCollection()

  private var titleViewTextStyle = TextStyles.title

  private var topPadding: CGFloat = 48
  private var trailingPadding: CGFloat = 48
  private var bottomPadding: CGFloat = 48
  private var leadingPadding: CGFloat = 48
  private var innerViewTopMargin: CGFloat = 0
  private var innerViewTrailingMargin: CGFloat = 0
  private var innerViewBottomMargin: CGFloat = 0
  private var innerViewLeadingMargin: CGFloat = 0
  private var innerViewTopPadding: CGFloat = 0
  private var innerViewTrailingPadding: CGFloat = 0
  private var innerViewBottomPadding: CGFloat = 0
  private var innerViewLeadingPadding: CGFloat = 0
  private var titleViewTopMargin: CGFloat = 0
  private var titleViewTrailingMargin: CGFloat = 0
  private var titleViewBottomMargin: CGFloat = 0
  private var titleViewLeadingMargin: CGFloat = 0
  private var spacerViewTopMargin: CGFloat = 0
  private var spacerViewTrailingMargin: CGFloat = 0
  private var spacerViewBottomMargin: CGFloat = 0
  private var spacerViewLeadingMargin: CGFloat = 0
  private var textStylePreviewCollectionViewTopMargin: CGFloat = 0
  private var textStylePreviewCollectionViewTrailingMargin: CGFloat = 0
  private var textStylePreviewCollectionViewBottomMargin: CGFloat = 0
  private var textStylePreviewCollectionViewLeadingMargin: CGFloat = 0

  private var innerViewTopAnchorConstraint: NSLayoutConstraint?
  private var innerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var innerViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var innerViewWidthAnchorConstraint: NSLayoutConstraint?
  private var titleViewTopAnchorConstraint: NSLayoutConstraint?
  private var titleViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var titleViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var spacerViewTopAnchorConstraint: NSLayoutConstraint?
  private var spacerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var spacerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var textStylePreviewCollectionViewBottomAnchorConstraint: NSLayoutConstraint?
  private var textStylePreviewCollectionViewTopAnchorConstraint: NSLayoutConstraint?
  private var textStylePreviewCollectionViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textStylePreviewCollectionViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var spacerViewHeightAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .noBorder
    innerView.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    spacerView.boxType = .custom
    spacerView.borderType = .noBorder
    spacerView.contentViewMargins = .zero

    addSubview(innerView)
    innerView.addSubview(titleView)
    innerView.addSubview(spacerView)
    innerView.addSubview(textStylePreviewCollectionView)

    titleViewTextStyle = TextStyles.title
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    titleView.attributedStringValue = titleViewTextStyle.apply(to: "Text Styles")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    textStylePreviewCollectionView.translatesAutoresizingMaskIntoConstraints = false

    let innerViewTopAnchorConstraint = innerView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + innerViewTopMargin)
    let innerViewBottomAnchorConstraint = innerView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + innerViewBottomMargin))
    let innerViewCenterXAnchorConstraint = innerView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0)
    let innerViewWidthAnchorConstraint = innerView.widthAnchor.constraint(equalToConstant: 840)
    let titleViewTopAnchorConstraint = titleView
      .topAnchor
      .constraint(equalTo: innerView.topAnchor, constant: innerViewTopPadding + titleViewTopMargin)
    let titleViewLeadingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: innerViewLeadingPadding + titleViewLeadingMargin)
    let titleViewTrailingAnchorConstraint = titleView
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor, constant: -(innerViewTrailingPadding + titleViewTrailingMargin))
    let spacerViewTopAnchorConstraint = spacerView
      .topAnchor
      .constraint(equalTo: titleView.bottomAnchor, constant: titleViewBottomMargin + spacerViewTopMargin)
    let spacerViewLeadingAnchorConstraint = spacerView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: innerViewLeadingPadding + spacerViewLeadingMargin)
    let spacerViewTrailingAnchorConstraint = spacerView
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor, constant: -(innerViewTrailingPadding + spacerViewTrailingMargin))
    let textStylePreviewCollectionViewBottomAnchorConstraint = textStylePreviewCollectionView
      .bottomAnchor
      .constraint(
        equalTo: innerView.bottomAnchor,
        constant: -(innerViewBottomPadding + textStylePreviewCollectionViewBottomMargin))
    let textStylePreviewCollectionViewTopAnchorConstraint = textStylePreviewCollectionView
      .topAnchor
      .constraint(
        equalTo: spacerView.bottomAnchor,
        constant: spacerViewBottomMargin + textStylePreviewCollectionViewTopMargin)
    let textStylePreviewCollectionViewLeadingAnchorConstraint = textStylePreviewCollectionView
      .leadingAnchor
      .constraint(
        equalTo: innerView.leadingAnchor,
        constant: innerViewLeadingPadding + textStylePreviewCollectionViewLeadingMargin)
    let textStylePreviewCollectionViewTrailingAnchorConstraint = textStylePreviewCollectionView
      .trailingAnchor
      .constraint(
        equalTo: innerView.trailingAnchor,
        constant: -(innerViewTrailingPadding + textStylePreviewCollectionViewTrailingMargin))
    let spacerViewHeightAnchorConstraint = spacerView.heightAnchor.constraint(equalToConstant: 24)

    NSLayoutConstraint.activate([
      innerViewTopAnchorConstraint,
      innerViewBottomAnchorConstraint,
      innerViewCenterXAnchorConstraint,
      innerViewWidthAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      spacerViewTopAnchorConstraint,
      spacerViewLeadingAnchorConstraint,
      spacerViewTrailingAnchorConstraint,
      textStylePreviewCollectionViewBottomAnchorConstraint,
      textStylePreviewCollectionViewTopAnchorConstraint,
      textStylePreviewCollectionViewLeadingAnchorConstraint,
      textStylePreviewCollectionViewTrailingAnchorConstraint,
      spacerViewHeightAnchorConstraint
    ])

    self.innerViewTopAnchorConstraint = innerViewTopAnchorConstraint
    self.innerViewBottomAnchorConstraint = innerViewBottomAnchorConstraint
    self.innerViewCenterXAnchorConstraint = innerViewCenterXAnchorConstraint
    self.innerViewWidthAnchorConstraint = innerViewWidthAnchorConstraint
    self.titleViewTopAnchorConstraint = titleViewTopAnchorConstraint
    self.titleViewLeadingAnchorConstraint = titleViewLeadingAnchorConstraint
    self.titleViewTrailingAnchorConstraint = titleViewTrailingAnchorConstraint
    self.spacerViewTopAnchorConstraint = spacerViewTopAnchorConstraint
    self.spacerViewLeadingAnchorConstraint = spacerViewLeadingAnchorConstraint
    self.spacerViewTrailingAnchorConstraint = spacerViewTrailingAnchorConstraint
    self.textStylePreviewCollectionViewBottomAnchorConstraint = textStylePreviewCollectionViewBottomAnchorConstraint
    self.textStylePreviewCollectionViewTopAnchorConstraint = textStylePreviewCollectionViewTopAnchorConstraint
    self.textStylePreviewCollectionViewLeadingAnchorConstraint = textStylePreviewCollectionViewLeadingAnchorConstraint
    self.textStylePreviewCollectionViewTrailingAnchorConstraint = textStylePreviewCollectionViewTrailingAnchorConstraint
    self.spacerViewHeightAnchorConstraint = spacerViewHeightAnchorConstraint

    // For debugging
    innerViewTopAnchorConstraint.identifier = "innerViewTopAnchorConstraint"
    innerViewBottomAnchorConstraint.identifier = "innerViewBottomAnchorConstraint"
    innerViewCenterXAnchorConstraint.identifier = "innerViewCenterXAnchorConstraint"
    innerViewWidthAnchorConstraint.identifier = "innerViewWidthAnchorConstraint"
    titleViewTopAnchorConstraint.identifier = "titleViewTopAnchorConstraint"
    titleViewLeadingAnchorConstraint.identifier = "titleViewLeadingAnchorConstraint"
    titleViewTrailingAnchorConstraint.identifier = "titleViewTrailingAnchorConstraint"
    spacerViewTopAnchorConstraint.identifier = "spacerViewTopAnchorConstraint"
    spacerViewLeadingAnchorConstraint.identifier = "spacerViewLeadingAnchorConstraint"
    spacerViewTrailingAnchorConstraint.identifier = "spacerViewTrailingAnchorConstraint"
    textStylePreviewCollectionViewBottomAnchorConstraint.identifier =
      "textStylePreviewCollectionViewBottomAnchorConstraint"
    textStylePreviewCollectionViewTopAnchorConstraint.identifier = "textStylePreviewCollectionViewTopAnchorConstraint"
    textStylePreviewCollectionViewLeadingAnchorConstraint.identifier =
      "textStylePreviewCollectionViewLeadingAnchorConstraint"
    textStylePreviewCollectionViewTrailingAnchorConstraint.identifier =
      "textStylePreviewCollectionViewTrailingAnchorConstraint"
    spacerViewHeightAnchorConstraint.identifier = "spacerViewHeightAnchorConstraint"
  }

  private func update() {}
}
