import AppKit
import Foundation

// MARK: - ColorPreviewCard

public class ColorPreviewCard: NSBox {

  // MARK: Lifecycle

  public init(colorName: String, colorCode: String, color: NSColor) {
    self.colorName = colorName
    self.colorCode = colorCode
    self.color = color

    super.init(frame: .zero)

    setUpViews()
    setUpConstraints()

    update()

    addTrackingArea(trackingArea)
  }

  public convenience init() {
    self.init(colorName: "", colorCode: "", color: NSColor.clear)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    removeTrackingArea(trackingArea)
  }

  // MARK: Public

  public var colorName: String { didSet { update() } }
  public var colorCode: String { didSet { update() } }
  public var color: NSColor { didSet { update() } }
  public var onClick: (() -> Void)? { didSet { update() } }

  // MARK: Private

  private lazy var trackingArea = NSTrackingArea(
    rect: self.frame,
    options: [.mouseEnteredAndExited, .activeAlways, .mouseMoved, .inVisibleRect],
    owner: self)

  private var previewView = NSBox()
  private var dividerView = NSBox()
  private var detailsView = NSBox()
  private var colorNameView = NSTextField(labelWithString: "")
  private var colorCodeView = NSTextField(labelWithString: "")

  private var colorNameViewTextStyle = TextStyles.large
  private var colorCodeViewTextStyle = TextStyles.regular

  private var topPadding: CGFloat = 0
  private var trailingPadding: CGFloat = 0
  private var bottomPadding: CGFloat = 0
  private var leadingPadding: CGFloat = 0
  private var previewViewTopMargin: CGFloat = 0
  private var previewViewTrailingMargin: CGFloat = 0
  private var previewViewBottomMargin: CGFloat = 0
  private var previewViewLeadingMargin: CGFloat = 0
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
  private var colorNameViewTopMargin: CGFloat = 0
  private var colorNameViewTrailingMargin: CGFloat = 0
  private var colorNameViewBottomMargin: CGFloat = 0
  private var colorNameViewLeadingMargin: CGFloat = 0
  private var colorCodeViewTopMargin: CGFloat = 6
  private var colorCodeViewTrailingMargin: CGFloat = 0
  private var colorCodeViewBottomMargin: CGFloat = 0
  private var colorCodeViewLeadingMargin: CGFloat = 0

  private var hovered = false
  private var pressed = false
  private var onPress: (() -> Void)?

  private var previewViewTopAnchorConstraint: NSLayoutConstraint?
  private var previewViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var previewViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewTopAnchorConstraint: NSLayoutConstraint?
  private var dividerViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var detailsViewBottomAnchorConstraint: NSLayoutConstraint?
  private var detailsViewTopAnchorConstraint: NSLayoutConstraint?
  private var detailsViewLeadingAnchorConstraint: NSLayoutConstraint?
  private var detailsViewTrailingAnchorConstraint: NSLayoutConstraint?
  private var dividerViewHeightAnchorConstraint: NSLayoutConstraint?
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
    previewView.borderType = .noBorder
    previewView.contentViewMargins = .zero
    dividerView.boxType = .custom
    dividerView.borderType = .noBorder
    dividerView.contentViewMargins = .zero
    detailsView.boxType = .custom
    detailsView.borderType = .noBorder
    detailsView.contentViewMargins = .zero
    colorNameView.lineBreakMode = .byWordWrapping
    colorCodeView.lineBreakMode = .byWordWrapping

    addSubview(previewView)
    addSubview(dividerView)
    addSubview(detailsView)
    detailsView.addSubview(colorNameView)
    detailsView.addSubview(colorCodeView)

