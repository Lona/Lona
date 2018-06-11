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

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var imageViewTopMargin: CGFloat = 0
  private var imageViewTrailingMargin: CGFloat = 0
  private var imageViewBottomMargin: CGFloat = 0
  private var imageViewLeadingMargin: CGFloat = 0

  private var imageViewTopAnchorConstraint: NSLayoutConstraint?
  private var imageViewBottomAnchorConstraint: NSLayoutConstraint?
  private var imageViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var imageViewHeightAnchorConstraint: NSLayoutConstraint?
  private var imageViewWidthAnchorConstraint: NSLayoutConstraint?

  private func setUpViews() {
    addSubview(imageView)

    imageView.image = #imageLiteral(resourceName: "icon_128x128")
    imageView.backgroundColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false

    let imageViewTopAnchorConstraint = imageView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + imageViewTopMargin)
    let imageViewBottomAnchorConstraint = imageView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + imageViewBottomMargin))
    let imageViewLeadingAnchorConstraint = imageView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + imageViewLeadingMargin)
    let imageViewHeightAnchorConstraint = imageView.heightAnchor.constraint(equalToConstant: 100)
    let imageViewWidthAnchorConstraint = imageView.widthAnchor.constraint(equalToConstant: 100)

    NSLayoutConstraint.activate([
      imageViewTopAnchorConstraint,
      imageViewBottomAnchorConstraint,
      imageViewLeadingAnchorConstraint,
      imageViewHeightAnchorConstraint,
      imageViewWidthAnchorConstraint
    ])

    self.imageViewTopAnchorConstraint = imageViewTopAnchorConstraint
    self.imageViewBottomAnchorConstraint = imageViewBottomAnchorConstraint
    self.imageViewLeadingAnchorConstraint = imageViewLeadingAnchorConstraint
    self.imageViewHeightAnchorConstraint = imageViewHeightAnchorConstraint
    self.imageViewWidthAnchorConstraint = imageViewWidthAnchorConstraint

    // For debugging
    imageViewTopAnchorConstraint.identifier = "imageViewTopAnchorConstraint"
    imageViewBottomAnchorConstraint.identifier = "imageViewBottomAnchorConstraint"
    imageViewLeadingAnchorConstraint.identifier = "imageViewLeadingAnchorConstraint"
    imageViewHeightAnchorConstraint.identifier = "imageViewHeightAnchorConstraint"
    imageViewWidthAnchorConstraint.identifier = "imageViewWidthAnchorConstraint"
  }

  private func update() {}
}
