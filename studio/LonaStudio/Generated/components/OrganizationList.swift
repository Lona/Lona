import AppKit
import Foundation

// MARK: - OrganizationList

public class OrganizationList: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(organizationIds: [String]) {
    self.init(Parameters(organizationIds: organizationIds))
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

  public var organizationIds: [String] {
    get { return parameters.organizationIds }
    set {
      if parameters.organizationIds != newValue {
        parameters.organizationIds = newValue
      }
    }
  }

  public var onSelectOrganizationId: ((String) -> Void)? {
    get { return parameters.onSelectOrganizationId }
    set { parameters.onSelectOrganizationId = newValue }
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

  private func handleOnSelectOrganizationId(_ arg0: String) {
    onSelectOrganizationId?(arg0)
  }
}

// MARK: - Parameters

extension OrganizationList {
  public struct Parameters: Equatable {
    public var organizationIds: [String]
    public var onSelectOrganizationId: ((String) -> Void)?

    public init(organizationIds: [String], onSelectOrganizationId: ((String) -> Void)? = nil) {
      self.organizationIds = organizationIds
      self.onSelectOrganizationId = onSelectOrganizationId
    }

    public init() {
      self.init(organizationIds: [])
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.organizationIds == rhs.organizationIds
    }
  }
}

// MARK: - Model

extension OrganizationList {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "OrganizationList"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(organizationIds: [String], onSelectOrganizationId: ((String) -> Void)? = nil) {
      self.init(Parameters(organizationIds: organizationIds, onSelectOrganizationId: onSelectOrganizationId))
    }

    public init() {
      self.init(organizationIds: [])
    }
  }
}