    fillColor = Colors.white
    borderColor = Colors.grey300
    cornerRadius = 4
    borderWidth = 1
    dividerView.fillColor = Colors.grey300
    colorNameViewTextStyle = TextStyles.large
    colorNameView.attributedStringValue = colorNameViewTextStyle.apply(to: colorNameView.attributedStringValue)
    colorNameView.maximumNumberOfLines = 1
  }

  private func setUpConstraints() {
    translatesAutoresizingMaskIntoConstraints = false
    previewView.translatesAutoresizingMaskIntoConstraints = false
    dividerView.translatesAutoresizingMaskIntoConstraints = false
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
    let dividerViewTopAnchorConstraint = dividerView
      .topAnchor
      .constraint(equalTo: previewView.bottomAnchor, constant: previewViewBottomMargin + dividerViewTopMargin)
    let dividerViewLeadingAnchorConstraint = dividerView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + dividerViewLeadingMargin)
    let dividerViewTrailingAnchorConstraint = dividerView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + dividerViewTrailingMargin))
    let detailsViewBottomAnchorConstraint = detailsView
      .bottomAnchor
      .constraint(equalTo: bottomAnchor, constant: -(bottomPadding + detailsViewBottomMargin))
    let detailsViewTopAnchorConstraint = detailsView
      .topAnchor
      .constraint(equalTo: dividerView.bottomAnchor, constant: dividerViewBottomMargin + detailsViewTopMargin)
    let detailsViewLeadingAnchorConstraint = detailsView
      .leadingAnchor
      .constraint(equalTo: leadingAnchor, constant: leadingPadding + detailsViewLeadingMargin)
    let detailsViewTrailingAnchorConstraint = detailsView
      .trailingAnchor
      .constraint(equalTo: trailingAnchor, constant: -(trailingPadding + detailsViewTrailingMargin))
    let dividerViewHeightAnchorConstraint = dividerView.heightAnchor.constraint(equalToConstant: 1)
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
      dividerViewTopAnchorConstraint,
      dividerViewLeadingAnchorConstraint,
      dividerViewTrailingAnchorConstraint,
      detailsViewBottomAnchorConstraint,
      detailsViewTopAnchorConstraint,
      detailsViewLeadingAnchorConstraint,
      detailsViewTrailingAnchorConstraint,
      dividerViewHeightAnchorConstraint,
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
    self.dividerViewTopAnchorConstraint = dividerViewTopAnchorConstraint
    self.dividerViewLeadingAnchorConstraint = dividerViewLeadingAnchorConstraint
    self.dividerViewTrailingAnchorConstraint = dividerViewTrailingAnchorConstraint
    self.detailsViewBottomAnchorConstraint = detailsViewBottomAnchorConstraint
    self.detailsViewTopAnchorConstraint = detailsViewTopAnchorConstraint
    self.detailsViewLeadingAnchorConstraint = detailsViewLeadingAnchorConstraint
    self.detailsViewTrailingAnchorConstraint = detailsViewTrailingAnchorConstraint
    self.dividerViewHeightAnchorConstraint = dividerViewHeightAnchorConstraint
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
    dividerViewTopAnchorConstraint.identifier = "dividerViewTopAnchorConstraint"
    dividerViewLeadingAnchorConstraint.identifier = "dividerViewLeadingAnchorConstraint"
    dividerViewTrailingAnchorConstraint.identifier = "dividerViewTrailingAnchorConstraint"
    detailsViewBottomAnchorConstraint.identifier = "detailsViewBottomAnchorConstraint"
    detailsViewTopAnchorConstraint.identifier = "detailsViewTopAnchorConstraint"
    detailsViewLeadingAnchorConstraint.identifier = "detailsViewLeadingAnchorConstraint"
    detailsViewTrailingAnchorConstraint.identifier = "detailsViewTrailingAnchorConstraint"
    dividerViewHeightAnchorConstraint.identifier = "dividerViewHeightAnchorConstraint"
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
    detailsView.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
    colorNameView.attributedStringValue = colorNameViewTextStyle.apply(to: colorName)
    colorCodeView.attributedStringValue = colorCodeViewTextStyle.apply(to: colorCode)
    previewView.fillColor = color
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
