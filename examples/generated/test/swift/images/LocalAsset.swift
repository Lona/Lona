import UIKit
import Foundation

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

  private var imageView = UIImageView(frame: .zero)

  private func setUpViews() {
    addSubview(imageView)

    imageView.image = #imageLiteral(resourceName: "icon_128x128")
    imageView.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false

    let imageViewTopAnchorConstraint = imageView.topAnchor.constraint(equalTo: topAnchor)
    let imageViewBottomAnchorConstraint = imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let imageViewLeadingAnchorConstraint = imageView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 100)
    let imageViewWidthAnchorConstraint = imageView.widthAnchor.constraint(equalToConstant: 100)

    NSLayoutConstraint.activate([
      imageViewTopAnchorConstraint,
      imageViewBottomAnchorConstraint,
      imageViewLeadingAnchorConstraint,
      imageViewHeightAnchorConstraint,
      imageViewWidthAnchorConstraint
    ])
  }

  private func update() {}
}
