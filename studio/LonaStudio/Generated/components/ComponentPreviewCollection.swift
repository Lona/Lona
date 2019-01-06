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

  public convenience init(componentNames: [String]) {
    self.init(Parameters(componentNames: componentNames))
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

  public var componentNames: [String] {
    get { return parameters.componentNames }
    set {
      if parameters.componentNames != newValue {
        parameters.componentNames = newValue
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
}

// MARK: - Parameters

extension ComponentPreviewCollection {
  public struct Parameters: Equatable {
    public var componentNames: [String]

    public init(componentNames: [String]) {
      self.componentNames = componentNames
    }

    public init() {
      self.init(componentNames: [])
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.componentNames == rhs.componentNames
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

    public init(componentNames: [String]) {
      self.init(Parameters(componentNames: componentNames))
    }

    public init() {
      self.init(componentNames: [])
    }
  }
}
