import AppKit
import Foundation

// MARK: - OpacityTest

public class OpacityTest: NSBox {

  // MARK: Lifecycle

  public init(selected: Bool) {
    self.selected = selected

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(selected: false)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var selected: Bool { didSet { update() } }

  // MARK: Private

  private var view1View = NSBox()
  private var textView = LNATextField(labelWithString: "")
  private var imageView = LNAImageView()

  private var textViewTextStyle = TextStyles.body1

  private func setUpViews() {
    boxType = .custom
    borderType = .lineBorder
    contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    textView.lineBreakMode = .byWordWrapping

    addSubview(view1View)
    view1View.addSubview(textView)
    view1View.addSubview(imageView)

    fillColor = Colors.blue500
    borderWidth = 10
    borderColor = Colors.pink300
    view1View.fillColor = Colors.red900
    view1View.alphaValue = 0.8
    textView.attributedStringValue = textViewTextStyle.apply(to: "Text goes here")
    textView.alphaValue = 0.8
    imageView.image = #imageLiteral(resourceName: "icon_128x128")
    imageView.alphaValue = 0.5
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
    alphaValue = 1
    if selected {
      alphaValue = 0.7
    }
  }
}
