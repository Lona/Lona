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
    previewView.cornerRadius = 3
    previewView.borderWidth = 1
    previewView.borderColor = Colors.darkTransparentOutline
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
