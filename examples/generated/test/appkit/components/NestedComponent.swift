import AppKit
import Foundation

// MARK: - NestedComponent

public class NestedComponent: NSBox {

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

  private var textView = NSTextField(labelWithString: "")
  private var fitContentParentSecondaryChildrenView = FitContentParentSecondaryChildren()
  private var text1View = NSTextField(labelWithString: "")
  private var localAssetView = LocalAsset()
  private var text2View = NSTextField(labelWithString: "")

  private var textViewTextStyle = TextStyles.subheading2
  private var text1ViewTextStyle = TextStyles.body1
  private var text2ViewTextStyle = TextStyles.body1

  private var topPadding: CGFloat = 10
  private var trailingPadding: CGFloat = 10
  private var bottomPadding: CGFloat = 10
  private var leadingPadding: CGFloat = 10
  private var textViewTopMargin: CGFloat = 0
  private var textViewTrailingMargin: CGFloat = 0
  private var textViewBottomMargin: CGFloat = 8
  private var textViewLeadingMargin: CGFloat = 0
  private var fitContentParentSecondaryChildrenViewTopMargin: CGFloat = 0
  private var fitContentParentSecondaryChildrenViewTrailingMargin: CGFloat = 0
  private var fitContentParentSecondaryChildrenViewBottomMargin: CGFloat = 0
  private var fitContentParentSecondaryChildrenViewLeadingMargin: CGFloat = 0
  private var text1ViewTopMargin: CGFloat = 12
  private var text1ViewTrailingMargin: CGFloat = 0
  private var text1ViewBottomMargin: CGFloat = 0
  private var text1ViewLeadingMargin: CGFloat = 0
  private var localAssetViewTopMargin: CGFloat = 0
  private var localAssetViewTrailingMargin: CGFloat = 0
  private var localAssetViewBottomMargin: CGFloat = 0
  private var localAssetViewLeadingMargin: CGFloat = 0
  private var text2ViewTopMargin: CGFloat = 0
  private var text2ViewTrailingMargin: CGFloat = 0
  private var text2ViewBottomMargin: CGFloat = 0
  private var text2ViewLeadingMargin: CGFloat = 0

  private var textViewTopAnchorConstraint: NSLayoutConstraint?
  private var textViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var fitContentParentSecondaryChildrenViewTopAnchorConstraint: NSLayoutConstraint?
  private var fitContentParentSecondaryChildrenViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var fitContentParentSecondaryChildrenViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text1ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text1ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text1ViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var localAssetViewTopAnchorConstraint: NSLayoutConstraint?
  private var localAssetViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var localAssetViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var text2ViewBottomAnchorConstraint: NSLayoutConstraint?
  private var text2ViewTopAnchorConstraint: NSLayoutConstraint?
  private var text2ViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var text2ViewTrailingAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    textView.lineBreakMode = .byWordWrapping
    text1View.lineBreakMode = .byWordWrapping
    text2View.lineBreakMode = .byWordWrapping

    addSubview(textView)
    addSubview(fitContentParentSecondaryChildrenView)
    addSubview(text1View)
    addSubview(localAssetView)
    addSubview(text2View)

    textViewTextStyle = TextStyles.subheading2
    textView.attributedStringValue = textViewTextStyle.apply(to: "Example nested component")
    text1View.attributedStringValue = text1ViewTextStyle.apply(to: "Text below")
    text2View.attributedStringValue = text2ViewTextStyle.apply(to: "Very bottom")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    fitContentParentSecondaryChildrenView.translatesAutoresizingMaskIntoConstraints = false
    text1View.translatesAutoresizingMaskIntoConstraints = false
    localAssetView.translatesAutoresizingMaskIntoConstraints = false
    text2View.translatesAutoresizingMaskIntoConstraints = false

