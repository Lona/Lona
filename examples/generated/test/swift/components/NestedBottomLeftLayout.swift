import UIKit
import Foundation

// MARK: - NestedBottomLeftLayout

public class NestedBottomLeftLayout: UIView {

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

// MARK: - Parameters

extension NestedBottomLeftLayout {
  public struct Parameters: Equatable {
    public init() {}
  }
}

// MARK: - Model

extension NestedBottomLeftLayout {
  public struct Model: LonaViewModel, Equatable {
    public var parameters: Parameters
    public var type: String {
      return "NestedBottomLeftLayout"
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init() {
      self.init(Parameters())
    }
  }
}
