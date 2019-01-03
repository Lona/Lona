import AppKit
import Foundation

// MARK: - TextStylePreviewCard

public class TextStylePreviewCard: NSBox {

  // MARK: Lifecycle

  public init(_ parameters: Parameters) {
    self.parameters = parameters

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init(
    example: String,
    textStyleSummary: String,
    textStyle: TextStyle,
    selected: Bool,
    inverse: Bool)
  {
    self
      .init(
        Parameters(
          example: example,
          textStyleSummary: textStyleSummary,
          textStyle: textStyle,
          selected: selected,
          inverse: inverse))
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

  public var example: String {
    get { return parameters.example }
    set {
      if parameters.example != newValue {
        parameters.example = newValue
      }
    }
  }

  public var textStyleSummary: String {
    get { return parameters.textStyleSummary }
    set {
      if parameters.textStyleSummary != newValue {
        parameters.textStyleSummary = newValue
      }
    }
  }

  public var textStyle: TextStyle {
    get { return parameters.textStyle }
    set {
      if parameters.textStyle != newValue {
        parameters.textStyle = newValue
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

  public var inverse: Bool {
    get { return parameters.inverse }
    set {
      if parameters.inverse != newValue {
        parameters.inverse = newValue
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
  private var exampleTextView = LNATextField(labelWithString: "")
  private var dividerView = NSBox()
  private var detailsView = NSBox()
  private var textStyleSummaryView = LNATextField(labelWithString: "")

  private var exampleTextViewTextStyle = TextStyles.regular
  private var textStyleSummaryViewTextStyle = TextStyles.regular

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
    exampleTextView.lineBreakMode = .byWordWrapping
    textStyleSummaryView.lineBreakMode = .byWordWrapping

    addSubview(previewView)
    addSubview(dividerView)
    addSubview(detailsView)
    previewView.addSubview(exampleTextView)
    detailsView.addSubview(textStyleSummaryView)

    cornerRadius = 4
    borderWidth = 1
    exampleTextView.maximumNumberOfLines = 1
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    previewView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    detailsView.translatesAutoresizingMaskIntoConstraints = false
    exampleTextView.translatesAutoresizingMaskIntoConstraints = false
    textStyleSummaryView.translatesAutoresizingMaskIntoConstraints = false

    let previewViewTopAnchorConstraint = previewView.topAnchor.constraint(equalTo: topAnchor, constant: 5)
    let previewViewLeadingAnchorConstraint = previewView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5)
    let previewViewTrailingAnchorConstraint = previewView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -5)
    let dividerViewTopAnchorConstraint = dividerView.topAnchor.constraint(equalTo: previewView.bottomAnchor)
    let dividerViewLeadingAnchorConstraint = dividerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5)
    let dividerViewTrailingAnchorConstraint = dividerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -5)
    let detailsViewTopAnchorConstraint = detailsView
      .topAnchor
      .constraint(equalTo: dividerView.bottomAnchor, constant: 5)
    let detailsViewLeadingAnchorConstraint = detailsView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5)
    let detailsViewTrailingAnchorConstraint = detailsView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -5)
    let exampleTextViewTopAnchorConstraint = exampleTextView.topAnchor.constraint(equalTo: previewView.topAnchor)
    let exampleTextViewBottomAnchorConstraint = exampleTextView
      .bottomAnchor
      .constraint(equalTo: previewView.bottomAnchor)
    let exampleTextViewLeadingAnchorConstraint = exampleTextView
      .leadingAnchor
      .constraint(equalTo: previewView.leadingAnchor, constant: 2)
    let exampleTextViewTrailingAnchorConstraint = exampleTextView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: previewView.trailingAnchor, constant: -2)
    let dividerViewHeightAnchorConstraint = dividerView.heightAnchor.constraint(equalToConstant: 1)
    let textStyleSummaryViewTopAnchorConstraint = textStyleSummaryView
      .topAnchor
      .constraint(equalTo: detailsView.topAnchor)
    let textStyleSummaryViewBottomAnchorConstraint = textStyleSummaryView
      .bottomAnchor
      .constraint(equalTo: detailsView.bottomAnchor)
    let textStyleSummaryViewLeadingAnchorConstraint = textStyleSummaryView
      .leadingAnchor
      .constraint(equalTo: detailsView.leadingAnchor)
    let textStyleSummaryViewTrailingAnchorConstraint = textStyleSummaryView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: detailsView.trailingAnchor)
    let textStyleSummaryViewHeightAnchorConstraint = textStyleSummaryView.heightAnchor.constraint(equalToConstant: 18)