    let textViewTopAnchorConstraint = textView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + textViewTopMargin)
    let textViewLeadingAnchorConstraint = textView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + textViewLeadingMargin)
    let textViewTrailingAnchorConstraint = textView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + textViewTrailingMargin))
    let fitContentParentSecondaryChildrenViewTopAnchorConstraint = fitContentParentSecondaryChildrenView
      .topAnchor
      .constraint(
        equalTo: textView.bottomAnchor,
        constant: textViewBottomMargin + fitContentParentSecondaryChildrenViewTopMargin)
    let fitContentParentSecondaryChildrenViewLeadingAnchorConstraint = fitContentParentSecondaryChildrenView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + fitContentParentSecondaryChildrenViewLeadingMargin)
    let fitContentParentSecondaryChildrenViewTrailingAnchorConstraint = fitContentParentSecondaryChildrenView
      .trailingAnchor
      .constraint(
        equalTo: trailingAnchor,
        constant: -(trailingPadding + fitContentParentSecondaryChildrenViewTrailingMargin))
    let text1ViewTopAnchorConstraint = text1View
      .topAnchor
      .constraint(
        equalTo: fitContentParentSecondaryChildrenView.bottomAnchor,
        constant: fitContentParentSecondaryChildrenViewBottomMargin + text1ViewTopMargin)
    let text1ViewLeadingAnchorConstraint = text1View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + text1ViewLeadingMargin)
    let text1ViewTrailingAnchorConstraint = text1View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + text1ViewTrailingMargin))
    let localAssetViewTopAnchorConstraint = localAssetView
      .topAnchor
      .constraint(equalTo: text1View.bottomAnchor, constant: text1ViewBottomMargin + localAssetViewTopMargin)
    let localAssetViewLeadingAnchorConstraint = localAssetView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + localAssetViewLeadingMargin)
    let localAssetViewTrailingAnchorConstraint = localAssetView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + localAssetViewTrailingMargin))
    let text2ViewBottomAnchorConstraint = text2View
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + text2ViewBottomMargin))
    let text2ViewTopAnchorConstraint = text2View
      .topAnchor
      .constraint(equalTo: localAssetView.bottomAnchor, constant: localAssetViewBottomMargin + text2ViewTopMargin)
    let text2ViewLeadingAnchorConstraint = text2View
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + text2ViewLeadingMargin)
    let text2ViewTrailingAnchorConstraint = text2View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -(trailingPadding + text2ViewTrailingMargin))

    NSLayoutConstraint.activate([
      textViewTopAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint,
      fitContentParentSecondaryChildrenViewTopAnchorConstraint,
      fitContentParentSecondaryChildrenViewLeadingAnchorConstraint,
      fitContentParentSecondaryChildrenViewTrailingAnchorConstraint,
      text1ViewTopAnchorConstraint,
      text1ViewLeadingAnchorConstraint,
      text1ViewTrailingAnchorConstraint,
      localAssetViewTopAnchorConstraint,
      localAssetViewLeadingAnchorConstraint,
      localAssetViewTrailingAnchorConstraint,
      text2ViewBottomAnchorConstraint,
      text2ViewTopAnchorConstraint,
      text2ViewLeadingAnchorConstraint,
      text2ViewTrailingAnchorConstraint
    ])

    self.textViewTopAnchorConstraint = textViewTopAnchorConstraint
    self.textViewLeadingAnchorConstraint = textViewLeadingAnchorConstraint
    self.textViewTrailingAnchorConstraint = textViewTrailingAnchorConstraint
    self.fitContentParentSecondaryChildrenViewTopAnchorConstraint =
      fitContentParentSecondaryChildrenViewTopAnchorConstraint
    self.fitContentParentSecondaryChildrenViewLeadingAnchorConstraint =
      fitContentParentSecondaryChildrenViewLeadingAnchorConstraint
    self.fitContentParentSecondaryChildrenViewTrailingAnchorConstraint =
      fitContentParentSecondaryChildrenViewTrailingAnchorConstraint
    self.text1ViewTopAnchorConstraint = text1ViewTopAnchorConstraint
    self.text1ViewLeadingAnchorConstraint = text1ViewLeadingAnchorConstraint
    self.text1ViewTrailingAnchorConstraint = text1ViewTrailingAnchorConstraint
    self.localAssetViewTopAnchorConstraint = localAssetViewTopAnchorConstraint
    self.localAssetViewLeadingAnchorConstraint = localAssetViewLeadingAnchorConstraint
    self.localAssetViewTrailingAnchorConstraint = localAssetViewTrailingAnchorConstraint
    self.text2ViewBottomAnchorConstraint = text2ViewBottomAnchorConstraint
    self.text2ViewTopAnchorConstraint = text2ViewTopAnchorConstraint
    self.text2ViewLeadingAnchorConstraint = text2ViewLeadingAnchorConstraint
    self.text2ViewTrailingAnchorConstraint = text2ViewTrailingAnchorConstraint

    // For debugging
    textViewTopAnchorConstraint.identifier = "textViewTopAnchorConstraint"
    textViewLeadingAnchorConstraint.identifier = "textViewLeadingAnchorConstraint"
    textViewTrailingAnchorConstraint.identifier = "textViewTrailingAnchorConstraint"
    fitContentParentSecondaryChildrenViewTopAnchorConstraint.identifier =
      "fitContentParentSecondaryChildrenViewTopAnchorConstraint"
    fitContentParentSecondaryChildrenViewLeadingAnchorConstraint.identifier =
      "fitContentParentSecondaryChildrenViewLeadingAnchorConstraint"
    fitContentParentSecondaryChildrenViewTrailingAnchorConstraint.identifier =
      "fitContentParentSecondaryChildrenViewTrailingAnchorConstraint"
    text1ViewTopAnchorConstraint.identifier = "text1ViewTopAnchorConstraint"
    text1ViewLeadingAnchorConstraint.identifier = "text1ViewLeadingAnchorConstraint"
    text1ViewTrailingAnchorConstraint.identifier = "text1ViewTrailingAnchorConstraint"
    localAssetViewTopAnchorConstraint.identifier = "localAssetViewTopAnchorConstraint"
    localAssetViewLeadingAnchorConstraint.identifier = "localAssetViewLeadingAnchorConstraint"
    localAssetViewTrailingAnchorConstraint.identifier = "localAssetViewTrailingAnchorConstraint"
    text2ViewBottomAnchorConstraint.identifier = "text2ViewBottomAnchorConstraint"
    text2ViewTopAnchorConstraint.identifier = "text2ViewTopAnchorConstraint"
    text2ViewLeadingAnchorConstraint.identifier = "text2ViewLeadingAnchorConstraint"
    text2ViewTrailingAnchorConstraint.identifier = "text2ViewTrailingAnchorConstraint"
  }

  private func update() {}
}
