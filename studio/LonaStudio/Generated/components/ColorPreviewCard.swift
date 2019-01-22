import AppKit
import Foundation

// MARK: - ColorPreviewCard

public class ColorPreviewCard: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(colorName: String, colorCode: String, color: NSColor, selected: Bool) {
    self.init(Parameters(colorName: colorName, colorCode: colorCode, color: color, selected: selected))
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

  public var colorName: String {
    get { return parameters.colorName }
    set {
      if parameters.colorName != newValue {
        parameters.colorName = newValue
      }
    }
  }

  public var colorCode: String {
    get { return parameters.colorCode }
    set {
      if parameters.colorCode != newValue {
        parameters.colorCode = newValue
      }
    }
  }

  public var color: NSColor {
    get { return parameters.color }
    set {
      if parameters.color != newValue {
        parameters.color = newValue
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
  private var detailsView = NSBox()
  private var colorNameView = LNATextField(labelWithString: "")
  private var colorCodeView = LNATextField(labelWithString: "")

  private var colorNameViewTextStyle = TextStyles.regular
  private var colorCodeViewTextStyle = TextStyles.monospacedMicro

  private func setUpViews() {
    boxType = .custom
    borderType = .lineBorder
    contentViewMargins = .zero
    previewView.boxType = .custom
    previewView.borderType = .lineBorder
    previewView.contentViewMargins = .zero
    detailsView.boxType = .custom
    detailsView.borderType = .noBorder
    detailsView.contentViewMargins = .zero
    colorNameView.lineBreakMode = .byWordWrapping
    colorCodeView.lineBreakMode = .byWordWrapping

    addSubview(previewView)
    addSubview(detailsView)
    detailsView.addSubview(colorNameView)
    detailsView.addSubview(colorCodeView)

    cornerRadius = 4
    borderWidth = 1
    previewView.borderColor = Colors.darkTransparentOutline
    previewView.cornerRadius = 3
    previewView.borderWidth = 1
    colorNameViewTextStyle = TextStyles.regular
    colorNameView.attributedStringValue = colorNameViewTextStyle.apply(to: colorNameView.attributedStringValue)
    colorNameView.maximumNumberOfLines = 2
    colorCodeViewTextStyle = TextStyles.monospacedMicro
    colorCodeView.attributedStringValue = colorCodeViewTextStyle.apply(to: colorCodeView.attributedStringValue)
    colorCodeView.maximumNumberOfLines = 2
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    previewView.translatesAutoresizingMaskIntoConstraints = false
    detailsView.translatesAutoresizingMaskIntoConstraints = false
    colorNameView.translatesAutoresizingMaskIntoConstraints = false
    colorCodeView.translatesAutoresizingMaskIntoConstraints = false

    let previewViewTopAnchorConstraint = previewView.topAnchor.constraint(equalTo: topAnchor, constant: 5)
    let previewViewLeadingAnchorConstraint = previewView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5)
    let previewViewTrailingAnchorConstraint = previewView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -5)
    let detailsViewBottomAnchorConstraint = detailsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
    let detailsViewTopAnchorConstraint = detailsView
      .topAnchor
      .constraint(equalTo: previewView.bottomAnchor, constant: 5)
    let detailsViewLeadingAnchorConstraint = detailsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5)
    let detailsViewTrailingAnchorConstraint = detailsView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -5)
    let colorNameViewTopAnchorConstraint = colorNameView.topAnchor.constraint(equalTo: detailsView.topAnchor)
    let colorNameViewLeadingAnchorConstraint = colorNameView
      .leadingAnchor
      .constraint(equalTo: detailsView.leadingAnchor)
    let colorNameViewTrailingAnchorConstraint = colorNameView
      .trailingAnchor
      .constraint(equalTo: detailsView.trailingAnchor)
    let colorCodeViewBottomAnchorConstraint = colorCodeView.bottomAnchor.constraint(equalTo: detailsView.bottomAnchor)
    let colorCodeViewTopAnchorConstraint = colorCodeView.topAnchor.constraint(equalTo: colorNameView.bottomAnchor)
    let colorCodeViewLeadingAnchorConstraint = colorCodeView
      .leadingAnchor
      .constraint(equalTo: detailsView.leadingAnchor)
    let colorCodeViewTrailingAnchorConstraint = colorCodeView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: detailsView.trailingAnchor)

    NSLayoutConstraint.activate([
      previewViewTopAnchorConstraint,
      previewViewLeadingAnchorConstraint,
      previewViewTrailingAnchorConstraint,
      detailsViewBottomAnchorConstraint,
      detailsViewTopAnchorConstraint,
      detailsViewLeadingAnchorConstraint,
      detailsViewTrailingAnchorConstraint,
      colorNameViewTopAnchorConstraint,
      colorNameViewLeadingAnchorConstraint,
      colorNameViewTrailingAnchorConstraint,
      colorCodeViewBottomAnchorConstraint,
      colorCodeViewTopAnchorConstraint,
      colorCodeViewLeadingAnchorConstraint,
      colorCodeViewTrailingAnchorConstraint
    ])
  }

  private func update() {
    borderColor = Colors.transparent
    colorNameView.attributedStringValue = colorNameViewTextStyle.apply(to: colorName)
    colorCodeView.attributedStringValue = colorCodeViewTextStyle.apply(to: colorCode)
    previewView.fillColor = color
    if selected {
      borderColor = Colors.lightblue600
    }
  }
}

// MARK: - Parameters

extension ColorPreviewCard {
  public struct Parameters: Equatable {
    public var colorName: String
    public var colorCode: String
    public var color: NSColor
    public var selected: Bool

    public init(colorName: String, colorCode: String, color: NSColor, selected: Bool) {
      self.colorName = colorName
      self.colorCode = colorCode
      self.color = color
      self.selected = selected
    }

    public init() {
      self.init(colorName: "", colorCode: "", color: NSColor.clear, selected: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.colorName == rhs.colorName &&
        lhs.colorCode == rhs.colorCode && lhs.color == rhs.color && lhs.selected == rhs.selected
    }
  }
}

// MARK: - Model

extension ColorPreviewCard {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "ColorPreviewCard"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(colorName: String, colorCode: String, color: NSColor, selected: Bool) {
      self.init(Parameters(colorName: colorName, colorCode: colorCode, color: color, selected: selected))
    }

    public init() {
      self.init(colorName: "", colorCode: "", color: NSColor.clear, selected: false)
    }
  }
}
