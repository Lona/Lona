import AppKit
import Foundation

// MARK: - ImageWithBackgroundColor

private class ImageWithBackgroundColor: LNAImageView {
  var fillColor = NSColor.clear

  override func draw(_ dirtyRect: NSRect) {
    fillColor.set()
    bounds.fill()
    super.draw(dirtyRect)
  }
}


// MARK: - FillWidthFitHeightCard

public class FillWidthFitHeightCard: NSBox {

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

  private var imageView = ImageWithBackgroundColor()
  private var text1View = LNATextField(labelWithString: "")
  private var textView = LNATextField(labelWithString: "")

  private var text1ViewTextStyle = TextStyles.body2
  private var textViewTextStyle = TextStyles.body1

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    text1View.lineBreakMode = .byWordWrapping
    textView.lineBreakMode = .byWordWrapping

    addSubview(imageView)
    addSubview(text1View)
    addSubview(textView)

    imageView.image = #imageLiteral(resourceName: "icon_128x128")
    imageView.fillColor = Colors.blue200
    text1View.attributedStringValue = text1ViewTextStyle.apply(to: "Title")
    text1ViewTextStyle = TextStyles.body2
    text1View.attributedStringValue = text1ViewTextStyle.apply(to: text1View.attributedStringValue)
    textView.attributedStringValue = textViewTextStyle.apply(to: "Subtitle")
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
