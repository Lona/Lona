import AppKit
import Foundation

// MARK: - ComponentBrowser

public class ComponentBrowser: NSBox {

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

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private var innerView = NSBox()
  private var titleView = LNATextField(labelWithString: "")
  private var spacerView = NSBox()
  private var componentPreviewCollectionView = ComponentPreviewCollection()

  private var titleViewTextStyle = TextStyles.title

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    innerView.boxType = .custom
    innerView.borderType = .noBorder
    innerView.contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    spacerView.boxType = .custom
    spacerView.borderType = .noBorder
    spacerView.contentViewMargins = .zero

    addSubview(innerView)
    innerView.addSubview(titleView)
    innerView.addSubview(spacerView)
    innerView.addSubview(componentPreviewCollectionView)

    titleView.attributedStringValue = titleViewTextStyle.apply(to: "Components")
    titleViewTextStyle = TextStyles.title
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    innerView.translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    spacerView.translatesAutoresizingMaskIntoConstraints = false
    componentPreviewCollectionView.translatesAutoresizingMaskIntoConstraints = false

    let innerViewTopAnchorConstraint = innerView.topAnchor.constraint(equalTo: topAnchor, constant: 48)
    let innerViewBottomAnchorConstraint = innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -48)
    let innerViewLeadingAnchorConstraint = innerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 64)
    let innerViewCenterXAnchorConstraint = innerView.centerXAnchor.constraint(equalTo: centerXAnchor)
    let innerViewTrailingAnchorConstraint = innerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -64)
    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: innerView.topAnchor)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: innerView.leadingAnchor)
    let titleViewTrailingAnchorConstraint = titleView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: innerView.trailingAnchor)
    let spacerViewTopAnchorConstraint = spacerView.topAnchor.constraint(equalTo: titleView.bottomAnchor)
    let spacerViewLeadingAnchorConstraint = spacerView.leadingAnchor.constraint(equalTo: innerView.leadingAnchor)
    let spacerViewTrailingAnchorConstraint = spacerView.trailingAnchor.constraint(equalTo: innerView.trailingAnchor)
    let componentPreviewCollectionViewBottomAnchorConstraint = componentPreviewCollectionView
      .bottomAnchor
      .constraint(equalTo: innerView.bottomAnchor)
    let componentPreviewCollectionViewTopAnchorConstraint = componentPreviewCollectionView
      .topAnchor
      .constraint(equalTo: spacerView.bottomAnchor)
    let componentPreviewCollectionViewLeadingAnchorConstraint = componentPreviewCollectionView
      .leadingAnchor
      .constraint(equalTo: innerView.leadingAnchor)
    let componentPreviewCollectionViewTrailingAnchorConstraint = componentPreviewCollectionView
      .trailingAnchor
      .constraint(equalTo: innerView.trailingAnchor)
    let spacerViewHeightAnchorConstraint = spacerView.heightAnchor.constraint(equalToConstant: 24)

    NSLayoutConstraint.activate([
      innerViewTopAnchorConstraint,
      innerViewBottomAnchorConstraint,
      innerViewLeadingAnchorConstraint,
      innerViewCenterXAnchorConstraint,
      innerViewTrailingAnchorConstraint,
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      spacerViewTopAnchorConstraint,
      spacerViewLeadingAnchorConstraint,
      spacerViewTrailingAnchorConstraint,
      componentPreviewCollectionViewBottomAnchorConstraint,
      componentPreviewCollectionViewTopAnchorConstraint,
      componentPreviewCollectionViewLeadingAnchorConstraint,
      componentPreviewCollectionViewTrailingAnchorConstraint,
      spacerViewHeightAnchorConstraint
    ])
  }

  private func update() {}
}

// MARK: - Parameters

extension ComponentBrowser {
  public struct Parameters: Equatable {
    public init() {}
  }
}

// MARK: - Model

extension ComponentBrowser {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "ComponentBrowser"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init() {
      self.init(Parameters())
    }
  }
}
