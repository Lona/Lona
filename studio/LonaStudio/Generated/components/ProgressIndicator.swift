import AppKit
import Foundation

// MARK: - ProgressIndicator

public class ProgressIndicator: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(percent: CGFloat) {
    self.init(Parameters(percent: percent))
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

  public var percent: CGFloat {
    get { return parameters.percent }
    set {
      if parameters.percent != newValue {
        parameters.percent = newValue
      }
    }
  }

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private var view1View = NSBox()

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .lineBorder
    view1View.contentViewMargins = .zero

    addSubview(view1View)

    view1View.borderColor = Colors.systemSelection
    view1View.cornerRadius = 20
    view1View.borderWidth = 1
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false

    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: topAnchor)
    let view1ViewBottomAnchorConstraint = view1View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewHeightAnchorConstraint = view1View.heightAnchor.constraint(equalToConstant: 40)
    let view1ViewWidthAnchorConstraint = view1View.widthAnchor.constraint(equalToConstant: 40)

    NSLayoutConstraint.activate([
      view1ViewTopAnchorConstraint,
      view1ViewBottomAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewHeightAnchorConstraint,
      view1ViewWidthAnchorConstraint
    ])
  }

  private func update() {}
}

// MARK: - Parameters

extension ProgressIndicator {
  public struct Parameters: Equatable {
    public var percent: CGFloat

    public init(percent: CGFloat) {
      self.percent = percent
    }

    public init() {
      self.init(percent: 0)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.percent == rhs.percent
    }
  }
}

// MARK: - Model

extension ProgressIndicator {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "ProgressIndicator"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(percent: CGFloat) {
      self.init(Parameters(percent: percent))
    }

    public init() {
      self.init(percent: 0)
    }
  }
}
