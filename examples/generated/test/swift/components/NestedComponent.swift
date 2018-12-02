import UIKit
import Foundation

// MARK: - NestedComponent

public class NestedComponent: UIView {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
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

  public var parameters: Parameters { didSet { update() } }

  // MARK: Private

  private var textView = UILabel()
  private var fitContentParentSecondaryChildrenView = FitContentParentSecondaryChildren()
  private var text1View = UILabel()
  private var localAssetView = LocalAsset()
  private var text2View = UILabel()

  private var textViewTextStyle = TextStyles.subheading2
  private var text1ViewTextStyle = TextStyles.body1
  private var text2ViewTextStyle = TextStyles.body1

  private func setUpViews() {
    textView.isUserInteractionEnabled = false
    textView.numberOfLines = 0
    text1View.isUserInteractionEnabled = false
    text1View.numberOfLines = 0
    text2View.isUserInteractionEnabled = false
    text2View.numberOfLines = 0

    addSubview(textView)
    addSubview(fitContentParentSecondaryChildrenView)
    addSubview(text1View)
    addSubview(localAssetView)
    addSubview(text2View)

    textView.attributedText = textViewTextStyle.apply(to: "Example nested component")
    textViewTextStyle = TextStyles.subheading2
    textView.attributedText = textViewTextStyle.apply(to: textView.attributedText ?? NSAttributedString())
    text1View.attributedText = text1ViewTextStyle.apply(to: "Text below")
    text2View.attributedText = text2ViewTextStyle.apply(to: "Very bottom")
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
      .constraint(equalTo: fitContentParentSecondaryChildrenView.bottomAnchor, constant: 12)
    let text1ViewLeadingAnchorConstraint = text1View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
    let text1ViewTrailingAnchorConstraint = text1View
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -10)
    let localAssetViewTopAnchorConstraint = localAssetView.topAnchor.constraint(equalTo: text1View.bottomAnchor)
    let localAssetViewLeadingAnchorConstraint = localAssetView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: 10)
    let localAssetViewTrailingAnchorConstraint = localAssetView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: trailingAnchor, constant: -10)
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

// MARK: - Parameters

extension NestedComponent {
  public struct Parameters: Equatable {
    public init() {}
  }
}

// MARK: - Model

extension NestedComponent {
  public struct Model: LonaViewModel, Equatable {
    public var parameters: Parameters
    public var type: String {
      return "NestedComponent"
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init() {
      self.init(Parameters())
    }
  }
}
