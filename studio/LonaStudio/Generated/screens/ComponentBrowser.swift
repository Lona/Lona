import AppKit
import Foundation

// MARK: - ComponentBrowser

public class ComponentBrowser: NSBox {

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
  private var componentPreviewCollectionView = ComponentPreviewCollection()

  private var titleViewTextStyle = TextStyles.title

  private var topPadding: CGFloat = 48
  private var trailingPadding: CGFloat = 64
  private var bottomPadding: CGFloat = 48
  private var leadingPadding: CGFloat = 64
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
  private var componentPreviewCollectionViewTopMargin: CGFloat = 0
  private var componentPreviewCollectionViewTrailingMargin: CGFloat = 0
  private var componentPreviewCollectionViewBottomMargin: CGFloat = 0
  private var componentPreviewCollectionViewLeadingMargin: CGFloat = 0

  private var innerViewTopAnchorConstraint: NSLayoutConstraint?
  private var innerViewBottomAnchorConstraint: NSLayoutConstraint?
  private var innerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var innerViewCenterXAnchorConstraint: NSLayoutConstraint?
  private var innerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var titleViewTopAnchorConstraint: NSLayoutConstraint?
  private var titleViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var titleViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var spacerViewTopAnchorConstraint: NSLayoutConstraint?
  private var spacerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var spacerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var componentPreviewCollectionViewBottomAnchorConstraint: NSLayoutConstraint?
  private var componentPreviewCollectionViewTopAnchorConstraint: NSLayoutConstraint?
  private var componentPreviewCollectionViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var componentPreviewCollectionViewTrailingAnchorConstraint: NSLayoutConstraint?
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
    innerView.addSubview(componentPreviewCollectionView)

