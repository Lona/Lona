import AppKit
import Foundation

// MARK: - RepositoryList

public class RepositoryList: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(repositoryIds: [String]) {
    self.init(Parameters(repositoryIds: repositoryIds))
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

  public var repositoryIds: [String] {
    get { return parameters.repositoryIds }
    set {
      if parameters.repositoryIds != newValue {
        parameters.repositoryIds = newValue
      }
    }
  }

  public var onSelectRepositoryId: ((String) -> Void)? {
    get { return parameters.onSelectRepositoryId }
    set { parameters.onSelectRepositoryId = newValue }
  }

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private var primaryButtonView = PrimaryButton()
  private var view1View = NSBox()
  private var primaryButton1View = PrimaryButton()

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    view1View.boxType = .custom
    view1View.borderType = .noBorder
    view1View.contentViewMargins = .zero

    addSubview(primaryButtonView)
    addSubview(view1View)
    addSubview(primaryButton1View)

    primaryButtonView.titleText = "Organization 1"
    primaryButton1View.titleText = "Organization 2"
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    primaryButtonView.translatesAutoresizingMaskIntoConstraints = false
    view1View.translatesAutoresizingMaskIntoConstraints = false
    primaryButton1View.translatesAutoresizingMaskIntoConstraints = false

    let primaryButtonViewTopAnchorConstraint = primaryButtonView.topAnchor.constraint(equalTo: topAnchor)
    let primaryButtonViewLeadingAnchorConstraint = primaryButtonView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let primaryButtonViewTrailingAnchorConstraint = primaryButtonView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let view1ViewTopAnchorConstraint = view1View.topAnchor.constraint(equalTo: primaryButtonView.bottomAnchor)
    let view1ViewLeadingAnchorConstraint = view1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let view1ViewTrailingAnchorConstraint = view1View.trailingAnchor.constraint(equalTo: trailingAnchor)
    let primaryButton1ViewBottomAnchorConstraint = primaryButton1View.bottomAnchor.constraint(equalTo: bottomAnchor)
    let primaryButton1ViewTopAnchorConstraint = primaryButton1View.topAnchor.constraint(equalTo: view1View.bottomAnchor)
    let primaryButton1ViewLeadingAnchorConstraint = primaryButton1View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let primaryButton1ViewTrailingAnchorConstraint = primaryButton1View
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let view1ViewHeightAnchorConstraint = view1View.heightAnchor.constraint(equalToConstant: 8)

    NSLayoutConstraint.activate([
      primaryButtonViewTopAnchorConstraint,
      primaryButtonViewLeadingAnchorConstraint,
      primaryButtonViewTrailingAnchorConstraint,
      view1ViewTopAnchorConstraint,
      view1ViewLeadingAnchorConstraint,
      view1ViewTrailingAnchorConstraint,
      primaryButton1ViewBottomAnchorConstraint,
      primaryButton1ViewTopAnchorConstraint,
      primaryButton1ViewLeadingAnchorConstraint,
      primaryButton1ViewTrailingAnchorConstraint,
      view1ViewHeightAnchorConstraint
    ])
  }

  private func update() {}

  private func handleOnSelectRepositoryId(_ arg0: String) {
    onSelectRepositoryId?(arg0)
  }
}

// MARK: - Parameters

extension RepositoryList {
  public struct Parameters: Equatable {
    public var repositoryIds: [String]
    public var onSelectRepositoryId: ((String) -> Void)?

    public init(repositoryIds: [String], onSelectRepositoryId: ((String) -> Void)? = nil) {
      self.repositoryIds = repositoryIds
      self.onSelectRepositoryId = onSelectRepositoryId
    }

    public init() {
      self.init(repositoryIds: [])
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.repositoryIds == rhs.repositoryIds
    }
  }
}

// MARK: - Model

extension RepositoryList {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "RepositoryList"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(repositoryIds: [String], onSelectRepositoryId: ((String) -> Void)? = nil) {
      self.init(Parameters(repositoryIds: repositoryIds, onSelectRepositoryId: onSelectRepositoryId))
    }

    public init() {
      self.init(repositoryIds: [])
    }
  }
}
