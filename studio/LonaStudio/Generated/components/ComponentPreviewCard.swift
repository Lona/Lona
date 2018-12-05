import AppKit
import Foundation

// MARK: - ComponentPreviewCard

public class ComponentPreviewCard: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(componentName: String, selected: Bool) {
    self.init(Parameters(componentName: componentName, selected: selected))
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

  public var componentName: String {
    get { return parameters.componentName }
    set {
      if parameters.componentName != newValue {
        parameters.componentName = newValue
      }
    }
  }

  public var selected: Bool {
    get { return parameters.selected }
    set {
      if parameters.selected != newValue {
        parameters.selected = newValue
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

  private var previewView = NSBox()
  private var componentPreviewView = ComponentPreview()
  private var dividerView = NSBox()
  private var detailsView = NSBox()
  private var componentNameView = LNATextField(labelWithString: "")

  private var componentNameViewTextStyle = TextStyles.large

  private func setUpViews() {
    boxType = .custom
    borderType = .lineBorder
    contentViewMargins = .zero
    previewView.boxType = .custom
    previewView.borderType = .noBorder
    previewView.contentViewMargins = .zero
    dividerView.boxType = .custom
    dividerView.borderType = .noBorder
    dividerView.contentViewMargins = .zero
    detailsView.boxType = .custom
    detailsView.borderType = .noBorder
    detailsView.contentViewMargins = .zero
    componentNameView.lineBreakMode = .byWordWrapping

    addSubview(previewView)
    addSubview(dividerView)
    addSubview(detailsView)
    previewView.addSubview(componentPreviewView)
    detailsView.addSubview(componentNameView)

    fillColor = Colors.white
    cornerRadius = 4
    borderWidth = 1
    borderColor = Colors.grey300
    componentNameView.maximumNumberOfLines = 1
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    previewView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    detailsView.translatesAutoresizingMaskIntoConstraints = false
    componentPreviewView.translatesAutoresizingMaskIntoConstraints = false
    componentNameView.translatesAutoresizingMaskIntoConstraints = false

    let previewViewTopAnchorConstraint = previewView.topAnchor.constraint(equalTo: topAnchor, constant: 1)
    let previewViewLeadingAnchorConstraint = previewView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1)
    let previewViewTrailingAnchorConstraint = previewView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -1)
    let dividerViewTopAnchorConstraint = dividerView.topAnchor.constraint(equalTo: previewView.bottomAnchor)
    let dividerViewLeadingAnchorConstraint = dividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1)
    let dividerViewTrailingAnchorConstraint = dividerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -1)
    let detailsViewBottomAnchorConstraint = detailsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1)
    let detailsViewTopAnchorConstraint = detailsView.topAnchor.constraint(equalTo: dividerView.bottomAnchor)
    let detailsViewLeadingAnchorConstraint = detailsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1)
    let detailsViewTrailingAnchorConstraint = detailsView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -1)
    let componentPreviewViewTopAnchorConstraint = componentPreviewView
      .topAnchor
      .constraint(equalTo: previewView.topAnchor, constant: 10)
    let componentPreviewViewBottomAnchorConstraint = componentPreviewView
      .bottomAnchor
      .constraint(equalTo: previewView.bottomAnchor, constant: -10)
    let componentPreviewViewLeadingAnchorConstraint = componentPreviewView
      .leadingAnchor
      .constraint(equalTo: previewView.leadingAnchor, constant: 10)
    let componentPreviewViewTrailingAnchorConstraint = componentPreviewView
      .trailingAnchor
      .constraint(equalTo: previewView.trailingAnchor, constant: -10)
    let dividerViewHeightAnchorConstraint = dividerView.heightAnchor.constraint(equalToConstant: 1)
    let componentNameViewTopAnchorConstraint = componentNameView
      .topAnchor
      .constraint(equalTo: detailsView.topAnchor, constant: 16)
    let componentNameViewBottomAnchorConstraint = componentNameView
      .bottomAnchor
      .constraint(equalTo: detailsView.bottomAnchor, constant: -16)
    let componentNameViewLeadingAnchorConstraint = componentNameView
      .leadingAnchor
      .constraint(equalTo: detailsView.leadingAnchor, constant: 20)
    let componentNameViewTrailingAnchorConstraint = componentNameView
      .trailingAnchor
      .constraint(equalTo: detailsView.trailingAnchor, constant: -20)
    let componentNameViewHeightAnchorConstraint = componentNameView.heightAnchor.constraint(equalToConstant: 18)

    NSLayoutConstraint.activate([
      previewViewTopAnchorConstraint,
      previewViewLeadingAnchorConstraint,
      previewViewTrailingAnchorConstraint,
      dividerViewTopAnchorConstraint,
      dividerViewLeadingAnchorConstraint,
      dividerViewTrailingAnchorConstraint,
      detailsViewBottomAnchorConstraint,
      detailsViewTopAnchorConstraint,
      detailsViewLeadingAnchorConstraint,
      detailsViewTrailingAnchorConstraint,
      componentPreviewViewTopAnchorConstraint,
      componentPreviewViewBottomAnchorConstraint,
      componentPreviewViewLeadingAnchorConstraint,
      componentPreviewViewTrailingAnchorConstraint,
      dividerViewHeightAnchorConstraint,
      componentNameViewTopAnchorConstraint,
      componentNameViewBottomAnchorConstraint,
      componentNameViewLeadingAnchorConstraint,
      componentNameViewTrailingAnchorConstraint,
      componentNameViewHeightAnchorConstraint
    ])
  }

  private func update() {
    componentNameViewTextStyle = TextStyles.large
    componentNameView.attributedStringValue =
      componentNameViewTextStyle.apply(to: componentNameView.attributedStringValue)
    detailsView.fillColor = Colors.transparent
    dividerView.fillColor = Colors.grey300
    previewView.fillColor = Colors.grey100
    componentNameView.attributedStringValue = componentNameViewTextStyle.apply(to: componentName)
    componentPreviewView.componentName = componentName
    if selected {
      previewView.fillColor = Colors.lightblue600
      detailsView.fillColor = Colors.lightblue600
      dividerView.fillColor = Colors.lightblue700
      componentNameViewTextStyle = TextStyles.largeInverse
      componentNameView.attributedStringValue =
        componentNameViewTextStyle.apply(to: componentNameView.attributedStringValue)
    }
  }
}

// MARK: - Parameters

extension ComponentPreviewCard {
  public struct Parameters: Equatable {
    public var componentName: String
    public var selected: Bool

    public init(componentName: String, selected: Bool) {
      self.componentName = componentName
      self.selected = selected
    }

    public init() {
      self.init(componentName: "", selected: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.componentName == rhs.componentName && lhs.selected == rhs.selected
    }
  }
}

// MARK: - Model

extension ComponentPreviewCard {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "ComponentPreviewCard"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(componentName: String, selected: Bool) {
      self.init(Parameters(componentName: componentName, selected: selected))
    }

    public init() {
      self.init(componentName: "", selected: false)
    }
  }
}
