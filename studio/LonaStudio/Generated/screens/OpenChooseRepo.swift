import AppKit
import Foundation

// MARK: - OpenChooseRepo

public class OpenChooseRepo: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(titleText: String, bodyText: String, repositoryIds: [String]) {
    self.init(Parameters(titleText: titleText, bodyText: bodyText, repositoryIds: repositoryIds))
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

  public var titleText: String {
    get { return parameters.titleText }
    set {
      if parameters.titleText != newValue {
        parameters.titleText = newValue
      }
    }
  }

  public var bodyText: String {
    get { return parameters.bodyText }
    set {
      if parameters.bodyText != newValue {
        parameters.bodyText = newValue
      }
    }
  }

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

  private var titleView = LNATextField(labelWithString: "")
  private var vSpacerView = NSBox()
  private var bodyView = LNATextField(labelWithString: "")
  private var vSpacer4View = NSBox()
  private var repositoryListView = RepositoryList()

  private var titleViewTextStyle = TextStyles.title
  private var bodyViewTextStyle = TextStyles.body

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero
    titleView.lineBreakMode = .byWordWrapping
    vSpacerView.boxType = .custom
    vSpacerView.borderType = .noBorder
    vSpacerView.contentViewMargins = .zero
    bodyView.lineBreakMode = .byWordWrapping
    vSpacer4View.boxType = .custom
    vSpacer4View.borderType = .noBorder
    vSpacer4View.contentViewMargins = .zero

    addSubview(titleView)
    addSubview(vSpacerView)
    addSubview(bodyView)
    addSubview(vSpacer4View)
    addSubview(repositoryListView)

    titleViewTextStyle = TextStyles.title
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleView.attributedStringValue)
    vSpacerView.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
    bodyViewTextStyle = TextStyles.body
    bodyView.attributedStringValue = bodyViewTextStyle.apply(to: bodyView.attributedStringValue)
    vSpacer4View.fillColor = #colorLiteral(red: 0.847058823529, green: 0.847058823529, blue: 0.847058823529, alpha: 1)
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    titleView.translatesAutoresizingMaskIntoConstraints = false
    vSpacerView.translatesAutoresizingMaskIntoConstraints = false
    bodyView.translatesAutoresizingMaskIntoConstraints = false
    vSpacer4View.translatesAutoresizingMaskIntoConstraints = false
    repositoryListView.translatesAutoresizingMaskIntoConstraints = false

    let titleViewTopAnchorConstraint = titleView.topAnchor.constraint(equalTo: topAnchor)
    let titleViewLeadingAnchorConstraint = titleView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let titleViewTrailingAnchorConstraint = titleView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let vSpacerViewTopAnchorConstraint = vSpacerView.topAnchor.constraint(equalTo: titleView.bottomAnchor)
    let vSpacerViewLeadingAnchorConstraint = vSpacerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let bodyViewTopAnchorConstraint = bodyView.topAnchor.constraint(equalTo: vSpacerView.bottomAnchor)
    let bodyViewLeadingAnchorConstraint = bodyView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let bodyViewTrailingAnchorConstraint = bodyView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let vSpacer4ViewTopAnchorConstraint = vSpacer4View.topAnchor.constraint(equalTo: bodyView.bottomAnchor)
    let vSpacer4ViewLeadingAnchorConstraint = vSpacer4View.leadingAnchor.constraint(equalTo: leadingAnchor)
    let repositoryListViewBottomAnchorConstraint = repositoryListView.bottomAnchor.constraint(equalTo: bottomAnchor)
    let repositoryListViewTopAnchorConstraint = repositoryListView
      .topAnchor
      .constraint(equalTo: vSpacer4View.bottomAnchor)
    let repositoryListViewLeadingAnchorConstraint = repositoryListView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let repositoryListViewTrailingAnchorConstraint = repositoryListView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor)
    let vSpacerViewHeightAnchorConstraint = vSpacerView.heightAnchor.constraint(equalToConstant: 32)
    let vSpacerViewWidthAnchorConstraint = vSpacerView.widthAnchor.constraint(equalToConstant: 0)
    let vSpacer4ViewHeightAnchorConstraint = vSpacer4View.heightAnchor.constraint(equalToConstant: 16)
    let vSpacer4ViewWidthAnchorConstraint = vSpacer4View.widthAnchor.constraint(equalToConstant: 0)

    NSLayoutConstraint.activate([
      titleViewTopAnchorConstraint,
      titleViewLeadingAnchorConstraint,
      titleViewTrailingAnchorConstraint,
      vSpacerViewTopAnchorConstraint,
      vSpacerViewLeadingAnchorConstraint,
      bodyViewTopAnchorConstraint,
      bodyViewLeadingAnchorConstraint,
      bodyViewTrailingAnchorConstraint,
      vSpacer4ViewTopAnchorConstraint,
      vSpacer4ViewLeadingAnchorConstraint,
      repositoryListViewBottomAnchorConstraint,
      repositoryListViewTopAnchorConstraint,
      repositoryListViewLeadingAnchorConstraint,
      repositoryListViewTrailingAnchorConstraint,
      vSpacerViewHeightAnchorConstraint,
      vSpacerViewWidthAnchorConstraint,
      vSpacer4ViewHeightAnchorConstraint,
      vSpacer4ViewWidthAnchorConstraint
    ])
  }

  private func update() {
    titleView.attributedStringValue = titleViewTextStyle.apply(to: titleText)
    bodyView.attributedStringValue = bodyViewTextStyle.apply(to: bodyText)
    repositoryListView.repositoryIds = repositoryIds
    repositoryListView.onSelectRepositoryId = handleOnSelectRepositoryId
  }

  private func handleOnSelectRepositoryId(_ arg0: String) {
    onSelectRepositoryId?(arg0)
  }
}

// MARK: - Parameters

extension OpenChooseRepo {
  public struct Parameters: Equatable {
    public var titleText: String
    public var bodyText: String
    public var repositoryIds: [String]
    public var onSelectRepositoryId: ((String) -> Void)?

    public init(
      titleText: String,
      bodyText: String,
      repositoryIds: [String],
      onSelectRepositoryId: ((String) -> Void)? = nil)
    {
      self.titleText = titleText
      self.bodyText = bodyText
      self.repositoryIds = repositoryIds
      self.onSelectRepositoryId = onSelectRepositoryId
    }

    public init() {
      self.init(titleText: "", bodyText: "", repositoryIds: [])
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.titleText == rhs.titleText && lhs.bodyText == rhs.bodyText && lhs.repositoryIds == rhs.repositoryIds
    }
  }
}

// MARK: - Model

extension OpenChooseRepo {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "OpenChooseRepo"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      titleText: String,
      bodyText: String,
      repositoryIds: [String],
      onSelectRepositoryId: ((String) -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            titleText: titleText,
            bodyText: bodyText,
            repositoryIds: repositoryIds,
            onSelectRepositoryId: onSelectRepositoryId))
    }

    public init() {
      self.init(titleText: "", bodyText: "", repositoryIds: [])
    }
  }
}
