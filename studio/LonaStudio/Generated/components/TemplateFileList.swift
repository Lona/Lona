import AppKit
import Foundation

// MARK: - TemplateFileList

public class TemplateFileList: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(fileNames: [String]) {
    self.init(Parameters(fileNames: fileNames))
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

  public var fileNames: [String] {
    get { return parameters.fileNames }
    set {
      if parameters.fileNames != newValue {
        parameters.fileNames = newValue
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
}

// MARK: - Parameters

extension TemplateFileList {
  public struct Parameters: Equatable {
    public var fileNames: [String]

    public init(fileNames: [String]) {
      self.fileNames = fileNames
    }

    public init() {
      self.init(fileNames: [])
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.fileNames == rhs.fileNames
    }
  }
}

// MARK: - Model

extension TemplateFileList {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "TemplateFileList"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(fileNames: [String]) {
      self.init(Parameters(fileNames: fileNames))
    }

    public init() {
      self.init(fileNames: [])
    }
  }
}
