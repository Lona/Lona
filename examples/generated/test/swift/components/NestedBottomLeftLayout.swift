import UIKit
import Foundation

// MARK: - NestedBottomLeftLayout

public class NestedBottomLeftLayout: UIView {

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

  private var view1View = UIView(frame: .zero)
  private var localAssetView = LocalAsset()

  private func setUpViews() {
    addSubview(view1View)
    view1View.addSubview(localAssetView)

    view1View.backgroundColor = Colors.red100
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    localAssetView.translatesAutoresizingMaskIntoConstraints = false

    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: topAnchor)
    let view1ViewBottomAnchorConstraint = view1View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewHeightAnchorConstraint = view1View.heightAnchor.constraint(equalToConstant: 150)
    let view1ViewWidthAnchorConstraint = view1View.widthAnchor.constraint(equalToConstant: 150)
    let localAssetViewLeadingAnchorConstraint = localAssetView
      .leadingAnchor
      .constraint(equalTo: view1View.leadingAnchor)
    let localAssetViewTopAnchorConstraint = localAssetView.topAnchor.constraint(equalTo: view1View.topAnchor)
    let localAssetViewBottomAnchorConstraint = localAssetView.bottomAnchor.constraint(equalTo: view1View.bottomAnchor)

    NSLayoutConstraint.activate([
      view1ViewTopAnchorConstraint,
      view1ViewBottomAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewHeightAnchorConstraint,
      view1ViewWidthAnchorConstraint,
      localAssetViewLeadingAnchorConstraint,
      localAssetViewTopAnchorConstraint,
      localAssetViewBottomAnchorConstraint
    ])
  }

  private func update() {}
}
