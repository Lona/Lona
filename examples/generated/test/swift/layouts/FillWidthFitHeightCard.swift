import UIKit
import Foundation

// MARK: - BackgroundImageView

private class BackgroundImageView: UIImageView {
  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)
  }
}

// MARK: - FillWidthFitHeightCard

public class FillWidthFitHeightCard: UIView {

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
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var parameters: Parameters { didSet { update() } }

  // MARK: Private

  private var imageView = BackgroundImageView(frame: .zero)
  private var text1View = UILabel()
  private var textView = UILabel()

  private var text1ViewTextStyle = TextStyles.body2
  private var textViewTextStyle = TextStyles.body1

  private func setUpViews() {
    imageView.contentMode = .scaleAspectFill
    imageView.layer.masksToBounds = true
    text1View.numberOfLines = 0
    textView.numberOfLines = 0

    addSubview(imageView)
    addSubview(text1View)
    addSubview(textView)

    imageView.image = #imageLiteral(resourceName: "icon_128x128")
    imageView.backgroundColor = Colors.blue200
    text1View.attributedText = text1ViewTextStyle.apply(to: "Title")
    text1ViewTextStyle = TextStyles.body2
    text1View.attributedText = text1ViewTextStyle.apply(to: text1View.attributedText ?? NSAttributedString())
    textView.attributedText = textViewTextStyle.apply(to: "Subtitle")
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    text1View.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false

    let imageViewTopAnchorConstraint = imageView.topAnchor.constraint(equalTo: topAnchor)
    let imageViewLeadingAnchorConstraint = imageView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let imageViewTrailingAnchorConstraint = imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let text1ViewTopAnchorConstraint = text1View.topAnchor.constraint(equalTo: imageView.bottomAnchor)
    let text1ViewLeadingAnchorConstraint = text1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let text1ViewTrailingAnchorConstraint = text1View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let textViewBottomAnchorConstraint = textView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: text1View.bottomAnchor)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let textViewTrailingAnchorConstraint = textView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 100)

    NSLayoutConstraint.activate([
      imageViewTopAnchorConstraint,
      imageViewLeadingAnchorConstraint,
      imageViewTrailingAnchorConstraint,
      text1ViewTopAnchorConstraint,
      text1ViewLeadingAnchorConstraint,
      text1ViewTrailingAnchorConstraint,
      textViewBottomAnchorConstraint,
      textViewTopAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint,
      imageViewHeightAnchorConstraint
    ])
  }

  private func update() {}
}

// MARK: - Parameters

extension FillWidthFitHeightCard {
  public struct Parameters: Equatable {
    public init() {}
  }
}

// MARK: - Model

extension FillWidthFitHeightCard {
  public struct Model: LonaViewModel, Equatable {
    public var parameters: Parameters
    public var type: String {
      return "FillWidthFitHeightCard"
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init() {
      self.init(Parameters())
    }
  }
}
