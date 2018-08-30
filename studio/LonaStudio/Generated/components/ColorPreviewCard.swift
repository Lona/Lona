import AppKit
import Foundation

// MARK: - ColorPreviewCard

public class ColorPreviewCard: NSBox {

  // MARK: Lifecycle

  public init(colorName: String, colorCode: String, color: NSColor, selected: Bool) {
    self.colorName = colorName
    self.colorCode = colorCode
    self.color = color
    self.selected = selected

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()
  }

  public convenience init() {
    self.init(colorName: "", colorCode: "", color: NSColor.clear, selected: false)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public var colorName: String { didSet { update() } }
  public var colorCode: String { didSet { update() } }
  public var color: NSColor { didSet { update() } }
  public var selected: Bool { didSet { update() } }

  // MARK: Private

  private var previewView = NSBox()
  private var detailsView = NSBox()
  private var colorNameView = NSTextField(labelWithString: "")
  private var colorCodeView = NSTextField(labelWithString: "")

  private var colorNameViewTextStyle = TextStyles.regular
  private var colorCodeViewTextStyle = TextStyles.monospacedMicro

  private var topPadding: CGFloat = 4
  private var trailingPadding: CGFloat = 4
  private var bottomPadding: CGFloat = 4
  private var leadingPadding: CGFloat = 4
  private var previewViewTopMargin: CGFloat = 0
  private var previewViewTrailingMargin: CGFloat = 0
  private var previewViewBottomMargin: CGFloat = 0
  private var previewViewLeadingMargin: CGFloat = 0
  private var detailsViewTopMargin: CGFloat = 5
  private var detailsViewTrailingMargin: CGFloat = 0
  private var detailsViewBottomMargin: CGFloat = 0
  private var detailsViewLeadingMargin: CGFloat = 0
  private var detailsViewTopPadding: CGFloat = 0
  private var detailsViewTrailingPadding: CGFloat = 0
  private var detailsViewBottomPadding: CGFloat = 0
  private var detailsViewLeadingPadding: CGFloat = 0
  private var colorNameViewTopMargin: CGFloat = 0
  private var colorNameViewTrailingMargin: CGFloat = 0
  private var colorNameViewBottomMargin: CGFloat = 0
  private var colorNameViewLeadingMargin: CGFloat = 0
  private var colorCodeViewTopMargin: CGFloat = 0
  private var colorCodeViewTrailingMargin: CGFloat = 0
  private var colorCodeViewBottomMargin: CGFloat = 0
  private var colorCodeViewLeadingMargin: CGFloat = 0

  private var previewViewTopAnchorConstraint: NSLayoutConstraint?
  private var previewViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var previewViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var detailsViewBottomAnchorConstraint: NSLayoutConstraint?
  private var detailsViewTopAnchorConstraint: NSLayoutConstraint?
  private var detailsViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var detailsViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var colorNameViewTopAnchorConstraint: NSLayoutConstraint?
  private var colorNameViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var colorNameViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var colorCodeViewBottomAnchorConstraint: NSLayoutConstraint?
  private var colorCodeViewTopAnchorConstraint: NSLayoutConstraint?
  private var colorCodeViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var colorCodeViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var colorNameViewHeightAnchorConstraint: NSLayoutConstraint?

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
    borderWidth = 0
    previewView.cornerRadius = 3
    previewView.borderWidth = 1
    previewView.borderColor = Colors.darkTransparentOutline
    colorNameView.maximumNumberOfLines = 2
    colorCodeView.maximumNumberOfLines = 2
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    previewView.translatesAutoresizingMaskIntoConstraints = false
    detailsView.translatesAutoresizingMaskIntoConstraints = false
    colorNameView.translatesAutoresizingMaskIntoConstraints = false
    colorCodeView.translatesAutoresizingMaskIntoConstraints = false

    let previewViewTopAnchorConstraint = previewView
      .topAnchor
      .constraint(equalTo: topAnchor, constant: topPadding + previewViewTopMargin)
    let previewViewLeadingAnchorConstraint = previewView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + previewViewLeadingMargin)
    let previewViewTrailingAnchorConstraint = previewView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + previewViewTrailingMargin))
    let detailsViewBottomAnchorConstraint = detailsView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + detailsViewBottomMargin))
    let detailsViewTopAnchorConstraint = detailsView
      .topAnchor
      .constraint(equalTo: previewView.bottomAnchor, constant: previewViewBottomMargin + detailsViewTopMargin)
    let detailsViewLeadingAnchorConstraint = detailsView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + detailsViewLeadingMargin)
    let detailsViewTrailingAnchorConstraint = detailsView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + detailsViewTrailingMargin))
    let colorNameViewTopAnchorConstraint = colorNameView
      .topAnchor
      .constraint(equalTo: detailsView.topAnchor, constant: detailsViewTopPadding + colorNameViewTopMargin)
    let colorNameViewLeadingAnchorConstraint = colorNameView
      .leadingAnchor
      .constraint(equalTo: detailsView.leadingAnchor, constant: detailsViewLeadingPadding + colorNameViewLeadingMargin)
    let colorNameViewTrailingAnchorConstraint = colorNameView
      .trailingAnchor
      .constraint(
        equalTo: detailsView.trailingAnchor,
        constant: -(detailsViewTrailingPadding + colorNameViewTrailingMargin))
    let colorCodeViewBottomAnchorConstraint = colorCodeView
      .bottomAnchor
      .constraint(equalTo: detailsView.bottomAnchor, constant: -(detailsViewBottomPadding + colorCodeViewBottomMargin))
    let colorCodeViewTopAnchorConstraint = colorCodeView
      .topAnchor
      .constraint(equalTo: colorNameView.bottomAnchor, constant: colorNameViewBottomMargin + colorCodeViewTopMargin)
    let colorCodeViewLeadingAnchorConstraint = colorCodeView
      .leadingAnchor
      .constraint(equalTo: detailsView.leadingAnchor, constant: detailsViewLeadingPadding + colorCodeViewLeadingMargin)
    let colorCodeViewTrailingAnchorConstraint = colorCodeView
      .trailingAnchor
      .constraint(
        lessThanOrEqualTo: detailsView.trailingAnchor,
        constant: -(detailsViewTrailingPadding + colorCodeViewTrailingMargin))
    let colorNameViewHeightAnchorConstraint = colorNameView.heightAnchor.constraint(equalToConstant: 18)

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
      colorCodeViewTrailingAnchorConstraint,
      colorNameViewHeightAnchorConstraint
    ])

    self.previewViewTopAnchorConstraint = previewViewTopAnchorConstraint
    self.previewViewLeadingAnchorConstraint = previewViewLeadingAnchorConstraint
    self.previewViewTrailingAnchorConstraint = previewViewTrailingAnchorConstraint
    self.detailsViewBottomAnchorConstraint = detailsViewBottomAnchorConstraint
    self.detailsViewTopAnchorConstraint = detailsViewTopAnchorConstraint
    self.detailsViewLeadingAnchorConstraint = detailsViewLeadingAnchorConstraint
    self.detailsViewTrailingAnchorConstraint = detailsViewTrailingAnchorConstraint
    self.colorNameViewTopAnchorConstraint = colorNameViewTopAnchorConstraint
    self.colorNameViewLeadingAnchorConstraint = colorNameViewLeadingAnchorConstraint
    self.colorNameViewTrailingAnchorConstraint = colorNameViewTrailingAnchorConstraint
    self.colorCodeViewBottomAnchorConstraint = colorCodeViewBottomAnchorConstraint
    self.colorCodeViewTopAnchorConstraint = colorCodeViewTopAnchorConstraint
    self.colorCodeViewLeadingAnchorConstraint = colorCodeViewLeadingAnchorConstraint
    self.colorCodeViewTrailingAnchorConstraint = colorCodeViewTrailingAnchorConstraint
    self.colorNameViewHeightAnchorConstraint = colorNameViewHeightAnchorConstraint

    // For debugging
    previewViewTopAnchorConstraint.identifier = "previewViewTopAnchorConstraint"
    previewViewLeadingAnchorConstraint.identifier = "previewViewLeadingAnchorConstraint"
    previewViewTrailingAnchorConstraint.identifier = "previewViewTrailingAnchorConstraint"
    detailsViewBottomAnchorConstraint.identifier = "detailsViewBottomAnchorConstraint"
    detailsViewTopAnchorConstraint.identifier = "detailsViewTopAnchorConstraint"
    detailsViewLeadingAnchorConstraint.identifier = "detailsViewLeadingAnchorConstraint"
    detailsViewTrailingAnchorConstraint.identifier = "detailsViewTrailingAnchorConstraint"
    colorNameViewTopAnchorConstraint.identifier = "colorNameViewTopAnchorConstraint"
    colorNameViewLeadingAnchorConstraint.identifier = "colorNameViewLeadingAnchorConstraint"
    colorNameViewTrailingAnchorConstraint.identifier = "colorNameViewTrailingAnchorConstraint"
    colorCodeViewBottomAnchorConstraint.identifier = "colorCodeViewBottomAnchorConstraint"
    colorCodeViewTopAnchorConstraint.identifier = "colorCodeViewTopAnchorConstraint"
    colorCodeViewLeadingAnchorConstraint.identifier = "colorCodeViewLeadingAnchorConstraint"
    colorCodeViewTrailingAnchorConstraint.identifier = "colorCodeViewTrailingAnchorConstraint"
    colorNameViewHeightAnchorConstraint.identifier = "colorNameViewHeightAnchorConstraint"
  }

  private func update() {
    colorCodeViewTextStyle = TextStyles.monospacedMicro
    colorCodeView.attributedStringValue = colorCodeViewTextStyle.apply(to: colorCodeView.attributedStringValue)
    colorNameViewTextStyle = TextStyles.regular
    colorNameView.attributedStringValue = colorNameViewTextStyle.apply(to: colorNameView.attributedStringValue)
    fillColor = Colors.white
    colorNameView.attributedStringValue = colorNameViewTextStyle.apply(to: colorName)
    colorCodeView.attributedStringValue = colorCodeViewTextStyle.apply(to: colorCode)
    previewView.fillColor = color
    if selected {
      fillColor = Colors.lightblue600
      colorNameViewTextStyle = TextStyles.regularInverse
      colorNameView.attributedStringValue = colorNameViewTextStyle.apply(to: colorNameView.attributedStringValue)
      colorCodeViewTextStyle = TextStyles.monospacedMicroInverse
      colorCodeView.attributedStringValue = colorCodeViewTextStyle.apply(to: colorCodeView.attributedStringValue)
    }
  }
}
