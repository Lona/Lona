import UIKit
import Foundation

// MARK: - BackgroundImageView

private class BackgroundImageView: UIImageView {
  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIViewNoIntrinsicMetric, height: UIViewNoIntrinsicMetric)
  }
}

// MARK: - LocalAsset

public class LocalAsset: UIView {

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

  private var imageView = BackgroundImageView(frame: .zero)

  private func setUpViews() {
    imageView.contentMode = .scaleAspectFill
    imageView.layer.masksToBounds = true

    addSubview(imageView)

    backgroundColor = Colors.red400
    imageView.image = #imageLiteral(resourceName: "icon_128x128")
    imageView.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
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

    imageViewWidthAnchorParentConstraint.priority = UILayoutPriority.defaultLow

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
