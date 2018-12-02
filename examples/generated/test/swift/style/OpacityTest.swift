import UIKit
import Foundation

// MARK: - BackgroundImageView

private class BackgroundImageView: UIImageView {
  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)
  }
}

// MARK: - OpacityTest

public class OpacityTest: UIView {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(selected: Bool) {
    self.init(Parameters(selected: selected))
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

  public var selected: Bool {
    get { return parameters.selected }
    set { parameters.selected = newValue }
  }

  public var parameters: Parameters { didSet { update() } }

  // MARK: Private

  private var view1View = UIView(frame: .zero)
  private var textView = UILabel()
  private var imageView = BackgroundImageView(frame: .zero)

  private var textViewTextStyle = TextStyles.body1

  private func setUpViews() {
    textView.isUserInteractionEnabled = false
    textView.numberOfLines = 0
    imageView.isUserInteractionEnabled = false
    imageView.contentMode = .scaleAspectFill
    imageView.layer.masksToBounds = true

    addSubview(view1View)
    view1View.addSubview(textView)
    view1View.addSubview(imageView)

    backgroundColor = Colors.blue500
    layer.borderWidth = 10
    layer.borderColor = Colors.pink300.cgColor
    view1View.backgroundColor = Colors.red900
    view1View.alpha = 0.8
    textView.attributedText = textViewTextStyle.apply(to: "Text goes here")
    textView.alpha = 0.8
    imageView.image = #imageLiteral(resourceName: "icon_128x128")
    imageView.alpha = 0.5
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false

    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: topAnchor, constant: 10)
    let view1ViewBottomAnchorConstraint = view1View.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
    let view1ViewHeightAnchorConstraint = view1View.heightAnchor.constraint(equalToConstant: 100)
    let view1ViewWidthAnchorConstraint = view1View.widthAnchor.constraint(equalToConstant: 100)
    let textViewTopAnchorConstraint = textView.topAnchor.constraint(equalTo: view1View.topAnchor)
    let textViewLeadingAnchorConstraint = textView.leadingAnchor.constraint(equalTo: view1View.leadingAnchor)
    let textViewTrailingAnchorConstraint = textView.trailingAnchor.constraint(equalTo: view1View.trailingAnchor)
    let imageViewTopAnchorConstraint = imageView.topAnchor.constraint(equalTo: textView.bottomAnchor)
    let imageViewLeadingAnchorConstraint = imageView.leadingAnchor.constraint(equalTo: view1View.leadingAnchor)
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 60)
    let imageViewWidthAnchorConstraint = imageView.widthAnchor.constraint(equalToConstant: 90)

    NSLayoutConstraint.activate([
      view1ViewTopAnchorConstraint,
      view1ViewBottomAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewHeightAnchorConstraint,
      view1ViewWidthAnchorConstraint,
      textViewTopAnchorConstraint,
      textViewLeadingAnchorConstraint,
      textViewTrailingAnchorConstraint,
      imageViewTopAnchorConstraint,
      imageViewLeadingAnchorConstraint,
      imageViewHeightAnchorConstraint,
      imageViewWidthAnchorConstraint
    ])
  }

  private func update() {
    alpha = 1
    if selected {
      alpha = 0.7
    }
  }
}

// MARK: - Parameters

extension OpacityTest {
  public struct Parameters: Equatable {
    public var selected: Bool

    public init(selected: Bool) {
      self.selected = selected
    }

    public init() {
      self.init(selected: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.selected == rhs.selected
    }
  }
}

// MARK: - Model

extension OpacityTest {
  public struct Model: LonaViewModel, Equatable {
    public var parameters: Parameters
    public var type: String {
      return "OpacityTest"
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(selected: Bool) {
      self.init(Parameters(selected: selected))
    }

    public init() {
      self.init(selected: false)
    }
  }
}