    titleViewTextStyle = TextStyles.title
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    titleView.attributedStringValue = titleViewTextStyle.apply(to: "Components")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    componentPreviewCollectionView.translatesAutoresizingMaskIntoConstraints = false

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
    let titleViewTopAnchorConstraint = titleView
      .topAnchor
      .constraint(equalTo: innerView.topAnchor, constant: innerViewTopPadding + titleViewTopMargin)
    let titleViewLeadingAnchorConstraint = titleView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: innerViewLeadingPadding + titleViewLeadingMargin)
    let titleViewTrailingAnchorConstraint = titleView
      .trailingAnchor
      .constraint(
        lessThanOrEqualTo: innerView.trailingAnchor,
        constant: -(innerViewTrailingPadding + titleViewTrailingMargin))
    let spacerViewTopAnchorConstraint = spacerView
      .topAnchor
      .constraint(equalTo: titleView.bottomAnchor, constant: titleViewBottomMargin + spacerViewTopMargin)
    let spacerViewLeadingAnchorConstraint = spacerView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor, constant: innerViewLeadingPadding + spacerViewLeadingMargin)
    let spacerViewTrailingAnchorConstraint = spacerView
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor, constant: -(innerViewTrailingPadding + spacerViewTrailingMargin))
    let componentPreviewCollectionViewBottomAnchorConstraint = componentPreviewCollectionView
      .bottomAnchor
      .constraint(
        equalTo: innerView.bottomAnchor,
        constant: -(innerViewBottomPadding + componentPreviewCollectionViewBottomMargin))
    let componentPreviewCollectionViewTopAnchorConstraint = componentPreviewCollectionView
      .topAnchor
      .constraint(
        equalTo: spacerView.bottomAnchor,
        constant: spacerViewBottomMargin + componentPreviewCollectionViewTopMargin)
    let componentPreviewCollectionViewLeadingAnchorConstraint = componentPreviewCollectionView
      .leadingAnchor
      .constraint(
        equalTo: innerView.leadingAnchor,
        constant: innerViewLeadingPadding + componentPreviewCollectionViewLeadingMargin)
    let componentPreviewCollectionViewTrailingAnchorConstraint = componentPreviewCollectionView
      .trailingAnchor
      .constraint(
        equalTo: innerView.trailingAnchor,
        constant: -(innerViewTrailingPadding + componentPreviewCollectionViewTrailingMargin))
    let spacerViewHeightAnchorConstraint = spacerView.heightAnchor.constraint(equalToConstant: 24)

    NSLayoutConstraint.activate([
      innerViewTopAnchorConstraint,
      innerViewBottomAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewCenterXAnchorConstraint,
      innerViewTrailingAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      spacerViewTopAnchorConstraint,
      spacerViewLeadingAnchorConstraint,
      spacerViewTrailingAnchorConstraint,
      componentPreviewCollectionViewBottomAnchorConstraint,
      componentPreviewCollectionViewTopAnchorConstraint,
      componentPreviewCollectionViewLeadingAnchorConstraint,
      componentPreviewCollectionViewTrailingAnchorConstraint,
      spacerViewHeightAnchorConstraint
    ])

    self.innerViewTopAnchorConstraint = innerViewTopAnchorConstraint
    self.innerViewBottomAnchorConstraint = innerViewBottomAnchorConstraint
    self.innerViewLeadingAnchorConstraint = innerViewLeadingAnchorConstraint
    self.innerViewCenterXAnchorConstraint = innerViewCenterXAnchorConstraint
    self.innerViewTrailingAnchorConstraint = innerViewTrailingAnchorConstraint
    self.titleViewTopAnchorConstraint = titleViewTopAnchorConstraint
    self.titleViewLeadingAnchorConstraint = titleViewLeadingAnchorConstraint
    self.titleViewTrailingAnchorConstraint = titleViewTrailingAnchorConstraint
    self.spacerViewTopAnchorConstraint = spacerViewTopAnchorConstraint
    self.spacerViewLeadingAnchorConstraint = spacerViewLeadingAnchorConstraint
    self.spacerViewTrailingAnchorConstraint = spacerViewTrailingAnchorConstraint
    self.componentPreviewCollectionViewBottomAnchorConstraint = componentPreviewCollectionViewBottomAnchorConstraint
    self.componentPreviewCollectionViewTopAnchorConstraint = componentPreviewCollectionViewTopAnchorConstraint
    self.componentPreviewCollectionViewLeadingAnchorConstraint = componentPreviewCollectionViewLeadingAnchorConstraint
    self.componentPreviewCollectionViewTrailingAnchorConstraint = componentPreviewCollectionViewTrailingAnchorConstraint
    self.spacerViewHeightAnchorConstraint = spacerViewHeightAnchorConstraint

    // For debugging
    innerViewTopAnchorConstraint.identifier = "innerViewTopAnchorConstraint"
    innerViewBottomAnchorConstraint.identifier = "innerViewBottomAnchorConstraint"
    innerViewLeadingAnchorConstraint.identifier = "innerViewLeadingAnchorConstraint"
    innerViewCenterXAnchorConstraint.identifier = "innerViewCenterXAnchorConstraint"
    innerViewTrailingAnchorConstraint.identifier = "innerViewTrailingAnchorConstraint"
    titleViewTopAnchorConstraint.identifier = "titleViewTopAnchorConstraint"
    titleViewLeadingAnchorConstraint.identifier = "titleViewLeadingAnchorConstraint"
    titleViewTrailingAnchorConstraint.identifier = "titleViewTrailingAnchorConstraint"
    spacerViewTopAnchorConstraint.identifier = "spacerViewTopAnchorConstraint"
    spacerViewLeadingAnchorConstraint.identifier = "spacerViewLeadingAnchorConstraint"
    spacerViewTrailingAnchorConstraint.identifier = "spacerViewTrailingAnchorConstraint"
    componentPreviewCollectionViewBottomAnchorConstraint.identifier =
      "componentPreviewCollectionViewBottomAnchorConstraint"
    componentPreviewCollectionViewTopAnchorConstraint.identifier = "componentPreviewCollectionViewTopAnchorConstraint"
    componentPreviewCollectionViewLeadingAnchorConstraint.identifier =
      "componentPreviewCollectionViewLeadingAnchorConstraint"
    componentPreviewCollectionViewTrailingAnchorConstraint.identifier =
      "componentPreviewCollectionViewTrailingAnchorConstraint"
    spacerViewHeightAnchorConstraint.identifier = "spacerViewHeightAnchorConstraint"
  }

  private func update() {}
}