    NSLayoutConstraint.activate([
      previewViewTopAnchorConstraint,
      previewViewLeadingAnchorConstraint,
      previewViewTrailingAnchorConstraint,
      dividerViewTopAnchorConstraint,
      dividerViewLeadingAnchorConstraint,
      dividerViewTrailingAnchorConstraint,
      detailsViewTopAnchorConstraint,
      detailsViewLeadingAnchorConstraint,
      detailsViewTrailingAnchorConstraint,
      exampleTextViewTopAnchorConstraint,
      exampleTextViewBottomAnchorConstraint,
      exampleTextViewLeadingAnchorConstraint,
      exampleTextViewTrailingAnchorConstraint,
      dividerViewHeightAnchorConstraint,
      textStyleSummaryViewTopAnchorConstraint,
      textStyleSummaryViewBottomAnchorConstraint,
      textStyleSummaryViewLeadingAnchorConstraint,
      textStyleSummaryViewTrailingAnchorConstraint,
      textStyleSummaryViewHeightAnchorConstraint
    ])
  }

  private func update() {
    borderColor = Colors.transparent
    previewView.fillColor = Colors.grey100
    exampleTextView.attributedStringValue = exampleTextViewTextStyle.apply(to: example)
    textStyleSummaryView.attributedStringValue = textStyleSummaryViewTextStyle.apply(to: textStyleSummary)
    exampleTextViewTextStyle = textStyle
    exampleTextView.attributedStringValue = exampleTextViewTextStyle.apply(to: exampleTextView.attributedStringValue)
    if inverse {
      previewView.fillColor = Colors.grey800
    }
    if selected {
      borderColor = Colors.lightblue600
    }
  }
}

// MARK: - Parameters

extension TextStylePreviewCard {
  public struct Parameters: Equatable {
    public var example: String
    public var textStyleSummary: String
    public var textStyle: TextStyle
    public var selected: Bool
    public var inverse: Bool

    public init(example: String, textStyleSummary: String, textStyle: TextStyle, selected: Bool, inverse: Bool) {
      self.example = example
      self.textStyleSummary = textStyleSummary
      self.textStyle = textStyle
      self.selected = selected
      self.inverse = inverse
    }

    public init() {
      self.init(example: "", textStyleSummary: "", textStyle: TextStyles.regular, selected: false, inverse: false)
    }

    public static func ==(lhs: Parameters, rhs: Parameters) -> Bool {
      return lhs.example == rhs.example &&
        lhs.textStyleSummary == rhs.textStyleSummary &&
          lhs.textStyle == rhs.textStyle && lhs.selected == rhs.selected && lhs.inverse == rhs.inverse
    }
  }
}

// MARK: - Model

extension TextStylePreviewCard {
  public struct Model: LonaViewModel, Equatable {
    public var id: String?
    public var parameters: Parameters
    public var type: String {
      return "TextStylePreviewCard"
    }

    public init(id: String? = nil, parameters: Parameters) {
      self.id = id
      self.parameters = parameters
    }

    public init(_ parameters: Parameters) {
      self.parameters = parameters
    }

    public init(example: String, textStyleSummary: String, textStyle: TextStyle, selected: Bool, inverse: Bool) {
      self
        .init(
          Parameters(
            example: example,
            textStyleSummary: textStyleSummary,
            textStyle: textStyle,
            selected: selected,
            inverse: inverse))
    }

    public init() {
      self.init(example: "", textStyleSummary: "", textStyle: TextStyles.regular, selected: false, inverse: false)
    }
  }
}
