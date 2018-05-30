import AppKit
import Foundation

// MARK: - TextStylePreviewCard

public class TextStylePreviewCard: NSBox {

  // MARK: Lifecycle

  public init(example: String, textStyleName: String, textStyleSummary: String, textStyle: AttributedFont) {
    self.example = example
    self.textStyleName = textStyleName
    self.textStyleSummary = textStyleSummary
    self.textStyle = textStyle

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()

    addTrackingArea(trackingArea)
  }

  public convenience init() {
    self.init(example: "", textStyleName: "", textStyleSummary: "", textStyle: AttributedFont())
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    removeTrackingArea(trackingArea)
  }

  // MARK: Public

  public var example: String { didSet { update() } }
  public var textStyleName: String { didSet { update() } }
  public var textStyleSummary: String { didSet { update() } }
  public var textStyle: AttributedFont { didSet { update() } }
  public var onClick: (() -> Void)? { didSet { update() } }

  // MARK: Private

  private lazy var trackingArea = NSTrackingArea(
    rect: self.frame,
    options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect],
    owner: self)

  private var previewView = NSBox()
  private var exampleTextView = NSTextField(labelWithString: "")
  private var dividerView = NSBox()
  private var detailsView = NSBox()
  private var textStyleNameView = NSTextField(labelWithString: "")
  private var textStyleSummaryView = NSTextField(labelWithString: "")

  private var exampleTextViewTextStyle = TextStyles.regular
  private var textStyleNameViewTextStyle = TextStyles.large
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
  private var textStyleNameViewTopMargin: CGFloat = 0
  private var textStyleNameViewTrailingMargin: CGFloat = 0
  private var textStyleNameViewBottomMargin: CGFloat = 0
  private var textStyleNameViewLeadingMargin: CGFloat = 0
  private var textStyleSummaryViewTopMargin: CGFloat = 6
  private var textStyleSummaryViewTrailingMargin: CGFloat = 0
  private var textStyleSummaryViewBottomMargin: CGFloat = 0
  private var textStyleSummaryViewLeadingMargin: CGFloat = 0

  private var hovered = false
  private var pressed = false
  private var onPress: (() -> Void)?

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
  private var textStyleNameViewTopAnchorConstraint: NSLayoutConstraint?
  private var textStyleNameViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textStyleNameViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var textStyleSummaryViewBottomAnchorConstraint: NSLayoutConstraint?
  private var textStyleSummaryViewTopAnchorConstraint: NSLayoutConstraint?
  private var textStyleSummaryViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var textStyleSummaryViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var textStyleNameViewHeightAnchorConstraint: NSLayoutConstraint?

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
    textStyleNameView.lineBreakMode = .byWordWrapping
    textStyleSummaryView.lineBreakMode = .byWordWrapping

    addSubview(previewView)
    addSubview(dividerView)
    addSubview(detailsView)
    previewView.addSubview(exampleTextView)
    detailsView.addSubview(textStyleNameView)
    detailsView.addSubview(textStyleSummaryView)

    fillColor = Colors.white
    borderColor = Colors.grey300
    cornerRadius = 4
    borderWidth = 1
    previewView.fillColor = Colors.white
    exampleTextView.maximumNumberOfLines = 1
    dividerView.fillColor = Colors.grey300
    textStyleNameViewTextStyle = TextStyles.large
    textStyleNameView.attributedStringValue =
      textStyleNameViewTextStyle.apply(to: textStyleNameView.attributedStringValue)
    textStyleNameView.maximumNumberOfLines = 1
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    previewView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
    detailsView.translatesAutoresizingMaskIntoConstraints = false
    exampleTextView.translatesAutoresizingMaskIntoConstraints = false
    textStyleNameView.translatesAutoresizingMaskIntoConstraints = false
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
    let textStyleNameViewTopAnchorConstraint = textStyleNameView
      .topAnchor
      .constraint(equalTo: detailsView.topAnchor, constant: detailsViewTopPadding + textStyleNameViewTopMargin)
    let textStyleNameViewLeadingAnchorConstraint = textStyleNameView
      .leadingAnchor
      .constraint(
        equalTo: detailsView.leadingAnchor,
        constant: detailsViewLeadingPadding + textStyleNameViewLeadingMargin)
    let textStyleNameViewTrailingAnchorConstraint = textStyleNameView
      .trailingAnchor
      .constraint(
        equalTo: detailsView.trailingAnchor,
        constant: -(detailsViewTrailingPadding + textStyleNameViewTrailingMargin))
    let textStyleSummaryViewBottomAnchorConstraint = textStyleSummaryView
      .bottomAnchor
      .constraint(
        equalTo: detailsView.bottomAnchor,
        constant: -(detailsViewBottomPadding + textStyleSummaryViewBottomMargin))
    let textStyleSummaryViewTopAnchorConstraint = textStyleSummaryView
      .topAnchor
      .constraint(
        equalTo: textStyleNameView.bottomAnchor,
        constant: textStyleNameViewBottomMargin + textStyleSummaryViewTopMargin)
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
    let textStyleNameViewHeightAnchorConstraint = textStyleNameView.heightAnchor.constraint(equalToConstant: 18)

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
      textStyleNameViewTopAnchorConstraint,
      textStyleNameViewLeadingAnchorConstraint,
      textStyleNameViewTrailingAnchorConstraint,
      textStyleSummaryViewBottomAnchorConstraint,
      textStyleSummaryViewTopAnchorConstraint,
      textStyleSummaryViewLeadingAnchorConstraint,
      textStyleSummaryViewTrailingAnchorConstraint,
      textStyleNameViewHeightAnchorConstraint
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
    self.textStyleNameViewTopAnchorConstraint = textStyleNameViewTopAnchorConstraint
    self.textStyleNameViewLeadingAnchorConstraint = textStyleNameViewLeadingAnchorConstraint
    self.textStyleNameViewTrailingAnchorConstraint = textStyleNameViewTrailingAnchorConstraint
    self.textStyleSummaryViewBottomAnchorConstraint = textStyleSummaryViewBottomAnchorConstraint
    self.textStyleSummaryViewTopAnchorConstraint = textStyleSummaryViewTopAnchorConstraint
    self.textStyleSummaryViewLeadingAnchorConstraint = textStyleSummaryViewLeadingAnchorConstraint
    self.textStyleSummaryViewTrailingAnchorConstraint = textStyleSummaryViewTrailingAnchorConstraint
    self.textStyleNameViewHeightAnchorConstraint = textStyleNameViewHeightAnchorConstraint

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
    textStyleNameViewTopAnchorConstraint.identifier = "textStyleNameViewTopAnchorConstraint"
    textStyleNameViewLeadingAnchorConstraint.identifier = "textStyleNameViewLeadingAnchorConstraint"
    textStyleNameViewTrailingAnchorConstraint.identifier = "textStyleNameViewTrailingAnchorConstraint"
    textStyleSummaryViewBottomAnchorConstraint.identifier = "textStyleSummaryViewBottomAnchorConstraint"
    textStyleSummaryViewTopAnchorConstraint.identifier = "textStyleSummaryViewTopAnchorConstraint"
    textStyleSummaryViewLeadingAnchorConstraint.identifier = "textStyleSummaryViewLeadingAnchorConstraint"
    textStyleSummaryViewTrailingAnchorConstraint.identifier = "textStyleSummaryViewTrailingAnchorConstraint"
    textStyleNameViewHeightAnchorConstraint.identifier = "textStyleNameViewHeightAnchorConstraint"
  }

  private func update() {
    detailsView.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    exampleTextView.attributedStringValue = exampleTextViewTextStyle.apply(to: example)
    textStyleNameView.attributedStringValue = textStyleNameViewTextStyle.apply(to: textStyleName)
    textStyleSummaryView.attributedStringValue = textStyleSummaryViewTextStyle.apply(to: textStyleSummary)
    exampleTextViewTextStyle = textStyle
    exampleTextView.attributedStringValue = exampleTextViewTextStyle.apply(to: exampleTextView.attributedStringValue)
    onPress = onClick
    if pressed {
      detailsView.fillColor = Colors.grey50
    }
  }

  private func updateHoverState(with event: NSEvent) {
    let hovered = bounds.contains(convert(event.locationInWindow, from: nil))
    if hovered != self.hovered {
      self.hovered = hovered

      update()
    }
  }

  public override func mouseEntered(with event: NSEvent) {
    updateHoverState(with: event)
  }

  public override func mouseMoved(with event: NSEvent) {
    updateHoverState(with: event)
  }

  public override func mouseDragged(with event: NSEvent) {
    updateHoverState(with: event)
  }

  public override func mouseExited(with event: NSEvent) {
    updateHoverState(with: event)
  }

  public override func mouseDown(with event: NSEvent) {
    let pressed = bounds.contains(convert(event.locationInWindow, from: nil))
    if pressed != self.pressed {
      self.pressed = pressed

      update()
    }
  }

  public override func mouseUp(with event: NSEvent) {
    let clicked = pressed && bounds.contains(convert(event.locationInWindow, from: nil))

    if pressed {
      pressed = false

      update()
    }

    if clicked {
      onPress?()
    }
  }
}
