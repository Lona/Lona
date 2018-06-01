import AppKit
import Foundation

// MARK: - TextStylePreviewCard

public class TextStylePreviewCard: NSBox {

  // MARK: Lifecycle

  public init(
    example: String,
    textStyleSummary: String,
    textStyle: AttributedFont,
    previewBackgroundColor: NSColor,
    selected: Bool) {
    self.example = example
    self.textStyleSummary = textStyleSummary
    self.textStyle = textStyle
    self.previewBackgroundColor = previewBackgroundColor
    self.selected = selected

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self
      .init(
        example: "",
        textStyleSummary: "",
        textStyle: TextStyles.regular,
        previewBackgroundColor: NSColor.clear,
        selected: false)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var example: String { didSet { update() } }
  public var textStyleSummary: String { didSet { update() } }
  public var textStyle: AttributedFont { didSet { update() } }
  public var previewBackgroundColor: NSColor { didSet { update() } }
  public var selected: Bool { didSet { update() } }

  // MARK: Private

  private var previewView = NSBox()
  private var exampleTextView = NSTextField(labelWithString: "")
  private var dividerView = NSBox()
  private var detailsView = NSBox()
  private var textStyleSummaryView = NSTextField(labelWithString: "")

  private var exampleTextViewTextStyle = TextStyles.regular
  private var textStyleSummaryViewTextStyle = TextStyles.regular

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var previewViewTopMargin: CGFloat = 0
  private var previewViewTrailingMargin: CGFloat = 0
  private var previewViewBottomMargin: CGFloat = 0
  private var previewViewLeadingMargin: CGFloat = 0
  private var previewViewTopPadding: CGFloat = 16
  private var previewViewTrailingPadding: CGFloat = 20
  private var previewViewBottomPadding: CGFloat = 16
  private var previewViewLeadingPadding: CGFloat = 20
  private var dividerViewTopMargin: CGFloat = 0
  private var dividerViewTrailingMargin: CGFloat = 0
  private var dividerViewBottomMargin: CGFloat = 0
  private var dividerViewLeadingMargin: CGFloat = 0
  private var detailsViewTopMargin: CGFloat = 0
  private var detailsViewTrailingMargin: CGFloat = 0
  private var detailsViewBottomMargin: CGFloat = 0
  private var detailsViewLeadingMargin: CGFloat = 0
  private var detailsViewTopPadding: CGFloat = 16
  private var detailsViewTrailingPadding: CGFloat = 20
  private var detailsViewBottomPadding: CGFloat = 16
  private var detailsViewLeadingPadding: CGFloat = 20
  private var exampleTextViewTopMargin: CGFloat = 0
  private var exampleTextViewTrailingMargin: CGFloat = 0
  private var exampleTextViewBottomMargin: CGFloat = 0
  private var exampleTextViewLeadingMargin: CGFloat = 0
  private var textStyleSummaryViewTopMargin: CGFloat = 0
  private var textStyleSummaryViewTrailingMargin: CGFloat = 0
  private var textStyleSummaryViewBottomMargin: CGFloat = 0
  private var textStyleSummaryViewLeadingMargin: CGFloat = 0

  private var previewViewTopAnchorConstraint: NSLayoutConstraint?
  private var previewViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var previewViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewTopAnchorConstraint: NSLayoutConstraint?
  private var dividerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var detailsViewTopAnchorConstraint: NSLayoutConstraint?
  private var detailsViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var detailsViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var exampleTextViewTopAnchorConstraint: NSLayoutConstraint?
  private var exampleTextViewBottomAnchorConstraint: NSLayoutConstraint?
  private var exampleTextViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var exampleTextViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var textStyleSummaryViewTopAnchorConstraint: NSLayoutConstraint?
  private var textStyleSummaryViewBottomAnchorConstraint: NSLayoutConstraint?
  private var textStyleSummaryViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textStyleSummaryViewTrailingAnchorConstraint: NSLayoutConstraint?

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
    borderColor = Colors.grey300
    cornerRadius = 4
    borderWidth = 1
    exampleTextView.maximumNumberOfLines = 1
    dividerView.fillColor = Colors.grey300
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    previewView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    detailsView.translatesAutoresizingMaskIntoConstraints = false
    exampleTextView.translatesAutoresizingMaskIntoConstraints = false
    textStyleSummaryView.translatesAutoresizingMaskIntoConstraints = false

    let previewViewTopAnchorConstraint = previewView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + previewViewTopMargin)
    let previewViewLeadingAnchorConstraint = previewView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + previewViewLeadingMargin)
    let previewViewTrailingAnchorConstraint = previewView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + previewViewTrailingMargin))
    let dividerViewTopAnchorConstraint = dividerView
      .topAnchor
      .constraint(equalTo: previewView.bottomAnchor, constant: previewViewBottomMargin + dividerViewTopMargin)
    let dividerViewLeadingAnchorConstraint = dividerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + dividerViewLeadingMargin)
    let dividerViewTrailingAnchorConstraint = dividerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + dividerViewTrailingMargin))
    let detailsViewTopAnchorConstraint = detailsView
      .topAnchor
      .constraint(equalTo: dividerView.bottomAnchor, constant: dividerViewBottomMargin + detailsViewTopMargin)
    let detailsViewLeadingAnchorConstraint = detailsView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + detailsViewLeadingMargin)
    let detailsViewTrailingAnchorConstraint = detailsView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + detailsViewTrailingMargin))
    let exampleTextViewTopAnchorConstraint = exampleTextView
      .topAnchor
      .constraint(equalTo: previewView.topAnchor, constant: previewViewTopPadding + exampleTextViewTopMargin)
    let exampleTextViewBottomAnchorConstraint = exampleTextView
      .bottomAnchor
      .constraint(
        equalTo: previewView.bottomAnchor,
        constant: -(previewViewBottomPadding + exampleTextViewBottomMargin))
    let exampleTextViewLeadingAnchorConstraint = exampleTextView
      .leadingAnchor
      .constraint(
        equalTo: previewView.leadingAnchor,
        constant: previewViewLeadingPadding + exampleTextViewLeadingMargin)
    let exampleTextViewTrailingAnchorConstraint = exampleTextView
      .trailingAnchor
      .constraint(
        lessThanOrEqualTo: previewView.trailingAnchor,
        constant: -(previewViewTrailingPadding + exampleTextViewTrailingMargin))
    let dividerViewHeightAnchorConstraint = dividerView.heightAnchor.constraint(equalToConstant: 1)
    let textStyleSummaryViewTopAnchorConstraint = textStyleSummaryView
      .topAnchor
      .constraint(equalTo: detailsView.topAnchor, constant: detailsViewTopPadding + textStyleSummaryViewTopMargin)
    let textStyleSummaryViewBottomAnchorConstraint = textStyleSummaryView
      .bottomAnchor
      .constraint(
        equalTo: detailsView.bottomAnchor,
        constant: -(detailsViewBottomPadding + textStyleSummaryViewBottomMargin))
    let textStyleSummaryViewLeadingAnchorConstraint = textStyleSummaryView
      .leadingAnchor
      .constraint(
        equalTo: detailsView.leadingAnchor,
        constant: detailsViewLeadingPadding + textStyleSummaryViewLeadingMargin)
    let textStyleSummaryViewTrailingAnchorConstraint = textStyleSummaryView
      .trailingAnchor
      .constraint(
        lessThanOrEqualTo: detailsView.trailingAnchor,
        constant: -(detailsViewTrailingPadding + textStyleSummaryViewTrailingMargin))

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
      textStyleSummaryViewTrailingAnchorConstraint
    ])

    self.previewViewTopAnchorConstraint = previewViewTopAnchorConstraint
    self.previewViewLeadingAnchorConstraint = previewViewLeadingAnchorConstraint
    self.previewViewTrailingAnchorConstraint = previewViewTrailingAnchorConstraint
    self.dividerViewTopAnchorConstraint = dividerViewTopAnchorConstraint
    self.dividerViewLeadingAnchorConstraint = dividerViewLeadingAnchorConstraint
    self.dividerViewTrailingAnchorConstraint = dividerViewTrailingAnchorConstraint
    self.detailsViewTopAnchorConstraint = detailsViewTopAnchorConstraint
    self.detailsViewLeadingAnchorConstraint = detailsViewLeadingAnchorConstraint
    self.detailsViewTrailingAnchorConstraint = detailsViewTrailingAnchorConstraint
    self.exampleTextViewTopAnchorConstraint = exampleTextViewTopAnchorConstraint
    self.exampleTextViewBottomAnchorConstraint = exampleTextViewBottomAnchorConstraint
    self.exampleTextViewLeadingAnchorConstraint = exampleTextViewLeadingAnchorConstraint
    self.exampleTextViewTrailingAnchorConstraint = exampleTextViewTrailingAnchorConstraint
    self.dividerViewHeightAnchorConstraint = dividerViewHeightAnchorConstraint
    self.textStyleSummaryViewTopAnchorConstraint = textStyleSummaryViewTopAnchorConstraint
    self.textStyleSummaryViewBottomAnchorConstraint = textStyleSummaryViewBottomAnchorConstraint
    self.textStyleSummaryViewLeadingAnchorConstraint = textStyleSummaryViewLeadingAnchorConstraint
    self.textStyleSummaryViewTrailingAnchorConstraint = textStyleSummaryViewTrailingAnchorConstraint

    // For debugging
    previewViewTopAnchorConstraint.identifier = "previewViewTopAnchorConstraint"
    previewViewLeadingAnchorConstraint.identifier = "previewViewLeadingAnchorConstraint"
    previewViewTrailingAnchorConstraint.identifier = "previewViewTrailingAnchorConstraint"
    dividerViewTopAnchorConstraint.identifier = "dividerViewTopAnchorConstraint"
    dividerViewLeadingAnchorConstraint.identifier = "dividerViewLeadingAnchorConstraint"
    dividerViewTrailingAnchorConstraint.identifier = "dividerViewTrailingAnchorConstraint"
    detailsViewTopAnchorConstraint.identifier = "detailsViewTopAnchorConstraint"
    detailsViewLeadingAnchorConstraint.identifier = "detailsViewLeadingAnchorConstraint"
    detailsViewTrailingAnchorConstraint.identifier = "detailsViewTrailingAnchorConstraint"
    exampleTextViewTopAnchorConstraint.identifier = "exampleTextViewTopAnchorConstraint"
    exampleTextViewBottomAnchorConstraint.identifier = "exampleTextViewBottomAnchorConstraint"
    exampleTextViewLeadingAnchorConstraint.identifier = "exampleTextViewLeadingAnchorConstraint"
    exampleTextViewTrailingAnchorConstraint.identifier = "exampleTextViewTrailingAnchorConstraint"
    dividerViewHeightAnchorConstraint.identifier = "dividerViewHeightAnchorConstraint"
    textStyleSummaryViewTopAnchorConstraint.identifier = "textStyleSummaryViewTopAnchorConstraint"
    textStyleSummaryViewBottomAnchorConstraint.identifier = "textStyleSummaryViewBottomAnchorConstraint"
    textStyleSummaryViewLeadingAnchorConstraint.identifier = "textStyleSummaryViewLeadingAnchorConstraint"
    textStyleSummaryViewTrailingAnchorConstraint.identifier = "textStyleSummaryViewTrailingAnchorConstraint"
  }

  private func update() {
    detailsView.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    textStyleSummaryViewTextStyle = TextStyles.regular
    textStyleSummaryView.attributedStringValue =
      textStyleSummaryViewTextStyle.apply(to: textStyleSummaryView.attributedStringValue)
    exampleTextView.attributedStringValue = exampleTextViewTextStyle.apply(to: example)
    textStyleSummaryView.attributedStringValue = textStyleSummaryViewTextStyle.apply(to: textStyleSummary)
    exampleTextViewTextStyle = textStyle
    exampleTextView.attributedStringValue = exampleTextViewTextStyle.apply(to: exampleTextView.attributedStringValue)
    previewView.fillColor = previewBackgroundColor
    if selected {
      detailsView.fillColor = Colors.lightblue600
      textStyleSummaryViewTextStyle = TextStyles.regularInverse
      textStyleSummaryView.attributedStringValue =
        textStyleSummaryViewTextStyle.apply(to: textStyleSummaryView.attributedStringValue)
    }
  }
}
