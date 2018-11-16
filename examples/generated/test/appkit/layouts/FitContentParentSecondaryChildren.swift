import AppKit
import Foundation

// MARK: - FitContentParentSecondaryChildren

public class FitContentParentSecondaryChildren: NSBox {

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
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var parameters: Parameters { didSet { update() } }

  // MARK: Private

  private var view1View = NSBox()
  private var view3View = NSBox()
  private var view2View = NSBox()

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero
    view3View.boxType = .custom
    view3View.borderType = .noBorder
    view3View.contentViewMargins = .zero
    view2View.boxType = .custom
    view2View.borderType = .noBorder
    view2View.contentViewMargins = .zero

    addSubview(view1View)
    addSubview(view3View)
    addSubview(view2View)

    fillColor = Colors.bluegrey50
    view1View.fillColor = Colors.blue500
    view3View.fillColor = Colors.lightblue500
    view2View.fillColor = Colors.cyan500
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    view3View.translatesAutoresizingMaskIntoConstraints = false
    view2View.translatesAutoresizingMaskIntoConstraints = false

    let view1ViewHeightAnchorParentConstraint = view1View
      .heightAnchor
      .constraint(lessThanOrEqualTo: heightAnchor, constant: -48)
    let view3ViewHeightAnchorParentConstraint = view3View
      .heightAnchor
      .constraint(lessThanOrEqualTo: heightAnchor, constant: -48)
    let view2ViewHeightAnchorParentConstraint = view2View
      .heightAnchor
      .constraint(lessThanOrEqualTo: heightAnchor, constant: -48)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)
    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: topAnchor, constant: 24)
    let view3ViewLeadingAnchorConstraint = view3View.leadingAnchor.constraint(equalTo: view1View.trailingAnchor)
    let view3ViewTopAnchorConstraint = view3View.topAnchor.constraint(equalTo: topAnchor, constant: 24)
    let view2ViewLeadingAnchorConstraint = view2View.leadingAnchor.constraint(equalTo: view3View.trailingAnchor)
    let view2ViewTopAnchorConstraint = view2View.topAnchor.constraint(equalTo: topAnchor, constant: 24)
    let view1ViewHeightAnchorConstraint = view1View.heightAnchor.constraint(equalToConstant: 60)
    let view1ViewWidthAnchorConstraint = view1View.widthAnchor.constraint(equalToConstant: 60)
    let view3ViewHeightAnchorConstraint = view3View.heightAnchor.constraint(equalToConstant: 120)
    let view3ViewWidthAnchorConstraint = view3View.widthAnchor.constraint(equalToConstant: 100)
    let view2ViewHeightAnchorConstraint = view2View.heightAnchor.constraint(equalToConstant: 180)
    let view2ViewWidthAnchorConstraint = view2View.widthAnchor.constraint(equalToConstant: 100)

    view1ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    view3ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow
    view2ViewHeightAnchorParentConstraint.priority = NSLayoutConstraint.Priority.defaultLow

    NSLayoutConstraint.activate([
      view1ViewHeightAnchorParentConstraint,
      view3ViewHeightAnchorParentConstraint,
      view2ViewHeightAnchorParentConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewTopAnchorConstraint,
      view3ViewLeadingAnchorConstraint,
      view3ViewTopAnchorConstraint,
      view2ViewLeadingAnchorConstraint,
      view2ViewTopAnchorConstraint,
      view1ViewHeightAnchorConstraint,
      view1ViewWidthAnchorConstraint,
      view3ViewHeightAnchorConstraint,
      view3ViewWidthAnchorConstraint,
      view2ViewHeightAnchorConstraint,
      view2ViewWidthAnchorConstraint
    ])
  }

  private func update() {}
}

// MARK: - Parameters

extension FitContentParentSecondaryChildren {
  public struct Parameters: Equatable {
    public init() {}
  }
}

// MARK: - Model

extension FitContentParentSecondaryChildren {
  public struct Model: LonaViewModel, Equatable {
    public var parameters: Parameters
    public var type: String {
      return "FitContentParentSecondaryChildren"
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init() {
      self.init(Parameters())
    }
  }
}
