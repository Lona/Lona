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

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var previewViewTopMargin: CGFloat = 0
  private var previewViewTrailingMargin: CGFloat = 0
  private var previewViewBottomMargin: CGFloat = 0
  private var previewViewLeadingMargin: CGFloat = 0
  private var previewViewTopPadding: CGFloat = 16
  private var previewViewTrailingPadding: CGFloat = 0
  private var previewViewBottomPadding: CGFloat = 16
  private var previewViewLeadingPadding: CGFloat = 0
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
  private var topLineViewTopMargin: CGFloat = 0
  private var topLineViewTrailingMargin: CGFloat = 0
  private var topLineViewBottomMargin: CGFloat = 0
  private var topLineViewLeadingMargin: CGFloat = 0
  private var exampleTextViewTopMargin: CGFloat = 0
  private var exampleTextViewTrailingMargin: CGFloat = 20
  private var exampleTextViewBottomMargin: CGFloat = 0
  private var exampleTextViewLeadingMargin: CGFloat = 20
  private var bottomLineViewTopMargin: CGFloat = 0
  private var bottomLineViewTrailingMargin: CGFloat = 0
  private var bottomLineViewBottomMargin: CGFloat = 0
  private var bottomLineViewLeadingMargin: CGFloat = 0
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
  private var topLineViewTopAnchorConstraint: NSLayoutConstraint?
  private var topLineViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var topLineViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var exampleTextViewTopAnchorConstraint: NSLayoutConstraint?
  private var exampleTextViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var exampleTextViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var bottomLineViewBottomAnchorConstraint: NSLayoutConstraint?
  private var bottomLineViewTopAnchorConstraint: NSLayoutConstraint?
  private var bottomLineViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var bottomLineViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewHeightAnchorConstraint: NSLayoutConstraint?
  private var textStyleSummaryViewTopAnchorConstraint: NSLayoutConstraint?
  private var textStyleSummaryViewBottomAnchorConstraint: NSLayoutConstraint?
  private var textStyleSummaryViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textStyleSummaryViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var topLineViewHeightAnchorConstraint: NSLayoutConstraint?
  private var bottomLineViewHeightAnchorConstraint: NSLayoutConstraint?

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
    let topLineViewTopAnchorConstraint = topLineView
      .topAnchor
      .constraint(equalTo: previewView.topAnchor, constant: previewViewTopPadding + topLineViewTopMargin)
    let topLineViewLeadingAnchorConstraint = topLineView
      .leadingAnchor
      .constraint(equalTo: previewView.leadingAnchor, constant: previewViewLeadingPadding + topLineViewLeadingMargin)
    let topLineViewTrailingAnchorConstraint = topLineView
      .trailingAnchor
      .constraint(
        equalTo: previewView.trailingAnchor,
        constant: -(previewViewTrailingPadding + topLineViewTrailingMargin))
    let exampleTextViewTopAnchorConstraint = exampleTextView
      .topAnchor
      .constraint(equalTo: topLineView.bottomAnchor, constant: topLineViewBottomMargin + exampleTextViewTopMargin)
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
    let bottomLineViewBottomAnchorConstraint = bottomLineView
      .bottomAnchor
      .constraint(equalTo: previewView.bottomAnchor, constant: -(previewViewBottomPadding + bottomLineViewBottomMargin))
    let bottomLineViewTopAnchorConstraint = bottomLineView
      .topAnchor
      .constraint(
        equalTo: exampleTextView.bottomAnchor,
        constant: exampleTextViewBottomMargin + bottomLineViewTopMargin)
    let bottomLineViewLeadingAnchorConstraint = bottomLineView
      .leadingAnchor
      .constraint(equalTo: previewView.leadingAnchor, constant: previewViewLeadingPadding + bottomLineViewLeadingMargin)
    let bottomLineViewTrailingAnchorConstraint = bottomLineView
      .trailingAnchor
      .constraint(
        equalTo: previewView.trailingAnchor,
        constant: -(previewViewTrailingPadding + bottomLineViewTrailingMargin))
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

    self.previewViewTopAnchorConstraint = previewViewTopAnchorConstraint
    self.previewViewLeadingAnchorConstraint = previewViewLeadingAnchorConstraint
    self.previewViewTrailingAnchorConstraint = previewViewTrailingAnchorConstraint
    self.dividerViewTopAnchorConstraint = dividerViewTopAnchorConstraint
    self.dividerViewLeadingAnchorConstraint = dividerViewLeadingAnchorConstraint
    self.dividerViewTrailingAnchorConstraint = dividerViewTrailingAnchorConstraint
    self.detailsViewTopAnchorConstraint = detailsViewTopAnchorConstraint
    self.detailsViewLeadingAnchorConstraint = detailsViewLeadingAnchorConstraint
    self.detailsViewTrailingAnchorConstraint = detailsViewTrailingAnchorConstraint
    self.topLineViewTopAnchorConstraint = topLineViewTopAnchorConstraint
    self.topLineViewLeadingAnchorConstraint = topLineViewLeadingAnchorConstraint
    self.topLineViewTrailingAnchorConstraint = topLineViewTrailingAnchorConstraint
    self.exampleTextViewTopAnchorConstraint = exampleTextViewTopAnchorConstraint
    self.exampleTextViewLeadingAnchorConstraint = exampleTextViewLeadingAnchorConstraint
    self.exampleTextViewTrailingAnchorConstraint = exampleTextViewTrailingAnchorConstraint
    self.bottomLineViewBottomAnchorConstraint = bottomLineViewBottomAnchorConstraint
    self.bottomLineViewTopAnchorConstraint = bottomLineViewTopAnchorConstraint
    self.bottomLineViewLeadingAnchorConstraint = bottomLineViewLeadingAnchorConstraint
    self.bottomLineViewTrailingAnchorConstraint = bottomLineViewTrailingAnchorConstraint
    self.dividerViewHeightAnchorConstraint = dividerViewHeightAnchorConstraint
    self.textStyleSummaryViewTopAnchorConstraint = textStyleSummaryViewTopAnchorConstraint
    self.textStyleSummaryViewBottomAnchorConstraint = textStyleSummaryViewBottomAnchorConstraint
    self.textStyleSummaryViewLeadingAnchorConstraint = textStyleSummaryViewLeadingAnchorConstraint
    self.textStyleSummaryViewTrailingAnchorConstraint = textStyleSummaryViewTrailingAnchorConstraint
    self.topLineViewHeightAnchorConstraint = topLineViewHeightAnchorConstraint
    self.bottomLineViewHeightAnchorConstraint = bottomLineViewHeightAnchorConstraint

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
    topLineViewTopAnchorConstraint.identifier = "topLineViewTopAnchorConstraint"
    topLineViewLeadingAnchorConstraint.identifier = "topLineViewLeadingAnchorConstraint"
    topLineViewTrailingAnchorConstraint.identifier = "topLineViewTrailingAnchorConstraint"
    exampleTextViewTopAnchorConstraint.identifier = "exampleTextViewTopAnchorConstraint"
    exampleTextViewLeadingAnchorConstraint.identifier = "exampleTextViewLeadingAnchorConstraint"
    exampleTextViewTrailingAnchorConstraint.identifier = "exampleTextViewTrailingAnchorConstraint"
    bottomLineViewBottomAnchorConstraint.identifier = "bottomLineViewBottomAnchorConstraint"
    bottomLineViewTopAnchorConstraint.identifier = "bottomLineViewTopAnchorConstraint"
    bottomLineViewLeadingAnchorConstraint.identifier = "bottomLineViewLeadingAnchorConstraint"
    bottomLineViewTrailingAnchorConstraint.identifier = "bottomLineViewTrailingAnchorConstraint"
    dividerViewHeightAnchorConstraint.identifier = "dividerViewHeightAnchorConstraint"
    textStyleSummaryViewTopAnchorConstraint.identifier = "textStyleSummaryViewTopAnchorConstraint"
    textStyleSummaryViewBottomAnchorConstraint.identifier = "textStyleSummaryViewBottomAnchorConstraint"
    textStyleSummaryViewLeadingAnchorConstraint.identifier = "textStyleSummaryViewLeadingAnchorConstraint"
    textStyleSummaryViewTrailingAnchorConstraint.identifier = "textStyleSummaryViewTrailingAnchorConstraint"
    topLineViewHeightAnchorConstraint.identifier = "topLineViewHeightAnchorConstraint"
    bottomLineViewHeightAnchorConstraint.identifier = "bottomLineViewHeightAnchorConstraint"
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
