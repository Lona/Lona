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
  private var topLineView = NSBox()
  private var exampleTextView = NSTextField(labelWithString: "")
  private var bottomLineView = NSBox()
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
    topLineView.boxType = .custom
    topLineView.borderType = .noBorder
    topLineView.contentViewMargins = .zero
    exampleTextView.lineBreakMode = .byWordWrapping
    bottomLineView.boxType = .custom
    bottomLineView.borderType = .noBorder
    bottomLineView.contentViewMargins = .zero
    textStyleSummaryView.lineBreakMode = .byWordWrapping

    addSubview(previewView)
    addSubview(dividerView)
    addSubview(detailsView)
    previewView.addSubview(topLineView)
    previewView.addSubview(exampleTextView)
    previewView.addSubview(bottomLineView)
    detailsView.addSubview(textStyleSummaryView)

    fillColor = Colors.white
    cornerRadius = 4
    borderWidth = 1
    borderColor = Colors.grey300
    exampleTextView.maximumNumberOfLines = 1
    dividerView.fillColor = Colors.grey300
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    previewView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    detailsView.translatesAutoresizingMaskIntoConstraints = false
    topLineView.translatesAutoresizingMaskIntoConstraints = false
    exampleTextView.translatesAutoresizingMaskIntoConstraints = false
    bottomLineView.translatesAutoresizingMaskIntoConstraints = false
    textStyleSummaryView.translatesAutoresizingMaskIntoConstraints = false

    let previewViewTopAnchorConstraint = previewView.topAnchor.constraint(equalTo: topAnchor)
    let previewViewLeadingAnchorConstraint = previewView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let previewViewTrailingAnchorConstraint = previewView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let dividerViewTopAnchorConstraint = dividerView.topAnchor.constraint(equalTo: previewView.bottomAnchor)
    let dividerViewLeadingAnchorConstraint = dividerView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let dividerViewTrailingAnchorConstraint = dividerView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let detailsViewTopAnchorConstraint = detailsView.topAnchor.constraint(equalTo: dividerView.bottomAnchor)
    let detailsViewLeadingAnchorConstraint = detailsView.leadingAnchor.constraint(equalTo: leadingAnchor)
    let detailsViewTrailingAnchorConstraint = detailsView.trailingAnchor.constraint(equalTo: trailingAnchor)
    let topLineViewTopAnchorConstraint = topLineView.topAnchor.constraint(equalTo: previewView.topAnchor, constant: 16)
    let topLineViewLeadingAnchorConstraint = topLineView.leadingAnchor.constraint(equalTo: previewView.leadingAnchor)
    let topLineViewTrailingAnchorConstraint = topLineView.trailingAnchor.constraint(equalTo: previewView.trailingAnchor)
    let exampleTextViewTopAnchorConstraint = exampleTextView.topAnchor.constraint(equalTo: topLineView.bottomAnchor)
    let exampleTextViewLeadingAnchorConstraint = exampleTextView
      .leadingAnchor
      .constraint(equalTo: previewView.leadingAnchor, constant: 20)
    let exampleTextViewTrailingAnchorConstraint = exampleTextView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: previewView.trailingAnchor, constant: -20)
    let bottomLineViewBottomAnchorConstraint = bottomLineView
      .bottomAnchor
      .constraint(equalTo: previewView.bottomAnchor, constant: -16)
    let bottomLineViewTopAnchorConstraint = bottomLineView.topAnchor.constraint(equalTo: exampleTextView.bottomAnchor)
    let bottomLineViewLeadingAnchorConstraint = bottomLineView
      .leadingAnchor
      .constraint(equalTo: previewView.leadingAnchor)
    let bottomLineViewTrailingAnchorConstraint = bottomLineView
      .trailingAnchor
      .constraint(equalTo: previewView.trailingAnchor)
    let dividerViewHeightAnchorConstraint = dividerView.heightAnchor.constraint(equalToConstant: 1)
    let textStyleSummaryViewTopAnchorConstraint = textStyleSummaryView
      .topAnchor
      .constraint(equalTo: detailsView.topAnchor, constant: 16)
    let textStyleSummaryViewBottomAnchorConstraint = textStyleSummaryView
      .bottomAnchor
      .constraint(equalTo: detailsView.bottomAnchor, constant: -16)
    let textStyleSummaryViewLeadingAnchorConstraint = textStyleSummaryView
      .leadingAnchor
      .constraint(equalTo: detailsView.leadingAnchor, constant: 20)
    let textStyleSummaryViewTrailingAnchorConstraint = textStyleSummaryView
      .trailingAnchor
      .constraint(lessThanOrEqualTo: detailsView.trailingAnchor, constant: -20)
    let topLineViewHeightAnchorConstraint = topLineView.heightAnchor.constraint(equalToConstant: 1)
    let bottomLineViewHeightAnchorConstraint = bottomLineView.heightAnchor.constraint(equalToConstant: 1)

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
      topLineViewTopAnchorConstraint,
      topLineViewLeadingAnchorConstraint,
      topLineViewTrailingAnchorConstraint,
      exampleTextViewTopAnchorConstraint,
      exampleTextViewLeadingAnchorConstraint,
      exampleTextViewTrailingAnchorConstraint,
      bottomLineViewBottomAnchorConstraint,
      bottomLineViewTopAnchorConstraint,
      bottomLineViewLeadingAnchorConstraint,
      bottomLineViewTrailingAnchorConstraint,
      dividerViewHeightAnchorConstraint,
      textStyleSummaryViewTopAnchorConstraint,
      textStyleSummaryViewBottomAnchorConstraint,
      textStyleSummaryViewLeadingAnchorConstraint,
      textStyleSummaryViewTrailingAnchorConstraint,
      topLineViewHeightAnchorConstraint,
      bottomLineViewHeightAnchorConstraint
    ])
  }

  private func update() {
    bottomLineView.fillColor = Colors.white
    detailsView.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    previewView.fillColor = Colors.white
    textStyleSummaryViewTextStyle = TextStyles.regular
    textStyleSummaryView.attributedStringValue =
      textStyleSummaryViewTextStyle.apply(to: textStyleSummaryView.attributedStringValue)
    topLineView.fillColor = Colors.white
    exampleTextView.attributedStringValue = exampleTextViewTextStyle.apply(to: example)
    textStyleSummaryView.attributedStringValue = textStyleSummaryViewTextStyle.apply(to: textStyleSummary)
    exampleTextViewTextStyle = textStyle
    exampleTextView.attributedStringValue = exampleTextViewTextStyle.apply(to: exampleTextView.attributedStringValue)
    if inverse {
      previewView.fillColor = Colors.grey900
      topLineView.fillColor = Colors.grey900
      bottomLineView.fillColor = Colors.grey900
    }
    if selected {
      detailsView.fillColor = Colors.lightblue600
      topLineView.fillColor = Colors.grey200
      bottomLineView.fillColor = Colors.grey200
      textStyleSummaryViewTextStyle = TextStyles.regularInverse
      textStyleSummaryView.attributedStringValue =
        textStyleSummaryViewTextStyle.apply(to: textStyleSummaryView.attributedStringValue)
      if inverse {
        topLineView.fillColor = Colors.grey700
        bottomLineView.fillColor = Colors.grey700
      }
    }
  }
}
