import AppKit
import Foundation

// MARK: - ComponentPreviewCollection

public class ComponentPreviewCollection: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(readme: String, componentNames: [String], logicFileNames: [String]) {
    self.init(Parameters(readme: readme, componentNames: componentNames, logicFileNames: logicFileNames))
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

  public var readme: String {
    get { return parameters.readme }
    set {
      if parameters.readme != newValue {
        parameters.readme = newValue
      }
    }
  }

  public var componentNames: [String] {
    get { return parameters.componentNames }
    set {
      if parameters.componentNames != newValue {
        parameters.componentNames = newValue
      }
    }
  }

  public var logicFileNames: [String] {
    get { return parameters.logicFileNames }
    set {
      if parameters.logicFileNames != newValue {
        parameters.logicFileNames = newValue
      }
    }
  }

  public var onSelectComponent: ((String) -> Void)? {
    get { return parameters.onSelectComponent }
    set { parameters.onSelectComponent = newValue }
  }

  public var parameters: Parameters {
    didSet {
      if parameters != oldValue {
        update()
      }
    }
  }

  // MARK: Private

  private func setUpViews() {
    boxType = .custom
    borderType = .noBorder
    contentViewMargins = .zero

    fillColor = Colors.pink50
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
  }

  private func update() {}

  private func handleOnSelectComponent(_ arg0: String) {
    onSelectComponent?(arg0)
  }
}

// MARK: - Parameters

extension ComponentPreviewCollection {
  public struct Parameters: Equatable {
    public var readme: String
    public var componentNames: [String]
    public var logicFileNames: [String]
    public var onSelectComponent: ((String) -> Void)?

    public init(
      readme: String,
      componentNames: [String],
      logicFileNames: [String],
      onSelectComponent: ((String) -> Void)? = nil)
    {
      self.readme = readme
      self.componentNames = componentNames
      self.logicFileNames = logicFileNames
      self.onSelectComponent = onSelectComponent
    }

    public init() {
      self.init(readme: "", componentNames: [], logicFileNames: [])
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.readme == rhs.readme &&
        lhs.componentNames == rhs.componentNames && lhs.logicFileNames == rhs.logicFileNames
    }
  }
}

// MARK: - Model

extension ComponentPreviewCollection {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "ComponentPreviewCollection"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      readme: String,
      componentNames: [String],
      logicFileNames: [String],
      onSelectComponent: ((String) -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            readme: readme,
            componentNames: componentNames,
            logicFileNames: logicFileNames,
            onSelectComponent: onSelectComponent))
    }

    public init() {
      self.init(readme: "", componentNames: [], logicFileNames: [])
    }
  }
}
