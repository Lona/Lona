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

    textView.attributedStringValue = textViewTextStyle.apply(to: "Example nested component")
    textViewTextStyle = TextStyles.subheading2
    textView.attributedStringValue = textViewTextStyle.apply(to: textView.attributedStringValue)
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

    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: topAnchor, constant: 10)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
    let textViewTrailingAnchorConstraint = textView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -10)
    let fitContentParentSecondaryChildrenViewTopAnchorConstraint = fitContentParentSecondaryChildrenView
      .topAnchor
      .constraint(equalTo: textView.bottomAnchor, constant: 8)
    let fitContentParentSecondaryChildrenViewLeadingAnchorConstraint = fitContentParentSecondaryChildrenView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: 10)
    let fitContentParentSecondaryChildrenViewTrailingAnchorConstraint = fitContentParentSecondaryChildrenView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -10)
    let text1ViewTopAnchorConstraint = text1View
      .topAnchor
      .constraint(equalTo: fitContentParentSecondaryChildrenView.bottomAnchor)
    let text1ViewLeadingAnchorConstraint = text1View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
    let text1ViewTrailingAnchorConstraint = text1View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -10)
    let localAssetViewTopAnchorConstraint = localAssetView
      .topAnchor
      .constraint(equalTo: text1View.bottomAnchor, constant: 12)
    let localAssetViewLeadingAnchorConstraint = localAssetView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: 10)
    let localAssetViewTrailingAnchorConstraint = localAssetView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -10)
    let text2ViewBottomAnchorConstraint = text2View.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
    let text2ViewTopAnchorConstraint = text2View.topAnchor.constraint(equalTo: localAssetView.bottomAnchor)
    let text2ViewLeadingAnchorConstraint = text2View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
    let text2ViewTrailingAnchorConstraint = text2View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -10)

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
  }

  private func update() {}
}
