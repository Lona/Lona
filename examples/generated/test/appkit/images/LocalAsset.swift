import AppKit
import Foundation

// MARK: - ImageWithBackgroundColor

private class ImageWithBackgroundColor: NSImageView {
  var fillColor = NSColor.clear

  override func draw(_ dirtyRect: NSRect) {
    fillColor.set()
    bounds.fill()
    super.draw(dirtyRect)
  }
}


// MARK: - LocalAsset

public class LocalAsset: NSBox {

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

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero

    addSubview(imageView)

    imageView.image = #imageLiteral(resourceName: "icon_128x128")
    imageView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false

    let imageViewWidthAnchorParentConstraint = imageView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor)
    let imageViewTopAnchorConstraint = imageView.topAnchor.constraint(equalTo: topAnchor)
    let imageViewBottomAnchorConstraint = imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let imageViewLeadingAnchorConstraint = imageView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 100)
    let imageViewWidthAnchorConstraint = imageView.widthAnchor.constraint(equalToConstant: 100)

    imageViewWidthAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      imageViewWidthAnchorParentConstraint,
      imageViewTopAnchorConstraint,
      imageViewBottomAnchorConstraint,
      imageViewLeadingAnchorConstraint,
      imageViewHeightAnchorConstraint,
      imageViewWidthAnchorConstraint
    ])
  }

  private func update() {}
}
