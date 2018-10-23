import AppKit
import Foundation

// MARK: - TextStylePreviewCard

public class TextStylePreviewCard: NSBox {

  // MARK: Lifecycle

  public init(example: String, textStyleSummary: String, textStyle: TextStyle, selected: Bool, inverse: Bool) {
    self.example = example
    self.textStyleSummary = textStyleSummary
    self.textStyle = textStyle
    self.selected = selected
    self.inverse = inverse

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(example: "", textStyleSummary: "", textStyle: TextStyles.regular, selected: false, inverse: false)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var example: String { didSet { update() } }
  public var textStyleSummary: String { didSet { update() } }
  public var textStyle: TextStyle { didSet { update() } }
  public var selected: Bool { didSet { update() } }
  public var inverse: Bool { didSet { update() } }

  // MARK: Private

  private var previewView = NSBox()
  private var exampleTextView = NSTextField(labelWithString: "")
  private var dividerView = NSBox()
  private var detailsView = NSBox()
  private var textStyleSummaryView = NSTextField(labelWithString: "")

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

    fillColor = Colors.white
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
      previewView.fillColor = Colors.grey900
    }
    if selected {
      borderColor = Colors.lightblue600
    }
  }
}
