import AppKit
import Foundation

// MARK: - TemplatePreviewCollection

public class TemplatePreviewCollection: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(
    templateTitles: [String],
    templateDescriptions: [String],
    templateImages: [String],
    selectedTemplateIndex: Int)
  {
    self
      .init(
        Parameters(
          templateTitles: templateTitles,
          templateDescriptions: templateDescriptions,
          templateImages: templateImages,
          selectedTemplateIndex: selectedTemplateIndex))
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

  public var templateTitles: [String] {
    get { return parameters.templateTitles }
    set {
      if parameters.templateTitles != newValue {
        parameters.templateTitles = newValue
      }
    }
  }

  public var templateDescriptions: [String] {
    get { return parameters.templateDescriptions }
    set {
      if parameters.templateDescriptions != newValue {
        parameters.templateDescriptions = newValue
      }
    }
  }

  public var templateImages: [String] {
    get { return parameters.templateImages }
    set {
      if parameters.templateImages != newValue {
        parameters.templateImages = newValue
      }
    }
  }

  public var onSelectTemplateIndex: ((Int) -> Void)? {
    get { return parameters.onSelectTemplateIndex }
    set { parameters.onSelectTemplateIndex = newValue }
  }

  public var selectedTemplateIndex: Int {
    get { return parameters.selectedTemplateIndex }
    set {
      if parameters.selectedTemplateIndex != newValue {
        parameters.selectedTemplateIndex = newValue
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
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
  }

  private func update() {}

  private func handleOnSelectTemplateIndex(_ arg0: Int) {
    onSelectTemplateIndex?(arg0)
  }
}

// MARK: - Parameters

extension TemplatePreviewCollection {
  public struct Parameters: Equatable {
    public var templateTitles: [String]
    public var templateDescriptions: [String]
    public var templateImages: [String]
    public var selectedTemplateIndex: Int
    public var onSelectTemplateIndex: ((Int) -> Void)?

    public init(
      templateTitles: [String],
      templateDescriptions: [String],
      templateImages: [String],
      selectedTemplateIndex: Int,
      onSelectTemplateIndex: ((Int) -> Void)? = nil)
    {
      self.templateTitles = templateTitles
      self.templateDescriptions = templateDescriptions
      self.templateImages = templateImages
      self.selectedTemplateIndex = selectedTemplateIndex
      self.onSelectTemplateIndex = onSelectTemplateIndex
    }

    public init() {
      self.init(templateTitles: [], templateDescriptions: [], templateImages: [], selectedTemplateIndex: 0)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.templateTitles == rhs.templateTitles &&
        lhs.templateDescriptions == rhs.templateDescriptions &&
          lhs.templateImages == rhs.templateImages && lhs.selectedTemplateIndex == rhs.selectedTemplateIndex
    }
  }
}

// MARK: - Model

extension TemplatePreviewCollection {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "TemplatePreviewCollection"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(
      templateTitles: [String],
      templateDescriptions: [String],
      templateImages: [String],
      selectedTemplateIndex: Int,
      onSelectTemplateIndex: ((Int) -> Void)? = nil)
    {
      self
        .init(
          Parameters(
            templateTitles: templateTitles,
            templateDescriptions: templateDescriptions,
            templateImages: templateImages,
            selectedTemplateIndex: selectedTemplateIndex,
            onSelectTemplateIndex: onSelectTemplateIndex))
    }

    public init() {
      self.init(templateTitles: [], templateDescriptions: [], templateImages: [], selectedTemplateIndex: 0)
    }
  }
}
